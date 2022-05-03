using Turing
function fit_model(
    agent::AgentStruct,
    inputs::Vector{Float64},
    responses::Vector{Float64},
    params_priors_list = []::Vector{Tuple{String,Distribution{Univariate,Continuous}}},
    fixed_params_list = []::Vector{Tuple{String,Real}},
    sampler = NUTS(),
    iterations = 1000,
)
    old_params = get_params(agent)
    change_params(agent::AgentStruct, fixed_params_list)
    @model function fit_hgf(y::Vector{Float64})
        params = Dict()
        for param in params_priors_list
            params[param[1]] ~ param[2]
        end
        reset!(agent)
        params_list = []
        for i in params
            push!(params_list, (i[1], i[2]))
        end
        change_params(agent::AgentStruct, params_list)

        for i in range(1, length(responses))
            y[i] ~ agent.action_model(agent, inputs[i])
        end
    end
    chain = sample(fit_hgf(responses), sampler, iterations)
    change_params(agent, old_params)
    reset!(agent)
    return chain
end
