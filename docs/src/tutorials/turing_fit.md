```@meta
EditURL = "<unknown>/tutorials/turing_fit.jl"
```

using Turing
using HGF

my_hgf = HGF.premade_hgf("continuous_2level");

my_agent = HGF.premade_agent(
    "hgf_gaussian_action",
    (hgf = my_hgf,)
);

inputs = [1,2,3,4]
# inputs = Float64[]
# open("data//canonical_input_trajectory.dat") do f
#     for ln in eachline(f)
#         push!(inputs, parse(Float64, ln))
#     end
# end

first_input = inputs[1]
#first20_variance = Turing.Statistics.var(inputs[1:20])
first20_variance = 1
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
    x1__initial_mean = Normal(first_input, first20_variance),
    x1__initial_precision = LogNormal(first20_variance, 1),
    x2__initial_precision = LogNormal(0.1, 1),
)

Turing.Statistics.mean(params_prior_list.x2__evolution_rate)

params_list = (x1__evolution_rate = 11.09, x2__evolution_rate = 7.08)

HGF.set_params!(my_agent, params_list)
HGF.set_params!(my_agent, fixed_params_list)

HGF.get_params(my_agent)

HGF.reset!(my_agent)
responses = convert.(Float64, HGF.give_inputs!(my_agent, inputs))

# params_name = Dict()
# for param in keys(params_prior_list)
#     params_name["params["*string(param)*"]"] = string(param)
# end
# params_name
# @model function fit_hgf(y::Vector{Float64})
#     x1__evolution_rate ~ Uniform(0, 1)
#     x2__evolution_rate ~ Uniform(0, 1)
#     omegain ~ truncated(Normal(0, 1),0, Inf)
#     kin_1 ~ Uniform(0, 1)
#     k1_2 ~ Uniform(0, 1)
#     std_dev ~ Uniform(0, 1)

#     HGF.reset!(my_agent)

#     my_agent.perception_struct.input_nodes["u"].params.evolution_rate = omegain
#     my_agent.perception_struct.state_nodes["x1"].params.evolution_rate = omega1
#     my_agent.perception_struct.state_nodes["x2"].params.evolution_rate = omega2
#     my_agent.perception_struct.input_nodes["u"].params.value_coupling["x1"] = kin_1
#     my_agent.perception_struct.state_nodes["x1"].params.volatility_coupling["x2"] = k1_2
#     my_agent.params["standard_deviation"] = std_dev

#     for i in range(1,length(responses))
#         y[i] ~ my_agent.action_model(my_agent, inputs[i])
#     end
# end
# nchains =2
# chains = map(i -> sample(fit_hgf(responses), HMC(0.05,10),1000), 1:nchains)
# chains = chainscat(chains...)
# new_chains = replacenames(chains, params_name)
# new_chains
# chain=sample(fit_hgf(responses), HMC(0.05,10),1000)
# using Plots
# posterior_parameter_plot(chains, params_prior_list)
# using Plots

# plot(chain["omegain"])
function fit_model(my_agent, inputs, responses, nchains = 2)
    old_params = HGF.get_params(my_agent)
    @model function fit_hgf(y::Vector{Float64})
        params = Dict()
        params["x1__evolution_rate"] ~ TruncatedNormal(10, 7, 0, Inf)
        params["x2__evolution_rate"] ~ TruncatedNormal(7, 3, 0, Inf)
        # params["post_mean_1"] ~ Normal(first_input, first20_variance)
        # params["post_prec_1"] ~  LogNormal(first20_variance, 1)
        # params["post_prec_2"] ~ LogNormal(0.1, 1)

        #my_agent.perception_struct.state_nodes["x1"].history.posterior_mean[1] = params["post_mean_1"]
        my_agent.perception_struct.state_nodes["x1"].params.evolution_rate =
            params["x1__evolution_rate"]
        my_agent.perception_struct.state_nodes["x2"].params.evolution_rate =
            params["x2__evolution_rate"]
        # my_agent.perception_struct.state_nodes["x2"].history.posterior_precision[1] =  params["post_prec_2"]
        # my_agent.perception_struct.state_nodes["x1"].history.posterior_precision[1] = params["post_prec_1"]

        HGF.reset!(my_agent)

        for i in range(1, length(inputs))
            y[i] ~ my_agent.action_model(my_agent, inputs[i])
        end
    end
    #@time chain = sample(fit_hgf(responses), HMC(0.05, 10), 1000)
    chains = map(i -> sample(fit_hgf(responses), HMC(0.05,10),1000), 1:nchains)
    chains = chainscat(chains...)

    HGF.set_params!(my_agent, old_params)
    HGF.reset!(my_agent)
    return chains
end

chain = fit_model(my_agent, inputs, responses,1)

describe(chain)[1]
using Plots

plot(chain["omegain"])

params_prior_list = [
    ("u_evolution_rate", Normal(0, 1)),
    ("x1_evolution_rate", Normal(2, 1)),
    ("standard_deviation", Uniform(1, 3)),
    ("x2_posterior_mean", Uniform(1, 2)),
]
fixed_params_list = [
    ("x2_evolution_rate", 7.0),
    ("u_x1_coupling_strenght", 6.0),
    ("action", 5.0),
    ("x1_posterior_mean", 1.04),
]
chain = HGF.fit_model(my_agent, input, missing, params_prior_list, fixed_params_list)

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

