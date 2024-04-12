"""
    get_prediction(hgf::HGF, node_name::String)

Get the prediction for the next timestep for a specified node in an HGF. If an agent is passed instead of an HGF, the HGF is extracted from the substruct in the agent.
A single node can also be passed.
"""
function get_prediction end

function get_prediction(agent::Agent, node_name::String, stepsize::Real = 1)

    #Get prediction from the HGF
    prediction = get_prediction(agent.substruct, node_name, stepsize)

    return prediction
end

function get_prediction(hgf::HGF, node_name::String, stepsize::Real = 1)
    #Get the prediction of the given node
    return get_prediction(hgf.all_nodes[node_name], stepsize)
end

### Single node functions ###
function get_prediction(node::ContinuousStateNode, stepsize::Real = 1)

    #Save old states
    old_states = (;
        prediction_mean = node.states.prediction_mean,
        prediction_precision = node.states.prediction_precision,
        effective_prediction_precision = node.states.effective_prediction_precision,
    )

    #Update prediction mean
    node.states.prediction_mean = calculate_prediction_mean(node, stepsize)

    #Update prediction precision
    node.states.prediction_precision, node.states.effective_prediction_precision =
        calculate_prediction_precision(node, stepsize)

    #Save new states
    new_states = (;
        prediction_mean = node.states.prediction_mean,
        prediction_precision = node.states.prediction_precision,
        effective_prediction_precision = node.states.effective_prediction_precision,
    )

    #Change states back to the old states
    node.states.prediction_mean = old_states.prediction_mean
    node.states.prediction_precision = old_states.prediction_precision
    node.states.effective_prediction_precision = old_states.effective_prediction_precision

    return new_states
end

function get_prediction(node::BinaryStateNode, stepsize::Real = 1)

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

function get_prediction(node::CategoricalStateNode, stepsize::Real = 1)

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


function get_prediction(node::ContinuousInputNode, stepsize::Real = 1)

    #Save old states
    old_states = (;
        prediction_mean = node.states.prediction_mean,
        prediction_precision = node.states.prediction_precision,
    )

    #Update prediction precision
    node.states.prediction_mean = calculate_prediction_mean(node)
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

function get_prediction(node::BinaryInputNode, stepsize::Real = 1)

    #Binary input nodes have no prediction states
    new_states = (;)

    return new_states
end

function get_prediction(node::CategoricalInputNode, stepsize::Real = 1)

    #Binary input nodes have no prediction states
    new_states = (;)

    return new_states
end
