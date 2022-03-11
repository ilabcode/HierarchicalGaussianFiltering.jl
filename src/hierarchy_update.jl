"""
Function for updating all nodes in an HGF hierarchy
"""
function update_hierarchy(HGF_struct::HGFModel)

    #Update each input node in the specified order
    for input_node in HGF_struct.input_nodes
        update_node(input_node)
    end

    #Update each state node in the specified order
    for state_node in HGF_struct.state_nodes
        update_node(state_node)
    end
end

