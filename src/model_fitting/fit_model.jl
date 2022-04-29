using Turing
function fit_model(agent::AgentStruct,inputs::Vector{Float64},responses::Vector{Float64},params_priors_list=[]::Vector{Tuple{String, Distribution{Univariate,Continuous}}},fixed_params_list=[]::Vector{Tuple{String, Real}}, sampler=NUTS(),iterations=1000)
    change_params(agent::AgentStruct, fixed_params_list)
    @model function fit_hgf(y::Vector{Float64})
        params = Dict()
        for param in params_priors_list
            params[param[1]] ~ param[2]
        end
        reset!(agent)
        params_list = []
        for i in params
            push!(params_list,(i[1],i[2]))
        end
        change_params(agent::AgentStruct, params_list)

        for i in range(1,length(responses))
            y[i] ~ agent.action_model(agent, inputs[i])
        end
    end
    chain=sample(fit_hgf(responses), sampler,iterations)
    return chain
end
# @model function fit_hgf(y::Vector{Float64})
#     omega1 ~ Uniform(0, 1)
#     omega2 ~ Uniform(0, 1)
#     omegain ~ truncated(Normal(0, 1),0, Inf)
#     kin_1 ~ Uniform(0, 1)
#     k1_2 ~ Uniform(0, 1)
#     std_dev ~ Uniform(0, 1)

#     reset!(my_agent)

#     my_agent.perceptual_struct.input_nodes["u"].params.evolution_rate = omegain
#     my_agent.perceptual_struct.state_nodes["x1"].params.evolution_rate = omega1
#     my_agent.perceptual_struct.state_nodes["x2"].params.evolution_rate = omega2
#     my_agent.perceptual_struct.input_nodes["u"].params.value_coupling["x1"] = kin_1
#     my_agent.perceptual_struct.state_nodes["x1"].params.volatility_coupling["x2"] = k1_2
#     my_agent.params["standard_deviation"] = std_dev

#     for i in range(1,length(response))
#         y[i] ~ my_agent.action_model(my_agent, input[i])
#     end
# end

# chain=sample(fit_hgf(response), HMC(0.05,10),1000)

# using Plots

# plot(chain["omegain"])