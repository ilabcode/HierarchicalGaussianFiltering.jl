#######################################
######## Continuous State Node ########
#######################################
"""
    update_node_prediction!(self::ContinuousStateNode)

Function for updating the prediction for a single state node
"""
function update_node_prediction!(self::AbstractStateNode)

    #Update prediction mean
    self.states.prediction_mean = calculate_prediction_mean(self)
    push!(self.history.prediction_mean, self.states.prediction_mean)

    #Update prediction volatility
    self.states.prediction_volatility = calculate_prediction_volatility(self)
    push!(self.history.prediction_volatility, self.states.prediction_volatility)

    #Update prediction precision
    self.states.prediction_precision = calculate_prediction_precision(self)
    push!(self.history.prediction_precision, self.states.prediction_precision)

    #Get auxiliary prediction precision, only if there are volatility children and/or volatility parents
    if length(self.volatility_parents) > 0 || length(self.volatility_children) > 0
        self.states.auxiliary_prediction_precision =
            calculate_auxiliary_prediction_precision(self)
        push!(
            self.history.auxiliary_prediction_precision,
            self.states.auxiliary_prediction_precision,
        )
    end

    return nothing
end

"""
    update_node_posterior!(self::ContinuousStateNode)

Function for updating the posterior of a single state node
"""
function update_node_posterior!(self::AbstractStateNode)
    #Update posterior precision
    self.states.posterior_precision = calculate_posterior_precision(self)
    push!(self.history.posterior_precision, self.states.posterior_precision)

    #If the posterior precision is negative
    if self.states.posterior_precision < 0
        #Throw an error
        throw(
            #Of the custom type where samples are rejected
            RejectParameters(
                "With these parameters and inputs, the posterior precision of node $(self.name) becomes negative after $(length(self.history.posterior_precision)) inputs"))
    end

    #Update posterior mean
    self.states.posterior_mean = calculate_posterior_mean(self)
    push!(self.history.posterior_mean, self.states.posterior_mean)

    return nothing
end

"""
Function for updating the value prediction error of a single state node
"""
function update_node_value_prediction_error!(self::AbstractStateNode)
    #Update value prediction error
    self.states.value_prediction_error = calculate_value_prediction_error(self)
    push!(self.history.value_prediction_error, self.states.value_prediction_error)

    return nothing
end

"""
Function for updating the volatility prediction error of a single state node
"""
function update_node_volatility_prediction_error!(self::AbstractStateNode)

    #Update volatility prediction error, only if there are volatility parents
    if length(self.volatility_parents) > 0
        self.states.volatility_prediction_error =
            calculate_volatility_prediction_error(self)
        push!(
            self.history.volatility_prediction_error,
            self.states.volatility_prediction_error,
        )
    end

    return nothing
end



##############################################
######## Binary State Node Variations ########
##############################################

"""
    update_node_prediction!(self::BinaryStateNode)

Function for updating the prediction for a single Binary state node
"""
function update_node_prediction!(self::BinaryStateNode)

    #Update prediction mean
    self.states.prediction_mean = calculate_prediction_mean(self)
    push!(self.history.prediction_mean, self.states.prediction_mean)

    #Update prediction precision
    self.states.prediction_precision = calculate_prediction_precision(self)
    push!(self.history.prediction_precision, self.states.prediction_precision)

    return nothing
end



###################################################
######## Conntinuous Input Node Variations ########
###################################################
"""
    update_node_input!(self::ContinuousInputNode, input::Real)

Function for updating the input for a single input node
"""
function update_node_input!(self::AbstractInputNode, input::Real)
    #Receive input
    self.states.input_value = input
    push!(self.history.input_value, self.states.input_value)

    return nothing
end

"""
    update_node_prediction!(self::ContinuousInputNode)

Function for updating the posterior of a single input node
"""
function update_node_prediction!(self::AbstractInputNode)
    #Update prediction volatility
    self.states.prediction_volatility = calculate_prediction_volatility(self)
    push!(self.history.prediction_volatility, self.states.prediction_volatility)

    #Update prediction precision
    self.states.prediction_precision = calculate_prediction_precision(self)
    push!(self.history.prediction_precision, self.states.prediction_precision)

    return nothing
end


"""
    update_node_value_prediction_error!(self::ContinuousInputNode)

Function for updating the value prediction error of a single input node
"""
function update_node_value_prediction_error!(self::AbstractInputNode)

    #Calculate value prediction error
    self.states.value_prediction_error = calculate_value_prediction_error(self)
    push!(self.history.value_prediction_error, self.states.value_prediction_error)

    return nothing
end

"""
    update_node_volatility_prediction_error!(self::ContinuousInputNode)

Function for updating the volatility prediction error of a single input node
"""
function update_node_volatility_prediction_error!(self::AbstractInputNode)

    #Calculate volatility prediction error, only if there are volatility parents
    if length(self.volatility_parents) > 0
        self.states.volatility_prediction_error =
            calculate_volatility_prediction_error(self)
        push!(
            self.history.volatility_prediction_error,
            self.states.volatility_prediction_error,
        )
    end

    return nothing
end


##############################################
######## Binary Input Node Variations ########
##############################################

"""
    update_node_prediction!(self::BinaryInputNode)

The prediction precision is constant for binary input nodes, so nothing is done here.
"""
function update_node_prediction!(self::BinaryInputNode)
    return nothing
end


"""
    update_node_value_prediction_error!(self::BinaryInputNode)

Function for updating the value prediction error of a single input node. 
"""
function update_node_value_prediction_error!(self::BinaryInputNode)

    #Calculate value prediction error
    self.states.value_prediction_error = calculate_value_prediction_error(self)
    push!(self.history.value_prediction_error, self.states.value_prediction_error)

    return nothing
end


"""
    update_node_volatility_prediction_error!(self::BinaryInputNode)

There is no volatility prediction error for binary input nodes.
"""
function update_node_volatility_prediction_error!(self::BinaryInputNode)
    return nothing
end