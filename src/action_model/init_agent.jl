function init_agent(
    action_model::Function,
    perception_struct,
    params,
    states,
)

    #Create action model struct
    action_struct = HGF.AgentStruct(
        action_model = action_model,
        perception_struct = perception_struct
    )

    #For each specified parameter
    for param in params
        #Add it and its value to the parameter field
        action_struct.params[param[1]] = param[2]
    end

    #For each specified state
    for state in states
        #Add it to the state field
        action_struct.state[state[1]] = state[2]
        #And put it in the history
        action_struct.history[state[1]] = [state[2]]
    end

    return action_struct
end