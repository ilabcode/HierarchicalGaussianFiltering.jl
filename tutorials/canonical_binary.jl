using Turing
using HGF
using Plots

my_hgf = HGF.premade_hgf("binary_3level");

my_agent = HGF.premade_agent(
    "unit_square_sigmoid",
    my_hgf,
    Dict("inverse_noise" => 5),
    Dict(),
);

#HGF.reset!(my_agent)

inputs = Float64[]
open("data//canonical_input_trajectory.dat") do f
    for ln in eachline(f)
        push!(inputs, parse(Float64, ln))
    end
end

HGF.get_params(my_agent)

params_list = (inverse_noise = 5, u_category_means = Real[0.0, 1.0], u_input_precision = Inf, u_x1_coupling_strenght = 1.,
 x1_x2_coupling_strenght = 1.0, x1_posterior_mean = inputs[1], x1_posterior_precision = Inf, x2_evolution_rate = -2.5, 
 x2_x3_coupling_strenght = 1.0, x2_posterior_mean = 0, x2_posterior_precision = 1, x3_evolution_rate = -6.0, 
 x3_posterior_mean = 1, x3_posterior_precision = 1)

HGF.set_params!(my_agent, params_list)
HGF.reset!(my_agent)

#print(HGF.get_history(my_hgf,"x1_prediction_mean"))
responses = HGF.give_inputs!(my_agent, inputs)

hgf_trajectory_plot(my_agent, "x1", "prediction")

fixed_params_list = (inverse_noise = 5, u_category_means = Real[0.0, 1.0], u_input_precision = Inf, 
u_x1_coupling_strenght = 1.,
x1_x2_coupling_strenght = 1.0, x1_posterior_mean = inputs[1],
x1_posterior_precision = Inf,
x2_x3_coupling_strenght = 1.0, x2_posterior_mean = 0, x2_posterior_precision = 1, 
x3_posterior_mean = 1, x3_posterior_precision = 1)

params_prior_list = (
    x2_evolution_rate = Normal(-3.0,16),
    x3_evolution_rate = Normal(-6.0,16)
)


HGF.set_params!(my_agent, fixed_params_list)
HGF.reset!(my_agent)

#HGF.get_params(my_agent)

#reduced_inputs = inputs[1:200]
#typeof(responses)
#chain=HGF.fit_model(my_agent,reduced_input,missing,params_prior_list,fixed_params_list)
#response = HGF.get_responses(chain)
@time chain2 =
    HGF.fit_model(my_agent, inputs, responses, params_prior_list, fixed_params_list)
#using Plots
#plot(chain2)
