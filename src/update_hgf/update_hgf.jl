"""
update_hgf!(hgf::HGF, inputs) 

Function for updating all nodes in an HGF hierarchy.
"""
function update_hgf!(hgf::HGF, inputs::Union{Union{Real,Missing},Vector{Union{Real,Missing}},Dict{String,Union{Real,Missing}}})

    ## Update node predictions from last timestep
    #For each node (in the opposite update order)
    for node in reverse(hgf.ordered_nodes.all_state_nodes)
        #Update its prediction from last trial
        update_node_prediction!(node)
    end

    #For each input node, in the specified update order
    for node in reverse(hgf.ordered_nodes.input_nodes)
        #Update its prediction from last trial
        update_node_prediction!(node)
    end

    ## Supply inputs to input nodes
    enter_node_inputs!(hgf, inputs)

    ## Update input node value prediction errors
    #For each input node, in the specified update order
    for node in hgf.ordered_nodes.input_nodes
        #Update its value prediction error
        update_node_value_prediction_error!(node)
    end

    ## Update input node value parent posteriors
    #For each node that is a value parent of an input node
    for node in hgf.ordered_nodes.early_update_state_nodes
        #Update its posterior    
        update_node_posterior!(node)
        #And its value prediction error
        update_node_value_prediction_error!(node)
        #And its volatility prediction error
        update_node_volatility_prediction_error!(node)
    end

    ## Update input node volatility prediction errors
    #For each input node, in the specified update order
    for node in hgf.ordered_nodes.input_nodes
        #Update its value prediction error
        update_node_volatility_prediction_error!(node)
    end

    ## Update remaining state nodes
    #For each state node, in the specified update order
    for node in hgf.ordered_nodes.late_update_state_nodes
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
    enter_node_inputs!(hgf::HGF, input::Number)

Function for entering a single input to a single input node. Can either take a single number, or a tuple which also includes the precision of the input.
"""
function enter_node_inputs!(hgf::HGF, input::Union{Real,Missing})

    #Update the input node by passing the specified input to it
    update_node_input!(hgf.ordered_nodes.input_nodes[1], input)

    return nothing
end

"""
    enter_node_inputs!(hgf::HGF, inputs::Vector)

Function for entering multiple inputs, structured as a vector, to multiple input nodes.
"""
function enter_node_inputs!(hgf::HGF, inputs::Vector{<:Union{Real,Missing}})

    #If the vector of inputs only contain a single input
    if length(inputs) == 1
        #Just input that into the first input node
        update_node_input!(hgf.ordered_nodes.input_nodes[1], inputs[1])

    else

        #For each input node and its corresponding input
        for (input_node, input) in zip(hgf.ordered_nodes.input_nodes, inputs)
            #Enter the input
            update_node_input!(input_node, input)
        end
    end

    return nothing
end

"""
    enter_node_inputs!(hgf::HGF, inputs::Dict)

Function for entering multiple inputs, structured as a dictionary, to multiple input nodes.
"""
function enter_node_inputs!(hgf::HGF, inputs::Dict{String,<:Union{Real,Missing}})

    #Update each input node by passing the corresponding input to it
    for (node_name, input) in inputs
        #Enter the input
        update_node_input!(hgf.input_nodes[node_name], input)
    end

    return nothing
end
