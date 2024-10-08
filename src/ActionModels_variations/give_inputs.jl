"""
give_inputs!(hgf::HGF, inputs)

Give inputs to an agent. Input can be a single value, a vector of values, or an array of values.
"""
# function ActionModels.give_inputs!() end


### Giving a single input ###
function ActionModels.give_inputs!(hgf::HGF, inputs::Real; stepsizes::Real = 1)

    #Input the value to the hgf
    update_hgf!(hgf, inputs, stepsize = stepsizes)

    return nothing
end

### Giving a vector of inputs ###
function ActionModels.give_inputs!(
    hgf::HGF,
    inputs::Vector;
    stepsizes::Union{Real,Vector} = 1,
)

    #Create vector of stepsizes
    if stepsizes isa Real
        stepsizes = fill(stepsizes, length(inputs))
    end

    #Check that inputs and stepsizes are the same length
    if length(inputs) != length(stepsizes)
        @error "The number of inputs and stepsizes must be the same."
    end

    #Each entry in the vector is an input
    for (input, stepsize) in zip(inputs, stepsizes)
        #Input it to the hgf
        update_hgf!(hgf, input; stepsize = stepsize)
    end

    return nothing
end


### Giving a matrix of inputs (multiple per timestep) ###
function ActionModels.give_inputs!(
    hgf::HGF,
    inputs::Array;
    stepsizes::Union{Real,Vector} = 1,
)

    #If number of column in input is diffferent from amount of input nodes
    if size(inputs, 2) != length(hgf.input_nodes)
        #Raise an error
        throw(
            ArgumentError(
                "the number of columns in the input is different from the number of input nodes in the model",
            ),
        )
    end

    #Create vector of stepsizes
    if stepsizes isa Real
        stepsizes = fill(stepsizes, size(inputs, 1))
    end

    #Check that inputs and stepsizes are the same length
    if size(inputs, 1) != length(stepsizes)
        @error "The number of inputs and stepsizes must be the same."
    end

    #Take each row in the array
    for (input, stepsize) in zip(eachrow(inputs), stepsizes)
        #Input it to the hgf
        update_hgf!(hgf, Vector(input), stepsize = stepsize)
    end

    return nothing
end
