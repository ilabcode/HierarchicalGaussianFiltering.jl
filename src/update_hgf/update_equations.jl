#######################################
######## Continuous State Node ########
#######################################

######## Prediction update ########

### Mean update ###
@doc raw"""
    calculate_prediction_mean(node::AbstractNode)

Calculates a node's prediction mean.

Uses the equation
`` \hat{\mu}_i=\mu_i+\sum_{j=1}^{j\;value\;parents} \mu_{j} \cdot \alpha_{i,j} ``
"""
function calculate_prediction_mean(node::AbstractNode)
    #Get out value parents
    value_parents = node.value_parents

    #Initialize the total drift as the basline drift plus the autoregressive drift
    predicted_drift =
        node.parameters.drift +
        node.parameters.autoregressive_rate *
        (node.parameters.autoregressive_target - node.states.posterior_mean)

    #Add contributions from value parents
    for parent in value_parents
        predicted_drift +=
            parent.states.posterior_mean * node.parameters.value_coupling[parent.name]
    end

    #Add the drift to the posterior to get the prediction mean
    prediction_mean = node.states.posterior_mean + 1 * predicted_drift

    return prediction_mean
end

### Volatility update ###
@doc raw"""
    calculate_predicted_volatility(node::AbstractNode)

Calculates a node's prediction volatility.

Uses the equation
`` \nu_i =exp( \omega_i + \sum_{j=1}^{j\;volatility\;parents} \mu_{j} \cdot \kappa_{i,j}} ``
"""
function calculate_predicted_volatility(node::AbstractNode)
    volatility_parents = node.volatility_parents

    predicted_volatility = node.parameters.evolution_rate

    for parent in volatility_parents
        predicted_volatility +=
            parent.states.posterior_mean * node.parameters.volatility_coupling[parent.name]
    end

    return exp(predicted_volatility)
end

### Precision update ###
@doc raw"""
    calculate_prediction_precision(node::AbstractNode)

Calculates a node's prediction precision.

Uses the equation
`` \hat{\pi}_i^ = \frac{1}{\frac{1}{\pi_i}+\nu_i^} ``
"""
function calculate_prediction_precision(node::AbstractNode)
    prediction_precision =
        1 / (1 / node.states.posterior_precision + node.states.predicted_volatility)

    #If the posterior precision is negative
    if prediction_precision < 0
        #Throw an error
        throw(
            #Of the custom type where samples are rejected
            RejectParameters(
                "With these parameters and inputs, the prediction precision of node $(node.name) becomes negative after $(length(node.history.prediction_precision)) inputs",
            ),
        )
    end

    return prediction_precision
end

@doc raw"""
    calculate_auxiliary_prediction_precision(node::AbstractNode)

Calculates a node's auxiliary prediction precision.

Uses the equation
`` \gamma_i = \nu_i \cdot \hat{\pi}_i ``
"""
function calculate_auxiliary_prediction_precision(node::AbstractNode)
    node.states.predicted_volatility * node.states.prediction_precision
end

######## Posterior update functions ########

### Precision update ###
@doc raw"""
    calculate_posterior_precision(node::AbstractNode)

Calculates a node's posterior precision.

Uses the equation
`` \pi_i^{'} = \hat{\pi}_i +\underbrace{\sum_{j=1}^{j\;children} \alpha_{j,i} \cdot \hat{\pi}_{j}} _\text{sum \;of \;VAPE \; continuous \; value \;chidren} ``
"""
function calculate_posterior_precision(node::AbstractNode)
    value_children = node.value_children
    volatility_children = node.volatility_children

    #Initialize as the node's own prediction
    posterior_precision = node.states.prediction_precision

    #Add update terms from value children
    for child in value_children
        posterior_precision += calculate_posterior_precision_vape(node, child)
    end

    #Add update terms from volatility children
    for child in volatility_children
        posterior_precision += calculate_posterior_precision_vope(node, child)
    end

    #If the posterior precision is negative
    if posterior_precision < 0
        #Throw an error
        throw(
            #Of the custom type where samples are rejected
            RejectParameters(
                "With these parameters and inputs, the posterior precision of node $(node.name) becomes negative after $(length(node.history.posterior_precision)) inputs",
            ),
        )
    end

    return posterior_precision
end

