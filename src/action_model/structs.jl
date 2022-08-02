"""
"""
Base.@kwdef mutable struct AgentStruct
    action_model::Function
    perception_struct::Any
    action::Any = missing
    params::Dict{String,Any} = Dict()
    state::Dict{String,Any} = Dict()
    settings::Dict{String,Any} = Dict()
    history::Dict{String,Vector{Any}} = Dict("action" => [])
end
