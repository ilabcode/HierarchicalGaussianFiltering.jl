#######################################
######## Continuous State Node ########
#######################################
"""
    update_node_prediction!(node::AbstractStateNode)

Update the prediction of a single state node.
"""
function update_node_prediction!(node::AbstractStateNode; stepsizes::Real = 1)

    #Update prediction mean
    node.states.prediction_mean = calculate_prediction_mean(node; stepsizes = stepsizes)
    push!(node.history.prediction_mean, node.states.prediction_mean)

    #Update prediction volatility
    node.states.prediction_volatility = calculate_prediction_volatility(node)
    push!(node.history.prediction_volatility, node.states.prediction_volatility)

    #Update prediction precision
    node.states.prediction_precision = calculate_prediction_precision(node)
    push!(node.history.prediction_precision, node.states.prediction_precision)

    #Get auxiliary prediction precision, only if there are volatility children and/or volatility parents
    if length(node.volatility_parents) > 0 || length(node.volatility_children) > 0
        node.states.auxiliary_prediction_precision =
            calculate_auxiliary_prediction_precision(node)
        push!(
            node.history.auxiliary_prediction_precision,
            node.states.auxiliary_prediction_precision,
        )
    end

    return nothing
end

"""
    update_node_posterior!(node::AbstractStateNode; update_type::HGFUpdate)

Update the posterior of a single continuous state node. This is the classic HGF update.
"""
function update_node_posterior!(node::AbstractStateNode, update_type::ClassicUpdate)
    #Update posterior precision
    node.states.posterior_precision = calculate_posterior_precision(node)
    push!(node.history.posterior_precision, node.states.posterior_precision)

    #Update posterior mean
    node.states.posterior_mean = calculate_posterior_mean(node, update_type)
    push!(node.history.posterior_mean, node.states.posterior_mean)

    return nothing
end

"""
    update_node_posterior!(node::AbstractStateNode)

Update the posterior of a single continuous state node. This is the enahnced HGF update.
"""
function update_node_posterior!(node::AbstractStateNode, update_type::EnhancedUpdate)
    #Update posterior mean
    node.states.posterior_mean = calculate_posterior_mean(node, update_type)
    push!(node.history.posterior_mean, node.states.posterior_mean)

    #Update posterior precision
    node.states.posterior_precision = calculate_posterior_precision(node)
    push!(node.history.posterior_precision, node.states.posterior_precision)

    return nothing
end

"""
    update_node_value_prediction_error!(node::AbstractStateNode)

Update the value prediction error of a single state node.
"""
function update_node_value_prediction_error!(node::AbstractStateNode)
    #Update value prediction error
    node.states.value_prediction_error = calculate_value_prediction_error(node)
    push!(node.history.value_prediction_error, node.states.value_prediction_error)

    return nothing
end

"""
    update_node_volatility_prediction_error!(node::AbstractStateNode)

Update the volatility prediction error of a single state node.
"""
function update_node_volatility_prediction_error!(node::AbstractStateNode)

    #Update volatility prediction error, only if there are volatility parents
    if length(node.volatility_parents) > 0
        node.states.volatility_prediction_error =
            calculate_volatility_prediction_error(node)
        push!(
            node.history.volatility_prediction_error,
            node.states.volatility_prediction_error,
        )
    end

    return nothing
end


##############################################
######## Binary State Node Variations ########
##############################################
"""
    update_node_prediction!(node::BinaryStateNode)

Update the prediction of a single binary state node.
"""
function update_node_prediction!(node::BinaryStateNode)

    #Update prediction mean
    node.states.prediction_mean = calculate_prediction_mean(node)
    push!(node.history.prediction_mean, node.states.prediction_mean)

    #Update prediction precision
    node.states.prediction_precision = calculate_prediction_precision(node)
    push!(node.history.prediction_precision, node.states.prediction_precision)

    return nothing
end

"""
    update_node_volatility_prediction_error!(node::BinaryStateNode)

There is no volatility prediction error update for binary state nodes.
"""
function update_node_volatility_prediction_error!(node::BinaryStateNode)
    return nothing
end


