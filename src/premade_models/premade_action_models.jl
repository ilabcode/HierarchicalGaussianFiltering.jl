"""
"""
function hgf_multiple_actions(agent, input)

    #Update the hgf
    hgf = agent.substruct
    update_hgf!(hgf, input)

    #Extract vector of action models
    action_models = agent.settings["action_models"]

    #Initialize vector for action distributions
    action_distributions = []

    #Do each action model separately
    for action_model in action_models
        #And append them to the vector of action distributions
        push!(action_distributions, action_model(agent, input; update_hgf = false))
    end

    return action_distributions
end


"""
    hgf_gaussian_action(agent, input)

Action model which reports a given HGF state with Gaussian noise.
"""
function hgf_gaussian_action(agent, input; update_hgf = true)

    #Get out settings and parameters
    target_node = agent.settings["target_node"]
    target_state = agent.settings["target_state"]
    action_precision = agent.params["gaussian_action_precision"]

    #Get out the HGF
    hgf = agent.substruct

    #Update the HGF
    if update_hgf
        update_hgf!(hgf, input)
    end

    #Get the specified state
    action_mean = get_states(hgf, (target_node, target_state))

    #If the gaussian mean becomes a NaN
    if isnan(action_mean)
        #Throw an error that will reject samples when fitted
        throw(
            ParamError(
                "With these parameters and inputs, the mean of the gaussian action became $action_mean, which is invalid. Try other parameter settings",
            ),
        )
    end

    #Create normal distribution with mean of the target value and a standard deviation from parameters
    distribution = Distributions.Normal(action_mean, 1 / action_precision)

    #Return the action distribution
    return distribution
end


"""
    hgf_binary_softmax_action(agent, input)

Action model which gives a binary action. The action probability is the softmax of a specified state of a node.
"""
function hgf_binary_softmax_action(agent, input; update_hgf = true)

    #Get out settings and parameters
    target_node = agent.settings["target_node"]
    target_state = agent.settings["target_state"]
    action_precision = agent.params["softmax_action_precision"]

    #Get out the HGF
    hgf = agent.substruct

    #Update the HGF
    if update_hgf
        update_hgf!(hgf, input)
    end

    #Get the specified state
    target_value = get_states(hgf, (target_node, target_state))

    #Use sotmax to get the action probability 
    action_probability = 1 / (1 + exp(-action_precision * target_value))

    #If the action probability is not between 0 and 1
    if !(0 <= action_probability <= 1)
        #Throw an error that will reject samples when fitted
        throw(
            ParamError(
                "With these parameters and inputs, the action probability became $action_probability, which should be between 0 and 1. Try other parameter settings",
            ),
        )
    end

    #Create Bernoulli normal distribution with mean of the target value and a standard deviation from parameters
    distribution = Distributions.Bernoulli(action_probability)

    #Return the action distribution
    return distribution
end


"""
    unit_square_sigmoid_action(agent, input)

Action model which gives a binary action. The action probability is the unit square sigmoid of a specified state of a node.
"""
function hgf_unit_square_sigmoid_action(agent, input; update_hgf = true)

    #Get out settings and parameters
    target_node = agent.settings["target_node"]
    target_state = agent.settings["target_state"]
    action_precision = agent.params["sigmoid_action_precision"]

    #Get out the HGF
    hgf = agent.substruct

    #Update the HGF
    if update_hgf
        update_hgf!(hgf, input)
    end

    #Get the specified state
    target_value = get_states(hgf, (target_node, target_state))

    #Use softmax to get the action probability 
    action_probability =
        target_value^action_precision /
        (target_value^action_precision + (1 - target_value)^action_precision)

    #If the action probability is not between 0 and 1
    if !(0 <= action_probability <= 1)
        #Throw an error that will reject samples when fitted
        throw(
            ParamError(
                "With these parameters and inputs, the action probability became $action_probability, which should be between 0 and 1. Try other parameter settings",
            ),
        )
    end

    #Create Bernoulli normal distribution with mean of the target value and a standard deviation from parameters
    distribution = Distributions.Bernoulli(action_probability)

    #Return the action distribution
    return distribution
end