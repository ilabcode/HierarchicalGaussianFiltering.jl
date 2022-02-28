mutable struct hidden_state
    # Index information
    name::String
    children::Vector{Tuple{String,String}} #each tuple contains the name of the child and the relation type
    parents::Vector{Tuple{String,String}}
    # State estimates
    posterior_mean::Vector{AbstractFloat}
    posterior_precision::Vector{AbstractFloat}
    value_prediction_error::Vector{AbstractFloat}
    volatility_prediction_error::Vector{AbstractFloat} #only if there is a volatility parent
    prediction_mean::Vector{AbstractFloat} #change to 'expected mean'
    prediction_precision::Vector{AbstractFloat}#change to 'expected precision'
    auxiliary_prediction_variance::Vector{AbstractFloat} #only if there is a volatility parent
    # Parameters
    evolution_rate::AbstractFloat
    value_coupling::Dict{String, AbstractFloat} #one for each value parent
    volatility_coupling::Dict{String, AbstractFloat} #one for each volatility parent
end
