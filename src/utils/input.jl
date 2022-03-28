"""

Function for inputting 
"""
function input(model_struct, inputs)

    #checks

    #for loop
    for input in inputs
        action = model_struct.action_model(model_struct, input)
        push!(model_struct.history.action, action)
    end
    
    #save


end



mutable struct ModelStruct
    action_struct
    input_history
    action_history
end
