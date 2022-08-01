"""
"""
function reset!(my_agent::AgentStruct)
    reset!(my_agent.perception_struct)
    for state in keys(my_agent.history)
        #Put it in the history
        my_agent.history[state] = []
    end
    for state in keys(my_agent.state)
         #Add it to the state field
         my_agent.state[state] = missing
    end
end

