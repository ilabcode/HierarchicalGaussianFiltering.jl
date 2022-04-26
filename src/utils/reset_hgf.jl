function reset_hgf!(my_hgf::HGFStruct)
    for node in keys(my_hgf.input_nodes)
        my_hgf.input_nodes[node].state.input_value = missing
        my_hgf.input_nodes[node].state.value_prediction_error = missing
        my_hgf.input_nodes[node].state.volatility_prediction_error = missing

        my_hgf.input_nodes[node].state.prediction_volatility = my_hgf.input_nodes[node].history.prediction_volatility[1]
        my_hgf.input_nodes[node].state.prediction_precision = my_hgf.input_nodes[node].history.prediction_precision[1]
        my_hgf.input_nodes[node].state.auxiliary_prediction_precision = 0.0
        my_hgf.input_nodes[node].history.input_value = []
        my_hgf.input_nodes[node].history.value_prediction_error = []
        my_hgf.input_nodes[node].history.volatility_prediction_error = []
        
        my_hgf.input_nodes[node].history.prediction_volatility = [my_hgf.input_nodes[node].state.prediction_volatility]
        my_hgf.input_nodes[node].history.prediction_precision = [my_hgf.input_nodes[node].state.prediction_precision]
        my_hgf.input_nodes[node].history.auxiliary_prediction_precision = []
    end

    for node in keys(my_hgf.state_nodes)
        my_hgf.state_nodes[node].state.posterior_mean = my_hgf.state_nodes[node].history.posterior_mean[1]
        my_hgf.state_nodes[node].state.posterior_precision = my_hgf.state_nodes[node].history.posterior_precision[1]
        my_hgf.state_nodes[node].state.prediction_mean = my_hgf.state_nodes[node].history.prediction_mean[1]
        my_hgf.state_nodes[node].state.prediction_volatility = my_hgf.state_nodes[node].history.prediction_volatility[1]
        my_hgf.state_nodes[node].state.prediction_precision = my_hgf.state_nodes[node].history.prediction_precision[1]
        my_hgf.state_nodes[node].state.auxiliary_prediction_precision = my_hgf.state_nodes[node].history.auxiliary_prediction_precision[1]

        my_hgf.state_nodes[node].history.posterior_mean = [my_hgf.state_nodes[node].state.posterior_mean]
        my_hgf.state_nodes[node].history.posterior_precision = [my_hgf.state_nodes[node].state.posterior_precision]
        my_hgf.state_nodes[node].history.prediction_mean = [my_hgf.state_nodes[node].state.prediction_mean]
        my_hgf.state_nodes[node].history.prediction_volatility = [my_hgf.state_nodes[node].state.prediction_volatility]
        my_hgf.state_nodes[node].history.prediction_precision = [my_hgf.state_nodes[node].state.prediction_precision]
        my_hgf.state_nodes[node].history.auxiliary_prediction_precision = [my_hgf.state_nodes[node].state.auxiliary_prediction_precision]

        my_hgf.state_nodes[node].state.value_prediction_error = missing
        my_hgf.state_nodes[node].state.volatility_prediction_error = missing
        my_hgf.state_nodes[node].history.value_prediction_error = []
        my_hgf.state_nodes[node].history.value_prediction_error = []
    end
end