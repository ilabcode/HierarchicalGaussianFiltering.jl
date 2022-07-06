using Turing
using HGF

my_hgf = HGF.premade_hgf("binary_3level");

my_agent = HGF.premade_agent(
    "hgf_gaussian_response",
    my_hgf,
    Dict("action_noise" => 1),
    Dict(),
    (; node = "x1", state = "posterior_mean"),
);

#HGF.reset!(my_agent)

inputs = [1.,2,3,4,5,6]
responses = HGF.give_inputs!(my_agent, inputs)

fixed_params_list = (action_noise = 1,
 #u_category_means = Real[0.0, 1.0],
  u_input_precision = Inf,
 u_x1_coupling_strenght = 1.0,
  x1_x2_coupling_strenght = 1.0, 
  x1_posterior_mean = 1, 
  x1_posterior_precision = Inf, 
# x2_evolution_rate = -2.0,
  x2_x3_coupling_strenght = 1.0,
   x2_posterior_mean = 1.228593083853502, 
x2_posterior_precision = 1.0476124981933757,
 #x3_evolution_rate = -2.0,
  x3_posterior_mean = 0.9929366601702533, 
x3_posterior_precision = 2.0051641026041525)

params_prior_list = (
    u_category_means =  MvNormal([0.,1],[1. 0 ; 0 1.]),
    x2_evolution_rate = Normal(-2.0,1),
    x3_evolution_rate = Normal(-2.0,1)
)


HGF.set_params!(my_agent, fixed_params_list)

#HGF.get_params(my_agent)

#reduced_inputs = inputs[1:200]
#typeof(responses)
#chain=HGF.fit_model(my_agent,reduced_input,missing,params_prior_list,fixed_params_list)
#response = HGF.get_responses(chain)
@time chain2 =
    HGF.fit_model(my_agent, inputs, responses, params_prior_list, fixed_params_list)
#using Plots
#plot(chain2)
