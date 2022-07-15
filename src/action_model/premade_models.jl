"""
    function premade_agent(
        model_name::String,
        perception_model = (;),
        params = Dict(),
        states = Dict(),
        settings = (;),
    )

Function for initializing the structure of an agent model.
"""
function premade_agent(
    model_name::String,
    perception_model = (;),
    params = Dict(),
    states = Dict(),
    settings = Dict(),
)

    #A list of all the included premade models
    premade_models = Dict(
        "hgf_gaussian_action" => gaussian_action,                           #A gaussian action based on an hgf
        "hgf_binary_softmax_action" => binary_softmax_action,               #A binary softmax action based on an hgf
        "hgf_unit_square_sigmoid_action" => unit_square_sigmoid_action,   #A binary unit square sigmoid action based on an hgf
    )

    #If the user asked for help
    if model_name == "help"
        #Return the list of keys
        print(keys(premade_models))
        return nothing

        #If the specified model is not in the list of keys
    elseif model_name ∉ keys(premade_models)
        #Raise an error
        throw(
            ArgumentError(
                "the specified string does not match any model. Type premade_agent('help') to see a list of valid input strings",
            ),
        )

        #Otherwise
    else
        #Create an agent with the corresponding model
        agent = HGF.init_agent(
            premade_models[model_name],
            perception_model,
            params,
            states,
            settings,
        )

        #Return the agent
        return agent
    end
end



"""
    gaussian_action(agent, input)

Action model which reports a given HGF state with Gaussian noise.
"""
function gaussian_action(agent, input)

    #Get out settings
    target_node = agent.settings["target_node"]
    target_state = agent.settings["target_state"]
    #Get out parameters
    action_precision = agent.params["action_precision"]

    #Get out the HGF
    hgf = agent.perception_struct

    #Update the HGF
    hgf.perception_model(hgf, input)

    #Extract the specified state from the specified node
    target_state = getproperty(hgf.state_nodes[target_node].state, Symbol(target_state))

    #Create normal distribution with mean of the target value and a standard deviation from parameters
    distribution = Distributions.Normal(target_state, 1 / action_precision)

    #Return the action distribution
    return distribution
end


"""
    binary_softmax_action(agent, input)

Action model which gives a binary action. The action probability is the softmax of a specified state of a node.
"""
function binary_softmax_action(agent, input)

    #Get out settings
    target_node = agent.settings["target_node"]
    target_state = agent.settings["target_state"]
    #Get out parameters
    action_precision = agent.params["action_precision"]

    #Get out the HGF
    hgf = agent.perception_struct

    #Update the HGF
    hgf.perception_model(hgf, input)

    #Extract the specified state from the specified node
    target_state = getproperty(hgf.state_nodes[target_node].state, Symbol(target_state))

    #Use sotmax to get the action probability 
    action_probability = 1 / (1 + exp(-action_precision * target_state))

    #Create Bernoulli normal distribution with mean of the target value and a standard deviation from parameters
    distribution = Distributions.Bernoulli(action_probability)

    #Return the action distribution
    return distribution
end


"""
    unit_square_sigmoid_action(agent, input)

Action model which gives a binary action. The action probability is the unit square sigmoid of a specified state of a node.
"""
function unit_square_sigmoid_action(agent, input)

    #Get out settings
    target_node = agent.settings["target_node"]
    target_state = agent.settings["target_state"]
    #Get out parameters
    action_precision = agent.params["action_precision"]

    #Get out the HGF
    hgf = agent.perception_struct

    #Update the HGF
    hgf.perception_model(hgf, input)

    #Extract the specified state from the specified node
    target_state = getproperty(hgf.state_nodes[target_node].state, Symbol(target_state))

    #Use sotmax to get the action probability 
    action_probability =
        target_state^action_precision /
        (target_state^action_precision + (1 - target_state)^action_precision)

    #Create Bernoulli normal distribution with mean of the target value and a standard deviation from parameters
    distribution = Distributions.Bernoulli(action_probability)

    #Return the action distribution
    return distribution
end