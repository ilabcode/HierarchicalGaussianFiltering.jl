"""
    update_hierarchy(HGF_struct::HGFStruct, input::AbstractFloat)

Function for updating all nodes in an HGF hierarchy, with a single input node.
"""
function update_HGF(HGF_struct::HGFStruct, input::AbstractFloat)

    #Check if input 
    if length(HGF_struct.input_nodes) != 1
        throw(ArgumentError("a single input was given, but there are multiple input nodes"))
    end

    #Update the input node by passing the specified input to it
    input_node = first(HGF_struct.input_nodes)[2]
    update_node(input_node, input)

    #For each state node, in the specified update order
    for node in HGF_struct.update_order
        #Update it
        update_node(node)
    end

    return nothing
end


"""
    update_hierarchy(HGF_struct::HGFStruct, input::Dict{String, Float64}) 

Function for updating all nodes in an HGF hierarchy, with multiple input nodes.
"""
function update_HGF(HGF_struct::HGFStruct, inputs::Dict{String, Float64})

    #If specified input destinations do not match input nodes
    if keys(input) != keys(HGF_struct.input_nodes)
        #Raise an error
        throw(ArgumentError("the specified input nodes do not match the existing input nodes in the model"))
    end

    #Update each input node by the corresponding input to it
    for input in inputs
        update_node(HGF_struct.input_nodes[input[1]], input[2])
    end

   #For each state node, in the specified update order
   for node in HGF_struct.update_order
        #Update it
        update_node(node)
    end

    return nothing
end