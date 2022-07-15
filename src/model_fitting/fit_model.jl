"""
function fit_model(
    agent::AgentStruct,
    inputs::Vector{Float64},
    responses::Union{Vector{Float64},Missing},
    params_priors_list = (;)::NamedTuple{Distribution},
    fixed_params_list = (;)::NamedTuple{String,Real},
    sampler = NUTS(),
    iterations = 1000,
)
Function to fit an agent parameters.
"""

function fit_model(
    agent::AgentStruct,
    inputs::Vector{Float64},
    responses::Union{Vector{Float64},Missing},
    params_priors_list = (;)::NamedTuple{Distribution},
    fixed_params_list = (;)::NamedTuple{String,Real},
    sampler = NUTS(),
    iterations = 1000,
)

    old_params = get_params(agent) #store the parametersofthe HGF
    set_params!(agent::AgentStruct, fixed_params_list) #fix the value of the parameters to be fixed
    params_name = Dict()
    for param in keys(params_priors_list)
        params_name["params["*string(param)*"]"] = string(param)
    end #creates a dictionary to store the parameters names to show in the dataframe at the end
    params = Dict()
    @model function fit_hgf(y, ::Type{T} = Float64) where {T} #creating a turing model macro representing the agent
        if responses === missing
            y = Vector{T}(undef, length(inputs))
        end #in case responses are not given they can be estimated 
        for param in keys(params_priors_list)
            params[string(param)] ~ getfield(params_priors_list, param)
        end #assigning parameters their prior distributions
        reset!(agent)
        params_tuple = (;)
        for i in params
            params_tuple = merge(params_tuple, (Symbol(i[1]) => i[2],))
        end
        set_params!(agent::AgentStruct, params_tuple)
        for i in range(1, length(inputs))
            y[i] ~ agent.action_model(agent, inputs[i])
        end
    end
    chain = sample(fit_hgf(responses), sampler, iterations)
    new_chain = replacenames(chain, params_name)
    set_params!(agent, old_params)
    reset!(agent)
    return new_chain
end
