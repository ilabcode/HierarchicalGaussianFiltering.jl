"""
update_hgf!(HGF_struct::HGFStruct, inputs) 

Function for updating all nodes in an HGF hierarchy.
"""
function update_hgf!(HGF::HGFStruct, inputs::Any)

    ## Update node predictions from last timestep
    #For each parent of a binary state node
    for node in HGF.ordered_nodes.early_prediction_state_nodes
        #Update its prediction from last trial
        update_node_prediction!(node)
    end

    #For each oother state node
    for node in HGF.ordered_nodes.late_prediction_state_nodes
        #Update its prediction from last trial
        update_node_prediction!(node)
    end

    #For each input node, in the specified update order
    for node in HGF.ordered_nodes.input_nodes
        #Update its prediction from last trial
        update_node_prediction!(node)
    end

    ## Supply inputs to input nodes
    enter_node_inputs!(HGF, inputs)

    ## Update input node value prediction errors
    #For each input node, in the specified update order
    for node in HGF.ordered_nodes.input_nodes
        #Update its value prediction error
        update_node_value_prediction_error!(node)
    end

    ## Update input node value parent posteriors
    #For each node that is a value parent of an input node
    for node in HGF.ordered_nodes.early_update_state_nodes
        #Update its posterior    
        update_node_posterior!(node)
        #And its value prediction error
        update_node_value_prediction_error!(node)
        #And its volatility prediction error
        update_node_volatility_prediction_error!(node)
    end

    ## Update input node volatility prediction errors
    #For each input node, in the specified update order
    for node in HGF.ordered_nodes.input_nodes
        #Update its value prediction error
        update_node_volatility_prediction_error!(node)
    end

    ## Update remaining state nodes
    #For each state node, in the specified update order
    for node in HGF.ordered_nodes.late_update_state_nodes
        #Update its posterior    
        update_node_posterior!(node)
        #And its value prediction error
        update_node_value_prediction_error!(node)
        #And its volatility prediction error
        update_node_volatility_prediction_error!(node)
    end

    return nothing
end

"""
    enter_node_inputs!(HGF::HGFStruct, input::Number)

Function for entering a single input to a single input node. Can either take a single number, or a tuple which also includes the precision of the input.
"""
function enter_node_inputs!(HGF::HGFStruct, input::Union{Real, Tuple{Real}})

    #Update the input node by passing the specified input to it
    update_node_input!(HGF.ordered_nodes.input_nodes[1], input)

    return nothing
end

"""
    enter_node_inputs!(HGF::HGFStruct, inputs::Vector)

Function for entering multiple inputs, structured as a vector, to multiple input nodes.
"""
function enter_node_inputs!(HGF::HGFStruct, inputs::Vector)

    #For each input node and its corresponding input
    for (input_node, input) in zip(HGF.ordered_nodes.input_nodes, inputs)
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
