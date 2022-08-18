"""
    get_prediction(hgf::HGFStruct, node_name::String)

Gets the full prediction for the next timestep for a specified node in an HGF.
"""
function get_prediction(hgf::HGFStruct, node_name::String = "x1")
    #Get the prediction of the given node
    return get_prediction(hgf.all_nodes[node_name])
end


"""
    get_prediction(node::AbstractNode)

Gets the full prediction for the next timestep for a single node.
"""
function get_prediction(node::AbstractNode)

    #Save old states
    old_states = (;
        prediction_mean = node.states.prediction_mean,
        prediction_volatility = node.states.prediction_volatility,
        prediction_precision = node.states.prediction_precision,
    )

    #Update prediction mean
    node.states.prediction_mean = calculate_prediction_mean(node, node.value_parents)

    #Update prediction volatility
    node.states.prediction_volatility =
        calculate_prediction_volatility(node, node.volatility_parents)

    #Update prediction precision
    node.states.prediction_precision = calculate_prediction_precision(node)

    #Save new states
    new_states = (;
        prediction_mean = node.states.prediction_mean,
        prediction_volatility = node.states.prediction_volatility,
        prediction_precision = node.states.prediction_precision,
    )

    #Change states back to the old states
    node.states.prediction_mean = old_states.prediction_mean
    node.states.prediction_volatility = old_states.prediction_volatility
    node.states.prediction_precision = old_states.prediction_precision

    return new_states
end