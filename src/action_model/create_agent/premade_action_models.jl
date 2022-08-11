"""
"""
function multiple_actions(agent, input)

    #Extract vector of action models
    action_models = agent.settings["action_models"]

    #Initialize vector for action distributions
    action_distributions = []

    #Do each action model separately
    for action_model in action_models
        #And append them to the vector of action distributions
        push!(action_distributions, action_model(agent, input))
    end

    return action_distributions
end


"""
"""
function hgf_multiple_actions(agent, input)

    #Update the hgf
    hgf = agent.substruct
    hgf.perception_model(hgf, input)

    #Extract vector of action models
    action_models = agent.settings["action_models"]

    #Initialize vector for action distributions
    action_distributions = []

    #Do each action model separately
    for action_model in action_models
        #And append them to the vector of action distributions
        push!(action_distributions, action_model(agent, input, update_hgf = false))
    end

    return action_distributions
end


"""
    hgf_gaussian_action(agent, input)

Action model which reports a given HGF state with Gaussian noise.
"""
function hgf_gaussian_action(agent, input, update_hgf = true)

    #Get out settings and parameters
    target_node = agent.settings["target_node"]
    target_state = agent.settings["target_state"]
    action_precision = agent.params["gaussian_action_precision"]

    #Get out the HGF
    hgf = agent.substruct
    #Update the HGF
    if update_hgf
        hgf.perception_model(hgf, input)
    end

    #Get out the specified node
    node = hgf.all_nodes[target_node]

    ## Extract the specified state from the specified node ##
    #If the target state is the prediction mean
    if target_state == "prediction_mean"
        #Calculate the prediction mean
        target_value = calculate_prediction_mean(node, node.value_parents)
        #If the target state is another component of the prediction
    elseif target_state in [
        "prediction_volatility",
        "prediction_precision",
        "auxiliary_prediction_precision",
    ]
        #Calculate the new prediction
        prediction = get_prediction(node)
        #And get the specified state from it
        target_value = getproperty(prediction, Symbol(target_state))
        #For other states
    else
        #Simply get them from the node
        target_value = getproperty(node.state, Symbol(target_state))
    end

    #Create normal distribution with mean of the target value and a standard deviation from parameters
    distribution = Distributions.Normal(target_value, 1 / action_precision)

    #Return the action distribution
    return distribution
end


"""
    hgf_binary_softmax_action(agent, input)

Action model which gives a binary action. The action probability is the softmax of a specified state of a node.
"""
function hgf_binary_softmax_action(agent, input, update_hgf = true)

    #Get out settings and parameters
    target_node = agent.settings["target_node"]
    target_state = agent.settings["target_state"]
    action_precision = agent.params["softmax_action_precision"]

    #Get out the HGF
    hgf = agent.substruct

    #Update the HGF
    if update_hgf
        hgf.perception_model(hgf, input)
    end

    #Get out the specified node
    node = hgf.all_nodes[target_node]

    ## Extract the specified state from the specified node ##
    #If the target state is the prediction mean
    if target_state == "prediction_mean"
        #Calculate the prediction mean
        target_value = calculate_prediction_mean(node, node.value_parents)
        #If the target state is another component of the prediction
    elseif target_state in [
        "prediction_volatility",
        "prediction_precision",
        "auxiliary_prediction_precision",
    ]
        #Calculate the new prediction
        prediction = get_prediction(node)
        #And get the specified state from it
        target_value = getproperty(prediction, Symbol(target_state))
        #For other states
    else
        #Simply get them from the node
        target_value = getproperty(node.state, Symbol(target_state))
    end

    #Use sotmax to get the action probability 
    action_probability = 1 / (1 + exp(-action_precision * target_value))

    #Create Bernoulli normal distribution with mean of the target value and a standard deviation from parameters
    distribution = Distributions.Bernoulli(action_probability)

    #Return the action distribution
    return distribution
end


"""
    unit_square_sigmoid_action(agent, input)

Action model which gives a binary action. The action probability is the unit square sigmoid of a specified state of a node.
"""
function hgf_unit_square_sigmoid_action(agent, input, update_hgf = true)

    #Get out settings and parameters
    target_node = agent.settings["target_node"]
    target_state = agent.settings["target_state"]
    action_precision = agent.params["sigmoid_action_precision"]

    #Get out the HGF
    hgf = agent.substruct

    #Update the HGF
    if update_hgf
        hgf.perception_model(hgf, input)
    end

    #Get out the specified node
    node = hgf.all_nodes[target_node]

    ## Extract the specified state from the specified node ##
    #If the target state is the prediction mean
    if target_state == "prediction_mean"
        #Calculate the prediction mean
        target_value = calculate_prediction_mean(node, node.value_parents)
        #If the target state is another component of the prediction
    elseif target_state in [
        "prediction_volatility",
        "prediction_precision",
        "auxiliary_prediction_precision",
    ]
        #Calculate the new prediction
        prediction = get_prediction(node)
        #And get the specified state from it
        target_value = getproperty(prediction, Symbol(target_state))
        #For other states
    else
        #Simply get them from the node
        target_value = getproperty(node.state, Symbol(target_state))
    end

    #Use sotmax to get the action probability 
    action_probability =
        target_value^action_precision /
        (target_value^action_precision + (1 - target_value)^action_precision)

    #Create Bernoulli normal distribution with mean of the target value and a standard deviation from parameters
    distribution = Distributions.Bernoulli(action_probability)

    #Return the action distribution
    return distribution
end