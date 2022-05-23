#Function to change Agent parameters in a more user-friendly way

function set_params(agent::AgentStruct, params_list = (;)::NamedTuple)
    for feat in keys(params_list)
        #Check if the feature is an agent parameter
        if string(feat) in keys(agent.params)
            agent.params[string(feat)] = getfield(params_list, feat)
            #Check if the feature is an agent state
        elseif string(feat) in keys(agent.state)
            agent.state[string(feat)] = getfield(params_list, feat)
            #Else it's an HGF parameter or starting state
        else
            first_arg = split(string(feat), '_')[1]
            second_arg = split(string(feat), '_')[2]
            #If it is an Input node
            if first_arg in keys(agent.perception_struct.input_nodes)
                #check if it is a value_coupling
                if second_arg in [
                    agent.perception_struct.input_nodes[first_arg].value_parents[i].name for
                    i =
                    1:length(agent.perception_struct.input_nodes[first_arg].value_parents)
                ]
                    agent.perception_struct.input_nodes[first_arg].params.value_coupling[second_arg] =
                        getfield(params_list, feat)
                    #check if it is a volatility_coupling
                elseif second_arg in [
                    my_agent.perception_struct.input_nodes[first_arg].volatility_parents[i].name
                    for i =
                    1:length(
                        agent.perception_struct.input_nodes[first_arg].volatility_parents,
                    )
                ]
                    agent.perception_struct.input_nodes[first_arg].params.volatility_coupling[second_arg] =
                        getfield(params_list, feat)
                    #It is a parameter
                else
                    param_name = split(string(feat), '_', limit = 2)[2]
                    setproperty!(
                        agent.perception_struct.input_nodes[first_arg].params,
                        Symbol(param_name),
                        getfield(params_list, feat),
                    )
                end
                #If it is a state node
            elseif first_arg in keys(agent.perception_struct.state_nodes)
                #check if it is a value_coupling
                if second_arg in [
                    agent.perception_struct.state_nodes[first_arg].value_parents[i].name for
                    i =
                    1:length(agent.perception_struct.state_nodes[first_arg].value_parents)
                ]
                    agent.perception_struct.state_nodes[first_arg].params.value_coupling[second_arg] =
                        getfield(params_list, feat)
                    #check if it is a volatility_coupling
                elseif second_arg in [
                    agent.perception_struct.state_nodes[first_arg].volatility_parents[i].name
                    for i =
                    1:length(
                        agent.perception_struct.state_nodes[first_arg].volatility_parents,
                    )
                ]
                    agent.perception_struct.state_nodes[first_arg].params.volatility_coupling[second_arg] =
                        getfield(params_list, feat)
                else
                    param_name = split(string(feat), '_', limit = 2)[2]
                    #if it's an inital value
                    if param_name in ["posterior_mean", "posterior_precision"]
                        getproperty(
                            agent.perception_struct.state_nodes[first_arg].history,
                            Symbol(param_name),
                        )[1] = getfield(params_list, feat)
                        #if it is a parameter
                    else
                        setproperty!(
                            agent.perception_struct.state_nodes[first_arg].params,
                            Symbol(param_name),
                            getfield(params_list, feat),
                        )
                    end
                end
            end
        end
    end
end