########### Full update function ###########
### Input node ###
function update_node(
    self::InputNode,
    value_parents,
    volatility_parents,
    value_children,
    volatility_children,
)
    return self
end


### Regular node ###
function update_node(
    self::Node,
    value_parents,
    volatility_parents,
    value_children,
    volatility_children,
)
    ### Updating prediction for current trial ###
    #Update prediction mean
    self.prediction_mean = calculate_prediction_mean(self, value_parents)
    push!(self.history.prediction_mean, self.prediction_mean)

    #Update prediction volatility
    self.prediction_volatility = calculate_prediction_volatility(self, volatility_parents)
    push!(self.history.prediction_volatility, self.prediction_volatility)

    #Update prediction precision
    self.prediction_precision = calculate_prediction_precision(self)
    push!(self.history.prediction_precision, self.prediction_precision)

    #Get auxiliary prediction precision, only if volatility_children exists
    if volatility_children != false
        self.auxiliary_prediction_precision = calculate_auxiliary_prediction_precision(self)
        push!(
            self.history.auxiliary_prediction_precision,
            self.auxiliary_prediction_precision,
        )
    end


    ### Update posterior estimate for current trial ###
    #Update posterior precision
    self.posterior_precision =
        calculate_posterior_precision(self, value_children, volatility_children)
    push!(self.history.prediction_posterior_precision, self.posterior_precision)

    #Update posterior mean
    self.posterior_mean =
        calculate_posterior_mean(self, value_children, volatility_children)
    push!(self.history.posterior_mean, self.posterior_mean)


    ### Update prediction error at current trial ###
    #Update value prediction error
    self.value_prediction_error = calculate_value_prediction_error(self)
    push!(self.history.value_prediction_error, self.value_prediction_error)

    #Update volatility prediction error, only if volatility_parents exists
    if volatility_parents != false
        self.volatility_prediction_error = calculate_volatility_prediction_error(self)
        push!(self.history.volatility_prediction_error, self.volatility_prediction_error)
    end

end



######## Prediction update functions ########

### Mean update ###
#Calculate prediction mean without parents
function calculate_prediction_mean(self::Node, value_parents::Bool)

    self.posterior_mean
end

#Calculate prediction mean with single parent
function calculate_prediction_mean(self::Node, value_parents::Node)

    self.posterior_mean + value_parents.posterior_mean * self.value_coupling
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
function calculate_prediction_volatility(self::Node, volatility_parents::Bool)

    exp(self.evolution_rate)

end

#Calculate prediction volatility with a singl value parent
function calculate_prediction_volatility(self::Node, volatility_parents::Node)

    exp(self.evolution_rate + volatility_parents.posterior_mean * self.volatility_coupling)
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
        calculate_posterior_precision_value(posterior_precision, self, value_children)

    #Updates from volatility children
    posterior_precision = calculate_posterior_precision_volatility(
        posterior_precision,
        self,
        volatility_children,
    )

    return posterior_precision
end

#Updating posterior precision without value children
function calculate_posterior_precision_value(
    posterior_precision,
    self::Node,
    value_children::Bool,
)
    posterior_precision
end

#Updating posterior precision with a single value child
function calculate_posterior_precision_value(
    posterior_precision,
    self::Node,
    value_children::Node,
)
    posterior_precision +
    value_children.value_coupling * value_children.prediction_precision
end

#Updating posterior precision with multiple value children
function calculate_posterior_precision_value(
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
function calculate_posterior_precision_volatility(
    posterior_precision,
    self::Node,
    volatility_children::Bool,
)
    posterior_precision
end

#Updating posterior precision with a single volatility child
function calculate_posterior_precision_volatility(
    posterior_precision,
    self::Node,
    volatility_children::Node,
)
    posterior_precision + calculate_posterior_precision_volatility_update(
        auxiliary_prediction_precision = self.auxiliary_prediction_precision,
        child_volatility_coupling = volatility_children.volatility_coupling,
        child_volatility_prediction_error = volatility_children.volatility_prediction_error,
    )
end

#Updating posterior precision with multiple volatility children
function calculate_posterior_precision_volatility(
    posterior_precision,
    self::Node,
    volatility_children::Vector{Node},
)
    for child in volatility_children
        posterior_precision += calculate_posterior_precision_volatility_update(
            auxiliary_prediction_precision = self.auxiliary_prediction_precision,
            child_volatility_coupling = child.volatility_coupling,
            child_volatility_prediction_error = child.volatility_prediction_error,
        )
    end
end

#Helper function to calculate the update term for posterior precision updates with volatility children
function calculate_posterior_precision_volatility_update(
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
    posterior_mean = calculate_posterior_mean_value(posterior_mean, self, value_children)

    #Updates from volatility children
    posterior_mean =
        calculate_mean_precision_volatility(posterior_mean, self, volatility_children)

    return posterior_mean
end

#Updating posterior mean without value children
function calculate_posterior_mean_value(posterior_mean, self::Node, value_children::Bool)
    posterior_mean
end

#Updating posterior mean with a single value child
function calculate_posterior_mean_value(posterior_mean, self::Node, value_children::Node)

    posterior_mean +
    (value_children.value_coupling * value_children.prediction_precision) /
    self.posterior_precision * value_children.value_prediction_error
end

#Updating posterior mean with multiple value children
function calculate_posterior_mean_value(
    posterior_mean,
    self::Node,
    value_children::Vector{Node},
)

    for child in value_children
        posterior_mean +=
            (child.value_coupling * child.prediction_precision) / self.posterior_precision *
            child.value_prediction_error
    end

    return posterior_mean
end

#Updating posterior mean without volatility children
function calculate_posterior_mean_volatility(
    posterior_mean,
    self::Node,
    volatility_children::Bool,
)
    posterior_mean
end

#Updating posterior mean with a single volatility child
function calculate_posterior_mean_volatility(
    posterior_mean,
    self::Node,
    volatility_children::Node,
)
    posterior_mean +
    1 / 2 *
    (volatility_children.volatility_coupling * self.auxiliary_prediction_precision) /
    self.posterior_precision * volatility_children.volatility_prediction_error
end

#Updating posterior mean with multiple volatility children
function calculate_posterior_mean_volatility(
    posterior_mean,
    self::Node,
    volatility_children::Vector{Node},
)

    for child in volatility_children
        posterior_mean +=
            1 / 2 * (child.volatility_coupling * self.auxiliary_prediction_precision) /
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