################################
######## Abstract Types ########
################################

#Top-level node type
abstract type AbstractNode end

#Input and state node subtypes
abstract type AbstractStateNode <: AbstractNode end
abstract type AbstractInputNode <: AbstractNode end

#Supertype for HGF update types
abstract type HGFUpdateType end

#Classic and enhance dupdate types
struct ClassicUpdate <: HGFUpdateType end
struct EnhancedUpdate <: HGFUpdateType end


#######################################
######## Continuous State Node ########
#######################################
"""
Configuration of continuous state nodes' parameters
"""
Base.@kwdef mutable struct ContinuousStateNodeParameters
    volatility::Real = 0
    drift::Real = 0
    autoregression_target::Real = 0
    autoregression_strength::Real = 0
    value_coupling::Dict{String,Real} = Dict{String,Real}()
    volatility_coupling::Dict{String,Real} = Dict{String,Real}()
    initial_mean::Real = 0
    initial_precision::Real = 0
end

"""
Configurations of the continuous state node states
"""
Base.@kwdef mutable struct ContinuousStateNodeState
    posterior_mean::Union{Real} = 0
    posterior_precision::Union{Real} = 1
    value_prediction_error::Union{Real,Missing} = missing
    volatility_prediction_error::Union{Real,Missing} = missing
    prediction_mean::Union{Real,Missing} = missing
    predicted_volatility::Union{Real,Missing} = missing
    prediction_precision::Union{Real,Missing} = missing
    volatility_weighted_prediction_precision::Union{Real,Missing} = missing
end

"""
Configuration of continuous state node history
"""
Base.@kwdef mutable struct ContinuousStateNodeHistory
    posterior_mean::Vector{Real} = []
    posterior_precision::Vector{Real} = []
    value_prediction_error::Vector{Union{Real,Missing}} = [missing]
    volatility_prediction_error::Vector{Union{Real,Missing}} = [missing]
    prediction_mean::Vector{Real} = []
    predicted_volatility::Vector{Real} = []
    prediction_precision::Vector{Real} = []
    volatility_weighted_prediction_precision::Vector{Real} = []
end

"""
"""
Base.@kwdef mutable struct ContinuousStateNode <: AbstractStateNode
    name::String
    value_parents::Vector{AbstractStateNode} = []
    volatility_parents::Vector{AbstractStateNode} = []
    value_children::Vector{AbstractNode} = []
    volatility_children::Vector{AbstractNode} = []
    parameters::ContinuousStateNodeParameters = ContinuousStateNodeParameters()
    states::ContinuousStateNodeState = ContinuousStateNodeState()
    history::ContinuousStateNodeHistory = ContinuousStateNodeHistory()
    update_type::HGFUpdateType = ClassicUpdate()
end


###################################
######## Binary State Node ########
###################################

"""
 Configure parameters of binary state node
"""
Base.@kwdef mutable struct BinaryStateNodeParameters
    value_coupling::Dict{String,Real} = Dict{String,Real}()
end

"""
Overview of the states of the binary state node
"""
Base.@kwdef mutable struct BinaryStateNodeState
    posterior_mean::Union{Real,Missing} = missing
    posterior_precision::Union{Real,Missing} = missing
    value_prediction_error::Union{Real,Missing} = missing
    prediction_mean::Union{Real,Missing} = missing
    prediction_precision::Union{Real,Missing} = missing
end

"""
Overview of the history of the binary state node
"""
Base.@kwdef mutable struct BinaryStateNodeHistory
    posterior_mean::Vector{Union{Real,Missing}} = []
    posterior_precision::Vector{Union{Real,Missing}} = []
    value_prediction_error::Vector{Union{Real,Missing}} = [missing]
    prediction_mean::Vector{Real} = []
    prediction_precision::Vector{Real} = []
end

"""
Overview of edge posibilities 
"""
Base.@kwdef mutable struct BinaryStateNode <: AbstractStateNode
    name::String
    value_parents::Vector{AbstractStateNode} = []
    volatility_parents::Vector{Nothing} = []
    value_children::Vector{AbstractNode} = []
    volatility_children::Vector{Nothing} = []
    parameters::BinaryStateNodeParameters = BinaryStateNodeParameters()
    states::BinaryStateNodeState = BinaryStateNodeState()
    history::BinaryStateNodeHistory = BinaryStateNodeHistory()
    update_type::HGFUpdateType = ClassicUpdate()
end


########################################
######## Categorical State Node ########
########################################
Base.@kwdef mutable struct CategoricalStateNodeParameters end

"""
Configuration of states in categorical state node
"""
Base.@kwdef mutable struct CategoricalStateNodeState
    posterior::Vector{Union{Real,Missing}} = []
    value_prediction_error::Vector{Union{Real,Missing}} = []
    prediction::Vector{Real} = []
    parent_predictions::Vector{Real} = []
end

"""
Configuration of history in categorical state node
"""
Base.@kwdef mutable struct CategoricalStateNodeHistory
    posterior::Vector{Vector{Union{Real,Missing}}} = []
    value_prediction_error::Vector{Vector{Union{Real,Missing}}} = []
    prediction::Vector{Vector{Real}} = []
    parent_predictions::Vector{Vector{Real}} = []
end

