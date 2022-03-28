Base.@kwdef mutable struct ActionStruct
    perceptual_struct
    action_model
    params::Dict{String, Any} = Dict()
    state::Dict{String, Any} = Dict()
    history::Dict{String, Vector{Any}} = Dict()
end


