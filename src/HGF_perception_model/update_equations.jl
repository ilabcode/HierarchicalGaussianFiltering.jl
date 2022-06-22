######## Prediction update ########

### Mean update ###
"""
    calculate_prediction_mean(self::AbstractNode, value_parent::Any)

Calculates a node's prediction mean.
"""
function calculate_prediction_mean(self::AbstractNode, value_parents::Vector{AbstractStateNode})

    prediction_mean = self.state.posterior_mean

    for parent in value_parents
        prediction_mean +=
            parent.state.posterior_mean * self.params.value_coupling[parent.name]
    end

    return prediction_mean
end


### Volatility update ###
"""
    calculate_prediction_volatility(self::AbstractNode,  volatility_parents::Any)

Calculates a node's prediction volatility.
"""
function calculate_prediction_volatility(self::AbstractNode, volatility_parents::Vector{AbstractStateNode})

    prediction_volatility = self.params.evolution_rate

    for parent in volatility_parents
        prediction_volatility +=
            parent.state.posterior_mean * self.params.volatility_coupling[parent.name]
    end

    return exp(prediction_volatility)
end


### Precision update ###
"""
    calculate_prediction_precision(self::StateNode)

Calculates a node's prediction precision.
"""
function calculate_prediction_precision(self::AbstractNode)
    1 / (1 / self.state.posterior_precision + self.state.prediction_volatility)
end

"""
    calculate_auxiliary_prediction_precision(self::AbstractNode)

Calculates a node's auxiliary prediction precision.
"""
function calculate_auxiliary_prediction_precision(self::AbstractNode)
    self.state.prediction_volatility * self.state.prediction_precision
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
function calculate_posterior_precision(
    self::AbstractNode,
    value_children::Vector{AbstractNode},
    volatility_children::Vector{AbstractNode},
)

    posterior_precision = self.state.prediction_precision

    posterior_precision =
        calculate_posterior_precision_vape(posterior_precision, self, value_children)

    posterior_precision =
        calculate_posterior_precision_vope(posterior_precision, self, volatility_children)

    return posterior_precision
end

"""
    calculate_posterior_precision_vape(
        posterior_precision::Real,
        self::AbstractNode,
        value_children::Any)

Calculates a node's posterior precision for a VAPE coupling.
"""
function calculate_posterior_precision_vape(
    posterior_precision::Real,
    self::AbstractNode,
    value_children::Vector{AbstractNode},
)
    for child in value_children
        posterior_precision +=
            child.params.value_coupling[self.name] * child.state.prediction_precision
    end

    return posterior_precision
end

"""
    calculate_posterior_precision_vope(
        posterior_precision::Real,
        self::AbstractNode,
        volatility_children::Any)

Calculates a node's posterior precision for a VOPE coupling.
"""
function calculate_posterior_precision_vope(
    posterior_precision::Real,
    self::AbstractNode,
    volatility_children::Vector{AbstractNode},
)
    for child in volatility_children
        posterior_precision += calculate_posterior_precision_vope_helper(
            child.state.auxiliary_prediction_precision,
            child.params.volatility_coupling[self.name],
            child.state.volatility_prediction_error,
        )
    end

    return posterior_precision
end

"""
    calculate_posterior_precision_vope_helper(
        auxiliary_prediction_precision::Real,
        child_volatility_coupling::Real,
        child_volatility_prediction_error::Real)

Helper function which calculates the additive term for updating posterior precision in a VOPE coupling.
"""
function calculate_posterior_precision_vope_helper(
    child_auxiliary_prediction_precision::Real,
    child_volatility_coupling::Real,
    child_volatility_prediction_error::Real,
)

    update_term =
        1 / 2 * (child_volatility_coupling * child_auxiliary_prediction_precision)^2 +
        child_volatility_prediction_error *
        (child_volatility_coupling * child_auxiliary_prediction_precision)^2 -
        1 / 2 *
        child_volatility_coupling^2 *
        child_auxiliary_prediction_precision *
        child_volatility_prediction_error

    return update_term
end


