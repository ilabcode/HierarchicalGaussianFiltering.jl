######## Prediction update ########

### Mean update ###
"""
    calculate_prediction_mean(self::AbstractNode, value_parent::Bool)

Calculates a node's prediction mean without a value parent.
"""
function calculate_prediction_mean(self::AbstractNode, value_parent::Bool)

    self.posterior_mean
end

"""
    calculate_prediction_mean(self::AbstractNode, value_parent::AbstractNode)

Calculates a node's prediction mean with a single value parent.
"""
function calculate_prediction_mean(self::AbstractNode, value_parent::AbstractNode)

    self.posterior_mean +
    value_parent.posterior_mean * self.value_coupling[value_parent.name]
end

"""
    calculate_prediction_mean(self::AbstractNode, value_parent::Vector{AbstractNode})

Calculates a node's prediction mean with multiple value parents.
"""
function calculate_prediction_mean(self::AbstractNode, value_parents::Vector{AbstractNode})

    prediction_mean = self.posterior_mean

    for parent in value_parents
        prediction_mean += parent.posterior_mean * self.value_coupling[parent.name]
    end

    return prediction_mean
end


### Volatility update ###
"""
    calculate_prediction_volatility(self::AbstractNode, volatility_parent::Bool)

Calculates a node's prediction volatility without a volatility parent.
"""
function calculate_prediction_volatility(self::AbstractNode, volatility_parent::Bool)

    exp(self.evolution_rate)
end

"""
    calculate_prediction_volatility(self::AbstractNode, volatility_parent::AbstractNode)

Calculates a node's prediction volatility with a single value parent.
"""
function calculate_prediction_volatility(self::AbstractNode, volatility_parent::AbstractNode)

    exp(
        self.evolution_rate +
        volatility_parent.posterior_mean * self.volatility_coupling[volatility_parent.name],
    )
end

"""
    calculate_prediction_volatility(self::AbstractNode,  volatility_parents::Vector{AbstractNode})

Calculates a node's prediction volatility with multiple volatility parents.
"""
function calculate_prediction_volatility(self::AbstractNode, volatility_parents::Vector{AbstractNode})

    prediction_volatility = self.evolution_rate

    for parent in volatility_parents
        prediction_volatility +=
            parent.posterior_mean * self.volatility_coupling[parent.name]
    end

    return exp(prediction_volatility)
end


### Precision update ###
"""
    calculate_prediction_precision(self::AbstractNode)

Calculates a node's prediction precision.
"""
function calculate_prediction_precision(self::AbstractNode)
    1 / (1 / self.posterior_precision + self.prediction_volatility)
end

"""
    calculate_auxiliary_prediction_precision(self::AbstractNode)

Calculates a node's auxiliary prediction precision.
"""
function calculate_auxiliary_prediction_precision(self::AbstractNode)
    self.prediction_volatility * self.prediction_precision
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
function calculate_posterior_precision(self::AbstractNode, value_children, volatility_children)

    posterior_precision = self.prediction_precision

    posterior_precision =
        calculate_posterior_precision_vape(posterior_precision, self, value_children)

    posterior_precision =
        calculate_posterior_precision_vope(posterior_precision, self, volatility_children)

    return posterior_precision
end

#Updating posterior precision without value children
"""
    calculate_posterior_precision_vape(
        posterior_precision::AbstractFloat,
        self::AbstractNode,
        value_child::Bool)

Calculates a node's posterior precision for a VAPE coupling without a value child.
"""
function calculate_posterior_precision_vape(
    posterior_precision::AbstractFloat,
    self::AbstractNode,
    value_child::Bool,
)
    posterior_precision
end

#Updating posterior precision with a single value child
"""
    calculate_posterior_precision_vape(
        posterior_precision::AbstractFloat,
        self::AbstractNode,
        value_child::AbstractNode)

Calculates a node's posterior precision for a VAPE coupling with a single value child.
"""
function calculate_posterior_precision_vape(
    posterior_precision::AbstractFloat,
    self::AbstractNode,
    value_child::AbstractNode,
)
    posterior_precision +
    value_child.value_coupling[self.name] * value_child.prediction_precision
