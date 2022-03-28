abstract type AbstractNode end
Base.@kwdef mutable struct NodeParams
    evolution_rate::AbstractFloat = 0.5
    value_coupling::Dict{String,AbstractFloat} = Dict{String,AbstractFloat}()
    volatility_coupling::Dict{String,AbstractFloat} = Dict{String,AbstractFloat}()
end
Base.@kwdef mutable struct NodeState
    posterior_mean::AbstractFloat = 0
    posterior_precision::AbstractFloat = 1
    value_prediction_error::AbstractFloat = 0
    volatility_prediction_error::AbstractFloat = 0
    prediction_mean::AbstractFloat = 0
    prediction_volatility::AbstractFloat = 0
    prediction_precision::AbstractFloat = 0
    auxiliary_prediction_precision::AbstractFloat = 0
end
Base.@kwdef mutable struct NodeHistory
    posterior_mean::Vector{AbstractFloat} = []
    posterior_precision::Vector{AbstractFloat} = []
    value_prediction_error::Vector{AbstractFloat} = []
    volatility_prediction_error::Vector{AbstractFloat} = []
    prediction_mean::Vector{AbstractFloat} = []
    prediction_volatility::Vector{AbstractFloat} = []
    prediction_precision::Vector{AbstractFloat} = []
    auxiliary_prediction_precision::Vector{AbstractFloat} = []
end
Base.@kwdef mutable struct StateNode <: AbstractNode
    # Index information
    name::String
    value_parents = []
    volatility_parents = []
    value_children = []
    volatility_children = []
    # Parameters
    params::NodeParams = NodeParams()
    # States
    state::NodeState = NodeState()
    # History
    history::NodeHistory = NodeHistory()
end
Base.@kwdef mutable struct InputNodeParams
    evolution_rate::AbstractFloat = 0.5
    value_coupling::Dict{String,AbstractFloat} = Dict{String,AbstractFloat}()
    volatility_coupling::Dict{String,AbstractFloat} = Dict{String,AbstractFloat}()
end
Base.@kwdef mutable struct InputNodeState
    input_value::AbstractFloat = 0
    value_prediction_error::AbstractFloat = 0
    volatility_prediction_error::AbstractFloat = 0
    prediction_volatility::AbstractFloat = 0
    prediction_precision::AbstractFloat = 0
end

Base.@kwdef mutable struct InputNodeHistory
    input_value::Vector{AbstractFloat} = []
    value_prediction_error::Vector{AbstractFloat} = []
    volatility_prediction_error::Vector{AbstractFloat} = []
    prediction_volatility::Vector{AbstractFloat} = []
    prediction_precision::Vector{AbstractFloat} = []
end
Base.@kwdef mutable struct InputNode <: AbstractNode
    # Index information
    name::String
    value_parents = []
    volatility_parents = []
    # Parameters
    params::InputNodeParams = InputNodeParams()
    # States
    state::InputNodeState = InputNodeState()
    # History
    history::InputNodeHistory = InputNodeHistory()
end
mutable struct HGFModel
    input_nodes::Dict{String,InputNode}
    state_nodes::Dict{String,StateNode}
    update_order::Vector{StateNode}
end

