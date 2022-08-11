"""
"""
function get_history(hgf::HGFStruct, target_state::String)

    # Split state name to get node and state name
    (node_name, state_name) = split(target_state, "__", limit = 2)

    #Check that the node exists
    if node_name in keys(hgf.all_nodes)
        #Get the history of that node
        state_history = getproperty(hgf.all_nodes[node_name].history, Symbol(state_name))
    else
        #If it doesn't exist, throw an error
        error("The node " * node_name * " does not exist")
    end

    return state_history
end

"""
"""
function get_history(hgf::HGFStruct, target_states::Array{String})
    #Initialize tuple for storing state histories
    state_histories = (;)

    #Go through each state
    for state in target_states
        #Add its history to the tuple
        state_histories = merge(state_histories, (Symbol(state) => get_history(hgf, state),))
    end

    return state_histories
end

"""
"""
function get_history(hgf::HGFStruct)

    #Initialize list for target states
    target_states = String[]

    #Go through each node
    for node in hgf.ordered_nodes.all_nodes
        #Go through each state in the node's history
        for state_name in fieldnames(typeof(node.history))
            #Add the name to the list of target states
            push!(target_states, node.name * "__" * String(state_name))
        end
    end

    #Get the state histories
    state_histories = get_history(hgf, target_states)

    return state_histories
end
