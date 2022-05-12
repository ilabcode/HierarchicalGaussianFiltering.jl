using HGF

inputs = Float64[]
open("data//canonical_input_trajectory.dat") do f
    for ln in eachline(f)
        push!(inputs, parse(Float64, ln))
    end
end

my_hgf = HGF.premade_hgf("continuous_2level");

my_agent = HGF.premade_agent(
    "hgf_gaussian_response",
    my_hgf,
    Dict("action_noise" => 1),
    Dict(),
    (; node = "x1", state = "posterior_mean"),
);

params_list = (
u_x1_coupling_strenght = 1.0,
x1_x2_coupling_strenght = 1.0,
u_evolution_rate =-log(9.39e6),
x1_evolution_rate = -11.8557,
x2_evolution_rate =-5.9085,
x1_posterior_mean =1.0315,
x1_posterior_precision =1/(3.2889e-5),
x2_posterior_mean = 1.,
x2_posterior_precision =1/0.0697,
action_noise = 0.01,
)

HGF.set_params(my_agent,params_list)

HGF.reset!(my_agent)

HGF.give_inputs!(my_agent,inputs)

using Plots
using LaTeXStrings

# hgf_trajectory_plot(my_agent, "u",
# size=(1300,500),
# xlims = (0,614),
# markerstrokecolor = :auto,
# markersize=3,
# markercolor = "green2")

hgf_trajectory_plot(my_agent, "u",
size=(1300,500),
xlims = (0,615),
markerstrokecolor = :auto,
markersize=3,
markercolor = "green2")
hgf_trajectory_plot!(my_agent, "x1", "posterior_mean",
color="red",
linewidth=1.5)



hgf_trajectory_plot(my_agent, "x2",
color="blue",
size=(1300,500),
xlims = (0,615),
title =L"Posterior\:expectation\,of\,x_{2}")

params_list_2 = (
u_x1_coupling_strenght = 1.0,
x1_x2_coupling_strenght = 1.0,
u_evolution_rate =-log(1e4),
x1_evolution_rate = -13,
x2_evolution_rate =-2,
x1_posterior_mean =1.04,
x1_posterior_precision =1/(0.0001),
x2_posterior_mean = 1.,
x2_posterior_precision =1/0.1,
action_noise = 0.01,
)

HGF.set_params(my_agent,params_list_2)
HGF.reset!(my_agent)

responses=HGF.give_inputs!(my_agent,inputs)

hgf_trajectory_plot(my_agent, "u",
size=(1300,500),
xlims = (0,615),
markerstrokecolor = :auto,
markersize=3,
markercolor = "green2")
hgf_trajectory_plot!(my_agent, "x1", "posterior_mean",
color="red",
linewidth=1.5)
hgf_trajectory_plot!(my_agent, "action",
size=(1300,500),
xlims = (0,614),
markerstrokecolor = :auto,
markersize=3,
markercolor = "orange")

hgf_trajectory_plot(my_agent, "x2",
color="blue",
size=(1300,500),
xlims = (0,615),
title =L"Posterior\:expectation\,of\,x_{2}")

using Turing

first_input = inputs[1]
first20_variance = Turing.Statistics.var(inputs[1:20])

fixed_params_list = ( 
u_x1_coupling_strenght = 1.0, 
x1_x2_coupling_strenght = 1.0,
action_noise =0.01,
x2_posterior_mean = 1.,
#x1_posterior_precision = first20_variance
)

params_prior_list = (
u_evolution_rate = Normal(log(first20_variance),2),
x1_evolution_rate = Normal(log(first20_variance),4),
x2_evolution_rate = Normal(-4,4),
x1_posterior_mean = Normal(first_input,sqrt(first20_variance)),
x1_posterior_precision = Truncated(LogNormal(HGF.lognormal_params(1/first20_variance,1).mean,HGF.lognormal_params(1/first20_variance,1).std),0,2/first20_variance),
x2_posterior_precision = LogNormal(HGF.lognormal_params(10,1).mean,HGF.lognormal_params(10,1).std),
)

@time chain2=HGF.fit_model(my_agent,inputs,responses,params_prior_list,fixed_params_list,NUTS(),1000)


