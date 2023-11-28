###################################
######## Update prediction ########
###################################

##### Superfunction #####
"""
    update_node_prediction!(node::CategoricalInputNode)

There is no prediction update for categorical input nodes, as the prediction precision is constant.
"""
function update_node_prediction!(node::CategoricalInputNode)
    return nothing
end


###############################################
######## Update value prediction error ########
###############################################

##### Superfunction #####
"""
    update_node_value_prediction_error!(node::CategoricalInputNode)

    There is no value prediction error update for categorical input nodes.
"""
function update_node_value_prediction_error!(node::CategoricalInputNode)
    return nothing
end


###################################################
######## Update precision prediction error ########
###################################################

##### Superfunction #####
"""
    update_node_precision_prediction_error!(node::CategoricalInputNode)

There is no volatility prediction error update for categorical input nodes.
"""
function update_node_precision_prediction_error!(node::CategoricalInputNode)
    return nothing
end
