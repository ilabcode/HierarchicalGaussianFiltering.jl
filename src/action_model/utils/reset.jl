"""
"""
function reset!(my_agent::AgentStruct) #need to document ckealry the use of reset!
    reset!(my_agent.substruct)
    for state in keys(my_agent.history)
        #Put it in the history
        my_agent.history[state] = []
    end
    for state in keys(my_agent.state)
        #Add it to the state field
        my_agent.state[state] = missing #start with original first value
    end
end

