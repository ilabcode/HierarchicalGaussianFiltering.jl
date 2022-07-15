function get_params(hgf::HGFStruct)
    params_list = (;)
    for node in hgf.input_nodes
        params_list = merge(params_list, get_params(node[2]))
    end
    for node in hgf.state_nodes
        params_list = merge(params_list, get_params(node[2]))
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

function get_params(node::AbstractInputNode)
    params_list = (;)
    for param in propertynames(getfield(node,Symbol("params")))
        if param in [:value_coupling, :volatility_coupling]
            for parent in getfield(getfield(node,Symbol("params")),param)
                params_list = merge(params_list,(Symbol(getfield(node,Symbol("name"))*"__"*parent[1]*"_coupling_strenght") => parent[2],))
            end
        else
        params_list = merge(params_list,(Symbol(getfield(node,Symbol("name"))*"__"*string(param)) => getfield(getfield(node,Symbol("params")),param),))
        end
    end
    return params_list
end

function get_params(node::AbstractStateNode)
    params_list = (;)
    for param in propertynames(getfield(node,Symbol("params")))
        if param in [:value_coupling, :volatility_coupling]
            for parent in getfield(getfield(node,Symbol("params")),param)
                params_list = merge(params_list,(Symbol(getfield(node,Symbol("name"))*"__"*parent[1]*"_coupling_strenght") => parent[2],))
            end
        else
        params_list = merge(params_list,(Symbol(getfield(node,Symbol("name"))*"__"*string(param)) => getfield(getfield(node,Symbol("params")),param),))
        end
    end
    params_list = merge(params_list,(Symbol(getfield(node,Symbol("name"))*"_posterior_mean") => getfield(getfield(node,Symbol("state")),Symbol("posterior_mean"))[1],
    Symbol(getfield(node,Symbol("name"))*"_posterior_precision") => getfield(getfield(node,Symbol("state")),Symbol("posterior_precision"))[1],))
    return params_list
end