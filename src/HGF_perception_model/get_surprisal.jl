"""
    get_surprisal(node::InputNode)

Calculates the surprisal of an input node on seeing the last input.
Implements the equation: −log(p(u(k)))= 1(log(2π)−log(πˆ(k))+πˆ(k)(u(k) −μˆ(k) )2)
"""
function get_surprisal(node::InputNode)

    #Get the surprisal
    -log(
        1 / 2 * (
            log(2 * pi) - log(node.state.prediction_precision) +
            node.state.prediction_precision *
            (node.state.input_value - node.state.prediction_mean)^2
        ),
    )
end


"""
    get_surprisal(node::BinaryInputNode)

Calculates the surprisal of a binary input node on seeing the last input.
"""
function get_surprisal(node::BinaryInputNode)

    #If the input precision is infinite
    if node.state.input_precision == Inf

        #If a 1 was observed
        if node.state.input_value == 1
            #Get surprisal
            surprisal = -log(1 - node.state.prediction_mean)

            #If a 0 was observed
        elseif node.state.input_value == 0
            #Get surprisal
            surprisal = -log(node.state.prediction_mean)

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
        #Get the surprisal
        surprisal =
            -log(
                node.state.prediction_mean * cdf(
                    Normal(node.params.category_means[1], node.state.prediction_precision),
                    node.state.input_value,
                ) +
                (1 - node.state.prediction_mean) * cdf(
                    Normal(node.params.category_means[2], node.state.prediction_precision),
                    node.state.input_value,
                ),
            )
    end

    return surprisal
end

