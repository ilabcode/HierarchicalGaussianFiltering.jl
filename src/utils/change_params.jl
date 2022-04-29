function change_params(agent::AgentStruct, params_list=[]::Vector{Tuple{String, Real}})
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
                    setproperty!(agent.perceptual_struct.input_nodes[first_arg].params,Symbol(param_name),feat[2])
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