@doc raw"""
    calculate_posterior_precision_vape(node::AbstractNode, child::AbstractNode)

Calculates the posterior precision update term for a single continuous value child to a state node.

Uses the equation
``   ``
"""
function calculate_posterior_precision_vape(node::AbstractNode, child::AbstractNode)

    #For input node children with missing input
    if child isa AbstractInputNode && ismissing(child.states.input_value)
        #No update
        return 0
    else
        return child.parameters.value_coupling[node.name] *
               child.states.prediction_precision
    end
end

@doc raw"""
    calculate_posterior_precision_vape(node::AbstractNode, child::BinaryStateNode)

Calculates the posterior precision update term for a single binary value child to a state node.

Uses the equation
``   ``
"""
function calculate_posterior_precision_vape(node::AbstractNode, child::BinaryStateNode)

    #For missing inputs
    if ismissing(child.states.posterior_mean)
        #No update
        return 0
    else
        return child.parameters.value_coupling[node.name]^2 /
               child.states.prediction_precision
    end
end

@doc raw"""
    calculate_posterior_precision_vope(node::AbstractNode, child::AbstractNode)

Calculates the posterior precision update term for a single continuous volatility child to a state node.

Uses the equation
``   ``
"""
function calculate_posterior_precision_vope(node::AbstractNode, child::AbstractNode)

    #For input node children with missing input
    if child isa AbstractInputNode && ismissing(child.states.input_value)
        #No update
        return 0
    else
        update_term =
            1 / 2 *
            (
                child.parameters.volatility_coupling[node.name] *
                child.states.auxiliary_prediction_precision
            )^2 +
            child.states.volatility_prediction_error *
            (
                child.parameters.volatility_coupling[node.name] *
                child.states.auxiliary_prediction_precision
            )^2 -
            1 / 2 *
            child.parameters.volatility_coupling[node.name]^2 *
            child.states.auxiliary_prediction_precision *
            child.states.volatility_prediction_error

        return update_term
    end
end

### Mean update ###
@doc raw"""
    calculate_posterior_mean(node::AbstractNode)

Calculates a node's posterior mean.

Uses the equation
``   ``
"""
function calculate_posterior_mean(node::AbstractNode, update_type::HGFUpdateType)
    value_children = node.value_children
    volatility_children = node.volatility_children

    #Initialize as the prediction
    posterior_mean = node.states.prediction_mean

    #Add update terms from value children
    for child in value_children
        posterior_mean +=
            calculate_posterior_mean_value_child_increment(node, child, update_type)
    end

    #Add update terms from volatility children
    for child in volatility_children
        posterior_mean +=
            calculate_posterior_mean_volatility_child_increment(node, child, update_type)
    end

    return posterior_mean
end

@doc raw"""
    calculate_posterior_mean_value_child_increment(node::AbstractNode, child::AbstractNode)

Calculates the posterior mean update term for a single continuous value child to a state node.
This is the classic HGF update.

Uses the equation
``   ``
"""
function calculate_posterior_mean_value_child_increment(
    node::AbstractNode,
    child::AbstractNode,
    update_type::HGFUpdateType,
)
    #For input node children with missing input
    if child isa AbstractInputNode && ismissing(child.states.input_value)
        #No update
        return 0
    else
        update_term =
            (
                child.parameters.value_coupling[node.name] *
                child.states.prediction_precision
            ) / node.states.posterior_precision * child.states.value_prediction_error

        return update_term
    end
end

@doc raw"""
    calculate_posterior_mean_value_child_increment(node::AbstractNode, child::AbstractNode)

Calculates the posterior mean update term for a single continuous value child to a state node.
This is the enhanced HGF update.

Uses the equation
``   ``
"""
function calculate_posterior_mean_value_child_increment(
    node::AbstractNode,
    child::AbstractNode,
    update_type::EnhancedUpdate,
)
    #For input node children with missing input
    if child isa AbstractInputNode && ismissing(child.states.input_value)
        #No update
        return 0
    else
        update_term =
            (
                child.parameters.value_coupling[node.name] *
                child.states.prediction_precision
            ) / node.states.prediction_precision * child.states.value_prediction_error

        return update_term
    end
end

@doc raw"""
    calculate_posterior_mean_value_child_increment(node::AbstractNode, child::BinaryStateNode)

Calculates the posterior mean update term for a single binary value child to a state node.
This is the classic HGF update.

Uses the equation
``   ``
"""
function calculate_posterior_mean_value_child_increment(
    node::AbstractNode,
    child::BinaryStateNode,
    update_type::HGFUpdateType,
)
    #For missing inputs
    if ismissing(child.states.posterior_mean)
        #No update
        return 0
    else
        return child.parameters.value_coupling[node.name] /
               (node.states.posterior_precision) * child.states.value_prediction_error
    end