"""
    calculate_posterior_mean(self::AbstractNode, value_children, volatility_children)

Calculates a node's posterior mean.
"""
function calculate_posterior_mean(self::AbstractNode, value_children::Vector{AbstractNode}, volatility_children::Vector{AbstractNode})

    posterior_mean = self.state.prediction_mean

    posterior_mean = calculate_posterior_mean_vape(posterior_mean, self, value_children)

    posterior_mean =
        calculate_posterior_mean_vope(posterior_mean, self, volatility_children)

    return posterior_mean
end

"""
    calculate_posterior_mean_vape(
        posterior_mean::Real,
        self::AbstractNode,
        value_children::Any)

Calculates a node's posterior mean for a VAPE coupling.
"""
function calculate_posterior_mean_vape(
    posterior_mean::Real,
    self::AbstractNode,
    value_children::Vector{AbstractNode},
)

    for child in value_children
        posterior_mean +=
            (child.params.value_coupling[self.name] * child.state.prediction_precision) /
            self.state.posterior_precision * child.state.value_prediction_error
    end

    return posterior_mean
end

"""
    calculate_posterior_mean_vope(
        posterior_mean::Real,
        self::AbstractNode,
        volatility_children::Any)

Calculates a node's posterior mean for a VOPE coupling.
"""
function calculate_posterior_mean_vope(
    posterior_mean::Real,
    self::AbstractNode,
    volatility_children::Vector{AbstractNode},
)

    for child in volatility_children
        posterior_mean +=
            1 / 2 * (
                child.params.volatility_coupling[self.name] *
                child.state.auxiliary_prediction_precision
            ) / self.state.posterior_precision * child.state.volatility_prediction_error
    end

    return posterior_mean
end



######## Prediction error update functions ########
"""
    calculate_value_prediction_error(self::AbstractNode)

Calculate's a state node's value prediction error.
"""
function calculate_value_prediction_error(self::AbstractNode)
    self.state.posterior_mean - self.state.prediction_mean
end

"""
    calculate_volatility_prediction_error(self::AbstractNode)

Calculates a state node's volatility prediction error.
"""
function calculate_volatility_prediction_error(self::AbstractNode)
    self.state.prediction_precision / self.state.posterior_precision +
    self.state.prediction_precision * self.state.value_prediction_error^2 - 1
end



######## Input Node variations ########
"""
    calculate_prediction_precision(self::InputNode)

Calculates an input node's prediction precision.
"""
function calculate_prediction_precision(self::AbstractInputNode)

    #Doesn't use own posterior precision
    1 / self.state.prediction_volatility
end

"""
    calculate_auxiliary_prediction_precision(self::AbstractInputNode)

An input nodes auxiliary precision is always 1.
"""
function calculate_auxiliary_prediction_precision(self::AbstractInputNode)
    1
end

"""
    calculate_value_prediction_error(self::InputNode, value_parents::Any)

Calculate's an input node's value prediction error.
"""
function calculate_value_prediction_error(self::InputNode, value_parents::Vector{AbstractStateNode})

    #Sum the prediction_means of the parents
    parents_prediction_mean = 0
    for parent in value_parents
        parents_prediction_mean += parent.state.prediction_mean
    end

    #Get VOPE using parents_prediction_mean instead of own
    self.state.input_value - parents_prediction_mean
end

"""
    calculate_volatility_prediction_error(self::InputNode, value_parents::Any)

Calculates an input node's volatility prediction error.
"""
function calculate_volatility_prediction_error(self::InputNode, value_parents::Vector{AbstractStateNode})

    #Sum the posterior mean and average the posterior precision of the value parents 
    parents_posterior_mean = 0
    parents_posterior_precision = 0

    for parent in value_parents
        parents_posterior_mean += parent.state.posterior_mean
        parents_posterior_precision += parent.state.posterior_precision
    end

    parents_posterior_precision / length(value_parents)

    #Get the VOPE using parents_posterior_precision and parents_posterior_mean 
    self.state.prediction_precision / parents_posterior_precision +
    self.state.prediction_precision * (self.state.input_value - parents_posterior_mean)^2 -
    1
end
