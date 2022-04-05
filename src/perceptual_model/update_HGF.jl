"""
update_HGF!(HGF_struct::HGFStruct, inputs) 

Function for updating all nodes in an HGF hierarchy.
"""
function update_HGF!(HGF::HGFStruct, inputs)

    ## Update node predictions from last timestep
    #For each state node, in the specified update order
    for node in HGF.ordered_state_nodes
        #Update its prediction from last trial
        update_node_prediction!(node)
    end

    #For each input node, in the specified update order
    for node in HGF.ordered_input_nodes
        #Update its prediction form last trial
        update_node_prediction!(node)
    end

    ## Supply inputs to input nodes
    enter_node_inputs!(HGF, inputs)

    ## Update node posteriors and predictions errors 
    #For each input node, in the specified update order
    for node in HGF.ordered_input_nodes
        #Update its prediction error
        update_node_prediction_error!(node)
    end

    #For each state node, in the specified update order
    for node in HGF.ordered_state_nodes
        #Update its posterior    
        update_node_posterior!(node)
        #And its prediction error
        update_node_prediction_error!(node)
    end

    return nothing
end

"""
    enter_node_inputs!(HGF::HGFStruct, input::Number)

Function for entering a single input to a single input node.
"""
function enter_node_inputs!(HGF::HGFStruct, input::Number)

    #Update the input node by passing the specified input to it
    update_node_input!(HGF.ordered_input_nodes[1], input)

    return nothing
end

"""
    enter_node_inputs!(HGF::HGFStruct, inputs::Vector)

Function for entering multiple inputs, structured as a vector, to multiple input nodes.
"""
function enter_node_inputs!(HGF::HGFStruct, inputs::Vector)

    #For each input node and its corresponding input
    for (input_node, input) in zip(HGF.ordered_input_nodes, inputs)
        #Enter the input
        update_node_input!(input_node, input)
    end

    return nothing
end

"""
    enter_node_inputs!(HGF::HGFStruct, inputs::Dict)

Function for entering multiple inputs, structured as a dictionary, to multiple input nodes.
"""
function enter_node_inputs!(HGF::HGFStruct, inputs::Dict)

    #Update each input node by passing the corresponding input to it
    for input in inputs
        #Enter the input
        update_node_input!(HGF.input_nodes[input[1]], input[2])
    end

    return nothing
end
