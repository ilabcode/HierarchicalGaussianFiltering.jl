function fit_model(agent::AgentStruct,inputs::Vector{Float64},responses::Union{Vector{Float64},Missing},params_priors_list=[]::Vector{Tuple{String, Distribution}},fixed_params_list=[]::Vector{Tuple{String, Real}}, sampler=NUTS(),iterations=1000)

    old_params = get_params(agent)
    change_params(agent::AgentStruct, fixed_params_list)
    params_name = Dict()
    for param in params_priors_list
        params_name["params["*param[1]*"]"] = param[1]
    end
    params = Dict()

    @model function fit_hgf(y, ::Type{T} = Float64) where {T}
        if responses === missing
            y = Vector{T}(undef, length(inputs))
        end
        for param in params_priors_list
            params[param[1]] ~ param[2]
        end
        reset!(agent)
        params_list = []
        for i in params
            push!(params_list, (i[1], i[2]))
        end
        change_params(agent::AgentStruct, params_list)

        for i in range(1,length(inputs))
            y[i] ~ agent.action_model(agent, inputs[i])
        end
    end
    chain=sample(fit_hgf(responses), sampler,iterations)
    new_chain = replacenames(chain, params_name)
    change_params(agent, old_params)
    reset!(agent)
    return new_chain
end
