using Turing
using HGF

my_hgf = HGF.premade_hgf("continuous_2level");

my_agent = HGF.premade_agent(
    "hgf_gaussian_response",
    my_hgf,
    Dict("action_noise" => 1),
    Dict(),
    (; node = "x1", state = "posterior_mean"),
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

fixed_params_list = (u_evolution_rate = 1.,x2_posterior_mean = 1.0, u_x1_coupling_strenght = 1.0, 
x1_x2_coupling_strenght = 1.0,action_noise =2., x2_evolution_rate =7.97)
params_prior_list = (x1_evolution_rate = TruncatedNormal(10,7 ,0,Inf), 
x1_posterior_mean = Normal(first_input, first20_variance), x1_posterior_precision = LogNormal(first20_variance, 1),
x2_posterior_precision = LogNormal(0.1, 1))

#Turing.Statistics.mean(TruncatedNormal(10,5 ,0,Inf))
#Turing.Statistics.mean(params_prior_list.x1_evolution_rate)

params_list = (x1_evolution_rate = 12.2, x1_posterior_mean = 1.03,
 x1_posterior_precision = 1.64 , x2_posterior_precision = 1.82)

typeof(params_list)
typeof(params_prior_list)

 
HGF.set_params(my_agent,params_list)
HGF.set_params(my_agent,fixed_params_list)

HGF.get_params(my_agent)

reduced_inputs = inputs[1:200]

responses = HGF.give_inputs!(my_agent, reduced_inputs)
#typeof(responses)
#chain=HGF.fit_model(my_agent,reduced_input,missing,params_prior_list,fixed_params_list)
#response = HGF.get_responses(chain)
@time chain2=HGF.fit_model(my_agent,reduced_inputs,responses,params_prior_list,fixed_params_list)