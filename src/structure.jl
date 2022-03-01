abstract type AbstractNode end
mutable struct Node <: AbstractNode
    # Index information
    name::String
    value_parents #vectors of identifiers
    volatility_parents
    value_children
    volatility_children
    # State estimates
    posterior_mean::Vector{AbstractFloat}
    posterior_precision::Vector{AbstractFloat}
    value_prediction_error::Vector{AbstractFloat}
    volatility_prediction_error::Vector{AbstractFloat}
    prediction_mean::Vector{AbstractFloat} #change to 'expected mean'
    prediction_precision::Vector{AbstractFloat}#change to 'expected precision'
    auxiliary_prediction_variance::Vector{AbstractFloat} #only if there is a volatility parent
    # Parameters
    evolution_rate::AbstractFloat
    value_coupling::Dict{String, AbstractFloat} #one for each value parent (NB: Maybe here use identifiers instead of string)
    volatility_coupling::Dict{String, AbstractFloat} #one for each volatility parent
end

mutable struct InputNode <: AbstractNode
    name
    parents
    children
end