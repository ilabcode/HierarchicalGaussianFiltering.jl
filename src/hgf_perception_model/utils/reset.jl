"""
"""
function reset!(my_hgf::HGFStruct)
    for node in keys(my_hgf.input_nodes)
        if typeof(my_hgf.input_nodes[node]) == InputNode 
            my_hgf.input_nodes[node].state.input_value = missing
            my_hgf.input_nodes[node].state.value_prediction_error = missing
            my_hgf.input_nodes[node].state.volatility_prediction_error = missing

            my_hgf.input_nodes[node].state.prediction_volatility = missing
            my_hgf.input_nodes[node].state.prediction_precision = missing
            my_hgf.input_nodes[node].state.auxiliary_prediction_precision = missing
            
            my_hgf.input_nodes[node].history.input_value = [missing]
            my_hgf.input_nodes[node].history.value_prediction_error = [missing]
            my_hgf.input_nodes[node].history.volatility_prediction_error = [missing]

            my_hgf.input_nodes[node].history.prediction_volatility = []
            my_hgf.input_nodes[node].history.prediction_precision = []
            my_hgf.input_nodes[node].history.auxiliary_prediction_precision = []
        elseif typeof(my_hgf.input_nodes[node]) == BinaryInputNode
            my_hgf.input_nodes[node].state.input_value = missing
            my_hgf.input_nodes[node].state.value_prediction_error = missing
            
            my_hgf.input_nodes[node].history.input_value = [missing]
            my_hgf.input_nodes[node].history.value_prediction_error = [missing]        
        end
    end

    for node in keys(my_hgf.state_nodes)
        if typeof(my_hgf.state_nodes[node]) == StateNode
            my_hgf.state_nodes[node].state.posterior_mean =
                my_hgf.state_nodes[node].params.initial_mean
            my_hgf.state_nodes[node].state.posterior_precision =
                my_hgf.state_nodes[node].params.initial_precision
            my_hgf.state_nodes[node].state.prediction_mean = missing
            my_hgf.state_nodes[node].state.prediction_volatility = missing
            my_hgf.state_nodes[node].state.prediction_precision = missing
            my_hgf.state_nodes[node].state.auxiliary_prediction_precision = missing

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
            my_hgf.state_nodes[node].history.value_prediction_error = [missing]
            my_hgf.state_nodes[node].history.volatility_prediction_error = [missing]
        
        elseif typeof(my_hgf.state_nodes[node]) == BinaryStateNode
            
            my_hgf.state_nodes[node].state.posterior_mean = missing
            my_hgf.state_nodes[node].state.posterior_precision =missing

            my_hgf.state_nodes[node].state.prediction_mean = missing
            my_hgf.state_nodes[node].state.prediction_precision = missing

            my_hgf.state_nodes[node].history.posterior_mean = 
                [missing]
            my_hgf.state_nodes[node].history.posterior_precision = 
                [missing]

            my_hgf.state_nodes[node].history.prediction_mean = []
            my_hgf.state_nodes[node].history.prediction_precision = []

            my_hgf.state_nodes[node].state.value_prediction_error = missing
            my_hgf.state_nodes[node].history.value_prediction_error = [missing]
        end
    end
end
