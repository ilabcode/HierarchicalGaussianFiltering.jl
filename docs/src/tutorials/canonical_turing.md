```@meta
EditURL = "<unknown>/tutorials/canonical_turing.jl"
```

using Turing
using HGF

my_hgf = HGF.premade_hgf("continuous_2level");

my_agent = HGF.premade_agent(
    "hgf_gaussian_action",
    (hgf=my_hgf,
    action_precision = 1,
            target_node = "x1",
            target_state = "posterior_mean"),
);

#HGF.reset!(my_agent)

inputs = Float64[]
open("data//canonical_input_trajectory.dat") do f
    for ln in eachline(f)
        push!(inputs, parse(Float64, ln))
    end
end

first_input = inputs[1]
first20_variance = Turing.Statistics.var(inputs[1:20])

fixed_params_list = (
    u__x1_coupling_strenght = 1.0,
    x1__x2_coupling_strenght = 1.0,
    action_precision = 100,
    # x1_evolution_rate = 7.3,
    # u_evolution_rate = -log(9.39e6),
    # x2_evolution_rate =4.2,
    x2__initial_mean = 1.0,
    # x1_posterior_mean = 1.03,
    x1__initial_precision = 1 / (3.2889e-5),
    # x2_posterior_precision = 1e6,
)

params_prior_list = (
    # u_x1_coupling_strenght = LogNormal(HGF.lognormal_params(1,0.3).mean,HGF.lognormal_params(1,0.3).std),
    u__evolution_rate = Normal(log(first20_variance), 2),
    x1__evolution_rate = Normal(log(first20_variance), 4),
    x2__evolution_rate = Normal(-4, 4),
    #x1__initial_mean = Normal(first_input, sqrt(first20_variance)),
    #x2_posterior_mean = Normal(1,0.3),
    # x1_posterior_precision = LogNormal(HGF.lognormal_params(1/first20_variance,1).mean,HGF.lognormal_params(1/first20_variance,1).std),
    #x2__initial_precision = LogNormal(
    #     HGF.lognormal_params(10, 1).mean,
    #     HGF.lognormal_params(10, 1).std,
    # ),
)

#Turing.Statistics.mean(TruncatedNormal(10,5 ,0,Inf))
#Turing.Statistics.mean(params_prior_list.x1_posterior_precision)

params_list = (
    #u_x1_coupling_strenght = 1.15, 
    u__evolution_rate = -log(9.39e6),
    x1__evolution_rate = -11.86,
    x2__evolution_rate = -5.91,
    x1__initial_mean = 1.0315,
    #x1_posterior_precision =1/(3.2889e-5),
    x2__initial_precision = 1 / 0.0697,
    #x2_posterior_mean = 1.2
)

#typeof(params_list)
#typeof(params_prior_list)

HGF.set_params!(my_agent, params_list)
HGF.set_params!(my_agent, fixed_params_list)

#HGF.get_params(my_agent)

#reduced_inputs = inputs[1:200]

responses = convert.(Float64,HGF.give_inputs!(my_agent, inputs))
#typeof(responses)
#chain=HGF.fit_model(my_agent,reduced_input,missing,params_prior_list,fixed_params_list)
#response = HGF.get_responses(chain)
@time chain2 =
    HGF.fit_model(my_agent, inputs, responses, params_prior_list, fixed_params_list, NUTS(), 500, 10)
#using Plots
#plot(chain2)

using Plots

HGF.predictive_simulation_plot(my_agent, chain2, "x2__posterior_mean", 1000, inputs)

using StatsPlots

posterior_parameter_plot(chain2,params_prior_list)

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*