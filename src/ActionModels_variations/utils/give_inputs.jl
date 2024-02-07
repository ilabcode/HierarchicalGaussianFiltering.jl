"""
give_inputs!(hgf::HGF, inputs)

Give inputs to an agent. Input can be a single value, a vector of values, or an array of values.
"""
function ActionModels.give_inputs!() end

function ActionModels.give_inputs!(hgf::HGF, inputs::Real; stepsizes::Real = 1)

    #Input the value to the hgf
    update_hgf!(hgf, inputs; stepsizes = stepsizes)

    return nothing
end

function ActionModels.give_inputs!(hgf::HGF, inputs::Vector; stepsizes::Union{Real, Vector} = 1)

if stepsizes isa Real
    stepsizes = fill(stepsizes, length(inputs)) # have a stepsizes vector with all equal timesteps
else
    if length(stepsizes) != length(inputs)
        throw("Stepsizes vector has a different lenght with respect to the inputs vector") #throw an error if the given stepsizes vector is the wrong lenght
    end
end

    #Each entry in the vector is an input
    for (input, stepsize) in zip(inputs, stepsizes)
        #Input it to the hgf
        update_hgf!(hgf, input; stepsizes = stepsize)
    end

    return nothing
end

function ActionModels.give_inputs!(hgf::HGF, inputs::Array; stepsizes::Union{Real, Vector} = 1)

    #If number of column in input is diffferent from amount of input nodes
    if size(inputs, 2) != length(hgf.input_nodes)
        #Raise an error
        throw(
            ArgumentError(
                "the number of columns in the input is different from the number of input nodes in the model",
            ),
        )
    end

    if stepsizes isa Real
        stepsizes = fill(stepsizes, length(inputs)) # have a stepsizes vector with all equal timesteps
    else
        if length(stepsizes) != length(inputs)
            throw("Stepsizes vector has a different lenght with respect to the inputs vector") #throw an error if the given stepsizes vector is the wrong lenght
        end
    end


    #Take each row in the array
    for (input, stepsize) in zip(eachrow(inputs), stepsizes)
        #Input it to the hgf
        update_hgf!(hgf, Vector(input); stepsizes = stepsize)
    end

    return nothing
end
