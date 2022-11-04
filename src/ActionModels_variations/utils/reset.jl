"""
"""
function ActionModels.reset!(hgf::HGF)

    #Go through each node
    for node in hgf.ordered_nodes.all_nodes

        #For categorical state nodes
        if node isa CategoricalStateNode
            #Reset the posterior
            empty!(node.states.posterior)
            #Set to missing
            node.states.prediction = missing
            node.states.value_prediction_error = missing

        #For other nodes
        else
            #For each state
            for state_name in fieldnames(typeof(node.states))
                #Set the state to first value in history
                setfield!(node.states, state_name, missing)
            end
        end

        #For continuous state nodes
        if node isa ContinuousStateNode
            #Set the initial posterior
            node.states.posterior_mean = node.params.initial_mean
            node.states.posterior_precision = node.params.initial_precision
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
