"""
Function for updating all nodes in an HGF hierarchy
"""
function update_hierarchy(HGF_struct::HGFModel, input::AbstractFloat)

    #Update each input node by passing the specified input to it
    for input_node in HGF_struct.input_nodes
        update_node(input_node, input)
    end

    #Update each state node in the specified order
    for state_node in HGF_struct.state_nodes
        update_node(state_node[2])
    end
end

