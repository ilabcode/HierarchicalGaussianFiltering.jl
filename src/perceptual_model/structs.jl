abstract type AbstractNode end
Base.@kwdef mutable struct NodeParams
    evolution_rate::Real = 0
    value_coupling::Dict{String,Real} = Dict{String,Real}()
    volatility_coupling::Dict{String,Real} = Dict{String,Real}()
end
Base.@kwdef mutable struct NodeState
    posterior_mean::Real = 0
    posterior_precision::Real = 1
    value_prediction_error::Union{Real,Missing} = missing
    volatility_prediction_error::Union{Real,Missing} = missing
    prediction_mean::Real = 0
    prediction_volatility::Real = 0
    prediction_precision::Real = 0
    auxiliary_prediction_precision::Real = 0
end
Base.@kwdef mutable struct NodeHistory
    posterior_mean::Vector{Real} = []
    posterior_precision::Vector{Real} = []
    value_prediction_error::Vector{Union{Real,Missing}} = [missing]
    volatility_prediction_error::Vector{Union{Real,Missing}} = [missing]
    prediction_mean::Vector{Real} = []
    prediction_volatility::Vector{Real} = []
    prediction_precision::Vector{Real} = []
    auxiliary_prediction_precision::Vector{Real} = []
end
Base.@kwdef mutable struct StateNode <: AbstractNode
    name::String
    value_parents = []
    volatility_parents = []
    value_children = []
    volatility_children = []
    params::NodeParams = NodeParams()
    state::NodeState = NodeState()
    history::NodeHistory = NodeHistory()
end
Base.@kwdef mutable struct InputNodeParams
    evolution_rate::Real = 0
    value_coupling::Dict{String,Real} = Dict{String,Real}()
    volatility_coupling::Dict{String,Real} = Dict{String,Real}()
end
Base.@kwdef mutable struct InputNodeState
    input_value::Union{Real,Missing} = missing
    value_prediction_error::Union{Real,Missing} = missing
    volatility_prediction_error::Union{Real,Missing} = missing
    prediction_volatility::Real = 0
    prediction_precision::Real = 0
    auxiliary_prediction_precision::Real = 0
end
Base.@kwdef mutable struct InputNodeHistory
    input_value::Vector{Union{Real,Missing}} = [missing]
    value_prediction_error::Vector{Union{Real,Missing}} = [missing]
    volatility_prediction_error::Vector{Union{Real,Missing}} = [missing]
    prediction_volatility::Vector{Real} = []
    prediction_precision::Vector{Real} = []
    auxiliary_prediction_precision::Vector{Real} = []
end
Base.@kwdef mutable struct InputNode <: AbstractNode
    name::String
    value_parents = []
    volatility_parents = []
    params::InputNodeParams = InputNodeParams()
    state::InputNodeState = InputNodeState()
    history::InputNodeHistory = InputNodeHistory()
end

mutable struct HGFStruct
    perceptual_model
    input_nodes::Dict{String,InputNode}
    state_nodes::Dict{String,StateNode}
    ordered_input_nodes::Vector{InputNode}
    ordered_state_nodes::Vector{StateNode}
end