end

@doc raw"""
    calculate_posterior_mean_value_child_increment(node::AbstractNode, child::BinaryStateNode)

Calculates the posterior mean update term for a single binary value child to a state node.
This is the enhanced HGF update.

Uses the equation
``   ``
"""
function calculate_posterior_mean_value_child_increment(
    node::AbstractNode,
    child::BinaryStateNode,
    update_type::EnhancedUpdate,
)
    #For missing inputs
    if ismissing(child.states.posterior_mean)
        #No update
        return 0
    else
        return child.parameters.value_coupling[node.name] /
               (node.states.prediction_precision) * child.states.value_prediction_error
    end
end

@doc raw"""
    calculate_posterior_mean_volatility_child_increment(node::AbstractNode, child::AbstractNode)

Calculates the posterior mean update term for a single continuos volatility child to a state node.

Uses the equation
``   ``
"""
function calculate_posterior_mean_volatility_child_increment(
    node::AbstractNode,
    child::AbstractNode,
    update_type::HGFUpdateType,
)
    #For input node children with missing input
    if child isa AbstractInputNode && ismissing(child.states.input_value)
        #No update
        return 0
    else
        update_term =
            1 / 2 * (
                child.parameters.volatility_coupling[node.name] *
                child.states.auxiliary_prediction_precision
            ) / node.states.posterior_precision * child.states.volatility_prediction_error

        return update_term
    end
end

@doc raw"""
    calculate_posterior_mean_volatility_child_increment(node::AbstractNode, child::AbstractNode)

Calculates the posterior mean update term for a single continuos volatility child to a state node.

Uses the equation
``   ``
"""
function calculate_posterior_mean_volatility_child_increment(
    node::AbstractNode,
    child::AbstractNode,
    update_type::EnhancedUpdate,
)
    #For input node children with missing input
    if child isa AbstractInputNode && ismissing(child.states.input_value)
        #No update
        return 0
    else
        update_term =
            1 / 2 * (
                child.parameters.volatility_coupling[node.name] *
                child.states.auxiliary_prediction_precision
            ) / node.states.prediction_precision * child.states.volatility_prediction_error

        return update_term
    end
end

######## Prediction error update functions ########
@doc raw"""
    calculate_value_prediction_error(node::AbstractNode)

Calculate's a state node's value prediction error.

Uses the equation
`` \delta_n = \mu_n - \hat{\mu}_n  ``
"""
function calculate_value_prediction_error(node::AbstractNode)
    node.states.posterior_mean - node.states.prediction_mean
end

@doc raw"""
    calculate_volatility_prediction_error(node::AbstractNode)

Calculates a state node's volatility prediction error.

Uses the equation
`` \Delta_n = \frac{\hat{\pi}_n}{\pi_n} + \hat{\pi}_n \cdot \delta_n^2-1  ``
"""
function calculate_volatility_prediction_error(node::AbstractNode)
    node.states.prediction_precision / node.states.posterior_precision +
    node.states.prediction_precision * node.states.value_prediction_error^2 - 1
end


##############################################
######## Binary State Node Variations ########
##############################################

######## Prediction update ########

### Mean update ###
@doc raw"""
    calculate_prediction_mean(node::BinaryStateNode)

Calculates a binary state node's prediction mean.

Uses the equation
`` \hat{\mu}_n= \big(1+e^{\sum_{j=1}^{j\;value \; parents} \hat{\mu}_{j}}\big)^{-1}  ``
"""
function calculate_prediction_mean(node::BinaryStateNode)
    value_parents = node.value_parents

    prediction_mean = 0

    for parent in value_parents
        prediction_mean +=
            parent.states.prediction_mean * node.parameters.value_coupling[parent.name]
    end

    prediction_mean = 1 / (1 + exp(-prediction_mean))

    return prediction_mean
end

### Precision update ###
@doc raw"""
    calculate_prediction_precision(node::BinaryStateNode)

Calculates a binary state node's prediction precision.

Uses the equation
`` \hat{\pi}_n = \frac{1}{\hat{\mu}_n \cdot (1-\hat{\mu}_n)} ``
"""
function calculate_prediction_precision(node::BinaryStateNode)
    1 / (node.states.prediction_mean * (1 - node.states.prediction_mean))
end

######## Posterior update functions ########

