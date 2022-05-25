using HGF
using Turing

my_hgf = HGF.premade_hgf("continuous_2level");

my_agent = HGF.premade_agent(
    "hgf_gaussian_response",
    my_hgf,
    Dict("action_noise" => 1),
    Dict(),
    (; node = "x1", state = "posterior_mean"),
);

#HGF.reset!(my_agent)

inputs = [1.,2,3,4]

fixed_params_list = ( 
u_x1_coupling_strenght = 1.0, 
x1_x2_coupling_strenght = 1.0,
action_noise =0.01,
# x1_evolution_rate = 7.3,
# u_evolution_rate = -log(9.39e6),
# x2_evolution_rate =4.2,
x2_posterior_mean = 1.,
# x1_posterior_mean = 1.03,
x1_posterior_precision = 1/(3.2889e-5),
# x2_posterior_precision = 1e6,
)

params_prior_list = (
# u_x1_coupling_strenght = LogNormal(HGF.lognormal_params(1,0.3).mean,HGF.lognormal_params(1,0.3).std),
u_evolution_rate = Normal(log(1),2),
x1_evolution_rate = Normal(log(1),4),
x2_evolution_rate = Normal(-4,4),
x1_posterior_mean = Normal(1,sqrt(1)),
#x2_posterior_mean = Normal(1,0.3),
# x1_posterior_precision = LogNormal(HGF.lognormal_params(1/first20_variance,1).mean,HGF.lognormal_params(1/first20_variance,1).std),
x2_posterior_precision = LogNormal(HGF.lognormal_params(10,1).mean,HGF.lognormal_params(10,1).std),
)

params_list = (
#u_x1_coupling_strenght = 1.15, 
u_evolution_rate =-log(9.39e6),
x1_evolution_rate = -11.86,
x2_evolution_rate =-5.91,
x1_posterior_mean =1.0315,
#x1_posterior_precision =1/(3.2889e-5),
x2_posterior_precision =1/0.0697,
#x2_posterior_mean = 1.2
)

HGF.set_params(my_agent,params_list)
HGF.set_params(my_agent,fixed_params_list)

responses = HGF.give_inputs!(my_agent, inputs)


@time chain2=HGF.fit_model(my_agent,inputs,responses,params_prior_list,fixed_params_list)

using Plots

posterior_parameter_plot(chain2,params_prior_list)



# HGF.get_params(chain2)

# chain2

# distr = LogNormal(0,1)
# Turing.Statistics.quantile(distr,0.5)
# Turing.Statistics.median(distr)

# u_evolution_sampled=Array(chain2[:,"u_evolution_rate",:])[:]

# typeof(u_evolution_sampled)

# quantile(u_evolution_sampled,0.5)

# chain2

# D = Dict()

# for i in keys(params_prior_list)
#     prior = getindex(params_prior_list,i)
#     posterior = Array(chain2[:,String(i),:])[:]
#     D[String(i)] = (;prior_quantiles=Turing.Statistics.quantile(prior,[0.1,0.25,0.5,0.75,0.9]),posterior_quantiles=Turing.Statistics.quantile(posterior,[0.1,0.25,0.5,0.75,0.9]))
# end

# D
# A=Dict()

# A["test"]=(a=Turing.Statistics.quantile(distr,[0.1,0.25,0.5,0.75,0.9]),b=3)

# A

# D["u_evolution_rate"]

# function 