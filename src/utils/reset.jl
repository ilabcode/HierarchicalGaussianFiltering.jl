function reset!(my_hgf::HGFStruct)
    for node in keys(my_hgf.input_nodes)
        if typeof(my_hgf.input_nodes[node]) == InputNode
            my_hgf.input_nodes[node].state.input_value = missing
            my_hgf.input_nodes[node].state.value_prediction_error = missing
            my_hgf.input_nodes[node].state.volatility_prediction_error = missing

            my_hgf.input_nodes[node].state.prediction_volatility = 0.0
            my_hgf.input_nodes[node].state.prediction_precision = 0.0
            my_hgf.input_nodes[node].state.auxiliary_prediction_precision = 0.0
            
            my_hgf.input_nodes[node].history.input_value = []
            my_hgf.input_nodes[node].history.value_prediction_error = []
            my_hgf.input_nodes[node].history.volatility_prediction_error = []

            my_hgf.input_nodes[node].history.prediction_volatility = []
            my_hgf.input_nodes[node].history.prediction_precision = []
            my_hgf.input_nodes[node].history.auxiliary_prediction_precision = []
        elseif typeof(my_hgf.input_nodes[node]) == BinaryInputNode
            my_hgf.input_nodes[node].state.input_value = missing
            my_hgf.input_nodes[node].state.value_prediction_error = missing
            my_hgf.input_nodes[node].state.prediction_precision = Inf
            
            my_hgf.input_nodes[node].history.input_value = []
            my_hgf.input_nodes[node].history.value_prediction_error = []        
        end
    end

    for node in keys(my_hgf.state_nodes)
        if typeof(my_hgf.state_nodes[node]) == StateNode
            my_hgf.state_nodes[node].state.posterior_mean =
                my_hgf.state_nodes[node].history.posterior_mean[1]
            my_hgf.state_nodes[node].state.posterior_precision =
                my_hgf.state_nodes[node].history.posterior_precision[1]
            my_hgf.state_nodes[node].state.prediction_mean = 0.0
            my_hgf.state_nodes[node].state.prediction_volatility = 0.0
            my_hgf.state_nodes[node].state.prediction_precision = 0.0
            my_hgf.state_nodes[node].state.auxiliary_prediction_precision = 0.0

            my_hgf.state_nodes[node].history.posterior_mean =
                [my_hgf.state_nodes[node].state.posterior_mean]
            my_hgf.state_nodes[node].history.posterior_precision =
                [my_hgf.state_nodes[node].state.posterior_precision]
            my_hgf.state_nodes[node].history.prediction_mean = []
            my_hgf.state_nodes[node].history.prediction_volatility = []
            my_hgf.state_nodes[node].history.prediction_precision = []
            my_hgf.state_nodes[node].history.auxiliary_prediction_precision = []

            my_hgf.state_nodes[node].state.value_prediction_error = missing
            my_hgf.state_nodes[node].state.volatility_prediction_error = missing
            my_hgf.state_nodes[node].history.value_prediction_error = []
            my_hgf.state_nodes[node].history.volatility_prediction_error = []
        elseif typeof(my_hgf.state_nodes[node]) == BinaryStateNode

            my_hgf.state_nodes[node].state.posterior_mean =
                my_hgf.state_nodes[node].history.posterior_mean[1]
            my_hgf.state_nodes[node].state.posterior_precision =
                my_hgf.state_nodes[node].history.posterior_precision[1]

            my_hgf.state_nodes[node].state.prediction_mean = 0.0
            my_hgf.state_nodes[node].state.prediction_precision = 0.0

            my_hgf.state_nodes[node].history.posterior_mean =
                [my_hgf.state_nodes[node].state.posterior_mean]
            my_hgf.state_nodes[node].history.posterior_precision =
                [my_hgf.state_nodes[node].state.posterior_precision]

            my_hgf.state_nodes[node].history.prediction_mean = []
            my_hgf.state_nodes[node].history.prediction_precision = []

            my_hgf.state_nodes[node].state.value_prediction_error = missing
            my_hgf.state_nodes[node].history.value_prediction_error = [missing]
        end
    end
end

function reset!(my_agent::AgentStruct)
    reset!(my_agent.perception_struct)
    for state in keys(my_agent.history)
        #Add it to the state field
        my_agent.state[state] = missing
        #And put it in the history
        my_agent.history[state] = []
    end
end

