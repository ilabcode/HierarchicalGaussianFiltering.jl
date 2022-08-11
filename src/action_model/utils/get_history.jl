### Functions for getting a single state ###
"""
"""
function get_history(agent::AgentStruct, target_state::String)
    #If the state is in the agent's history
    if target_state in keys(agent.history)
        #Extract it
        state_history = agent.history[target_state]
    else
        #Otherwise look in the substruct
        state_history = get_history(agent.substruct, target_state) #should be an error if the substruct also gives nothing
    end

    return state_history
end

"""
"""
function get_history(substruct::Any, target_state::String)
    throw(
        ArgumentError(
            "The specified state $target_state does not exist in the agent's history, nor in the substructure",
        ),
    )
    return nothing
end


### Functions for getting multiple states ###

"""
"""
function get_history(agent::AgentStruct, target_states::Vector{String}) #make it just call the agent many times
    #Make empty tuple for populaitng with histories
    state_histories = (;)

    #Go through each state
    for state in target_states
        #Get them with get_history, and add to the tuple
        state_histories =
            merge(state_histories, (Symbol(state) => get_history(agent, state),))
    end

    return state_histories
end


### Function for getting all states ###
"""
"""
function get_history(agent::AgentStruct)
    #Make empty list for populating with target states
    target_states = String[]

    #Go throuh each state in the agent's history
    for state in keys(agent.history)
        #Add it to a list of states to get the history for
        push!(target_states, state)
    end

    #Get the agent's state histories
    state_histories = get_history(agent, target_states)

    #Get state histories from the substruct
    substruct_state_histories = get_history(agent.substruct)

    #Add them to the agent's states
    target_states = merge(substruct_state_histories, target_states)

    return state_histories
end

"""
"""
function get_history(substruct::Any)
    #For empty substructs, return an empty list
    return (;)
end
