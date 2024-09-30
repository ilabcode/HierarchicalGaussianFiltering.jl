##### GRW Parameter Types #####
#Abstract parameter type
abstract type AbstractGRWParameter <: AbstractParameter end

# Type for the drift parameter ρ
struct GRWDrift <: AbstractGRWParameter
    origin::GaussianRandomWalkNode
    edges::Vector{Union{Edge{GRWDrift, FixedValueNode}, Edge{GRWDrift, GaussianRandomWalkNode}}}

    GRWDrift(origin) = new(origin, Union{Edge{GRWDrift, FixedValueNode}, Edge{GRWDrift, GaussianRandomWalkNode}}[])
end
#Type for the volatility parameter ω
struct GRWVolatility <: AbstractGRWParameter
    origin::GaussianRandomWalkNode
    edges::Vector{Union{Edge{GRWDrift, FixedValueNode}, Edge{GRWDrift, GaussianRandomWalkNode}}}

    GRWVolatility(origin) = new(origin, Union{Edge{GRWVolatility, FixedValueNode}, Edge{GRWVolatility, GaussianRandomWalkNode}}[])
end

#Type for the autoconnection strength parameter λ
struct GRWAutoconnectionStrength <: AbstractGRWParameter
    origin::GaussianRandomWalkNode
    edges::Vector{Edge{GRWAutoconnectionStrength, FixedValueNode}}

    GRWAutoconnectionStrength(origin) = new(origin, Edge{GRWAutoconnectionStrength, FixedValueNode}[])
end

#Parameter collection type
mutable struct GaussianRandomWalkParameters <: Abstract ParameterCollection
    drift::GRWDrift
    volatility::GRWVolatility
    autoconnection_strength::GRWAutoconnectionStrength
end

##### GRW States #####
Base.@kwdef mutable struct GaussianRandomWalkStates
    posterior_mean::Real = 0
    posterior_precision::Real = 1
    value_prediction_error::Union{Real,Missing} = missing
    precision_prediction_error::Union{Real,Missing} = missing
    prediction_mean::Union{Real,Missing} = missing
    prediction_precision::Union{Real,Missing} = missing
    effective_prediction_precision::Union{Real,Missing} = missing
end

##### GRW History #####
Base.@kwdef mutable struct GaussianRandomWalkHistory
    posterior_mean::Vector{Real} = []
    posterior_precision::Vector{Real} = []
    value_prediction_error::Vector{Union{Real,Missing}} = []
    precision_prediction_error::Vector{Union{Real,Missing}} = []
    prediction_mean::Vector{Union{Real,Missing}} = []
    prediction_precision::Vector{Union{Real,Missing}} = []
    effective_prediction_precision::Vector{Union{Real,Missing}} = []
end

