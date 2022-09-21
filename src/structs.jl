### Abstract node types ###
"""
"""
abstract type AbstractNode end

"""
"""
abstract type AbstractStateNode <: AbstractNode end

"""
"""
abstract type AbstractInputNode <: AbstractNode end

### Continuous state nodes ###
"""
"""
Base.@kwdef mutable struct StateNodeParams
    evolution_rate::Real = 0
    value_coupling::Dict{String,Real} = Dict{String,Real}()
    volatility_coupling::Dict{String,Real} = Dict{String,Real}()
    initial_mean::Real = 0
    initial_precision::Real = 0
end

"""
"""
Base.@kwdef mutable struct StateNodeState
    posterior_mean::Union{Real,Missing} = 0
    posterior_precision::Union{Real,Missing} = 1
    value_prediction_error::Union{Real,Missing} = missing
    volatility_prediction_error::Union{Real,Missing} = missing
    prediction_mean::Union{Real,Missing} = missing
    prediction_volatility::Union{Real,Missing} = missing
    prediction_precision::Union{Real,Missing} = missing
    auxiliary_prediction_precision::Union{Real,Missing} = missing
end

"""
"""
Base.@kwdef mutable struct StateNodeHistory
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
Base.@kwdef mutable struct StateNode <: AbstractStateNode
    name::String
    value_parents::Vector{AbstractStateNode} = []
    volatility_parents::Vector{AbstractStateNode} = []
    value_children::Vector{AbstractNode} = []
    volatility_children::Vector{AbstractNode} = []
    params::StateNodeParams = StateNodeParams()
    states::StateNodeState = StateNodeState()
    history::StateNodeHistory = StateNodeHistory()
end

### Binary state nodes ###
Base.@kwdef mutable struct BinaryStateNodeParams
    value_coupling::Dict{String,Real} = Dict{String,Real}()
    volatility_coupling::Dict{String,Real} = Dict{String,Real}()
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
    volatility_children::Vector{AbstractNode} = []
    params::BinaryStateNodeParams = BinaryStateNodeParams()
    states::BinaryStateNodeState = BinaryStateNodeState()
    history::BinaryStateNodeHistory = BinaryStateNodeHistory()
end

### Continuous input nodes ###
"""
"""
Base.@kwdef mutable struct InputNodeParams
    evolution_rate::Real = 0
    value_coupling::Dict{String,Real} = Dict{String,Real}()
    volatility_coupling::Dict{String,Real} = Dict{String,Real}()
end

"""
"""
Base.@kwdef mutable struct InputNodeState
    input_value::Union{Real,Missing} = missing
    value_prediction_error::Union{Real,Missing} = missing
    volatility_prediction_error::Union{Real,Missing} = missing
    prediction_volatility::Union{Real,Missing} = missing
    prediction_precision::Union{Real,Missing} = missing
    auxiliary_prediction_precision::Union{Real,Missing} = missing
end

"""
"""
Base.@kwdef mutable struct InputNodeHistory
    input_value::Vector{Union{Real,Missing}} = [missing]
    value_prediction_error::Vector{Union{Real,Missing}} = [missing]
    volatility_prediction_error::Vector{Union{Real,Missing}} = [missing]
    prediction_volatility::Vector{Real} = []
    prediction_precision::Vector{Real} = []
    auxiliary_prediction_precision::Vector{Real} = []
end

"""
"""
Base.@kwdef mutable struct InputNode <: AbstractInputNode
    name::String
    value_parents::Vector{AbstractStateNode} = []
    volatility_parents::Vector{AbstractStateNode} = []
    params::InputNodeParams = InputNodeParams()
    states::InputNodeState = InputNodeState()
    history::InputNodeHistory = InputNodeHistory()
end

### Binary input nodes ###
Base.@kwdef mutable struct BinaryInputNodeParams
    category_means::Union{Vector{Real},Missing} = missing
    input_precision::Real = Inf
    value_coupling::Dict{String,Real} = Dict{String,Real}()
    volatility_coupling::Dict{String,Real} = Dict{String,Real}()
end

"""
"""
Base.@kwdef mutable struct BinaryInputNodeState
    input_value::Union{Real,Missing} = missing
    value_prediction_error::Union{Vector{Real},Missing} = missing
end

"""
"""
Base.@kwdef mutable struct BinaryInputNodeHistory
    input_value::Vector{Union{Real,Missing}} = [missing]
    value_prediction_error::Vector{Union{Vector{Real},Missing}} = [missing]
end

"""
"""
Base.@kwdef mutable struct BinaryInputNode <: AbstractInputNode
    name::String
    value_parents::Vector{AbstractStateNode} = []
    volatility_parents::Vector{Nothing} = []
    params::BinaryInputNodeParams = BinaryInputNodeParams()
    states::BinaryInputNodeState = BinaryInputNodeState()
    history::BinaryInputNodeHistory = BinaryInputNodeHistory()
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
    early_prediction_state_nodes::Vector{AbstractStateNode} = []
    late_prediction_state_nodes::Vector{AbstractStateNode} = []
end

"""
"""
Base.@kwdef mutable struct HGFStruct
    all_nodes::Dict{String,AbstractNode}
    input_nodes::Dict{String,AbstractInputNode}
    state_nodes::Dict{String,AbstractStateNode}
    ordered_nodes::OrderedNodes = OrderedNodes()
end

 