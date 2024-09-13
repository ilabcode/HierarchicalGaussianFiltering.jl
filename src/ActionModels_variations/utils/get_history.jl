"""
    get_history(hgf::HGF, target_state::Tuple{String,String})

Gets the history of a state from a specific node in an HGF. A vector of states can also be passed.

    get_history(hgf::HGF, node_name::String)

Gets the history of all states for a specific node in an HGF. If only a node object is passed, it will return the history of all states in that node. If only an HGF object is passed, it will return the history of all states in all nodes in the HGF.
"""
# function ActionModels.get_history() end

### For getting histories of specific states ###
function ActionModels.get_history(hgf::HGF, target_state::Tuple{String,String})

    #Unpack node name and state name
    (node_name, state_name) = target_state

    #If the node does not exist
    if !(node_name in keys(hgf.all_nodes))
        #Throw an error
        throw(ArgumentError("The node $node_name does not exist"))
    end

    #Get out the node
    node = hgf.all_nodes[node_name]

    #If the state does not exist in the node
    if !(Symbol(state_name) in fieldnames(typeof(node.history)))
        #throw an error
        throw(
            ArgumentError(
                "The node $node_name does not have the state $state_name in its history",
            ),
        )
    end

    #Return the history of that state the history of that node
    state_history = getproperty(node.history, Symbol(state_name))

    return state_history
end

function ActionModels.get_history(hgf::HGF, target_states::Vector)
    #Initialize tuple for storing state histories
    state_histories = Dict()

    #Go through each state
    for target_state in target_states

        #If a specific state history has been requested
        if target_state isa Tuple

            #Get the history of that state and add it to the dict
            state_histories[target_state] = get_history(hgf, target_state)

            #If all histories are requested
        elseif target_state isa String

            #Get out the histories of the node
            node_histories = get_history(hgf, target_state)
            #And merge them with the dict
            merge(state_histories, node_histories)
        end
    end

    return state_histories
end


### For getting histories from all states ###
function ActionModels.get_history(hgf::HGF, node_name::String)

    #If the node does not exist
    if !(node_name in keys(hgf.all_nodes))
        #Throw an error
        throw(ArgumentError("The node $node_name does not exist"))
    end

    #Get out the node
    node = hgf.all_nodes[node_name]

    #Get its histories
    return get_history(node)
end

function ActionModels.get_history(node::AbstractNode)

    #Get the node's name and history
    node_name = node.name
    node_history = node.history

    #Return a dictionary of the node's history
    Dict((node_name,string(key))=>getfield(node_history, key) for key ∈ fieldnames(typeof(node_history)))

end

function ActionModels.get_history(hgf::HGF)

    #Get the histories of all nodes
    merge(
        [get_history(node) for node in hgf.ordered_nodes.all_nodes]...
        )

end
