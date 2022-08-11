"""
    premade_agent(model_name::String, hgf::HGFStruct, params_list::NamedTuple = (;))

Function for making a premade agent, where a HGF is passed as a separate argument.
"""
function premade_agent(model_name::String, hgf::HGFStruct, params_list::NamedTuple = (;))

    #Add the HGF to the params list
    params_list = merge(params_list, (; hgf = hgf))

    #Make the agent as usual
    return premade_agent(model_name, params_list)
end

"""
    function premade_agent(
        model_name::String, params_list::NamedTuple = (;)
    )

Function for making a premade agent.
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
    gaussian_action_precision::Real = 1,
    target_node::String = "x1",
    target_state::String = "posterior_mean",
)

    #Set the action model
    action_model = hgf_gaussian_action

    #Set parameters
    params = Dict("gaussian_action_precision" => gaussian_action_precision)
    #Set states
    states = Dict()
    #Set settings
    settings = Dict("target_node" => target_node, "target_state" => target_state)

    #Create the agent
    return HGF.init_agent(action_model, hgf, params, states, settings)
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
    softmax_action_precision::Real = 1,
    target_node::String = "x1",
    target_state::String = "prediction_mean",
)

    #Set the action model
    action_model = hgf_binary_softmax_action

    #Set parameters
    params = Dict("softmax_action_precision" => softmax_action_precision)
    #Set states
    states = Dict()
    #Set settings
    settings = Dict("target_node" => target_node, "target_state" => target_state)

    #Create the agent
    return HGF.init_agent(action_model, hgf, params, states, settings)
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
    sigmoid_action_precision::Real = 1,
    target_node::String = "x1",
    target_state::String = "prediction_mean",
)

    #Set the action model
    action_model = hgf_unit_square_sigmoid_action

    #Set parameters
    params = Dict("sigmoid_action_precision" => sigmoid_action_precision)
    #Set states
    states = Dict()
    #Set settings
    settings = Dict("target_node" => target_node, "target_state" => target_state)

    #Create the agent
    return HGF.init_agent(action_model, hgf, params, states, settings)
end