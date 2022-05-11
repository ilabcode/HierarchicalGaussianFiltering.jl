function fit_model(agent::AgentStruct,inputs::Vector{Float64},responses::Union{Vector{Float64},Missing},params_priors_list=(;)::NamedTuple{Distribution},fixed_params_list=(;)::NamedTuple{String, Real}, sampler=NUTS(),iterations=1000)

    old_params = get_params(agent)
    set_params(agent::AgentStruct, fixed_params_list)
    params_name = Dict()
    for param in keys(params_priors_list)
        params_name["params["*string(param)*"]"] = string(param)
    end
    params = Dict()
    @model function fit_hgf(y, ::Type{T} = Float64) where {T}
        if responses === missing
            y = Vector{T}(undef, length(inputs))
        end
        for param in keys(params_priors_list)
            params[string(param)] ~ getfield(params_priors_list,param)
        end
        reset!(agent)
        params_tuple = (;)
        for i in params
            params_tuple = merge(params_tuple, (Symbol(i[1]) => i[2],))
        end
        set_params(agent::AgentStruct, params_tuple)
        for i in range(1,length(inputs))
            y[i] ~ agent.action_model(agent, inputs[i])
        end
    end
    chain=sample(fit_hgf(responses), sampler,iterations)
    new_chain = replacenames(chain, params_name)
    set_params(agent, old_params)
    reset!(agent)
    return new_chain
end
