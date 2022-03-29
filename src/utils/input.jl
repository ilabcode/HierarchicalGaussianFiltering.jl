"""
    input(HGF_struct::HGFStruct, inputs::Array)

Function for inputting multiple observations to an HGF. Input is structured as an array, with one column per input node and one row per timestep.
"""
function input(HGF::HGFStruct, inputs::Array)

    ### Checks ###
    #If number of column in input is diffferent from amount of input nodes
    if size(inputs, 2) != length(HGF.input_nodes)
        #Raise an error
        throw(ArgumentError("the number of columns in the input is different from the number of input nodes in the model"))
    end

    ### Input data ###
    #Take each row in the array
    for rownr in 1:size(inputs, 1)
        #Input it to the HGF
        update_HGF(HGF, inputs[rownr,:])
    end
    
    return nothing
end



"""
    input(HGF_struct::HGFStruct, inputs)

Function for inputting multiple observations to an HGF. Input is structured as a dictionary with a vector for each input node.
"""
function input(HGF::HGFStruct, inputs::Dict{String, Vector})

    ### Checks ###
    #If specified input destinations do not match input nodes
    if keys(input) != keys(HGF.input_nodes)
        #Raise an error
        throw(ArgumentError("the input nodes specified in the input do not match the input nodes in the model"))
    end

    ### Input data ###
    for input in inputs
        update_HGF(HGF, input)
    end
    
    return nothing
end