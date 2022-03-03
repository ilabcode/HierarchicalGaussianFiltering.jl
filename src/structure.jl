abstract type AbstractNode end
Base.@kwdef mutable struct NodeHistory
    posterior_mean::Vector{AbstractFloat} = [0.5]
    posterior_precision::Vector{AbstractFloat} = [0.5]
    value_prediction_error::Vector{AbstractFloat} = [0.5]
    volatility_prediction_error::Vector{AbstractFloat} = [0.5]
    prediction_mean::Vector{AbstractFloat} = [0.5]
    prediction_volatility::Vector{AbstractFloat} = [0.5]  
    prediction_precision::Vector{AbstractFloat} = [0.5] 
    auxiliary_prediction_precision::Vector{AbstractFloat} = [0.5]
end
Base.@kwdef mutable struct Node <: AbstractNode
    # Index information
    name::String
    value_parents = false
    volatility_parents = false
    value_children = false
    volatility_children = false
    # Parameters
    evolution_rate::AbstractFloat = 0.5 #change this
    value_coupling::Dict{String, AbstractFloat} = Dict{String, AbstractFloat}()
    volatility_coupling::Dict{String, AbstractFloat}  = Dict{String, AbstractFloat}()
    # State estimates
    posterior_mean::AbstractFloat = 0.5
    posterior_precision::AbstractFloat = 0.5
    value_prediction_error::AbstractFloat = 0.5
    volatility_prediction_error::AbstractFloat = 0.5
    prediction_mean::AbstractFloat = 0.5
    prediction_volatility::AbstractFloat = 0.5
    prediction_precision::AbstractFloat = 0.5 
    auxiliary_prediction_precision::AbstractFloat = 0.5
    # History
    history::NodeHistory = NodeHistory()
end

mutable struct InputNode <: AbstractNode
    name
    parents
    children
end