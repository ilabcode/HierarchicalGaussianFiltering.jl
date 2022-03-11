########### Input node ###########
"""
    update_node(self::InputNode)

Full update function for an input node.
"""
function update_node(
    self::InputNode
)
    return self
end


########### Regular node ###########
"""
    update_node(self::StateNode)

Full update function for a single node. States, parents and children are contained within the node.
"""
function update_node(
    self::StateNode
)
    ### Updating prediction for current trial ###
    #Update prediction mean
    self.prediction_mean = calculate_prediction_mean(self, self.value_parents)
    push!(self.history.prediction_mean, self.prediction_mean)

    #Update prediction volatility
    self.prediction_volatility = calculate_prediction_volatility(self, self.volatility_parents)
    push!(self.history.prediction_volatility, self.prediction_volatility)

    #Update prediction precision
    self.prediction_precision = calculate_prediction_precision(self)
    push!(self.history.prediction_precision, self.prediction_precision)

    #Get auxiliary prediction precision, only if volatility_children exists
    if self.volatility_children != false
        self.auxiliary_prediction_precision = calculate_auxiliary_prediction_precision(self)
        push!(
            self.history.auxiliary_prediction_precision,
            self.auxiliary_prediction_precision,
        )
    end


    ### Update posterior estimate for current trial ###
    #Update posterior precision
    self.posterior_precision =
        calculate_posterior_precision(self, self.value_children, self.volatility_children)
    push!(self.history.posterior_precision, self.posterior_precision)

    #Update posterior mean
    self.posterior_mean =
        calculate_posterior_mean(self, self.value_children, self.volatility_children)
    push!(self.history.posterior_mean, self.posterior_mean)


    ### Update prediction error at current trial ###
    #Update value prediction error
    self.value_prediction_error = calculate_value_prediction_error(self)
    push!(self.history.value_prediction_error, self.value_prediction_error)

    #Update volatility prediction error, only if volatility_parents exists
    if self.volatility_parents != false
        self.volatility_prediction_error = calculate_volatility_prediction_error(self)
        push!(self.history.volatility_prediction_error, self.volatility_prediction_error)
    end

end
