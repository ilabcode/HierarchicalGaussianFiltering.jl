#######################################
######## Continuous State Node ########
#######################################


######## Prediction update ########

### Mean update ###
"""
    calculate_prediction_mean(node::AbstractNode, value_parent::Any)

Calculates a node's prediction mean.
"""
function calculate_prediction_mean(node::AbstractNode)
    value_parents = node.value_parents

    prediction_mean = node.states.posterior_mean

    for parent in value_parents
        prediction_mean +=
            parent.states.posterior_mean * node.params.value_coupling[parent.name]
    end

    return prediction_mean
end


### Volatility update ###
"""
    calculate_prediction_volatility(node::AbstractNode,  volatility_parents::Any)

Calculates a node's prediction volatility.
"""
function calculate_prediction_volatility(node::AbstractNode)
    volatility_parents = node.volatility_parents

    prediction_volatility = node.params.evolution_rate

    for parent in volatility_parents
        prediction_volatility +=
            parent.states.posterior_mean * node.params.volatility_coupling[parent.name]
    end

    return exp(prediction_volatility)
end


### Precision update ###
"""
    calculate_prediction_precision(node::ContinuousStateNode)

Calculates a node's prediction precision.
"""
function calculate_prediction_precision(node::AbstractNode)
    1 / (1 / node.states.posterior_precision + node.states.prediction_volatility)
end

"""
    calculate_auxiliary_prediction_precision(node::AbstractNode)

Calculates a node's auxiliary prediction precision.
"""
function calculate_auxiliary_prediction_precision(node::AbstractNode)
    node.states.prediction_volatility * node.states.prediction_precision
end



######## Posterior update functions ########

### Precision update ###
"""
    calculate_posterior_precision(
        node::AbstractNode,
        value_children,
        volatility_children)

Calculates a node's posterior precision.
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

    return posterior_precision
end

"""
    calculate_posterior_precision_vape(
        node::AbstractNode,
        child::AbstractNode)

Calculates the posterior precision update term for a single continuous value child to a state node.
"""
function calculate_posterior_precision_vape(node::AbstractNode, child::AbstractNode)
    update_term = child.params.value_coupling[node.name] * child.states.prediction_precision

    return update_term
end

"""
    calculate_posterior_precision_vape(
        node::AbstractNode,
        child::BinaryStateNode)

Calculates the posterior precision update term for a single binary value child to a state node.
"""
function calculate_posterior_precision_vape(node::AbstractNode, child::BinaryStateNode)
    update_term = 1 / child.states.prediction_precision

    return update_term
end

"""
    calculate_posterior_precision_vope(
        posterior_precision::Real,
        node::AbstractNode,
        volatility_children::Any)

Calculates the posterior precision update term for a single continuous volatility child to a state node.
"""
function calculate_posterior_precision_vope(node::AbstractNode, child::AbstractNode)
    update_term =
        1 / 2 *
        (
            child.params.volatility_coupling[node.name] *
            child.states.auxiliary_prediction_precision
        )^2 +
        child.states.volatility_prediction_error *
        (
            child.params.volatility_coupling[node.name] *
            child.states.auxiliary_prediction_precision
        )^2 -
        1 / 2 *
        child.params.volatility_coupling[node.name]^2 *
        child.states.auxiliary_prediction_precision *
        child.states.volatility_prediction_error

    return update_term
end


### Mean update ###
"""
    calculate_posterior_mean(node::AbstractNode, value_children, volatility_children)

Calculates a node's posterior mean.
"""
function calculate_posterior_mean(node::AbstractNode)
    value_children = node.value_children
    volatility_children = node.volatility_children

    #Initialize as the prediction
    posterior_mean = node.states.prediction_mean

    #Add update terms from value children
    for child in value_children
        posterior_mean += calculate_posterior_mean_value_child_increment(node, child)
    end

    #Add update terms from volatility children
    for child in volatility_children
        posterior_mean += calculate_posterior_mean_volatility_child_increment(node, child)
    end

    return posterior_mean
end

"""
    calculate_posterior_mean_value_child_increment(
        node::AbstractNode,
        child::AbstractNode)

Calculates the posterior mean update term for a single continuous value child to a state node.
"""
function calculate_posterior_mean_value_child_increment(
    node::AbstractNode,
    child::AbstractNode,
)

    update_term =
        (child.params.value_coupling[node.name] * child.states.prediction_precision) /
        node.states.posterior_precision * child.states.value_prediction_error

    return update_term
end

"""
    calculate_posterior_mean_value_child_increment(
        node::AbstractNode,
        child::BinaryStateNode)

Calculates the posterior mean update term for a single binary value child to a state node.
"""
function calculate_posterior_mean_value_child_increment(
    node::AbstractNode,
    child::BinaryStateNode,
)

    update_term =
        1 / (node.states.posterior_precision) * child.states.value_prediction_error

    return update_term
end

"""
    calculate_posterior_mean_volatility_child_increment(
        node::AbstractNode,
        child::Any)

Calculates the posterior mean update term for a single continuos volatility child to a state node.
"""
function calculate_posterior_mean_volatility_child_increment(
    node::AbstractNode,
    child::AbstractNode,
)

    update_term =
        1 / 2 * (
            child.params.volatility_coupling[node.name] *
            child.states.auxiliary_prediction_precision
        ) / node.states.posterior_precision * child.states.volatility_prediction_error

    return update_term
end



######## Prediction error update functions ########
"""
    calculate_value_prediction_error(node::AbstractNode)

Calculate's a state node's value prediction error.
"""
function calculate_value_prediction_error(node::AbstractNode)
    node.states.posterior_mean - node.states.prediction_mean
end

"""
    calculate_volatility_prediction_error(node::AbstractNode)

