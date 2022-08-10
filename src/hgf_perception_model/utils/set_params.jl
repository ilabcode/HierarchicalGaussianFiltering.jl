function set_params!(hgf::HGFStruct, target_param::String, param_value::Real)

    #Get node name and parameter name from the string
    (node_name, param_name) = split(target_param, "__", limit = 2)

    #If the parameter is a couplting strength
    if param_name in ["value_coupling_strength", "volatility_coupling_strength"]

        #Split the node name into the child and the parent
        (child_name, parent_name) = split(node_name, "_", limit=2)

        #Get the child node
        node = hgf.all_nodes[child_name]

        #Set the coupling strength to the specified parent to the specified value
        getfield(node.params, Symbol(param_name))[parent_name] = param_value

    else
        #Get out node
        node = hgf.all_nodes[node_name]

        #Set the parameter value
        setfield!(node.params, Symbol(param_name), param_value)
    end
end



### For setting multiple parameters ###
"""
"""
function set_params!(hgf::HGFStruct, params_list::NamedTuple = (;))

    #For each parameter to set
    for (target_param, param_value) in zip(keys(params_list), params_list)
        #Set that parameter
        set_params!(hgf, String(target_param), param_value)
    end
end