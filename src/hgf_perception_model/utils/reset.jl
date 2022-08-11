"""
"""
function reset!(hgf::HGFStruct)

    #Go through each node
    for node in hgf.ordered_nodes.all_nodes

        #For each state
        for state_name in fieldnames(typeof(node.state))
            #Set it to missing
            setfield!(node.state, state_name, missing)
        end

        #For continuous state nodes
        if node isa StateNode
            #Set the initial posterior
            node.state.posterior_mean = node.params.initial_mean
            node.state.posterior_precision = node.params.initial_precision
        end

        #For each state in the history
        for state_name in fieldnames(typeof(node.history))

            #Empty the history
            empty!(getfield(node.history, state_name))

            #For states other than prediction states
            if !(state_name in [
                :prediction_mean,
                :prediction_volatility,
                :prediction_precision,
                :auxiliary_prediction_precision,
            ])
            
            #Add the new current state as the first state in the history
            push!(getfield(node.history, state_name), getfield(node.state, state_name))
            end
        end
    end
end
