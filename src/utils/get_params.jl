function get_params(hgf::HGFStruct)
    params_list = (;)
    for node in keys(hgf.input_nodes)
        params_list = merge(params_list,(Symbol(node*"_evolution_rate") => hgf.input_nodes[node].params.evolution_rate,))
        for parent in hgf.input_nodes[node].params.value_coupling
            params_list = merge(params_list,(Symbol(node*"_"*parent[1]*"_coupling_strenght") => parent[2],))
        end
        for parent in hgf.input_nodes[node].params.volatility_coupling
            params_list = merge(params_list,(Symbol(node*"_"*parent[1]*"_coupling_strenght") => parent[2],))
        end
    end
    for node in keys(hgf.state_nodes)
        params_list = merge(params_list,(Symbol(node*"_evolution_rate") => hgf.state_nodes[node].params.evolution_rate,))
        params_list = merge(params_list,(Symbol(node*"_posterior_mean") => hgf.state_nodes[node].history.posterior_mean[1],))
        params_list = merge(params_list,(Symbol(node*"_posterior_precision") => hgf.state_nodes[node].history.posterior_precision[1],))
        for parent in hgf.state_nodes[node].params.value_coupling
            params_list = merge(params_list,(Symbol(node*"_"*parent[1]*"_coupling_strenght") => parent[2],))
        end
        for parent in hgf.state_nodes[node].params.volatility_coupling
            params_list = merge(params_list,(Symbol(node*"_"*parent[1]*"_coupling_strenght") => parent[2],))
        end
    end
    return params_list
end

function get_params(agent::AgentStruct)
    params_list = (;)
    for par in keys(agent.params)
        params_list = merge(params_list,(Symbol(par)=>agent.params[par],))
    end
    hgf = agent.perception_struct
    hgf_params = get_params(hgf)
    params_list = merge(params_list, hgf_params)
    return params_list
end


function get_params(chain::Chains)
    df = describe(chain)[2]
    params_list = (;)
    for i in 1:getproperty(df,:nrows)
        params_list = merge(params_list, (df.:nt.parameters[i] => getproperty(df.:nt,Symbol("50.0%"))[i],))
    end
    return params_list
end
