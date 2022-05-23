Base.@kwdef mutable struct AgentStruct
    action_model
    perception_struct
    action = missing
    params::Dict{String, Any} = Dict()
    state::Dict{String, Any} = Dict()
    history::Dict{String, Vector{Float64}} = Dict("action" => [])
end


