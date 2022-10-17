#######################################
######## Continuous State Node ########
#######################################


######## Prediction update ########

### Mean update ###
"""
    calculate_prediction_mean(self::AbstractNode, value_parent::Any)

Calculates a node's prediction mean.
"""
function calculate_prediction_mean(self::AbstractNode)
    value_parents = self.value_parents

    prediction_mean = self.states.posterior_mean

    for parent in value_parents
        prediction_mean +=
            parent.states.posterior_mean * self.params.value_coupling[parent.name]
    end

    return prediction_mean
end


### Volatility update ###
"""
    calculate_prediction_volatility(self::AbstractNode,  volatility_parents::Any)

Calculates a node's prediction volatility.
"""
function calculate_prediction_volatility(self::AbstractNode)
    volatility_parents = self.volatility_parents

    prediction_volatility = self.params.evolution_rate

    for parent in volatility_parents
        prediction_volatility +=
            parent.states.posterior_mean * self.params.volatility_coupling[parent.name]
    end

    return exp(prediction_volatility)
end


### Precision update ###
"""
    calculate_prediction_precision(self::ContinuousStateNode)

Calculates a node's prediction precision.
"""
function calculate_prediction_precision(self::AbstractNode)
    1 / (1 / self.states.posterior_precision + self.states.prediction_volatility)
end

"""
    calculate_auxiliary_prediction_precision(self::AbstractNode)

Calculates a node's auxiliary prediction precision.
"""
function calculate_auxiliary_prediction_precision(self::AbstractNode)
    self.states.prediction_volatility * self.states.prediction_precision
end



######## Posterior update functions ########

### Precision update ###
"""
    calculate_posterior_precision(
        self::AbstractNode,
        value_children,
        volatility_children)

Calculates a node's posterior precision.
"""
function calculate_posterior_precision(self::AbstractNode)
    value_children = self.value_children
    volatility_children = self.volatility_children

    #Initialize as the node's own prediction
    posterior_precision = self.states.prediction_precision

    #Add update terms from value children
    for child in value_children
        posterior_precision += calculate_posterior_precision_vape(self, child)
    end

    #Add update terms from volatility children
    for child in volatility_children
        posterior_precision += calculate_posterior_precision_vope(self, child)
    end

    return posterior_precision
end

"""
    calculate_posterior_precision_vape(
        self::AbstractNode,
        child::AbstractNode)

Calculates the posterior precision update term for a single continuous value child to a state node.
"""
function calculate_posterior_precision_vape(self::AbstractNode, child::AbstractNode)
    update_term = child.params.value_coupling[self.name] * child.states.prediction_precision

    return update_term
end

"""
    calculate_posterior_precision_vape(
        self::AbstractNode,
        child::BinaryStateNode)

Calculates the posterior precision update term for a single binary value child to a state node.
"""
function calculate_posterior_precision_vape(self::AbstractNode, child::BinaryStateNode)
    update_term = 1 / child.states.prediction_precision

    return update_term
end

"""
    calculate_posterior_precision_vope(
        posterior_precision::Real,
        self::AbstractNode,
        volatility_children::Any)

Calculates the posterior precision update term for a single continuous volatility child to a state node.
"""
function calculate_posterior_precision_vope(self::AbstractNode, child::AbstractNode)
    update_term =
        1 / 2 *
        (
            child.params.volatility_coupling[self.name] *
            child.states.auxiliary_prediction_precision
        )^2 +
        child.states.volatility_prediction_error *
        (
            child.params.volatility_coupling[self.name] *
            child.states.auxiliary_prediction_precision
        )^2 -
        1 / 2 *
        child.params.volatility_coupling[self.name]^2 *
        child.states.auxiliary_prediction_precision *
        child.states.volatility_prediction_error

    return update_term
end


### Mean update ###
"""
    calculate_posterior_mean(self::AbstractNode, value_children, volatility_children)

Calculates a node's posterior mean.
"""
function calculate_posterior_mean(self::AbstractNode)
    value_children = self.value_children
    volatility_children = self.volatility_children

    #Initialize as the prediction
    posterior_mean = self.states.prediction_mean

    #Add update terms from value children
    for child in value_children
        posterior_mean += calculate_posterior_mean_vape(self, child)
    end

    #Add update terms from volatility children
    for child in volatility_children
        posterior_mean += calculate_posterior_mean_vope(self, child)
    end

    return posterior_mean
end

"""
    calculate_posterior_mean_vape(
        self::AbstractNode,
        child::AbstractNode)

Calculates the posterior mean update term for a single continuous value child to a state node.
"""
function calculate_posterior_mean_vape(self::AbstractNode, child::AbstractNode)

    update_term =
        (child.params.value_coupling[self.name] * child.states.prediction_precision) /
        self.states.posterior_precision * child.states.value_prediction_error

    return update_term
end

"""
    calculate_posterior_mean_vape(
        self::AbstractNode,
        child::BinaryStateNode)

Calculates the posterior mean update term for a single binary value child to a state node.
"""
function calculate_posterior_mean_vape(self::AbstractNode, child::BinaryStateNode)

    update_term =
        1 / (self.states.posterior_precision) * child.states.value_prediction_error

    return update_term
end

