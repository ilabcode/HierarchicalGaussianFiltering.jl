"""
    update_hgf!(
        hgf::HGF,
        inputs::Union{
            Real,
            Missing,
            Vector{<:Union{Real,Missing}},
            Dict{String,<:Union{Real,Missing}},
        },
    )

Update all nodes in an HGF based on an input. The input can either be missing, a single value, a vector of values, or a dictionary of input node names and corresponding values.
"""
function update_hgf!(
    hgf::HGF,
    inputs::Union{
        Real,
        Missing,
        Vector{<:Union{Real,Missing}},
        Dict{String,<:Union{Real,Missing}},
    },
)
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
        update_node_posterior!(node, node.update_type)
        #And its value prediction error
        update_node_value_prediction_error!(node)
        #And its precision prediction error
        update_node_precision_prediction_error!(node)
    end

    ## Update input node precision prediction errors
    #For each input node, in the specified update order
    for node in hgf.ordered_nodes.input_nodes
        #Update its value prediction error
        update_node_precision_prediction_error!(node)
    end

    ## Update remaining state nodes
    #For each state node, in the specified update order
    for node in hgf.ordered_nodes.late_update_state_nodes
        #Update its posterior    
        update_node_posterior!(node, node.update_type)
        #And its value prediction error
        update_node_value_prediction_error!(node)
        #And its volatility prediction error
        update_node_precision_prediction_error!(node)
    end

    return nothing
end

"""
    enter_node_inputs!(hgf::HGF, input)

Set input values in input nodes. Can either take a single value, a vector of values, or a dictionary of input node names and corresponding values.
"""
function enter_node_inputs!(hgf::HGF, input::Union{Real,Missing})

    #Update the input node by passing the specified input to it
    update_node_input!(first(hgf.ordered_nodes.input_nodes), input)

    return nothing
end

function enter_node_inputs!(hgf::HGF, inputs::Vector{<:Union{Real,Missing}})

    #If the vector of inputs only contain a single input
    if length(inputs) == 1
        #Just input that into the first input node
        enter_node_inputs!(hgf, first(inputs))

    else

        #For each input node and its corresponding input
        for (input_node, input) in zip(hgf.ordered_nodes.input_nodes, inputs)
            #Enter the input
            update_node_input!(input_node, input)
        end
    end

    return nothing
end

function enter_node_inputs!(hgf::HGF, inputs::Dict{String,<:Union{Real,Missing}})

    #Update each input node by passing the corresponding input to it
    for (node_name, input) in inputs
        #Enter the input
        update_node_input!(hgf.input_nodes[node_name], input)
    end

    return nothing
end


"""
    update_node_input!(node::AbstractInputNode, input::Union{Real,Missing})

Update the prediction of a single input node.
"""
function update_node_input!(node::AbstractInputNode, input::Union{Real,Missing})
    #Receive input
    node.states.input_value = input
    push!(node.history.input_value, node.states.input_value)

    return nothing
end
