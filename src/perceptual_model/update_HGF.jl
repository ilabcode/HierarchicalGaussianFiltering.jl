"""
    update_hierarchy(HGF_struct::HGFStruct, input::AbstractFloat)

Function for updating all nodes in an HGF hierarchy, with a single input node.
"""
function update_HGF(HGF::HGFStruct, input::Number)

    #Update the input node by passing the specified input to it
    input_node = HGF.ordered_input_nodes[1]
    update_node(input_node, input)

    #For each state node, in the specified update order
    for node in HGF.ordered_state_nodes
        #Update it
        update_node(node)
    end

    return nothing
end


"""
    update_hierarchy(HGF_struct::HGFStruct, input::Dict{String, Float64}) 

Function for updating all nodes in an HGF hierarchy, with multiple input nodes structured as a dictionary.
"""
function update_HGF(HGF::HGFStruct, inputs::Dict)

    #Update each input node by passing the corresponding input to it
    for input in inputs
        update_node(HGF.input_nodes[input[1]], input[2])
    end

   #For each state node, in the specified update order
   for node in HGF.ordered_state_nodes
        #Update it
        update_node(node)
    end

    return nothing
end


"""
    update_hierarchy(HGF_struct::HGFStruct, input::Vector{Number}) 

Function for updating all nodes in an HGF hierarchy, with multiple input nodes structured as a dictionary.
"""
function update_HGF(HGF::HGFStruct, inputs::Vector)

    #Update each input node with the corresponding input, as defined by the order
    for (input, input_node) in zip(inputs, HGF.ordered_input_nodes)
        update_node(input_node, input)
    end

   #For each state node, in the specified update order
   for node in HGF.ordered_state_nodes
        #Update it
        update_node(node)
    end

    return nothing
end