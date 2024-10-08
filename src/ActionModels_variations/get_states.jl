"""
    get_states(hgf::HGF, target_state::Tuple{String,String})

Gets a single state value from a specific node in an HGF. A vector of states can also be passed.

    get_states(hgf::HGF, node_name::String)

Gets all parameter values for a specific node in an HGF. If only a node object is passed, returns all states in that node. If only an HGF object is passed, returns all states of all nodes in the HGF.
"""
# function ActionModels.get_states() end


### For getting a specific state from a specific node ###
function ActionModels.get_states(hgf::HGF, target_state::Tuple{String,String})

    #Unpack node name and state name
    (node_name, state_name) = target_state

    #If the node does not exist
    if !(node_name in keys(hgf.all_nodes))
        #Throw an error
        throw(ArgumentError("The node $node_name does not exist"))
    end

    #Get out the node
    node = hgf.all_nodes[node_name]

    #Return the states of that state the states of that node
    state = get_states(node, String(state_name))

    return state
end

function ActionModels.get_states(node::AbstractNode, state_name::String)

    #If the state does not exist in the node
    if !(Symbol(state_name) in fieldnames(typeof(node.states)))
        #throw an error
        throw(
            ArgumentError("The node $(node.node_name) does not have the state $state_name"),
        )
    end

    #If a prediction state has been specified
    if state_name in [
        "prediction",
        "prediction_mean",
        "prediction_precision",
        "effective_prediction_precision",
    ]
        #Get the new prediction
        prediction = get_prediction(node)
        #And get the specified state from it
        state = getproperty(prediction, Symbol(state_name))

    else

        #Get the state from the node
        state = getproperty(node.states, Symbol(state_name))

    end

    return state
end

### For getting multiple states ###
function ActionModels.get_states(hgf::HGF, target_states::Vector)
    #Initialize tuple for storing states
    states = Dict()

    #Go through each state
    for target_state in target_states

        #If a specific state states has been requested
        if target_state isa Tuple

            #Get the states of that state and add it to the dict
            states[target_state] = get_states(hgf, target_state)

            #If all states from the node are requested
        elseif target_state isa String

            #Get out the states of the node
            node_states = get_states(hgf, target_state)
            #And merge them with the dict
            merge(states, node_states)
        end
    end

    return states
end


### For getting all states of a specified node ###
function ActionModels.get_states(hgf::HGF, node_name::String)

    #If the node does not exist
    if !(node_name in keys(hgf.all_nodes))
        #Throw an error
        throw(ArgumentError("The node $node_name does not exist"))
    end

    #Get the states of the node
    node = get_states(hgf.all_nodes[node_name])
end

function ActionModels.get_states(node::AbstractNode)

    #Get the node's name and states
    node_name = node.name
    node_states = node.states

    #Return a dictionary of the node's states
    Dict((node_name,string(key))=>getfield(node_states, key) for key ∈ fieldnames(typeof(node_states)))

end

### For getting all states of an HGF ###
function ActionModels.get_states(hgf::HGF)

    #Get the states of all nodes
    merge(
        [get_states(node) for node in hgf.ordered_nodes.all_nodes]...
        )
        
end
