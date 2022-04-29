"""
    input(HGF_struct::HGFStruct, inputs::Array)

Function for inputting multiple observations to an HGF. Input is structured as an array, with one column per input node and one row per timestep.
"""
function give_inputs!(HGF::HGFStruct, inputs::Array)

    ### Checks ###
    #If number of column in input is diffferent from amount of input nodes
    if size(inputs, 2) != length(HGF.input_nodes)
        #Raise an error
        throw(
            ArgumentError(
                "the number of columns in the input is different from the number of input nodes in the model",
            ),
        )
    end

    ### Input data ###
    #Take each row in the array
    for rownr = 1:size(inputs, 1)
        #Input it to the HGF
        update_hgf!(HGF, inputs[rownr, :])
    end

    return nothing
end



"""
    input(HGF_struct::HGFStruct, inputs)

Function for inputting multiple observations to an HGF. Input is structured as a dictionary with a vector for each input node.
"""
function give_inputs!(HGF::HGFStruct, inputs::Dict{String,Vector})

    ### Checks ###
    #If specified input destinations do not match input nodes
    if keys(input) != keys(HGF.input_nodes)
        #Raise an error
        throw(
            ArgumentError(
                "the input nodes specified in the input do not match the input nodes in the model",
            ),
        )
    end

    #If all input vectors are not of the same length
    for input_set in input

    end

    ### Input data ###

    #

    for input in inputs
        update_hgf!(HGF, input)
    end

    return nothing
end




"""
    input(action_struct::AgentStruct, inputs::Array)

Function for inputting multiple observations to an action model. Input is structured as an array, with one column per input node and one row per timestep.
"""
function give_inputs!(agent::AgentStruct, inputs::Array)

    ### Checks ###
    #If number of column in input is diffferent from amount of input nodes
    if size(inputs, 2) != length(agent.perceptual_struct.input_nodes)
        #Raise an error
        throw(
            ArgumentError(
                "the number of columns in the input is different from the number of input nodes in the model",
            ),
        )
    end

    ### Input data ###
    #Take each row in the array
    for rownr = 1:size(inputs, 1)

        #Get the action distribution
        distribution = agent.action_model(agent, inputs[rownr, :])[1]

        #Sample the action from the distribution
        agent.state["action"] = rand(distribution, 1)[1]

        #Record the action
        push!(agent.history["action"], agent.state["action"])

    end

    return nothing
end

# function give_inputs!(action_struct::AgentStruct, inputs::Number)

#     ### Checks ###
#     #If number of column in input is diffferent from amount of input nodes
#     if size(inputs, 2) != length(action_struct.perceptual_struct.input_nodes)
#         #Raise an error
#         throw(ArgumentError("the number of columns in the input is different from the number of input nodes in the model"))
#     end

#     ### Input data ###
#     #Take each row in the array
#     for rownr in 1:size(inputs, 1)
#         #Input it to the model and record the action
#         action_struct.state["action"] = action_struct.action_model(action_struct, inputs[rownr,:])[1]
#         push!(action_struct.history["action"], action_struct.state["action"])
#     end

#     return nothing
# end


function give_inputs!(agent::AgentStruct, input::Number)
    
        ### Input data ###
        #Take input
        
        #Get the action distribution
        distribution = agent.action_model(agent, input)

        #Sample the action from the distribution
        agent.state["action"] = rand(distribution, 1)[1]

        #Record the action
        push!(agent.history["action"], agent.state["action"])
    
        return distribution
end