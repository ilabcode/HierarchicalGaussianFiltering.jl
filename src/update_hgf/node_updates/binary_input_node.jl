###################################
######## Update prediction ########
###################################

##### Superfunction #####
"""
    update_node_prediction!(node::BinaryInputNode)

There is no prediction update for binary input nodes, as the prediction precision is constant.
"""
function update_node_prediction!(node::BinaryInputNode)
    return nothing
end


###############################################
######## Update value prediction error ########
###############################################

##### Superfunction #####
"""
    update_node_value_prediction_error!(node::BinaryInputNode)

Update the value prediction error of a single binary input node.
"""
function update_node_value_prediction_error!(node::BinaryInputNode)
    return nothing
end

###################################################
######## Update precision prediction error ########
###################################################

##### Superfunction #####
"""
    update_node_precision_prediction_error!(node::BinaryInputNode)

There is no volatility prediction error update for binary input nodes.
"""
function update_node_precision_prediction_error!(node::BinaryInputNode)
    return nothing
end
