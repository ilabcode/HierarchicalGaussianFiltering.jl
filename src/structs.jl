############################
######## Node Types ########
############################

abstract type AbstractNode end

abstract type AbstractStateNode <: AbstractNode end

abstract type AbstractInputNode <: AbstractNode end


#######################################
######## Continuous State Node ########
#######################################
"""
"""
Base.@kwdef mutable struct ContinuousStateNodeParameters
    evolution_rate::Real = 0
    value_coupling::Dict{String,Real} = Dict{String,Real}()
    volatility_coupling::Dict{String,Real} = Dict{String,Real}()
    initial_mean::Real = 0
    initial_precision::Real = 0
end

"""
"""
Base.@kwdef mutable struct ContinuousStateNodeState
    posterior_mean::Union{Real} = 0
    posterior_precision::Union{Real} = 1
    value_prediction_error::Union{Real,Missing} = missing
    volatility_prediction_error::Union{Real,Missing} = missing
    prediction_mean::Union{Real,Missing} = missing
    prediction_volatility::Union{Real,Missing} = missing
    prediction_precision::Union{Real,Missing} = missing
    auxiliary_prediction_precision::Union{Real,Missing} = missing
end

"""
"""
Base.@kwdef mutable struct ContinuousStateNodeHistory
    posterior_mean::Vector{Real} = []
    posterior_precision::Vector{Real} = []
    value_prediction_error::Vector{Union{Real,Missing}} = [missing]
    volatility_prediction_error::Vector{Union{Real,Missing}} = [missing]
    prediction_mean::Vector{Real} = []
    prediction_volatility::Vector{Real} = []
    prediction_precision::Vector{Real} = []
    auxiliary_prediction_precision::Vector{Real} = []
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
end


###################################
######## Binary State Node ########
###################################

"""
"""
Base.@kwdef mutable struct BinaryStateNodeParameters
    value_coupling::Dict{String,Real} = Dict{String,Real}()
end

"""
"""
Base.@kwdef mutable struct BinaryStateNodeState
    posterior_mean::Union{Real,Missing} = missing
    posterior_precision::Union{Real,Missing} = missing
    value_prediction_error::Union{Real,Missing} = missing
    prediction_mean::Union{Real,Missing} = missing
    prediction_precision::Union{Real,Missing} = missing
end

"""
"""
Base.@kwdef mutable struct BinaryStateNodeHistory
    posterior_mean::Vector{Union{Real,Missing}} = []
    posterior_precision::Vector{Union{Real,Missing}} = []
    value_prediction_error::Vector{Union{Real,Missing}} = [missing]
    prediction_mean::Vector{Real} = []
    prediction_precision::Vector{Real} = []
end

"""
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
end


########################################
######## Categorical State Node ########
########################################
Base.@kwdef mutable struct CategoricalStateNodeParameters end

"""
"""
Base.@kwdef mutable struct CategoricalStateNodeState
    posterior::Vector{Union{Real,Missing}} = []
    value_prediction_error::Vector{Union{Real,Missing}} = []
    prediction::Vector{Real} = []
end

"""
"""
Base.@kwdef mutable struct CategoricalStateNodeHistory
    posterior::Vector{Vector{Union{Real,Missing}}} = []
    value_prediction_error::Vector{Vector{Union{Real,Missing}}} = []
    prediction::Vector{Vector{Real}} = []
end

"""
"""
Base.@kwdef mutable struct CategoricalStateNode <: AbstractStateNode
    name::String
    category_parent_order::Vector{String} = []
    value_parents::Vector{AbstractStateNode} = []
    volatility_parents::Vector{Nothing} = []
    value_children::Vector{AbstractNode} = []
    volatility_children::Vector{Nothing} = []
    parameters::CategoricalStateNodeParameters = CategoricalStateNodeParameters()
    states::CategoricalStateNodeState = CategoricalStateNodeState()
    history::CategoricalStateNodeHistory = CategoricalStateNodeHistory()
end


#######################################
######## Continuous Input Node ########
#######################################
"""
"""
Base.@kwdef mutable struct ContinuousInputNodeParameters
    evolution_rate::Real = 0
    value_coupling::Dict{String,Real} = Dict{String,Real}()
    volatility_coupling::Dict{String,Real} = Dict{String,Real}()
end

"""
"""
Base.@kwdef mutable struct ContinuousInputNodeState
    input_value::Union{Real,Missing} = missing
    value_prediction_error::Union{Real,Missing} = missing
    volatility_prediction_error::Union{Real,Missing} = missing
    prediction_volatility::Union{Real,Missing} = missing
    prediction_precision::Union{Real,Missing} = missing
    auxiliary_prediction_precision::Union{Real} = 1
end

"""
"""
Base.@kwdef mutable struct ContinuousInputNodeHistory
    input_value::Vector{Union{Real,Missing}} = [missing]
    value_prediction_error::Vector{Union{Real,Missing}} = [missing]
    volatility_prediction_error::Vector{Union{Real,Missing}} = [missing]
    prediction_volatility::Vector{Real} = []
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
"""
Base.@kwdef mutable struct BinaryInputNodeParameters
    category_means::Vector{Union{Real}} = [0, 1]
    input_precision::Real = Inf
end

"""
"""
Base.@kwdef mutable struct BinaryInputNodeState
    input_value::Union{Real,Missing} = missing
    value_prediction_error::Vector{Union{Real,Missing}} = [missing, missing]
end

"""
"""
Base.@kwdef mutable struct BinaryInputNodeHistory
    input_value::Vector{Union{Real,Missing}} = [missing]
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
"""
Base.@kwdef mutable struct CategoricalInputNodeState
    input_value::Union{Real,Missing} = missing
end

"""
"""
Base.@kwdef mutable struct CategoricalInputNodeHistory
    input_value::Vector{Union{Real,Missing}} = [missing]
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



### Full HGF struct ###
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
