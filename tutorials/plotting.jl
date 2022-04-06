using HGF
using Plots

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
my_hgf = HGF.premade_hgf("continuous_2level", params_list, starting_state_list)

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

#Plot
trajectory_plot(my_hgf, "x1", "posterior")


