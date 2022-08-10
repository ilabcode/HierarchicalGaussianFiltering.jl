"""
"""
function reset!(agent::AgentStruct) #need to document ckealry the use of reset!
    
    #For each of the agent's states
    for state in keys(agent.state)
        #Set it to the first value in the history
        agent.state[state] = agent.history[state] 
    end

    #For each state in the history
    for state in keys(agent.history)
        #Reset the history to the new state
        agent.history[state] = [agent.state[state]]
    end

    #Reset the agents substruct
    reset!(agent.substruct)
end

"""
"""
function reset!(substruct::Any)
    return nothing
end