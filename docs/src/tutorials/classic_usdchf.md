```@meta
EditURL = "<unknown>/tutorials/classic_usdchf.jl"
```

````@example classic_usdchf
using HGF
````

inputs = Float64[]
open("data//canonical_input_trajectory.dat") do f
    for ln in eachline(f)
        push!(inputs, parse(Float64, ln))
    end
end

my_hgf = HGF.premade_hgf("continuous_2level");

agent_params_list = (;
            action_precision = 1,
            target_node = "x1",
            target_state = "posterior_mean");

my_agent = HGF.premade_agent(
    "hgf_gaussian_action",
    my_hgf,
    agent_params_list
);

HGF.get_params(my_agent)

params_list = (
    u__x1_coupling_strenght = 1.0,
    x1__x2_coupling_strenght = 1.0,
    u__evolution_rate = -log(9.39e6),
    x1__evolution_rate = -11.8557,
    x2__evolution_rate = -5.9085,
    x1__initial_mean = 1.0315,
    x1__initial_precision = 1 / (3.2889e-5),
    x2__initial_mean = 1.0,
    x2__initial_precision = 1 / 0.0697,
    action_precision = 100,
)

HGF.set_params!(my_agent, params_list)

HGF.reset!(my_agent)

HGF.give_inputs!(my_agent, inputs)

HGF.get_history(my_agent,"action")

using Plots
using LaTeXStrings

# hgf_trajectory_plot(my_agent, "u",
# size=(1300,500),
# xlims = (0,614),
# markerstrokecolor = :auto,
# markersize=3,
# markercolor = "green2")

hgf_trajectory_plot(
    my_agent,
    "u",
    size = (1300, 500),
    xlims = (0, 615),
    markerstrokecolor = :auto,
    markersize = 3,
    markercolor = "green2",
)
hgf_trajectory_plot!(my_agent, "x1", "posterior_mean", color = "red", linewidth = 1.5)

hgf_trajectory_plot(
    my_agent,
    "x2",
    color = "blue",
    size = (1300, 500),
    xlims = (0, 615),
    title = L"Posterior\:expectation\,of\,x_{2}",
)

params_list_2 = (
    u__x1_coupling_strenght = 1.0,
    x1__x2_coupling_strenght = 1.0,
    u__evolution_rate = -log(1e4),
    x1__evolution_rate = -13,
    x2__evolution_rate = -2,
    x1__initial_mean = 1.04,
    x1__initial_precision = 1 / (0.0001),
    x2__initial_mean = 1.0,
    x2__initial_precision = 1 / 0.1,
    action_precision = 100,
)

HGF.set_params!(my_agent, params_list_2)
HGF.reset!(my_agent)

responses = HGF.give_inputs!(my_agent, inputs)
responses = Float64.(responses)

pyplot()

hgf_trajectory_plot(my_agent, "u",
size=(1300,500),
xlims = (0,615),
markerstrokecolor = :auto,
markersize=3,
markercolor = "green2",
title ="Agent simulation",
ylabel="CHF-USD exchange rate",
xlabel="Trading days since 1 January 2010"
)

hgf_trajectory_plot!(my_agent, "x1", "posterior_mean",
color="red",
linewidth=1.5)
hgf_trajectory_plot!(my_agent, "action",
size=(1300,500),
xlims = (0,614),
markerstrokecolor = :auto,
markersize=3,
markercolor = "orange",
)

hgf_trajectory_plot(
    my_agent,
    "x2",
    color = "blue",
    size = (1300, 500),
    xlims = (0, 615),
    title = L"Posterior\:expectation\,of\,x_{2}",
    xlabel="Trading days since 1 January 2010"
)

using Turing

first_input = inputs[1]
first20_variance = Turing.Statistics.var(inputs[1:20])

fixed_params_list = (
u__x1_coupling_strenght = 1.0,
x1__x2_coupling_strenght = 1.0,
action_precision =100,
x2__initial_mean = 1.,
x1__initial_precision = 1/first20_variance,
x2__initial_precision = 600.
)

params_prior_list = (
u__evolution_rate = Normal(log(first20_variance),2),
x1__evolution_rate = Normal(log(first20_variance),4),
x2__evolution_rate = Normal(-4,4),
x1__initial_mean = Normal(first_input,sqrt(first20_variance)),
#x1_posterior_precision = Truncated(LogNormal(HGF.lognormal_params(1/first20_variance,1).mean,HGF.lognormal_params(1/first20_variance,1).std),0,2/first20_variance),
#x2_posterior_precision = LogNormal(HGF.lognormal_params(10,1).mean,HGF.lognormal_params(10,1).std),
)

HGF.predictive_simulation_plot(my_agent, params_prior_list, "x1__posterior_mean", 1000, inputs;title = "x1__posterior_mean")

chain2 = HGF.fit_model(
    my_agent,
    inputs,
    responses,
    params_prior_list,
    fixed_params_list,
    NUTS(),
    1000,
)

HGF.predictive_simulation_plot(my_agent, chain2, "x1__posterior_mean", 1000, inputs;title = "x2__posterior_mean")

fitted_params = HGF.get_params(chain2)

HGF.set_params!(my_agent, fitted_params)
HGF.reset!(my_agent)

responses = HGF.give_inputs!(my_agent, inputs)

hgf_trajectory_plot(
    my_agent,
    "u",
    size = (1300, 500),
    xlims = (0, 615),
    markerstrokecolor = :auto,
    markersize = 3,
    markercolor = "green2",
)
hgf_trajectory_plot!(my_agent, "x1", "posterior_mean", color = "red", linewidth = 1.5)
hgf_trajectory_plot!(
    my_agent,
    "action",
    size = (1300, 500),
    xlims = (0, 614),
    markerstrokecolor = :auto,
    markersize = 3,
    markercolor = "orange",
)

hgf_trajectory_plot(
    my_agent,
    "x2",
    color = "blue",
    size = (1300, 500),
    xlims = (0, 615),
    title = L"Posterior\:expectation\,of\,x_{2}",
)

chain2

using StatsPlots

posterior_parameter_plot(chain2,params_prior_list)

-log(1e4)

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