Calculates a state node's volatility prediction error.
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
"""
    calculate_prediction_mean(node::AbstractNode, value_parent::Any)

Calculates a binary state node's prediction mean.
"""
function calculate_prediction_mean(node::BinaryStateNode)
    value_parents = node.value_parents

    prediction_mean = 0

    for parent in value_parents
        prediction_mean += parent.states.prediction_mean
    end

    prediction_mean = 1 / (1 + exp(-prediction_mean))

    return prediction_mean
end


### Precision update ###
"""
    calculate_prediction_precision(node::BinaryStateNode)

Calculates a binary state node's prediction precision.
"""
function calculate_prediction_precision(node::BinaryStateNode)
    1 / (node.states.prediction_mean * (1 - node.states.prediction_mean))
end


######## Posterior update functions ########

### Precision update ###
"""
    calculate_posterior_precision(
        node::BinaryStateNode,
        value_children,
        volatility_children)

Calculates a binary node's posterior precision.
"""
function calculate_posterior_precision(node::BinaryStateNode)
    #Extract the child
    child = node.value_children[1]

    #Simple update with inifinte precision
    if child.params.input_precision == Inf || child isa CategoricalStateNode
        posterior_precision = Inf
        #Update with finite precision
    else
        posterior_precision =
            1 / (node.states.prediction_mean * (1 - node.states.prediction_mean))
    end

    return posterior_precision
end

### Mean update ###
"""
    calculate_posterior_mean(node::BinaryStateNode, value_children, volatility_children)

Calculates a node's posterior mean.
"""
function calculate_posterior_mean(node::BinaryStateNode)
    #Extract the child
    child = node.value_children[1]

    #Update with categorical state node child
    if child isa CategoricalStateNode
        #Find the posterior in the categorical child
        posterior_mean = child.posterior[node.name]
    
    #Simple binary input node child update with infinte input precision
    elseif child.params.input_precision == Inf
        posterior_mean = child.states.input_value

    #Update with finite precision binary input node
    else
        posterior_mean =
            node.states.prediction_mean * exp(
                -0.5 * node.states.prediction_precision * child.params.category_means[1]^2,
            ) / (
                node.states.prediction_mean * exp(
                    -0.5 *
                    node.states.prediction_precision *
                    child.params.category_means[1]^2,
                ) +
                (1 - node.states.prediction_mean) * exp(
                    -0.5 *
                    node.states.prediction_precision *
                    child.params.category_means[2]^2,
                )
            )
    end

    return posterior_mean
end



###################################################
######## Categorical State Node Variations ########
###################################################

"""
"""
function calculate_posterior(node:CategoricalStateNode)
    
    #Get child
    child = node.value_children[1]

    #Initialize posterior as previous posterior
    posterior = node.posterior

    #Set all values to 0
    map!(x -> 0, values(posterior))

    #Get the name of the parent for the observed category
    observed_category_parent = keys(node.value_parents)[child.input_value]

    #Set the posterior for that category to 1
    posterior[observed_category_parent] = 1

    return posterior
end

"""
"""
function calculate_prediction(node:CategoricalStateNode)

    #Get out prediction means from all value parents
    prediction = map(x -> x.prediction_mean, collect(values(node.value_parents)))

    #Normalize prediction vector
    prediction = prediction/sum(prediction)

    return prediction
end



###################################################
######## Conntinuous Input Node Variations ########
###################################################

"""
    calculate_prediction_precision(node::ContinuousInputNode)

Calculates an input node's prediction precision.
"""
function calculate_prediction_precision(node::AbstractInputNode)

    #Doesn't use own posterior precision
    1 / node.states.prediction_volatility
end

"""
    calculate_auxiliary_prediction_precision(node::AbstractInputNode)

An input nodes auxiliary precision is always 1.
"""
function calculate_auxiliary_prediction_precision(node::AbstractInputNode)
    1
end

"""
    calculate_value_prediction_error(node::ContinuousInputNode, value_parents::Any)

Calculate's an input node's value prediction error.
"""
function calculate_value_prediction_error(node::ContinuousInputNode)
    value_parents = node.value_parents

    #Sum the prediction_means of the parents
    parents_prediction_mean = 0
    for parent in value_parents
        parents_prediction_mean += parent.states.prediction_mean
    end

    #Get VOPE using parents_prediction_mean instead of own
    node.states.input_value - parents_prediction_mean
end

"""
    calculate_volatility_prediction_error(node::ContinuousInputNode, value_parents::Any)

Calculates an input node's volatility prediction error.
"""
function calculate_volatility_prediction_error(node::ContinuousInputNode)
    value_parents = node.value_parents

    #Sum the posterior mean and average the posterior precision of the value parents 
    parents_posterior_mean = 0
    parents_posterior_precision = 0

    for parent in value_parents
        parents_posterior_mean += parent.states.posterior_mean
        parents_posterior_precision += parent.states.posterior_precision
    end

    parents_posterior_precision / length(value_parents)

    #Get the VOPE using parents_posterior_precision and parents_posterior_mean 
    node.states.prediction_precision / parents_posterior_precision +
    node.states.prediction_precision *
    (node.states.input_value - parents_posterior_mean)^2 - 1
end


##############################################
######## Binary Input Node Variations ########
##############################################

"""
    calculate_value_prediction_error(node::BinaryInputNode)

Calculates the prediciton error of a binary input node with finite precision
"""
function calculate_value_prediction_error(node::BinaryInputNode)
    #Substract to find the difference to each of the Gaussian means
    node.params.category_means .- node.states.input_value
end


###################################################
######## Categorical Input Node Variations ########
###################################################