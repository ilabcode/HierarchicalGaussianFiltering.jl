"""
"""
function init_agent(action_model::Function, perception_struct, params, states, settings)

    #Create action model struct
    agent =
        HGF.AgentStruct(action_model = action_model, perception_struct = perception_struct)

    #If the action state has not been set manually
    if !("action" in keys(states))
        #Initialize the action state
        agent.state["action"] = missing
        agent.history["action"] = [missing]
    end

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


"""
"""
function init_agent(action_model::Vector{Function}, perception_struct, params, states, settings)

    #Create action model struct
    agent =
        HGF.AgentStruct(action_model = multiple_actions, perception_struct = perception_struct)

    #If a setting called action_models has been specified manually
    if "action_models" in keys(settings)
        #Throw an error
        throw(ArgumentError("Using a setting called 'action_models' with multiple action models is not supported"))
    else
        #Add vector of action models to settings
        agent.settings["action_models"] = action_model
    end

    #If the action state has not been set manually
    if !("action" in keys(states))
        #Initialize the action state
        agent.state["action"] = missing
        agent.history["action"] = [missing]
    end

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



"""
"""
function init_agent(action_model::Vector{Function}, perception_struct::HGFStruct, params, states, settings)

    #Create action model struct
    agent =
        HGF.AgentStruct(action_model = hgf_multiple_actions, perception_struct = perception_struct)

    #If a setting called action_models has been specified manually
    if "action_models" in keys(settings)
        #Throw an error
        throw(ArgumentError("Using a setting called 'action_models' with multiple action models is not supported"))
    else
        #Add vector of action models to settings
        agent.settings["action_models"] = action_model
    end

    #If the action state has not been set manually
    if !("action" in keys(states))
        #Initialize the action state
        agent.state["action"] = missing
        agent.history["action"] = [missing]
    end

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