### Precision update ###
@doc raw"""
    calculate_posterior_precision(node::BinaryStateNode)

Calculates a binary node's posterior precision.

Uses the equations

`` \pi_n = inf ``
if the precision is infinite 

 `` \pi_n = \frac{1}{\hat{\mu}_n \cdot (1-\hat{\mu}_n)} ``
 if the precision is other than infinite
"""
function calculate_posterior_precision(node::BinaryStateNode)
    #Extract the child
    child = node.value_children[1]

    #Simple update with inifinte precision
    if child isa CategoricalStateNode || child.parameters.input_precision == Inf
        posterior_precision = Inf
        #Update with finite precision
    else
        posterior_precision =
            1 / (node.states.posterior_mean * (1 - node.states.posterior_mean))
    end

    return posterior_precision
end

### Mean update ###
@doc raw"""
    calculate_posterior_mean(node::BinaryStateNode)

Calculates a node's posterior mean.

Uses the equation
`` \mu = \frac{e^{-0.5 \cdot \pi_n \cdot \eta_1^2}}{\hat{\mu}_n \cdot e^{-0.5 \cdot \pi_n \cdot \eta_1^2} \; + 1-\hat{\mu}_n \cdot e^{-0.5 \cdot \pi_n \cdot \eta_2^2}}  ``
"""
function calculate_posterior_mean(node::BinaryStateNode, update_type::HGFUpdateType)
    #Extract the child
    child = node.value_children[1]

    #Update with categorical state node child
    if child isa CategoricalStateNode

        #Find the nodes' own category number
        category_number = findfirst(child.category_parent_order .== node.name)

        #Find the corresponding value in the child
        posterior_mean = child.states.posterior[category_number]

        #For binary input node children
    elseif child isa BinaryInputNode

        #For missing inputs
        if ismissing(child.states.input_value)
            #Set the posterior to missing
            posterior_mean = missing
        else
            #Update with infinte input precision
            if child.parameters.input_precision == Inf
                posterior_mean = child.states.input_value

                #Update with finite input precision
            else
                posterior_mean =
                    node.states.prediction_mean * exp(
                        -0.5 *
                        node.states.prediction_precision *
                        child.parameters.category_means[1]^2,
                    ) / (
                        node.states.prediction_mean * exp(
                            -0.5 *
                            node.states.prediction_precision *
                            child.parameters.category_means[1]^2,
                        ) +
                        (1 - node.states.prediction_mean) * exp(
                            -0.5 *
                            node.states.prediction_precision *
                            child.parameters.category_means[2]^2,
                        )
                    )
            end
        end
    end
    return posterior_mean
end


###################################################
######## Categorical State Node Variations ########
###################################################
@doc raw"""
    calculate_posterior(node::CategoricalStateNode)

Calculate the posterior for a categorical state node.

One hot encoding
`` \vec{u} = [0, 0, \dots ,1, \dots,0]  ``
"""
function calculate_posterior(node::CategoricalStateNode)

    #Get child
    child = node.value_children[1]

    #Initialize posterior as previous posterior
    posterior = node.states.posterior

    #For missing inputs
    if ismissing(child.states.input_value)
        #Set the posterior to be all missing
        posterior .= missing

    else
        #Set all values to 0
        posterior .= zero(Real)

        #Set the posterior for the observed category to 1
        posterior[child.states.input_value] = 1
    end
    return posterior
end

@doc raw"""
    function calculate_prediction(node::CategoricalStateNode)

Calculate the prediction for a categorical state node.

Uses the equation
``  \vec{\hat{\mu}_n}= \frac{\hat{\mu}_j}{\sum_{j=1}^{j\;binary \;parents} \hat{\mu}_j} ``
"""
function calculate_prediction(node::CategoricalStateNode)

    #Get parent posteriors
    parent_posteriors =
        map(x -> x.states.posterior_mean, collect(values(node.value_parents)))

    #Get current parent predictions
    parent_predictions =
        map(x -> x.states.prediction_mean, collect(values(node.value_parents)))

    #Get previous parent predictions
    previous_parent_predictions = node.states.parent_predictions

    #If there was an observation
    if any(!ismissing, node.states.posterior)

        #Calculate implied learning rate
        implied_learning_rate =
            (
                (parent_posteriors .- previous_parent_predictions) ./
                (parent_predictions .- previous_parent_predictions)
            ) .- 1

        # calculate the prediction mean
        prediction =
            ((implied_learning_rate .* parent_predictions) .+ 1) ./
            sum(implied_learning_rate .* parent_predictions .+ 1)

        #If there was no observation
    else
        #Extract prediction from last timestep
        prediction = node.states.prediction
    end

    return prediction, parent_predictions

