using Turing
using HGF

my_hgf = HGF.premade_hgf("continuous_2level");
my_action_model = HGF.gaussian_response
my_pars = Dict("standard_deviation" => 0.5)
starting_state = Dict("action" => 0.0)

my_agent = HGF.init_agent(
    my_hgf,
    my_action_model,
    my_pars,
    starting_state
);

inputs = Float64[]
open("data//canonical_input_trajectory.dat") do f
    for ln in eachline(f)
        push!(inputs, parse(Float64, ln))
    end
end

params_list = [("x1_evolution_rate", 5.), ("x2_evolution_rate", 3.5), ("x1_posterior_mean", 1.36),
 ("x1_posterior_precision", 20.) , ("x2_posterior_precision", 35.3)]

HGF.change_params(my_agent,params_list)

HGF.get_params(my_agent)

responses = HGF.get_responses(my_agent, inputs)

first_input = inputs[1]
first20_variance = Turing.Statistics.var(inputs[1:20])

fixed_params_list = [("u_evolution_rate", 1),("x2_posterior_mean", 1.0), ("u_x1_coupling_strenght", 1.0), ("x1_x2_coupling_strenght", 1.0)]
params_prior_list = [("x1_evolution_rate", LogNormal(first20_variance, 16)), ("x2_evolution_rate", LogNormal(4, 16)), ("x1_posterior_mean", Normal(first_input, first20_variance)), ("x1_posterior_precision", LogNormal(first20_variance, 1)), ("x2_posterior_precision", LogNormal(0.1, 1))]

#chain=HGF.fit_model(my_agent,reduced_input,missing,params_prior_list,fixed_params_list)
#response = HGF.get_responses(chain)

chain2=HGF.fit_model(my_agent,inputs,responses,params_prior_list,fixed_params_list)