"""
    calculate_posterior_mean_vope(
        self::AbstractNode,
        child::Any)

Calculates the posterior mean update term for a single continuos volatility child to a state node.
"""
function calculate_posterior_mean_vope(self::AbstractNode, child::AbstractNode)

    update_term =
        1 / 2 * (
            child.params.volatility_coupling[self.name] *
            child.states.auxiliary_prediction_precision
        ) / self.states.posterior_precision * child.states.volatility_prediction_error

    return update_term
end



######## Prediction error update functions ########
"""
    calculate_value_prediction_error(self::AbstractNode)

Calculate's a state node's value prediction error.
"""
function calculate_value_prediction_error(self::AbstractNode)
    self.states.posterior_mean - self.states.prediction_mean
end

"""
    calculate_volatility_prediction_error(self::AbstractNode)

Calculates a state node's volatility prediction error.
"""
function calculate_volatility_prediction_error(self::AbstractNode)
    self.states.prediction_precision / self.states.posterior_precision +
    self.states.prediction_precision * self.states.value_prediction_error^2 - 1
end



##############################################
######## Binary State Node Variations ########
##############################################

######## Prediction update ########

### Mean update ###
"""
    calculate_prediction_mean(self::AbstractNode, value_parent::Any)

Calculates a binary state node's prediction mean.
"""
function calculate_prediction_mean(self::BinaryStateNode)
    value_parents = self.value_parents

    prediction_mean = 0

    for parent in value_parents
        prediction_mean += parent.states.prediction_mean
    end

    prediction_mean = 1 / (1 + exp(-prediction_mean))

    return prediction_mean
end


### Precision update ###
"""
    calculate_prediction_precision(self::BinaryStateNode)

Calculates a binary state node's prediction precision.
"""
function calculate_prediction_precision(self::BinaryStateNode)
    1 / (self.states.prediction_mean * (1 - self.states.prediction_mean))
end


######## Posterior update functions ########

### Precision update ###
"""
    calculate_posterior_precision(
        self::BinaryStateNode,
        value_children,
        volatility_children)

Calculates a binary node's posterior precision.
"""
function calculate_posterior_precision(self::BinaryStateNode)
    #Extract the child
    child = self.value_children[1]

    #Simple update with inifinte precision
    if child.params.input_precision == Inf
        posterior_precision = Inf
        #Update with finite precision
    else
        posterior_precision =
            1 / (self.states.prediction_mean * (1 - self.states.prediction_mean))
    end

    return posterior_precision
end

### Mean update ###
"""
    calculate_posterior_mean(self::BinaryStateNode, value_children, volatility_children)

Calculates a node's posterior mean.
"""
function calculate_posterior_mean(self::BinaryStateNode)
    #Extract the child
    child = self.value_children[1]

    #Simple update with infinte input precision
    if child.params.input_precision == Inf
        posterior_mean = child.states.input_value
        #Update with finite precision
    else
        posterior_mean =
            self.states.prediction_mean * exp(
                -0.5 * self.states.prediction_precision * child.params.category_means[1]^2,
            ) / (
                self.states.prediction_mean * exp(
                    -0.5 *
                    self.states.prediction_precision *
                    child.params.category_means[1]^2,
                ) +
                (1 - self.states.prediction_mean) * exp(
                    -0.5 *
                    self.states.prediction_precision *
                    child.params.category_means[2]^2,
                )
            )
    end

    return posterior_mean
end



###################################################
######## Conntinuous Input Node Variations ########
###################################################

"""
    calculate_prediction_precision(self::ContinuousInputNode)

Calculates an input node's prediction precision.
"""
function calculate_prediction_precision(self::AbstractInputNode)

    #Doesn't use own posterior precision
    1 / self.states.prediction_volatility
end

"""
    calculate_auxiliary_prediction_precision(self::AbstractInputNode)

An input nodes auxiliary precision is always 1.
"""
function calculate_auxiliary_prediction_precision(self::AbstractInputNode)
    1
end

"""
    calculate_value_prediction_error(self::ContinuousInputNode, value_parents::Any)

Calculate's an input node's value prediction error.
"""
function calculate_value_prediction_error(self::ContinuousInputNode)
    value_parents = self.value_parents

    #Sum the prediction_means of the parents
    parents_prediction_mean = 0
    for parent in value_parents
        parents_prediction_mean += parent.states.prediction_mean
    end

    #Get VOPE using parents_prediction_mean instead of own
    self.states.input_value - parents_prediction_mean
end

"""
    calculate_volatility_prediction_error(self::ContinuousInputNode, value_parents::Any)

Calculates an input node's volatility prediction error.
"""
function calculate_volatility_prediction_error(self::ContinuousInputNode)
    value_parents = self.value_parents

    #Sum the posterior mean and average the posterior precision of the value parents 
    parents_posterior_mean = 0
    parents_posterior_precision = 0

    for parent in value_parents
        parents_posterior_mean += parent.states.posterior_mean
        parents_posterior_precision += parent.states.posterior_precision
    end

    parents_posterior_precision / length(value_parents)

    #Get the VOPE using parents_posterior_precision and parents_posterior_mean 
    self.states.prediction_precision / parents_posterior_precision +
    self.states.prediction_precision *
    (self.states.input_value - parents_posterior_mean)^2 - 1
end

##############################################
######## Binary Input Node Variations ########
##############################################

"""
    calculate_value_prediction_error(self::BinaryInputNode)

Calculates the prediciton error of a binary input node with finite precision
"""
function calculate_value_prediction_error(self::BinaryInputNode)
    #Substract to find the difference to each of the Gaussian means
    self.params.category_means .- self.states.input_value
end