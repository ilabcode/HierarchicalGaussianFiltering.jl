################################
######## Abstract types ########
################################

##### Abstract Node Types #####
#Type for nodes
abstract type AbstractNode end

#Type for nodes that transition (i.e. depend on their previous timepoint), and nodes that do not - and for fixed values
abstract type AbstractTransitionNode <: AbstractNode end
abstract type AbstractStationaryNode <: AbstractNode end
abstract type AbstractFixedValueNode <: AbstractNode end

#Type for nodes that transition with a Gaussian random walk (i.e. the classic HGF nodes)
abstract type AbstractGaussianRandomWalkNode <: AbstractTransitionNode end
#Type for nodes that transition as a discrete random walk
abstract type AbstractDiscreteRandomWalkNode <: AbstractTransitionNode end

#Type for exponential family nodes (that do not transition)
abstract type AbstractExponentialFamilyNode <: AbstractStationaryNode end


##### Abstract edge Type #####
abstract type AbstractEdge end

##### Abstract parameter Type #####
abstract type AbstractParameter end



####################################
######## Concrete Edge Type ########
####################################

mutable struct Edge{T1<:AbstractParameter, T2<:AbstractNode} <: AbstractEdge
    child::T1
    parent::T2
    coupling_strength::Union{Nothing, Real}
    Edge(child::T1, parent::T2, coupling_strength::Union{Nothing, Real}) where {T1<:AbstractParameter, T2<:AbstractNode} = new{T1,T2}(child, parent, coupling_strength)
end


####################################
######## Fixed Value Node Type ########
####################################
mutable struct FixedValueNode <: AbstractFixedValueNode
    value::Real
end


###########################################
######## Gaussian Random Walk node ########
###########################################

##### GRW Parameter Types #####
#Abstract parameter type
abstract type AbstractGRWParameter <: AbstractParameter end

# Type for the drift parameter ρ
struct GRWDrift <: AbstractGRWParameter
    origin
    edges
    GRWDrift(origin) = (@assert origin isa GaussianRandomWalkParameters; new(origin, Union{Edge{GRWDrift, FixedValueNode}, Edge{GRWDrift, GaussianRandomWalkNode}}[]))
end
#Type for the volatility parameter ω
struct GRWVolatility <: AbstractGRWParameter
    origin
    edges
    GRWVolatility(origin) = (@assert origin isa GaussianRandomWalkParameters; new(origin, Union{Edge{GRWVolatility, FixedValueNode}, Edge{GRWVolatility, GaussianRandomWalkNode}}[]))
end

#Type for the autoconnection strength parameter λ
struct GRWAutoconnectionStrength <: AbstractGRWParameter
    origin
    edges
    GRWAutoconnectionStrength(origin) = new{Vector{Edge{GRWAutoconnectionStrength, FixedValueNode}}}(origin, Edge{GRWAutoconnectionStrength, FixedValueNode}[])
end

##### GRW Parameter collection Type #####
#Type for the collection of Gaussian Random Walk parameters
mutable struct GaussianRandomWalkParameters{T<:AbstractGaussianRandomWalkNode}
    origin::T
    ρ::GRWDrift
    ω::GRWVolatility
    λ::GRWAutoconnectionStrength
    #Constructor
    GaussianRandomWalkParameters(origin) = begin
        #confirm that the origin node is a GaussianRandomWalkNode
        @assert origin isa GaussianRandomWalkNode

        #Create struct
        parameters = new{GaussianRandomWalkNode}()

        #Set the origin
        parameters.origin = origin

        #Set the parameters
        parameters.ρ = GRWDrift(parameters)
        parameters.ω = GRWVolatility(parameters)
        parameters.λ = GRWAutoconnectionStrength(parameters)

        return parameters
    end
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

##### GRW Full Node Type #####
#Type for nodes that transition with a Gaussian random walk (i.e. the classic HGF nodes)
mutable struct GaussianRandomWalkNode <: AbstractGaussianRandomWalkNode
    name::String
    parameters::GaussianRandomWalkParameters
    states::GaussianRandomWalkStates
    history::GaussianRandomWalkHistory
    GaussianRandomWalkNode(name::String) = begin
        #Create new node
        node = new()
        #Set the name
        node.name = name
        #Set the parameters
        node.parameters = GaussianRandomWalkParameters(node)
        #Set the states
        node.states = GaussianRandomWalkStates()
        #Set the history
        node.history = GaussianRandomWalkHistory()
        return node
    end
end



ZZ = GaussianRandomWalkNode("Hello")
BB = FixedValueNode(1.0)
EE = Edge(ZZ.parameters.λ, BB, nothing)
push!(ZZ.parameters.λ.edges, EE)




using ActionModels

@model function testmodel(node::GaussianRandomWalkNode, prior_coupling_strength::D1, action::T) where {D1<:Distribution, T<:Real}
    
    noise ~ Beta()

    #sample coupling strength
    coupling_strength ~ prior_coupling_strength
    #Set coupling strength
    first(node.parameters.λ.edges).coupling_strength = coupling_strength

    #Do something with the coupling strength
    mean = first(node.parameters.λ.edges).coupling_strength * 2

    #Sample the action
    action ~ Normal(mean, noise)

end

model = testmodel(ZZ, Uniform(0, 1), 1.0)

using Random
@code_warntype model.f(
    model,
    Turing.VarInfo(model),
    Turing.SamplingContext(
        Random.GLOBAL_RNG, Turing.SampleFromPrior(), Turing.DefaultContext(),
    ),
    model.args...,
)



#TODO: Make pretty print for nodes
#TODO: Make aliases for the parameter names
#TODO: Figure out what to do with Reals