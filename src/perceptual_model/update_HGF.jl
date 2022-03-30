"""
    update_hierarchy(HGF_struct::HGFStruct, input::AbstractFloat)

Function for updating all nodes in an HGF hierarchy, with a single input node.
"""
function update_HGF(HGF::HGFStruct, input::Number)

    ## Update state node predictions from last timestep
    #For each state node, in the specified update order
    for node in HGF.ordered_state_nodes
        #Update its predictions from last trial
        update_node_prediction(node)
    end

    ## Update input node
    #Update the input node by passing the specified input to it
    input_node = HGF.ordered_input_nodes[1]
    update_input_node(input_node, input)

    ## Update state nodes
    #For each state node, in the specified update order
    for node in HGF.ordered_state_nodes
        #Update its posterior    
        update_node_posterior(node)
        #And its prediction error
        update_node_prediction_error(node)
    end

    return nothing
end


"""
    update_hierarchy(HGF_struct::HGFStruct, input::Dict{String, Float64}) 

Function for updating all nodes in an HGF hierarchy, with multiple input nodes structured as a dictionary.
"""
function update_HGF(HGF::HGFStruct, inputs::Dict)

    ## Update state node predictions from last timestep
    #For each state node, in the specified update order
    for node in HGF.ordered_state_nodes
        #Update its predictions from last trial
        update_node_prediction(node)
    end

    ## Update input nodes
    #Update each input node by passing the corresponding input to it
    for input in inputs
        update_input_node(HGF.input_nodes[input[1]], input[2])
    end

    ## Update state nodes
    #For each state node, in the specified update order
    for node in HGF.ordered_state_nodes
        #Update its posterior    
        update_node_posterior(node)
        #And its prediction error
        update_node_prediction_error(node)
    end

    return nothing
end


"""
    update_hierarchy(HGF_struct::HGFStruct, input::Vector{Number}) 

Function for updating all nodes in an HGF hierarchy, with multiple input nodes structured as a dictionary.
"""
function update_HGF(HGF::HGFStruct, inputs::Vector)

    ## Update state node predictions from last timestep
    #For each state node, in the specified update order
    for node in HGF.ordered_state_nodes
        #Update its predictions from last trial
        update_node_prediction(node)
    end

    ## Update input nodes
    #Update each input node with the corresponding input, as defined by the order
    for (input, input_node) in zip(inputs, HGF.ordered_input_nodes)
        update_input_node(input_node, input)
    end

    ## Update state nodes
    #For each state node, in the specified update order
    for node in HGF.ordered_state_nodes
        #Update its posterior    
        update_node_posterior(node)
        #And its prediction error
        update_node_prediction_error(node)
    end

    return nothing
end