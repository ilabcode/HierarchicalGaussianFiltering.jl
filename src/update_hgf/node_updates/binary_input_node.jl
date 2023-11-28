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

    #Calculate value prediction error
    node.states.value_prediction_error = calculate_value_prediction_error(node)
    push!(node.history.value_prediction_error, node.states.value_prediction_error)

    return nothing
end

@doc raw"""
    calculate_value_prediction_error(node::BinaryInputNode)

Calculates the prediciton error of a binary input node with finite precision.

Uses the equation
``  \delta_n= u - \sum_{j=1}^{j\;value\;parents} \hat{\mu}_{j} ``
"""
function calculate_value_prediction_error(node::BinaryInputNode)

    #For missing input
    if ismissing(node.states.input_value)
        #Set the prediction error to missing
        value_prediction_error = [missing, missing]
    else
        #Substract to find the difference to each of the Gaussian means
        value_prediction_error = node.parameters.category_means .- node.states.input_value
    end
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
