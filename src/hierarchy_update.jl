"""
    update_hierarchy(HGF_struct::HGFModel, input::AbstractFloat)

Function for updating all nodes in an HGF hierarchy, with a single input node.
"""
function update_hierarchy(HGF_struct::HGFModel, input::AbstractFloat)

    #Update the input node by passing the specified input to it
    input_node = HGF_struct.input_nodes[1]
    update_node(input_node, input)

    #Update each state node in the specified order
    for state_node in HGF_struct.state_nodes
        update_node(state_node[2])
    end
end



"""
    update_hierarchy(HGF_struct::HGFModel, input::Dict{String, AbstractFloar}) 

Function for updating all nodes in an HGF hierarchy, with multiple input nodes.
"""
function update_hierarchy(HGF_struct::HGFModel, input::Dict{String, AbstractFloar})

    #Update each input node by passing the specified input to it
    for input_node in HGF_struct.input_nodes
        update_node(input_node, input)
    end

    #Update each state node in the specified order
    for state_node in HGF_struct.state_nodes
        update_node(state_node[2])
    end
end