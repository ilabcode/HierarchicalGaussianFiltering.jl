using Turing
using HGF

my_hgf = HGF.premade_hgf("continuous_2level");
my_action_model = HGF.gaussian_response
my_pars = Dict("standard_deviation" => 0.5)
starting_state = Dict("action" => 0.)
input = [1.,2,3,4]
response = [1., 4,5,6]

my_agent = HGF.init_agent(
    my_hgf,
    my_action_model,
    my_pars,
    starting_state
);


# @model function fit_hgf(y::Vector{Float64})
#     omega1 ~ Uniform(0, 1)
#     omega2 ~ Uniform(0, 1)
#     omegain ~ truncated(Normal(0, 1),0, Inf)
#     kin_1 ~ Uniform(0, 1)
#     k1_2 ~ Uniform(0, 1)
#     std_dev ~ Uniform(0, 1)

#     HGF.reset!(my_agent)

#     my_agent.perceptual_struct.input_nodes["u"].params.evolution_rate = omegain
#     my_agent.perceptual_struct.state_nodes["x1"].params.evolution_rate = omega1
#     my_agent.perceptual_struct.state_nodes["x2"].params.evolution_rate = omega2
#     my_agent.perceptual_struct.input_nodes["u"].params.value_coupling["x1"] = kin_1
#     my_agent.perceptual_struct.state_nodes["x1"].params.volatility_coupling["x2"] = k1_2
#     my_agent.params["standard_deviation"] = std_dev

#     for i in range(1,length(response))
#         y[i]~HGF.give_inputs!(my_agent, input[i])
#     end
# end

# chain=sample(fit_hgf(response), HMC(0.05,10),1000)

# using Plots

# plot(chain["omegain"])

@model function fit_hgf(y::Vector{Float64})
    params = Dict()
    params["omega1"] ~ Uniform(0, 1)
    params["omega2"] ~ Uniform(0, 1)
    params["omegain"] ~ truncated(Normal(0, 1),0, Inf)
    params["kin_1"] ~ Uniform(0, 1)
    params["k1_2"] ~ Uniform(0, 1)
    params["stdev"] ~ Uniform(0, 1)

    HGF.reset!(my_agent)

    my_agent.perceptual_struct.input_nodes["u"].params.evolution_rate = params["omegain"]
    my_agent.perceptual_struct.state_nodes["x1"].params.evolution_rate = params["omega1"]
    my_agent.perceptual_struct.state_nodes["x2"].params.evolution_rate =  params["omega2"]
    my_agent.perceptual_struct.input_nodes["u"].params.value_coupling["x1"] = params["kin_1"]
    my_agent.perceptual_struct.state_nodes["x1"].params.volatility_coupling["x2"] = params["k1_2"]
    my_agent.params["standard_deviation"] = params["stdev"]

    for i in range(1,length(response))
        y[i]~HGF.give_inputs!(my_agent, input[i])
    end
end

chain=sample(fit_hgf(response), HMC(0.05,10),1000)
describe(chain)[1]
using Plots

plot(chain["omegain"])