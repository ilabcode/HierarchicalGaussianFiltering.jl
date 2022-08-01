"""
"""
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

"""
"""
function get_params(chain::Chains)
    df = describe(chain)[2]
    params_list = (;)
    for i in 1:getproperty(df,:nrows)
        params_list = merge(params_list, (df.:nt.parameters[i] => getproperty(df.:nt,Symbol("50.0%"))[i],))
    end
    return params_list
end