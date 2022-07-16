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
function premade_agent(model_name::String, params_list::NamedTuple = (;))

    #A list of all the included premade models
    premade_models = Dict(
        "hgf_gaussian_action" => premade_hgf_gaussian,                           #A gaussian action based on an hgf
        "hgf_binary_softmax_action" => premade_hgf_binary_softmax,               #A binary softmax action based on an hgf
        "hgf_unit_square_sigmoid_action" => premade_hgf_unit_square_sigmoid,     #A binary unit square sigmoid action based on an hgf
    )

    #Check that the specified model is in the list of keys
    if model_name in keys(premade_models)
        #Create the specified model
        return premade_models[model_name](; params_list...)

        #If the user asked for help
    elseif model_name == "help"
        #Return the list of keys
        print(keys(premade_models))
        return nothing

        #If the model was misspecified
    else
        #Raise an error
        throw(
            ArgumentError(
                "the specified string does not match any model. Type premade_agent('help') to see a list of valid input strings",
            ),
        )
    end
end



"""
    premade_hgf_gaussian(
        hgf = HGF.premade_hgf("continuous_2level"),
        action_precision = 1,
        target_node = "x1",
        target_state = "posterior_mean",
    )

Function that initializes as premade HGF gaussian action agent
"""
function premade_hgf_gaussian(;
    hgf::HGFStruct = HGF.premade_hgf("continuous_2level"),
    action_precision::Real = 1,
    target_node::String = "x1",
    target_state::String = "posterior_mean",
)

    #Set the action model
    action_model = hgf_gaussian_action

    #Set parameters
    params = Dict("action_precision"=>action_precision)
    #Set states
    states = Dict()
    #Set settings
    settings = Dict("target_node"=>target_node, "target_state"=>target_state)

    #Create the agent
    return HGF.init_agent(action_model, hgf, params, states, settings)
end


"""
    gaussian_action(agent, input)

Action model which reports a given HGF state with Gaussian noise.
"""
function hgf_gaussian_action(agent, input)

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
    premade_hgf_binary_softmax(
        hgf = HGF.premade_hgf("binary_3level"),
        action_precision = 1,
        target_node = "x1",
        target_state = "posterior_mean",
    )

Function that initializes as premade HGF binary softmax action agent
"""
function premade_hgf_binary_softmax(;
    hgf::HGFStruct = HGF.premade_hgf("binary_3level"),
    action_precision::Real = 1,
    target_node::String = "x1",
    target_state::String = "prediction_mean",
)

    #Set the action model
    action_model = hgf_binary_softmax_action

    #Set parameters
    params = Dict("action_precision"=>action_precision)
    #Set states
    states = Dict()
    #Set settings
    settings = Dict("target_node"=>target_node, "target_state"=>target_state)

    #Create the agent
    return HGF.init_agent(action_model, hgf, params, states, settings)
end

"""
    hgf_binary_softmax_action(agent, input)

Action model which gives a binary action. The action probability is the softmax of a specified state of a node.
"""
function hgf_binary_softmax_action(agent, input)

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
    premade_hgf_unit_square_sigmoid(
        hgf = HGF.premade_hgf("binary_3level"),
        action_precision = 1,
        target_node = "x1",
        target_state = "posterior_mean",
    )

Function that initializes as premade HGF binary softmax action agent
"""
function premade_hgf_unit_square_sigmoid(;
    hgf::HGFStruct = HGF.premade_hgf("binary_3level"),
    action_precision::Real = 1,
    target_node::String = "x1",
    target_state::String = "prediction_mean",
)

    #Set the action model
    action_model = hgf_unit_square_sigmoid_action

    #Set parameters
    params = Dict("action_precision"=>action_precision)
    #Set states
    states = Dict()
    #Set settings
    settings = Dict("target_node"=>target_node, "target_state"=>target_state)

    #Create the agent
    return HGF.init_agent(action_model, hgf, params, states, settings)
end


"""
    unit_square_sigmoid_action(agent, input)

Action model which gives a binary action. The action probability is the unit square sigmoid of a specified state of a node.
"""
function hgf_unit_square_sigmoid_action(agent, input)

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