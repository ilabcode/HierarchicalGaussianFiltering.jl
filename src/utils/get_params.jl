function get_params(agent::AgentStruct)
    params_list = []
    for par in agent.params
        push!(params_list,(par[1],par[2]))
    end
    for st in agent.state
        push!(params_list,(st[1],st[2]))
    end
    for node in keys(agent.perceptual_struct.input_nodes)
        push!(params_list,(node*"_evolution_rate", agent.perceptual_struct.input_nodes[node].params.evolution_rate))
        for parent in agent.perceptual_struct.input_nodes[node].params.value_coupling
            push!(params_list,(node*"_"*parent[1]*"_coupling_strenght", parent[2]))
        end
        for parent in agent.perceptual_struct.input_nodes[node].params.volatility_coupling
            push!(params_list,(node*"_"*parent[1]*"_coupling_strenght", parent[2]))
        end
    end
    for node in keys(agent.perceptual_struct.state_nodes)
        push!(params_list,(node*"_evolution_rate", agent.perceptual_struct.state_nodes[node].params.evolution_rate))
        push!(params_list,(node*"_posterior_mean", agent.perceptual_struct.state_nodes[node].history.posterior_mean[1]))
        push!(params_list,(node*"_posterior_precision", agent.perceptual_struct.state_nodes[node].history.posterior_precision[1]))
        for parent in agent.perceptual_struct.state_nodes[node].params.value_coupling
            push!(params_list,(node*"_"*parent[1]*"_coupling_strenght", parent[2]))
        end
        for parent in agent.perceptual_struct.state_nodes[node].params.volatility_coupling
            push!(params_list,(node*"_"*parent[1]*"_coupling_strenght", parent[2]))
        end
    end
    return params_list
end