"""
Configuration of edges in categorical state node
"""
Base.@kwdef mutable struct CategoricalStateNode <: AbstractStateNode
    name::String
    value_parents::Vector{AbstractStateNode} = []
    volatility_parents::Vector{Nothing} = []
    value_children::Vector{AbstractNode} = []
    volatility_children::Vector{Nothing} = []
    category_parent_order::Vector{String} = []
    parameters::CategoricalStateNodeParameters = CategoricalStateNodeParameters()
    states::CategoricalStateNodeState = CategoricalStateNodeState()
    history::CategoricalStateNodeHistory = CategoricalStateNodeHistory()
    update_type::HGFUpdateType = ClassicUpdate()
end


#######################################
######## Continuous Input Node ########
#######################################
"""
Configuration of continuous input node parameters
"""
Base.@kwdef mutable struct ContinuousInputNodeParameters
    input_noise::Real = 0
    value_coupling::Dict{String,Real} = Dict{String,Real}()
    volatility_coupling::Dict{String,Real} = Dict{String,Real}()
end

"""
Configuration of continuous input node states
"""
Base.@kwdef mutable struct ContinuousInputNodeState
    input_value::Union{Real,Missing} = missing
    input_time::Union{Real,Missing} = missing
    value_prediction_error::Union{Real,Missing} = missing
    volatility_prediction_error::Union{Real,Missing} = missing
    predicted_volatility::Union{Real,Missing} = missing
    prediction_precision::Union{Real,Missing} = missing
    volatility_weighted_prediction_precision::Union{Real} = 1
end

"""
Configuration of continuous input node history
"""
Base.@kwdef mutable struct ContinuousInputNodeHistory
    input_value::Vector{Union{Real,Missing}} = [missing]
    input_time::Vector{Union{Real,Missing}} = [missing]
    value_prediction_error::Vector{Union{Real,Missing}} = [missing]
    volatility_prediction_error::Vector{Union{Real,Missing}} = [missing]
    predicted_volatility::Vector{Real} = []
    prediction_precision::Vector{Real} = []
end

"""
"""
Base.@kwdef mutable struct ContinuousInputNode <: AbstractInputNode
    name::String
    value_parents::Vector{AbstractStateNode} = []
    volatility_parents::Vector{AbstractStateNode} = []
    parameters::ContinuousInputNodeParameters = ContinuousInputNodeParameters()
    states::ContinuousInputNodeState = ContinuousInputNodeState()
    history::ContinuousInputNodeHistory = ContinuousInputNodeHistory()
end



###################################
######## Binary Input Node ########
###################################

"""
Configuration of parameters in binary input node. Default category mean set to [0,1]
"""
Base.@kwdef mutable struct BinaryInputNodeParameters
    category_means::Vector{Union{Real}} = [0, 1]
    input_precision::Real = Inf
end

"""
Configuration of states of binary input node
"""
Base.@kwdef mutable struct BinaryInputNodeState
    input_value::Union{Real,Missing} = missing
    input_time::Union{Real,Missing} = missing 
    value_prediction_error::Vector{Union{Real,Missing}} = [missing, missing]
end

"""
Configuration of history of binary input node
"""
Base.@kwdef mutable struct BinaryInputNodeHistory
    input_value::Vector{Union{Real,Missing}} = [missing]
    input_time::Vector{Union{Real,Missing}} = [missing]
    value_prediction_error::Vector{Vector{Union{Real,Missing}}} = [[missing, missing]]
end

"""
"""
Base.@kwdef mutable struct BinaryInputNode <: AbstractInputNode
    name::String
    value_parents::Vector{AbstractStateNode} = []
    volatility_parents::Vector{Nothing} = []
    parameters::BinaryInputNodeParameters = BinaryInputNodeParameters()
    states::BinaryInputNodeState = BinaryInputNodeState()
    history::BinaryInputNodeHistory = BinaryInputNodeHistory()
end




########################################
######## Categorical Input Node ########
########################################

Base.@kwdef mutable struct CategoricalInputNodeParameters end

"""
Configuration of states of categorical input node
"""
Base.@kwdef mutable struct CategoricalInputNodeState
    input_value::Union{Real,Missing} = missing
    input_time::Union{Real,Missing} = missing

end

"""
History of categorical input node
"""
Base.@kwdef mutable struct CategoricalInputNodeHistory
    input_value::Vector{Union{Real,Missing}} = [missing]
    input_time::Vector{Union{Real,Missing}} = [missing]

end

"""
"""
Base.@kwdef mutable struct CategoricalInputNode <: AbstractInputNode
    name::String
    value_parents::Vector{AbstractStateNode} = []
    volatility_parents::Vector{Nothing} = []
    parameters::CategoricalInputNodeParameters = CategoricalInputNodeParameters()
    states::CategoricalInputNodeState = CategoricalInputNodeState()
    history::CategoricalInputNodeHistory = CategoricalInputNodeHistory()
end


############################
######## HGF Struct ########
############################
"""
"""
Base.@kwdef mutable struct OrderedNodes
    all_nodes::Vector{AbstractNode} = []
    input_nodes::Vector{AbstractInputNode} = []
    all_state_nodes::Vector{AbstractStateNode} = []
    early_update_state_nodes::Vector{AbstractStateNode} = []
    late_update_state_nodes::Vector{AbstractStateNode} = []
end

"""
"""
Base.@kwdef mutable struct HGF
    all_nodes::Dict{String,AbstractNode}
    input_nodes::Dict{String,AbstractInputNode}
    state_nodes::Dict{String,AbstractStateNode}
    ordered_nodes::OrderedNodes = OrderedNodes()
    shared_parameters::Dict = Dict()
end
