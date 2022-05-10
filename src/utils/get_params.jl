function get_params(agent::AgentStruct)
    params_list = (;)
    for par in keys(agent.params)
        params_list = merge(params_list,(Symbol(par)=>agent.params[par],))
    end
    for node in keys(agent.perception_struct.input_nodes)
        params_list = merge(params_list,(Symbol(node*"_evolution_rate") => agent.perception_struct.input_nodes[node].params.evolution_rate,))
        for parent in agent.perception_struct.input_nodes[node].params.value_coupling
            params_list = merge(params_list,(Symbol(node*"_"*parent[1]*"_coupling_strenght") => parent[2],))
        end
        for parent in agent.perception_struct.input_nodes[node].params.volatility_coupling
            params_list = merge(params_list,(Symbol(node*"_"*parent[1]*"_coupling_strenght") => parent[2],))
        end
    end
    for node in keys(agent.perception_struct.state_nodes)
        params_list = merge(params_list,(Symbol(node*"_evolution_rate") => agent.perception_struct.state_nodes[node].params.evolution_rate,))
        params_list = merge(params_list,(Symbol(node*"_posterior_mean") => agent.perception_struct.state_nodes[node].history.posterior_mean[1],))
        params_list = merge(params_list,(Symbol(node*"_posterior_precision") => agent.perception_struct.state_nodes[node].history.posterior_precision[1],))
        for parent in agent.perception_struct.state_nodes[node].params.value_coupling
            params_list = merge(params_list,(Symbol(node*"_"*parent[1]*"_coupling_strenght") => parent[2],))
        end
        for parent in agent.perception_struct.state_nodes[node].params.volatility_coupling
            params_list = merge(params_list,(Symbol(node*"_"*parent[1]*"_coupling_strenght") => parent[2],))
        end
    end
    return params_list
end