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
abstract type AbstractParameterCollection end


####################################
######## Concrete Edge Type ########
####################################

mutable struct Edge{T1<:AbstractParameter, T2<:AbstractNode} <: AbstractEdge
    name::String
    child::T1
    parent::T2
    coupling_strength::Union{Nothing, Real}

    #Constructor with name
    Edge(name, child::T1, parent::T2; coupling_strength = nothing) where {T1<:AbstractParameter, T2<:AbstractNode} = new{T1,T2}(name, child, parent, coupling_strength)

    #Constructor with default name
    Edge(child::T1, parent::T2; coupling_strength = nothing) where {T1<:AbstractParameter, T2<:AbstractNode} = begin
        new{T1,T2}(string(parent.name, "__", child.origin.name), child, parent, coupling_strength)
    end
end


#######################################
######## Fixed Value Node Type ########
#######################################
mutable struct FixedValueNode <: AbstractFixedValueNode
    name::String
    value::Real
    children::Vector{Edge{<:AbstractParameter, FixedValueNode}}

    FixedValueNode(name::String, value::Real) = begin
        node = new(name, value, Edge{<:AbstractParameter, FixedValueNode}[])
        return node
    end
end


###########################################
######## Gaussian Random Walk Node ########
###########################################

##### GRW Full Node Type #####
#Type for nodes that transition with a Gaussian random walk (i.e. the classic HGF nodes)
mutable struct GaussianRandomWalkNode{T1, T2, T3} <: AbstractGaussianRandomWalkNode
    name::String
    parameters::T1
    states::T2
    history::T3
    children::Vector{Edge{<:AbstractParameter, GaussianRandomWalkNode}}
    GaussianRandomWalkNode(name::String) = begin
        #Create new node
        node = new{GaussianRandomWalkParameters, GaussianRandomWalkStates, GaussianRandomWalkHistory}()
        #Set the name
        node.name = name
        #Set the parameters
        node.parameters = GaussianRandomWalkParameters(
            GRWDrift(node),
            GRWVolatility(node),
            GRWAutoconnectionStrength(node),
            )
        #Set the states
        node.states = GaussianRandomWalkStates()
        #Set the history
        node.history = GaussianRandomWalkHistory()
        #Set the children
        node.children = Edge{<:AbstractParameter, GaussianRandomWalkNode}[]

        return node
    end
end



###########################################
######## Discrete Random Walk Node ########
###########################################





##############################################
######## Exponential Family Node Node ########
##############################################


