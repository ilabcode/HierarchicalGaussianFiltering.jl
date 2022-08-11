### Functions for getting a single state
"""
"""
function get_states(agent::AgentStruct, state_name::String)
    #If the state is in the agent's states
    if state_name in keys(agent.state)
        #Extract it from the agent
        state = agent.state[state_name]
    #Otherwise
    else
        #Look in the substruct
        state = get_states(agent.substruct, state_name)
    end

    return state
end


function get_states(substruct::Any, State_name::String)
    throw(ArgumentError("The specified state $state_name does not exist in the agent or in the substructure"))

end


### Function for getting multiple states ###
"""
"""
function get_states(agent::AgentStruct, state_names::Array{String})

    #Initialize tuple for populating with states
    state_list = (;)

    #Go through each state name
    for state_name in state_names
        #Add its value to the list
        state_list = merge(state_list,(Symbol(state_name) => get_states(agent,state_name),))
    end

    return state_list
end

### Function for getting all of an agent's states
"""
"""
function get_states(agent::AgentStruct)

    #Get all state names for the agent
    target_states = collect(keys(agent.state))

    #Get the agent's states 
    agent_states = get_states(agent, target_states)

    #Get states from the substruct
    substruct_states = get_states(agent.substruct)

    #Merge into one list
    states = merge(substruct_states, agent_states)

    return states
end

"""
"""
function get_states(substruct::Any)
    return (;)
end