end

#Updating posterior precision with multiple value children
"""
    calculate_posterior_precision_vape(
        posterior_precision::AbstractFloat,
        self::AbstractNode,
        value_children::Vector{AbstractNode})

Calculates a node's posterior precision for a VAPE coupling with multiple value children.
"""
function calculate_posterior_precision_vape(
    posterior_precision::AbstractFloat,
    self::AbstractNode,
    value_children::Vector{AbstractNode},
)
    for child in value_children
        posterior_precision += child.value_coupling[self.name] * child.prediction_precision
    end

    return posterior_precision
end

#Updating posterior precision without volatility children 
"""
    calculate_posterior_precision_vope(
        posterior_precision::AbstractFloat,
        self::AbstractNode,
        volatility_child::Bool)

Calculates a node's posterior precision for a VOPE coupling without a volatility child.
"""
function calculate_posterior_precision_vope(
    posterior_precision::AbstractFloat,
    self::AbstractNode,
    volatility_child::Bool,
)
    posterior_precision
end

#Updating posterior precision with a single volatility child
"""
    calculate_posterior_precision_vope(
        posterior_precision::AbstractFloat
        self::AbstractNode
        volatility_child::AbstractNode)

Calculates a node's posterior precision for a VOPE coupling with a single volatility child.
"""
function calculate_posterior_precision_vope(
    posterior_precision::AbstractFloat,
    self::AbstractNode,
    volatility_child::AbstractNode,
)
    posterior_precision + calculate_posterior_precision_vope_helper(
        self.auxiliary_prediction_precision,
        volatility_child.volatility_coupling[self.name],
        volatility_child.volatility_prediction_error,
    )
end

#Updating posterior precision with multiple volatility children
"""
    calculate_posterior_precision_vope(
        posterior_precision::AbstractFloat,
        self::AbstractNode,
        volatility_children::Vector{AbstractNode})

Calculates a node's posterior precision for a VOPE coupling with multiple volatility children.
"""
function calculate_posterior_precision_vope(
    posterior_precision::AbstractFloat,
    self::AbstractNode,
    volatility_children::Vector{AbstractNode},
)
    for child in volatility_children
        posterior_precision += calculate_posterior_precision_vope_helper(
            self.auxiliary_prediction_precision,
            child.volatility_coupling[self.name],
            child.volatility_prediction_error,
        )
    end

    return posterior_precision
end

#Helper function to calculate the update term for posterior precision updates with volatility children
"""
    calculate_posterior_precision_vope_helper(
        auxiliary_prediction_precision::AbstractFloat,
        child_volatility_coupling::AbstractFloat,
        child_volatility_prediction_error::AbstractFloat)

Helper function which calculates the additive term for updating posterior precision in a VOPE coupling.
"""
function calculate_posterior_precision_vope_helper(
    auxiliary_prediction_precision::AbstractFloat,
    child_volatility_coupling::AbstractFloat,
    child_volatility_prediction_error::AbstractFloat,
)

    update_term =
        1 / 2 * (child_volatility_coupling * auxiliary_prediction_precision)^2 +
        child_volatility_prediction_error *
        (child_volatility_coupling * auxiliary_prediction_precision)^2 -
        1 / 2 *
        child_volatility_coupling^2 *
        auxiliary_prediction_precision *
        child_volatility_prediction_error

    return update_term
end


### Mean update ###
#Umbrella function for updating posterior mean
"""
    calculate_posterior_mean(self::AbstractNode, value_children, volatility_children)

Calculates a node's posterior mean.
"""
function calculate_posterior_mean(self::AbstractNode, value_children, volatility_children)

    #Set up
    posterior_mean = self.prediction_mean

    #Updates from value children
    posterior_mean = calculate_posterior_mean_vape(posterior_mean, self, value_children)

    #Updates from volatility children
    posterior_mean =
        calculate_posterior_mean_vope(posterior_mean, self, volatility_children)

    return posterior_mean
end

