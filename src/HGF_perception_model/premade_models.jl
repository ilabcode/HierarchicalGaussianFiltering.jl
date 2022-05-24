"""
    function premade_hgf(
        model_name,
        params,
        starting_state,
    )

Function for initializing the structure of an HGF model.
"""
function premade_hgf(model_name::String, params_list = (;), starting_state_list = (;))

    #A list of all the included premade models
    premade_models = Dict(
        "continuous_2level" => premade_continuous_2level,    #The standard continuous input 2 level HGF
        "binary_3level" => premade_binary_3level,            #The standard binary input 3 level HGF
        "JGET" => premade_continuous_3level,                 #The JGET model
    )

    #If the user asked for help
    if model_name == "help"
        #Return the list of keys
        print(keys(premade_models))
        return nothing
    end

    #Check that the specified model is in the list of keys
    if model_name in keys(premade_models)
        #Create the specified 
        return premade_models[model_name](; params_list..., starting_state_list...)
        #If an invalid name is given
    else
        #Raise an error
        throw(
            ArgumentError(
                "the specified string does not match any model. Type premade_hgf('help') to see a list of valid input strings",
            ),
        )
    end
end


"""
    standard_function_2level(params_list, starting_state_list)

The standard 2 level HGF. It has a continous input node U, with a single value parent x1, which in turn has a single volatility parent x2.
"""
function premade_continuous_2level(;
    u_evolution_rate = 0.0,
    x1_evolution_rate = -12.0,
    x2_evolution_rate = -2.0,
    x1_x2_coupling_strength = 1.0,
    x1_posterior_mean = 1.04,
    x1_posterior_precision = Inf,
    x2_posterior_mean = 1.0,
    x2_posterior_precision = Inf,
)

    #Parameter values to be used for all nodes unless other values are given
    default_params = (params = (;), starting_state = (;), coupling_strengths = (;))

    #List of input nodes to create
    input_nodes = [(name = "u", params = (; evolution_rate = u_evolution_rate))]

    #List of state nodes to create
    state_nodes = [
        (
            name = "x1",
            params = (; evolution_rate = x1_evolution_rate),
            starting_state = (;
                posterior_mean = x1_posterior_mean,
                posterior_precision = x1_posterior_precision,
            ),
        ),
        (
            name = "x2",
            params = (; evolution_rate = x2_evolution_rate),
            starting_state = (;
                posterior_mean = x2_posterior_mean,
                posterior_precision = x2_posterior_precision,
            ),
        ),
    ]

    #List of child-parent relations
    edges = [
        (
            child_node = "u",
            value_parents = [(name = "x1", coupling_strength = 1)],
            volatility_parents = Dict(),
        ),
        (
            child_node = "x1",
            value_parents = Dict(),
            volatility_parents = [(
                name = "x2",
                coupling_strength = x1_x2_coupling_strength,
            )],
        ),
    ]

    #Initialize the HGF
    HGF.init_hgf(default_params, input_nodes, state_nodes, edges, verbose = false)
end


"""
    premade_binary_3level(params_list, starting_state_list)

The standard binary 3 level HGF model
"""
function premade_binary_3level(params_list = (;), starting_state_list = (;))
    throw(ArgumentError("the specified model has not yet been implemented"))
end


"""
    premade_continuous_3level(params_list, starting_state_list)

The JGET model.
"""
function premade_continuous_3level(params_list = (;), starting_state_list = (;))
    throw(ArgumentError("the specified model has not yet been implemented"))
end


