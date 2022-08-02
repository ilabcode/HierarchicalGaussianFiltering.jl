"""
"""
function get_states(agent::AgentStruct)
    hgf = agent.perception_struct
    state_list =  merge(get_states(agent, collect(keys(agent.state))),get_states(hgf))
    return state_list
end

"""
"""
function get_states(agent::AgentStruct, state_names::Array{String})
    state_list = (;)
    for state_name in state_names
        state_list = merge(state_list,(Symbol(state_name) => get_states(agent,state_name),))
    end
    return state_list
end

"""
"""
function get_states(agent::AgentStruct, state_name::String)
    if state_name in keys(agent.state)
        state =  get_states(agent.state,state_name)
    else
        hgf = agent.perception_struct
        state = get_states(hgf, state_name)
    end
    return state
end