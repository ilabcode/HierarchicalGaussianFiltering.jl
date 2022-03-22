"""
    function premade_HGF(
        model_name,
        params,
        starting_state,
    )

Function for initializing the structure of an HGF model.
"""
function premade_HGF(model_name::String, params_list, starting_state_list)
    #Return a list of models
    
    #Binary 2 level

    #The standard 2 level HGF
    if model_name == "Standard2level"
        standard_function_2level(params_list, starting_state_list)
    #The JGET HGF model
    elseif model_name == "Standard3level"
        standard_function_3level(params_list, starting_state_list)
    #Raise an error if the string doesn't match any model
    else
        return "error"
    end
end


"""
    standard_function_2level(params_list, starting_state_list)

The standard 2 level HGF. It has a continous input node U, with a single value parent x1, which in turn has a single volatility parent x2.
"""
function standard_function_2level(params_list, starting_state_list)
    input_nodes =
        [(name = "x_in1", params = (; evolution_rate = params_list.evolution_rate_in1))]
    state_nodes = [
        (
            name = "x_1",
            params = (; evolution_rate = params_list.evolution_rate_1),
            starting_state = starting_state_list.starting_state_1,
        ),
    ]
    child_parent_relations = [
        (
            child_node = "x_in1",
            value_parents = Dict("x_1" => params_list.coupling_1_in1),
            volatility_parents = Dict(),
        ),
    ]
    default_params = (
        params = (; evolution_rate = 3),
        starting_state = (; posterior_mean = 1, posterior_precision = 1),
    )
    Standard2levelHGF =
        HGF.init_HGF(default_params, input_nodes, state_nodes, child_parent_relations)
    return Standard2levelHGF
end


"""
    standard_function_3level(params_list, starting_state_list)

The JGET model.
"""
function standard_function_3level(params_list, starting_state_list)
    input_nodes =
        [(name = "x_in1", params = (; evolution_rate = params_list.evolution_rate_in1))]
    state_nodes = [
        (
            name = "x_1",
            params = (; evolution_rate = params_list.evolution_rate_1),
            starting_state = starting_state_list.starting_state_1,
        ),
        (
            name = "x_2",
            params = (; evolution_rate = params_list.evolution_rate_2),
            starting_state = starting_state_list.starting_state_2,
        ),
    ]
    child_parent_relations = [
        (
            child_node = "x_in1",
            value_parents = Dict("x_1" => params_list.coupling_1_in1),
            volatility_parents = Dict("x_2" => params_list.coupling_2_in1),
        ),
    ]
    default_params = (
        params = (; evolution_rate = 3),
        starting_state = (; posterior_mean = 1, posterior_precision = 1),
    )
    Standard3levelHGF =
        HGF.init_HGF(default_params, input_nodes, state_nodes, child_parent_relations)
    return Standard3levelHGF
end
