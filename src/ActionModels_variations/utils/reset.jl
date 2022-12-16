"""
"""
function ActionModels.reset!(hgf::HGF)

    #Go through each node
    for node in hgf.ordered_nodes.all_nodes

        #For categorical state nodes
        if node isa CategoricalStateNode
            #Set states to vectors of missing
            node.states.posterior .= missing
            node.states.value_prediction_error .= missing
            #Empty prediction state
            empty!(node.states.prediction)

            #For binary input nodes
        elseif node isa BinaryInputNode
            #Set states to missing 
            node.states.value_prediction_error .= missing
            node.states.input_value = missing

            #For continuous state nodes
        elseif node isa ContinuousStateNode
            #Set posterior to initial belief
            node.states.posterior_mean = node.parameters.initial_mean
            node.states.posterior_precision = node.parameters.initial_precision
            #For other states
            for state_name in [
                :value_prediction_error,
                :volatility_prediction_error,
                :prediction_mean,
                :prediction_volatility,
                :prediction_precision,
                :auxiliary_prediction_precision,
            ]
                #Set the state to missing
                setfield!(node.states, state_name, missing)
            end

            #For continuous input nodes
        elseif node isa ContinuousInputNode

            #For all states except auxiliary prediction precision
            for state_name in [
                :input_value,
                :value_prediction_error,
                :volatility_prediction_error,
                :prediction_volatility,
                :prediction_precision,
            ]
                #Set the state to missing
                setfield!(node.states, state_name, missing)
            end

            #For other nodes
        else
            #For each state
            for state_name in fieldnames(typeof(node.states))
                #Set the state to missing
                setfield!(node.states, state_name, missing)
            end
        end

        #For each state in the history
        for state_name in fieldnames(typeof(node.history))

            #Empty the history
            empty!(getfield(node.history, state_name))

            #For states other than prediction states
            if !(
                state_name in [
                    :prediction,
                    :prediction_mean,
                    :prediction_volatility,
                    :prediction_precision,
                    :auxiliary_prediction_precision,
                ]
            )
                #Add the new current state as the first state in the history
                push!(getfield(node.history, state_name), getfield(node.states, state_name))
            end
        end
    end
end