#Updating posterior mean without value children
"""
    calculate_posterior_mean_vape(
        posterior_mean::AbstractFloat,
        self::AbstractNode,
        value_child::Bool)

Calculates a node's posterior mean for a VAPE coupling without a value child.
"""
function calculate_posterior_mean_vape(
    posterior_mean::AbstractFloat,
    self::AbstractNode,
    value_child::Bool,
)
    posterior_mean
end

#Updating posterior mean with a single value child
"""
    calculate_posterior_mean_vape(
        posterior_mean::AbstractFloat,
        self::AbstractNode,
        value_child::AbstractNode)

Calculates a node's posterior mean for a VAPE coupling with a single value child.
"""
function calculate_posterior_mean_vape(
    posterior_mean::AbstractFloat,
    self::AbstractNode,
    value_child::AbstractNode,
)

    posterior_mean +
    (value_child.value_coupling[self.name] * value_child.prediction_precision) /
    self.posterior_precision * value_child.value_prediction_error
end

#Updating posterior mean with multiple value children
"""
    calculate_posterior_mean_vape(
        posterior_mean::AbstractFloat,
        self::AbstractNode,
        value_children::Vector{AbstractNode})

Calculates a node's posterior mean for a VAPE coupling with multiple value children.
"""
function calculate_posterior_mean_vape(
    posterior_mean::AbstractFloat,
    self::AbstractNode,
    value_children::Vector{AbstractNode},
)

    for child in value_children
        posterior_mean +=
            (child.value_coupling[self.name] * child.prediction_precision) /
            self.posterior_precision * child.value_prediction_error
    end

    return posterior_mean
end

#Updating posterior mean without volatility children
"""
    calculate_posterior_mean_vope(
        posterior_mean::AbstractFloat,
        self::AbstractNode,
        volatility_child::Bool)

Calculates a node's posterior mean for a VOPE coupling without a volatility child.
"""
function calculate_posterior_mean_vope(
    posterior_mean::AbstractFloat,
    self::AbstractNode,
    volatility_child::Bool,
)
    posterior_mean
end

#Updating posterior mean with a single volatility child
"""
    calculate_posterior_mean_vope(
        posterior_mean::AbstractFloat,
        self::AbstractNode,
        volatility_child::AbstractNode)

Calculates a node's posterior mean for a VOPE coupling with a single volatility child.
"""
function calculate_posterior_mean_vope(
    posterior_mean::AbstractFloat,
    self::AbstractNode,
    volatility_child::AbstractNode,
)
    posterior_mean +
    1 / 2 * (
        volatility_child.volatility_coupling[self.name] *
        self.auxiliary_prediction_precision
    ) / self.posterior_precision * volatility_child.volatility_prediction_error
end

#Updating posterior mean with multiple volatility children
"""
    calculate_posterior_mean_vope(
        posterior_mean::AbstractFloat,
        self::AbstractNode,
        volatility_children::Vector{AbstractNode})

Calculates a node's posterior mean for a VOPE coupling with multiple volatility children.
"""
function calculate_posterior_mean_vope(
    posterior_mean::AbstractFloat,
    self::AbstractNode,
    volatility_children::Vector{AbstractNode},
)

    for child in volatility_children
        posterior_mean +=
            1 / 2 *
            (child.volatility_coupling[self.name] * self.auxiliary_prediction_precision) /
            self.posterior_precision * child.volatility_prediction_error
    end

    return posterior_mean
end



######## Prediction error update functions ########

#Get the value prediction error
"""
    calculate_value_prediction_error(self::AbstractNode)

Calculate's a node's value prediction error.
"""
function calculate_value_prediction_error(self::AbstractNode)
    self.posterior_mean - self.prediction_mean
end

#Get the volatility prediction error
"""
    calculate_volatility_prediction_error(self::AbstractNode)

Calculates a node's volatility prediction error.
"""
function calculate_volatility_prediction_error(self::AbstractNode)
    self.prediction_precision / self.posterior_precision +
    self.prediction_precision * self.value_prediction_error^2 - 1
end