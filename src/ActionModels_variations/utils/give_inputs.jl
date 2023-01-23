"""
    give_inputs!(hgf::HGF, inputs::Number)

Function for inputting multiple observations to an hgf. Input is a single value.
"""
function ActionModels.give_inputs!(hgf::HGF, inputs::Real)

    #Input the value to the hgf
    update_hgf!(hgf, inputs)

    return nothing
end


"""
"""
function ActionModels.give_inputs!(hgf::HGF, inputs::Vector)

    #Each entry in the vector is an input
    for input in inputs
        #Input it to the hgf
        update_hgf!(hgf, input)
    end

    return nothing
end


"""
    give_inputs!(hgf::HGF, inputs::Array)

Function for inputting multiple observations to an hgf. Input is structured as an array, with one column per input node and one row per timestep.
"""
function ActionModels.give_inputs!(hgf::HGF, inputs::Array)

    #If number of column in input is diffferent from amount of input nodes
    if size(inputs, 2) != length(hgf.input_nodes)
        #Raise an error
        throw(
            ArgumentError(
                "the number of columns in the input is different from the number of input nodes in the model",
            ),
        )
    end

    #Take each row in the array
    for input in eachrow(inputs)
        #Input it to the hgf
        update_hgf!(hgf, Vector(input))
    end

    return nothing
end
