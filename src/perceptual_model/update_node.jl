########### State node ###########
"""
    update_node_prediction(self::StateNode)

Function for updating the prediction for a single node
"""
function update_node_prediction(self::StateNode)

    #Update prediction mean
    self.state.prediction_mean = calculate_prediction_mean(self, self.value_parents)
    push!(self.history.prediction_mean, self.state.prediction_mean)

    #Update prediction volatility
    self.state.prediction_volatility =
        calculate_prediction_volatility(self, self.volatility_parents)
    push!(self.history.prediction_volatility, self.state.prediction_volatility)

    #Update prediction precision
    self.state.prediction_precision = calculate_prediction_precision(self)
    push!(self.history.prediction_precision, self.state.prediction_precision)

    #Get auxiliary prediction precision, only if there are volatility children and/or volatility parents
    if length(self.volatility_parents) > 0 || length(self.volatility_children) > 0
        self.state.auxiliary_prediction_precision =
            calculate_auxiliary_prediction_precision(self)
        push!(
            self.history.auxiliary_prediction_precision,
            self.state.auxiliary_prediction_precision,
        )
    end

    return nothing
end

"""
    update_node_posterior(self::StateNode)

Function for updating the posterior of a single node
"""
function update_node_posterior(self::StateNode)
    #Update posterior precision
    self.state.posterior_precision =
        calculate_posterior_precision(self, self.value_children, self.volatility_children)
    push!(self.history.posterior_precision, self.state.posterior_precision)

    #Update posterior mean
    self.state.posterior_mean =
        calculate_posterior_mean(self, self.value_children, self.volatility_children)
    push!(self.history.posterior_mean, self.state.posterior_mean)

    return nothing
end

"""
    update_node_prediction_error(self::StateNode)

Function for updating the prediction errors for a single node
"""
function update_node_prediction_error(self::StateNode)
    #Update value prediction error
    self.state.value_prediction_error = calculate_value_prediction_error(self)
    push!(self.history.value_prediction_error, self.state.value_prediction_error)

    #Update volatility prediction error, only if there are volatility parents
    if length(self.volatility_parents) > 0
        self.state.volatility_prediction_error = calculate_volatility_prediction_error(self)
        push!(
            self.history.volatility_prediction_error,
            self.state.volatility_prediction_error,
        )
    end

    return nothing
end


########### Input node ###########

function update_node_input(self::InputNode, input::AbstractFloat)
    #Receive input
    self.state.input_value = input
    push!(self.history.input_value, self.state.input_value)

    return nothing
end

function update_node_prediction(self::InputNode)
    #Update prediction volatility
    self.state.prediction_volatility =
        calculate_prediction_volatility(self, self.volatility_parents)
    push!(self.history.prediction_volatility, self.state.prediction_volatility)

    #Update prediction precision
    self.state.prediction_precision = calculate_prediction_precision(self)
    push!(self.history.prediction_precision, self.state.prediction_precision)

    return nothing
end


function update_node_prediction_error(self::InputNode)

    #Calculate value prediction error
    self.state.value_prediction_error =
        calculate_value_prediction_error(self, self.value_parents)
    push!(self.history.value_prediction_error, self.state.value_prediction_error)

    #Calculate volatility prediction error, only if there are volatility parents
    if length(self.volatility_parents) > 0
        self.state.volatility_prediction_error =
            calculate_volatility_prediction_error(self, self.value_parents)
        push!(
            self.history.volatility_prediction_error,
            self.state.volatility_prediction_error,
        )
    end

    return nothing
end