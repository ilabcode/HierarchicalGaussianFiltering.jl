"""
"""
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

"""
"""
function get_params(node::AbstractNode)
    params_list = (;)
    for param in propertynames(getfield(node,Symbol("params")))
        if param in [:value_coupling, :volatility_coupling]
            for parent in getfield(getfield(node,Symbol("params")),param)
                params_list = merge(params_list,(Symbol(getfield(node,Symbol("name"))*"__"*parent[1]*"_coupling_strenght") => parent[2],)) #clean this up, use node.name, split parent into parent_name and coupling_strength
            end
        else
        params_list = merge(params_list,(Symbol(getfield(node,Symbol("name"))*"__"*string(param)) => getfield(getfield(node,Symbol("params")),param),))
        end
    end
    return params_list
end
