Base.@kwdef mutable struct AgentStruct
    perceptual_struct
    action_model
    params::Dict{String, Any} = Dict()
    state::Dict{String, Any} = Dict()
    distr::Distribution = Distributions.Uniform(0,1)
    history::Dict{String, Vector{Any}} = Dict()
end