end

@doc raw"""
    calculate_value_prediction_error(node::CategoricalStateNode)

Calculate the value prediction error for a categorical state node.

Uses the equation
`` \delta_n= u - \sum_{j=1}^{j\;value\;parents} \hat{\mu}_{j}  ``
"""
function calculate_value_prediction_error(node::CategoricalStateNode)

    #Get the prediction error for each category
    value_prediction_error = node.states.posterior - node.states.prediction

    return value_prediction_error
end


###################################################
######## Conntinuous Input Node Variations ########
###################################################
@doc raw"""
    calculate_prediction_precision(node::AbstractInputNode)

Calculates an input node's prediction precision.

Uses the equation
`` \hat{\pi}_n = \frac{1}{\nu}_n  ``
"""
function calculate_prediction_precision(node::AbstractInputNode)

    #Doesn't use own posterior precision
    1 / node.states.predicted_volatility
end

"""
    calculate_auxiliary_prediction_precision(node::AbstractInputNode)

An input node's auxiliary prediction precision is always 1.
"""
function calculate_auxiliary_prediction_precision(node::AbstractInputNode)
    1
end

@doc raw"""
    calculate_value_prediction_error(node::ContinuousInputNode)

Calculate's an input node's value prediction error.

Uses the equation
``\delta_n= u - \sum_{j=1}^{j\;value\;parents} \hat{\mu}_{j} ``


"""
function calculate_value_prediction_error(node::ContinuousInputNode)
    #For missing input
    if ismissing(node.states.input_value)
        #Set the prediction error to missing
        value_prediction_error = missing
    else
        #Extract parents
        value_parents = node.value_parents

        #Sum the prediction_means of the parents
        parents_prediction_mean = 0
        for parent in value_parents
            parents_prediction_mean += parent.states.prediction_mean
        end

        #Get VOPE using parents_prediction_mean instead of own
        value_prediction_error = node.states.input_value - parents_prediction_mean
    end
    return value_prediction_error
end

@doc raw"""
    calculate_volatility_prediction_error(node::ContinuousInputNode)

Calculates an input node's volatility prediction error.

Uses the equation
``  \mu'_j=\sum_{j=1}^{j\;value\;parents} \mu_{j} ``
`` \pi'_j=\frac{{\sum_{j=1}^{j\;value\;parents} \pi_{j}}}{j} ``
`` \Delta_n=\frac{\hat{\pi}_n}{\pi'_j} + \hat{\mu}_i\cdot (u -\mu'_j^2 )-1 ``
"""
function calculate_volatility_prediction_error(node::ContinuousInputNode)

    #For missing input
    if ismissing(node.states.input_value)
        #Set the prediction error to missing
        volatility_prediction_error = missing
    else
        #Extract parents
        value_parents = node.value_parents

        #Sum the posterior mean and average the posterior precision of the value parents 
        parents_posterior_mean = 0
        parents_posterior_precision = 0

        for parent in value_parents
            parents_posterior_mean += parent.states.posterior_mean
            parents_posterior_precision += parent.states.posterior_precision
        end

        parents_posterior_precision = parents_posterior_precision / length(value_parents)

        #Get the VOPE using parents_posterior_precision and parents_posterior_mean 
        volatility_prediction_error =
            node.states.prediction_precision / parents_posterior_precision +
            node.states.prediction_precision *
            (node.states.input_value - parents_posterior_mean)^2 - 1
    end

    return volatility_prediction_error
end


##############################################
######## Binary Input Node Variations ########
##############################################
@doc raw"""
    calculate_value_prediction_error(node::BinaryInputNode)

Calculates the prediciton error of a binary input node with finite precision.

Uses the equation
``  \delta_n= u - \sum_{j=1}^{j\;value\;parents} \hat{\mu}_{j} ``
"""
function calculate_value_prediction_error(node::BinaryInputNode)

    #For missing input
    if ismissing(node.states.input_value)
        #Set the prediction error to missing
        value_prediction_error = [missing, missing]
    else
        #Substract to find the difference to each of the Gaussian means
        value_prediction_error = node.parameters.category_means .- node.states.input_value
    end
end


###################################################
######## Categorical Input Node Variations ########
###################################################
