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
    get_surprise(node::ContinuousInputNode)

Calculates the surprise of an input node on seeing the last input.
Implements the equation: −log(p(u(k)))= 1(log(2π)−log(πˆ(k))+πˆ(k)(u(k) −μˆ(k) )2)
"""
function get_surprise(node::ContinuousInputNode)

    #Sum the predictions of the vaue parents
    parents_prediction_mean = 0
    for parent in node.value_parents
        parents_prediction_mean += parent.states.prediction_mean
    end

    #Get the surprise
    -log(
        pdf(
            Normal(parents_prediction_mean, node.states.prediction_precision),
            node.states.input_value,
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
        parents_prediction_mean += parent.states.prediction_mean
    end

    #If the input precision is infinite
    if node.params.input_precision == Inf

        #If a 1 was observed
        if node.states.input_value == 1
            #Get surprise
            surprise = -log(1 - parents_prediction_mean)

            #If a 0 was observed
        elseif node.states.input_value == 0
            #Get surprise
            surprise = -log(parents_prediction_mean)
        end

        #If the input precision is finite
    else
        #Get the surprise
        surprise =
            -log(
                parents_prediction_mean * pdf(
                    Normal(node.params.category_means[1], node.params.input_precision),
                    node.states.input_value,
                ) +
                (1 - parents_prediction_mean) * pdf(
                    Normal(node.params.category_means[2], node.params.input_precision),
                    node.states.input_value,
                ),
            )
    end

    return surprise
end