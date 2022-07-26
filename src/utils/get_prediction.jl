"""
    get_prediction(hgf::HGFStruct, node_name::String)

Gets the full prediction for the next timestep for a specified node in an HGF.
"""
function get_prediction(hgf::HGFStruct, node_name::String = "x1")
    
    #If the specified node is an input node 
    if node_name in keys(hgf.input_nodes)
        # get the prediction for that node
        return get_prediction(hgf.input_nodes[node_name])
    #Otherwise
    else   
        #Find it in the state nodes
        return get_prediction(hgf.state_nodes[node_name])
    end
end


"""
    get_prediction(node::AbstractNode)

Gets the full prediction for the next timestep for a single node.
"""
function get_prediction(node::AbstractNode)

    #Save old states
    old_states = (;
        prediction_mean = node.state.prediction_mean,
        prediction_volatility = node.state.prediction_volatility,
        prediction_precision = node.state.prediction_precision,
    )

    #Update prediction mean
    node.state.prediction_mean = calculate_prediction_mean(node, node.value_parents)

    #Update prediction volatility
    node.state.prediction_volatility =
        calculate_prediction_volatility(node, node.volatility_parents)

    #Update prediction precision
    node.state.prediction_precision = calculate_prediction_precision(node)

    #Save new states
    new_states = (;
        prediction_mean = node.state.prediction_mean,
        prediction_volatility = node.state.prediction_volatility,
        prediction_precision = node.state.prediction_precision,
    )

    #Change states back to the old states
    node.state.prediction_mean = old_states.prediction_mean
    node.state.prediction_volatility = old_states.prediction_volatility
    node.state.prediction_precision = old_states.prediction_precision

    return new_states
end