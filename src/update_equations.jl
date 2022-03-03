######## Prediction update functions ########

### Mean update ###
#Calculate prediction mean without parents
function calculate_prediction_mean(self::Node, value_parent::Bool)

    self.posterior_mean
end

#Calculate prediction mean with single parent
function calculate_prediction_mean(self::Node, value_parent::Node)

    self.posterior_mean + value_parent.posterior_mean * self.value_coupling[value_parent.name]
end

#Calculate prediction mean with multiple parents
function calculate_prediction_mean(self::Node, value_parents::Vector{Node})

    #Set up prediction mean
    prediction_mean = self.posterior_mean

    #Add weighted parent posteriors
    for parent in value_parents
        prediction_mean += parent.posterior_mean * self.value_coupling[parent.name]
    end

    return prediction_mean
end


### Volatility update ###
#Calculate prediction volatility without a value parent
function calculate_prediction_volatility(self::Node, volatility_parent::Bool)

    exp(self.evolution_rate)

end

#Calculate prediction volatility with a singl value parent
function calculate_prediction_volatility(self::Node, volatility_parent::Node)

    exp(self.evolution_rate + volatility_parent.posterior_mean * self.volatility_coupling[volatility_parent.name])
end

#Calculate prediction volatility with a singl value parent
function calculate_prediction_volatility(self::Node, volatility_parents::Vector{Node})

    prediction_volatility = self.evolution_rate

    for parent in volatility_parents
        prediction_volatility +=
            parent.posterior_mean * self.volatility_coupling[parent.name]
    end

    return exp(prediction_volatility)
end


### Precision update ###
#Calculate prediction precision
function calculate_prediction_precision(self)
    1 / (1 / self.posterior_precision + self.prediction_volatility)
end

#Calculate auxiliary prediction precision
function calculate_auxiliary_prediction_precision(self)
    self.prediction_volatility * self.prediction_precision
end



######## Posterior update functions ########

### Precision update ###
#Umbrella function for updating posterior precision
function calculate_posterior_precision(self, value_children, volatility_children)

    #Set up
    posterior_precision = self.prediction_precision

    #Updates from value children
    posterior_precision =
        calculate_posterior_precision_vape(posterior_precision, self, value_children)

    #Updates from volatility children
    posterior_precision = calculate_posterior_precision_vope(
        posterior_precision,
        self,
        volatility_children,
    )

    return posterior_precision
end

#Updating posterior precision without value children
function calculate_posterior_precision_vape(
    posterior_precision,
    self::Node,
    value_child::Bool,
)
    posterior_precision
end

#Updating posterior precision with a single value child
function calculate_posterior_precision_vape(
    posterior_precision,
    self::Node,
    value_child::Node,
)
    posterior_precision +
    value_child.value_coupling[self.name] * value_child.prediction_precision
end

#Updating posterior precision with multiple value children
function calculate_posterior_precision_vape(
    posterior_precision,
    self::Node,
    value_children::Vector{Node},
)
    for child in value_children
        posterior_precision += child.value_coupling[self.name] * child.prediction_precision
    end

    return posterior_precision
end

#Updating posterior precision without volatility children
function calculate_posterior_precision_vope(
    posterior_precision,
    self::Node,
    volatility_child::Bool,
)
    posterior_precision
end

#Updating posterior precision with a single volatility child
function calculate_posterior_precision_vope(
    posterior_precision,
    self::Node,
    volatility_child::Node,
)
    posterior_precision + calculate_posterior_precision_vope_helper(
        self.auxiliary_prediction_precision,
        volatility_child.volatility_coupling[self.name],
        volatility_child.volatility_prediction_error,
    )
end

#Updating posterior precision with multiple volatility children
function calculate_posterior_precision_vope(
    posterior_precision,
    self::Node,
    volatility_children::Vector{Node},
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
function calculate_posterior_mean(self, value_children, volatility_children)

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
function calculate_posterior_mean_vape(posterior_mean, self::Node, value_child::Bool)
    posterior_mean
end

#Updating posterior mean with a single value child
function calculate_posterior_mean_vape(posterior_mean, self::Node, value_child::Node)

    posterior_mean +
    (value_child.value_coupling[self.name] * value_child.prediction_precision) /
    self.posterior_precision * value_child.value_prediction_error
end

#Updating posterior mean with multiple value children
function calculate_posterior_mean_vape(
    posterior_mean,
    self::Node,
    value_children::Vector{Node},
)

    for child in value_children
        posterior_mean +=
            (child.value_coupling[self.name] * child.prediction_precision) / self.posterior_precision *
            child.value_prediction_error
    end

    return posterior_mean
end

#Updating posterior mean without volatility children
function calculate_posterior_mean_vope(
    posterior_mean,
    self::Node,
    volatility_child::Bool,
)
    posterior_mean
end

#Updating posterior mean with a single volatility child
function calculate_posterior_mean_vope(
    posterior_mean,
    self::Node,
    volatility_child::Node,
)
    posterior_mean +
    1 / 2 *
    (volatility_child.volatility_coupling[self.name] * self.auxiliary_prediction_precision) /
    self.posterior_precision * volatility_child.volatility_prediction_error
end

#Updating posterior mean with multiple volatility children
function calculate_posterior_mean_vope(
    posterior_mean,
    self::Node,
    volatility_children::Vector{Node},
)

    for child in volatility_children
        posterior_mean +=
            1 / 2 * (child.volatility_coupling[self.name] * self.auxiliary_prediction_precision) /
            self.posterior_precision * child.volatility_prediction_error
    end

    return posterior_mean
end



######## Prediction error update functions ########

#Get the value prediction error
function calculate_value_prediction_error(self)
    self.posterior_mean - self.prediction_mean
end

#Get the volatility prediction error
function calculate_volatility_prediction_error(self)
    self.prediction_precision / self.posterior_precision +
    self.prediction_precision * self.value_prediction_error^2 - 1
end