#Function to change Agent parameters in a more user-friendly way

function change_params(agent::AgentStruct, params_list=[]::Vector{Tuple{String, Real}})
    for feat in params_list
        #Check if the feature is an agent parameter
        if feat[1] in keys(agent.params)
            agent.params[feat[1]] = feat[2]
        #Check if the feature is an agent state
        elseif feat[1] in keys(agent.state)
            agent.state[feat[1]] = feat[2]
        #Else it's an HGF parameter or starting state
        else
            first_arg = split(feat[1],'_')[1]
            second_arg = split(feat[1],'_')[2]
            #If it is an Input node
            if first_arg in keys(agent.perceptual_struct.input_nodes)
                #check if it is a value_coupling
                if second_arg in [agent.perceptual_struct.input_nodes[first_arg].value_parents[i].name for i in 1:length(agent.perceptual_struct.input_nodes[first_arg].value_parents)]
                    agent.perceptual_struct.input_nodes[first_arg].params.value_coupling[second_arg] = feat[2]
                #check if it is a volatility_coupling
                elseif second_arg in [my_agent.perceptual_struct.input_nodes[first_arg].volatility_parents[i].name for i in 1:length(agent.perceptual_struct.input_nodes[first_arg].volatility_parents)]
                    agent.perceptual_struct.input_nodes[first_arg].params.volatility_coupling[second_arg] = feat[2]
                #It is a parameter
                else
                    param_name = split(feat[1],'_',limit=2)[2]
                    setproperty!(agent.perceptual_struct.input_nodes[first_arg].params,Symbol(param_name),feat[2])
                end
            #If it is a state node
            elseif  first_arg in keys(agent.perceptual_struct.state_nodes)
                #check if it is a value_coupling
                if second_arg in [agent.perceptual_struct.state_nodes[first_arg].value_parents[i].name for i in 1:length(agent.perceptual_struct.state_nodes[first_arg].value_parents)]
                    agent.perceptual_struct.state_nodes[first_arg].params.value_coupling[second_arg] = feat[2]
                #check if it is a volatility_coupling
                elseif second_arg in [agent.perceptual_struct.state_nodes[first_arg].volatility_parents[i].name for i in 1:length(agent.perceptual_struct.state_nodes[first_arg].volatility_parents)]
                    agent.perceptual_struct.state_nodes[first_arg].params.volatility_coupling[second_arg] = feat[2]
                else
                    param_name = split(feat[1],'_',limit=2)[2]
                    #if it's an inital value
                    if param_name in ["posterior_mean","posterior_precision"]
                        getproperty(agent.perceptual_struct.state_nodes[first_arg].history, Symbol(param_name))[1] = feat[2]
                    #if it is a parameter
                    else
                        setproperty!(agent.perceptual_struct.state_nodes[first_arg].params,Symbol(param_name),feat[2])
                    end
                end
            end
        end
    end
end