###################################################
######## Categorical State Node Variations ########
###################################################
"""
    update_node_prediction!(node::CategoricalStateNode)

Update the prediction of a single categorical state node.
"""
function update_node_prediction!(node::CategoricalStateNode)

    #Update prediction mean
    node.states.prediction, node.states.parent_predictions = calculate_prediction(node)
    push!(node.history.prediction, node.states.prediction)
    push!(node.history.parent_predictions, node.states.parent_predictions)
    return nothing
end

"""
    update_node_posterior!(node::CategoricalStateNode)

Update the posterior of a single categorical state node.
"""
function update_node_posterior!(node::CategoricalStateNode, update_type::ClassicUpdate)

    #Update posterior mean
    node.states.posterior = calculate_posterior(node)
    push!(node.history.posterior, node.states.posterior)

    return nothing
end

"""
    update_node_volatility_prediction_error!(node::CategoricalStateNode)

There is no volatility prediction error update for categorical state nodes.
"""
function update_node_volatility_prediction_error!(node::CategoricalStateNode)
    return nothing
end


###################################################
######## Conntinuous Input Node Variations ########
###################################################
"""
    update_node_input!(node::AbstractInputNode, input::Union{Real,Missing})

Update the prediction of a single input node.
"""
function update_node_input!(node::AbstractInputNode, input::Union{Real,Missing})
    #Receive input
    node.states.input_value = input
    push!(node.history.input_value, node.states.input_value)

    return nothing
end

"""
    update_node_prediction!(node::AbstractInputNode)

Update the posterior of a single input node.
"""
function update_node_prediction!(node::AbstractInputNode)
    #Update prediction volatility
    node.states.prediction_volatility = calculate_prediction_volatility(node)
    push!(node.history.prediction_volatility, node.states.prediction_volatility)

    #Update prediction precision
    node.states.prediction_precision = calculate_prediction_precision(node)
    push!(node.history.prediction_precision, node.states.prediction_precision)

    return nothing
end

"""
    update_node_value_prediction_error!(node::AbstractInputNode)

Update the value prediction error of a single input node.
"""
function update_node_value_prediction_error!(node::AbstractInputNode)

    #Calculate value prediction error
    node.states.value_prediction_error = calculate_value_prediction_error(node)
    push!(node.history.value_prediction_error, node.states.value_prediction_error)

    return nothing
end

"""
    update_node_volatility_prediction_error!(node::AbstractInputNode)

Update the value prediction error of a single input node.
"""
function update_node_volatility_prediction_error!(node::AbstractInputNode)

    #Calculate volatility prediction error, only if there are volatility parents
    if length(node.volatility_parents) > 0
        node.states.volatility_prediction_error =
            calculate_volatility_prediction_error(node)
        push!(
            node.history.volatility_prediction_error,
            node.states.volatility_prediction_error,
        )
    end

    return nothing
end


##############################################
######## Binary Input Node Variations ########
##############################################
"""
    update_node_prediction!(node::BinaryInputNode)

There is no prediction update for binary input nodes, as the prediction precision is constant.
"""
function update_node_prediction!(node::BinaryInputNode)
    return nothing
end

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

"""
    update_node_volatility_prediction_error!(node::BinaryInputNode)

There is no volatility prediction error update for binary input nodes.
"""
function update_node_volatility_prediction_error!(node::BinaryInputNode)
    return nothing
end


###################################################
######## Categorical Input Node Variations ########
###################################################
"""
    update_node_prediction!(node::CategoricalInputNode)

There is no prediction update for categorical input nodes, as the prediction precision is constant.
"""
function update_node_prediction!(node::CategoricalInputNode)
    return nothing
end

"""
    update_node_value_prediction_error!(node::CategoricalInputNode)

    There is no value prediction error update for categorical input nodes.
"""
function update_node_value_prediction_error!(node::CategoricalInputNode)
    return nothing
end

"""
    update_node_volatility_prediction_error!(node::CategoricalInputNode)

There is no volatility prediction error update for categorical input nodes.
"""
function update_node_volatility_prediction_error!(node::CategoricalInputNode)
    return nothing
end
