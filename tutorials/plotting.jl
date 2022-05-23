using HGF
###

#Create HGF
params_list = (;
    u_evolution_rate = log(1e-4),
    x1_evolution_rate = -13.0,
    x2_evolution_rate = -2.0,
    x1_x2_coupling_strength = 1,
)
starting_state_list = (;
    x1_posterior_mean = 1.04,
    x1_posterior_precision = 1e4,
    x2_posterior_mean = 1.0,
    x2_posterior_precision = 10,
)
my_hgf = HGF.premade_hgf("continuous_2level", params_list, starting_state_list);

#Get inputs from data
input = Float64[]
open("data//canonical_input_trajectory.dat") do f
    for ln in eachline(f)
        push!(input, parse(Float64, ln))
    end
end

#Input to HGF
for i in range(1, length(input))
    HGF.update_hgf!(my_hgf, input[i])
end
#my_hgf.state_nodes["x1"].history.posterior_precision = my_hgf.state_nodes["x1"].history.posterior_precision/100000

#Plot
using Plots
hgf_trajectory_plot(my_hgf, "x2", "posterior_mean")
hgf_trajectory_plot!(my_hgf, "x2", "prediction_precision")

hgf_trajectory_plot(my_hgf, "u", "prediction_precision")

hgf_trajectory_plot(my_hgf, "u", "typo")
hgf_trajectory_plot!(my_hgf, "x2", "typo")

hgf_trajectory_plot(my_hgf, "x1", "posterior")
hgf_trajectory_plot(my_hgf, "x1", "prediction")


hgf_trajectory_plot(my_hgf, "x1", "posterior")
hgf_trajectory_plot!(my_hgf, "u"; c = "red", alpha = 0.2)


hgf_trajectory_plot(my_hgf, "u"; c = "red", alpha = 1)

hgf_trajectory_plot(my_hgf, "x1", "posterior")
hgf_trajectory_plot!(my_hgf, "u"; c = "red", alpha = 0.2)

HGF.reset!(my_hgf)

hgf_trajectory_plot(my_hgf, "x1", "posterior")
hgf_trajectory_plot!(my_hgf, "u"; c = "red", alpha = 0.2)

for i in range(1, length(input))
    HGF.update_hgf!(my_hgf, input[i])
end

hgf_trajectory_plot(my_hgf, "x1", "posterior")
hgf_trajectory_plot!(my_hgf, "u"; c = "red", alpha = 0.2)


my_agent = HGF.premade_agent(
    "hgf_gaussian_response",
    my_hgf,
    Dict("action_noise" => 0.1),
    Dict(),
    (; node = "x1", state = "posterior_mean"),
);

HGF.reset!(my_agent)
HGF.give_inputs!(my_agent, input)
HGF.set_params(my_agent, (action_noise = 0.01,))
#my_agent.history["action"]

using Plots
hgf_trajectory_plot(my_agent, "action")
hgf_trajectory_plot!(my_agent, "u")
hgf_trajectory_plot!(my_agent, "x1")

