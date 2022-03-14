abstract type AbstractNode end
# Base.@kwdef mutable struct NodeParams
#     evolution_rate::AbstractFloat = 0.5 #change this
#     value_coupling::Dict{String, AbstractFloat} = Dict{String, AbstractFloat}()
#     volatility_coupling::Dict{String, AbstractFloat}  = Dict{String, AbstractFloat}()
# end

# Base.@kwdef mutable struct NodeStates
#     posterior_mean::AbstractFloat = 0.5
#     posterior_precision::AbstractFloat = 0.5
#     value_prediction_error::AbstractFloat = 0.5
#     volatility_prediction_error::AbstractFloat = 0.5
#     prediction_mean::AbstractFloat = 0.5
#     prediction_volatility::AbstractFloat = 0.5
#     prediction_precision::AbstractFloat = 0.5 
#     auxiliary_prediction_precision::AbstractFloat = 0.5
# end
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
Base.@kwdef mutable struct StateNode <: AbstractNode
    # Index information
    name::String
    value_parents = []
    volatility_parents = []
    value_children = []
    volatility_children = []
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

# Base.@kwdef mutable struct StateNode <: AbstractNode
#     # Index information
#     name::String
#     value_parents = false
#     volatility_parents = false
#     value_children = false
#     volatility_children = false
#     # Parameters
#     params::NodeParams = NodeParams()
#     # State estimates
#     state::NodeStates = NodeStates()
#     # History
#     history::NodeHistory = NodeHistory()
# end

Base.@kwdef mutable struct InputNode <: AbstractNode #THIS IS A DUMMY
        # Index information
        name::String
        value_parents = []
        volatility_parents = []
        value_children = []
        volatility_children = []
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

mutable struct HGFModel 
    input_nodes::Dict{String, InputNode}
    state_nodes::Dict{String, StateNode}
end