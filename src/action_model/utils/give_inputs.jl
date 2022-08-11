"""
    single_input!(agent::AgentStruct, input)

Function for giving an input to an AgentStruct.
"""
function single_input!(agent::AgentStruct, input)

    ### Input data ###
    #Run the action model to get the action distribution
    action_distribution = agent.action_model(agent, input)

    #If a single action distribution is returned
    if length(action_distribution) == 1

        #Sample an action from the distribution
        agent.action = rand(action_distribution, 1)[1]

        #If multiple action distributiomns are returned
    else
        #Initialize vector for storing actions
        actions = []

        #For each action distribution
        for distribution in action_distribution
            #Sample an action and add it to the vector
            push!(actions, rand(distribution, 1)[1])
        end

        #And store it 
        agent.action = actions
    end

    #Record the action
    push!(agent.history["action"], agent.action)

    #Return the action
    return agent.action
end


"""
    give_inputs!(agent::AgentStruct, inputs::Vector)

Function for inputting multiple observations to an agent. Input is structured as an vector, with each value being an input.
"""
function give_inputs!(agent::AgentStruct, inputs::Vector)

    ### Input data ###
    #Take each row in the array
    for rownr = 1:size(inputs, 1)

        #Input that row
        single_input!(agent, inputs[rownr, :])

    end

    #Return the action trajectory
    return agent.history["action"]
end


"""
    give_inputs!(agent::AgentStruct, inputs::Real)

Convenience method for inputting multiple observations to an agent. Input is here just a single value.
"""
function give_inputs!(agent::AgentStruct, inputs::Real)

    #Input the single input
    single_input!(agent, inputs)

    #Return the action trajectory
    return agent.history["action"]
end