
"""
"""
function init_agent(action_model::Function, perception_struct, params, states, settings)

    #Create action model struct
    agent =
        HGF.AgentStruct(action_model = action_model, perception_struct = perception_struct)

    #For each specified parameter
    for param in params
        #Add it and its value to the parameter field
        agent.params[param[1]] = param[2]
    end

    #For each specified state
    for state in states
        #Add it to the state field
        agent.state[state[1]] = state[2]
        #And put it in the history
        agent.history[state[1]] = [state[2]]
    end

    #For each specified setting
    for setting in settings
        #Add it to the settings field
        agent.settings[setting[1]] = setting[2]
    end

    return agent
end