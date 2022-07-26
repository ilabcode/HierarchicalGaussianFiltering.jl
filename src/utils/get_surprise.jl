"""
    get_surprise(node::AgentStruct)

Calculates the surprisal of a specified input node in an agent with an HGF.
"""
function get_surprise(agent::AgentStruct, node_name::String = "u")
        
        #Get out the input node
        node = agent.perception_struct.input_nodes[node_name]

        #Calculate its surprise
        return get_surprise(node)
end


"""
    get_surprise(node::HGFStruct)

Calculates the surprisal of a specified input node in an HGF.
"""
function get_surprise(hgf::HGFStruct, node_name::String = "u")
        
        #Get out the input node
        node = hgf.input_nodes[node_name]

        #Calculate its surprise
        return get_surprise(node)
end


"""
    get_surprise(node::InputNode)

Calculates the surprise of an input node on seeing the last input.
Implements the equation: −log(p(u(k)))= 1(log(2π)−log(πˆ(k))+πˆ(k)(u(k) −μˆ(k) )2)
"""
function get_surprise(node::InputNode)

    #Sum the predictions of the vaue parents
    parents_prediction_mean = 0
    for parent in node.value_parents
        parents_prediction_mean += parent.state.prediction_mean
    end

    #Get the surprise
    -log(
        pdf(
            Normal(parents_prediction_mean, node.state.prediction_precision),
            node.state.input_value,
        ),
    )
end


"""
    get_surprise(node::BinaryInputNode)

Calculates the surprise of a binary input node on seeing the last input.
"""
function get_surprise(node::BinaryInputNode)

    #Sum the predictions of the vaue parents
    parents_prediction_mean = 0
    for parent in node.value_parents
        parents_prediction_mean += parent.state.prediction_mean
    end

    #If the input precision is infinite
    if node.params.input_precision == Inf

        #If a 1 was observed
        if node.state.input_value == 1
            #Get surprise
            surprise = -log(1 - parents_prediction_mean)

            #If a 0 was observed
        elseif node.state.input_value == 0
            #Get surprise
            surprise = -log(parents_prediction_mean)

            #If a non-binary input was received
        else
            throw(
                ArgumentError(
                    "The binary input node $node.name has infinite input precision, but received a non-binary input. 
                    Either change the input precision, or change the inputs to 0's and 1's.",
                ),
            )
        end

        #If the input precision is finite
    else
        #Get the surprise
        surprise =
            -log(
                parents_prediction_mean * pdf(
                    Normal(node.params.category_means[1], node.params.input_precision),
                    node.state.input_value,
                ) +
                (1 - parents_prediction_mean) * pdf(
                    Normal(node.params.category_means[2], node.params.input_precision),
                    node.state.input_value,
                ),
            )
    end

    return surprise
end

