# using HGF
# params_list =
#     (; u_evolution_rate = log(1e-4), x1_evolution_rate = -13.0, x2_evolution_rate=-2.0, x1_x2_coupling_strength = 1)
# starting_state_list =
#     (; x1_posterior_mean = 1.04, x1_posterior_precision = 1e4, x2_posterior_mean = 1.0, x2_posterior_precision=10,)
# my_hgf=HGF.premade_hgf("continuous_2level",params_list,starting_state_list)
# input=Float64[]
# open("test//forward_model//canonical_test//data//canonical_input_trajectory.dat") do f
#     for ln in eachline(f)
#         push!(input,parse(Float64, ln))
#     end
# end
# for i in range(1, length(input))
#     HGF.update_hgf!(my_hgf, input[i])
# end
# my_hgf.state_nodes["x1"].history.posterior_mean
# my_hgf.input_nodes["u"].history.input_value
# using Plots
# #print(my_hgf.state_nodes["x1"].history.posterior_precision)

# trajectory_plot(my_hgf,"x1","posterior")
# trajectory_plot!(my_hgf,"u")
# trajectory_plot!(my_hgf,"x1","value_prediction_error")
# trajectory_plot(my_hgf,"x2","prediction")
# trajectory_plot!(my_hgf,"u")
# trajectory_plot!(my_hgf,"x1","volatility_prediction_error")
