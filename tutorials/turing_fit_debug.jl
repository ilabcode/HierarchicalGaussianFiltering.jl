using Turing
using HGF

my_hgf = HGF.premade_hgf("continuous_2level");

my_agent = HGF.premade_agent(
    "hgf_gaussian_action",
    (hgf = my_hgf,)
);

inputs = rand(100)
responses = convert.(Float64, HGF.give_inputs!(my_agent, inputs))


# function fit_model(my_agent, inputs, responses, nchains = 2)
#     old_params = HGF.get_params(my_agent)
#     @model function fit_hgf(y::Vector{Float64})
#         params = Dict()
#         params["x1__evolution_rate"] ~ TruncatedNormal(10, 7, 0, Inf)
#         params["x2__evolution_rate"] ~ TruncatedNormal(7, 3, 0, Inf)
#         # params["post_mean_1"] ~ Normal(first_input, first20_variance)
#         # params["post_prec_1"] ~  LogNormal(first20_variance, 1)
#         # params["post_prec_2"] ~ LogNormal(0.1, 1)

#         #my_agent.perception_struct.state_nodes["x1"].history.posterior_mean[1] = params["post_mean_1"]
#         my_agent.perception_struct.state_nodes["x1"].params.evolution_rate =
#             params["x1__evolution_rate"]
#         my_agent.perception_struct.state_nodes["x2"].params.evolution_rate =
#             params["x2__evolution_rate"]
#         # my_agent.perception_struct.state_nodes["x2"].history.posterior_precision[1] =  params["post_prec_2"]
#         # my_agent.perception_struct.state_nodes["x1"].history.posterior_precision[1] = params["post_prec_1"]

#         HGF.reset!(my_agent)

#         for i in range(1, length(inputs))
#             y[i] ~ my_agent.action_model(my_agent, inputs[i])
#         end
#     end
#     #@time chain = sample(fit_hgf(responses), HMC(0.05, 10), 1000)
#     chains = map(i -> sample(fit_hgf(responses), NUTS(),1000), 1:nchains)
#     chains = chainscat(chains...)

#     HGF.set_params!(my_agent, old_params)
#     HGF.reset!(my_agent)
#     return chains
# end

# chain = fit_model(my_agent, inputs, responses,4)

# chain

fixed_params_list = (
    u__evolution_rate = 1.0,
    x2__initial_mean = 1.0,
    u__x1_coupling_strenght = 1.0,
    x1__x2_coupling_strenght = 1.0,
    action_precision = 0.5,
    x1__initial_mean = 1.03,
    x1__initial_precision = 1.64,
    x2__initial_precision = 1.82,
)

params_prior_list = (
    x1__evolution_rate = TruncatedNormal(10, 7, 0, Inf),
    x2__evolution_rate = TruncatedNormal(7, 3, 0, Inf),
)

function fit_model(
    agent::HGF.AgentStruct,
    inputs::Vector{Float64},
    responses::Union{Vector{Float64},Missing},
    params_priors_list = (;)::NamedTuple{Distribution},
    fixed_params_list = (;)::NamedTuple{String,Real},
    sampler = NUTS(),
    iterations = 1000,
    nchains = 1,
)
    old_params = HGF.get_params(agent) #store the parametersofthe HGF
    HGF.set_params!(agent, fixed_params_list) #fix the value of the parameters to be fixed
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
        HGF.reset!(agent)
        params_tuple = (;)
        for i in params
            params_tuple = merge(params_tuple, (Symbol(i[1]) => i[2],))
        end
        HGF.set_params!(agent, params_tuple)
        for i in range(1, length(inputs))
            y[i] ~ agent.action_model(agent, inputs[i])
        end
    end
    chains = map(i -> sample(fit_hgf(responses), sampler, iterations), 1:nchains)
    chains = chainscat(chains...)
    new_chains = replacenames(chains, params_name)
    HGF.set_params!(agent, old_params)
    HGF.reset!(agent)
    return new_chains
end

fit_model(my_agent,inputs,responses,params_prior_list,fixed_params_list, NUTS(),1000,52)