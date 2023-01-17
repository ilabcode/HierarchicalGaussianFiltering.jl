"""
    get_prediction(hgf::HGF, node_name::String)

Get the prediction for the next timestep for a specified node in an HGF. If an agent is passed instead of an HGF, the HGF is extracted from the substruct in the agent.
A single node can also be passed.
"""
function get_prediction end

function get_prediction(agent::Agent, node_name::String = "x1")

    #Get prediction form the HGF
    prediction = get_prediction(agent.substruct, node_name)

    return prediction
end

function get_prediction(hgf::HGF, node_name::String = "x1")
    #Get the prediction of the given node
    return get_prediction(hgf.all_nodes[node_name])
end

### Single node functions ###
function get_prediction(node::AbstractNode)

    #Save old states
    old_states = (;
        prediction_mean = node.states.prediction_mean,
        prediction_volatility = node.states.prediction_volatility,
        prediction_precision = node.states.prediction_precision,
        auxiliary_prediction_precision = node.states.auxiliary_prediction_precision,
    )

    #Update prediction mean
    node.states.prediction_mean = calculate_prediction_mean(node)

    #Update prediction volatility
    node.states.prediction_volatility = calculate_prediction_volatility(node)

    #Update prediction precision
    node.states.prediction_precision = calculate_prediction_precision(node)

    node.states.auxiliary_prediction_precision =
        calculate_auxiliary_prediction_precision(node)

    #Save new states
    new_states = (;
        prediction_mean = node.states.prediction_mean,
        prediction_volatility = node.states.prediction_volatility,
        prediction_precision = node.states.prediction_precision,
        auxiliary_prediction_precision = node.states.auxiliary_prediction_precision,
    )

    #Change states back to the old states
    node.states.prediction_mean = old_states.prediction_mean
    node.states.prediction_volatility = old_states.prediction_volatility
    node.states.prediction_precision = old_states.prediction_precision
    node.states.auxiliary_prediction_precision = old_states.auxiliary_prediction_precision

    return new_states
end

function get_prediction(node::BinaryStateNode)

    #Save old states
    old_states = (;
        prediction_mean = node.states.prediction_mean,
        prediction_precision = node.states.prediction_precision,
    )

    #Update prediction mean
    node.states.prediction_mean = calculate_prediction_mean(node)

    #Update prediction precision
    node.states.prediction_precision = calculate_prediction_precision(node)

    #Save new states    
    new_states = (;
        prediction_mean = node.states.prediction_mean,
        prediction_precision = node.states.prediction_precision,
    )

    #Change states back to the old states
    node.states.prediction_mean = old_states.prediction_mean
    node.states.prediction_precision = old_states.prediction_precision

    return new_states
end

function get_prediction(node::CategoricalStateNode)

    #Save old states
    old_states = (; prediction = node.states.prediction)

    #Update prediction mean
    node.states.prediction = calculate_prediction(node)

    #Save new states
    new_states = (; prediction = node.states.prediction)

    #Change states back to the old states
    node.states.prediction = old_states.prediction

    return new_states
end


function get_prediction(node::AbstractInputNode)

    #Save old states
    old_states = (;
        prediction_volatility = node.states.prediction_volatility,
        prediction_precision = node.states.prediction_precision,
    )

    #Update prediction volatility
    node.states.prediction_volatility = calculate_prediction_volatility(node)

    #Update prediction precision
    node.states.prediction_precision = calculate_prediction_precision(node)

    #Save new states
    new_states = (;
        prediction_volatility = node.states.prediction_volatility,
        prediction_precision = node.states.prediction_precision,
        auxiliary_prediction_precision = 1.0,
    )

    #Change states back to the old states
    node.states.prediction_volatility = old_states.prediction_volatility
    node.states.prediction_precision = old_states.prediction_precision

    return new_states
end

function get_prediction(node::BinaryInputNode)

    #Binary input nodes have no prediction states
    new_states = (;)

    return new_states
end

function get_prediction(node::CategoricalInputNode)

    #Binary input nodes have no prediction states
    new_states = (;)

    return new_states
end
