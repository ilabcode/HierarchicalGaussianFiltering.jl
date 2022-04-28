using Turing
function change_params(agent::ActionStruct, params_list=[]::Vector{Tuple{String, Real}})
    for feat in params_list
        if feat[1] in keys(agent.params)
            agent.params[feat[1]] = feat[2]
        elseif feat[1] in keys(agent.state)
            agent.state[feat[1]] = feat[2]
        else
            first_arg = split(feat[1],'_')[1]
            second_arg = split(feat[1],'_')[2]
            if first_arg in keys(agent.perceptual_struct.input_nodes)
                if second_arg in [agent.perceptual_struct.input_nodes[first_arg].value_parents[i].name for i in 1:length(agent.perceptual_struct.input_nodes[first_arg].value_parents)]
                    agent.perceptual_struct.input_nodes[first_arg].params.value_coupling[second_arg] = feat[2]
                elseif second_arg in [my_agent.perceptual_struct.input_nodes[first_arg].volatility_parents[i].name for i in 1:length(agent.perceptual_struct.input_nodes[first_arg].volatility_parents)]
                    agent.perceptual_struct.input_nodes[first_arg].params.volatility_coupling[second_arg] = feat[2]
                else
                    param_name = split(feat[1],'_',limit=2)[2]
                    agent.perceptual_struct.input_nodes[first_arg].params.param_name = feat[2]
                end
            elseif  first_arg in keys(agent.perceptual_struct.state_nodes)
                if second_arg in [agent.perceptual_struct.state_nodes[first_arg].value_parents[i].name for i in 1:length(agent.perceptual_struct.state_nodes[first_arg].value_parents)]
                    agent.perceptual_struct.state_nodes[first_arg].params.value_coupling[second_arg] = feat[2]
                elseif second_arg in [agent.perceptual_struct.state_nodes[first_arg].volatility_parents[i].name for i in 1:length(agent.perceptual_struct.state_nodes[first_arg].volatility_parents)]
                    agent.perceptual_struct.state_nodes[first_arg].params.volatility_coupling[second_arg] = feat[2]
                else
                    param_name = split(feat[1],'_',limit=2)[2]
                    setproperty!(agent.perceptual_struct.state_nodes[first_arg].params,Symbol(param_name),feat[2])
                end
            end
        end
    end
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
#         give_inputs!(my_agent, [input[i]])
#         y[i]~my_agent.distr
#     end
# end

# chain=sample(fit_hgf(response), HMC(0.05,10),1000)

# using Plots

# plot(chain["omegain"])