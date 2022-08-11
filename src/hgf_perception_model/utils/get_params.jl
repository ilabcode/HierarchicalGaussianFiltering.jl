"""
"""
function get_params(hgf::HGFStruct)
    #Initialize empty list for populating with parameter values
    params_list = (;)

    #Go through each node
    for node in hgf.ordered_nodes.all_nodes
        #Add its parameters to the list
        params_list = merge(params_list, get_params(node))
    end

    return params_list
end

"""
"""
function get_params(node::AbstractNode)

    #Initialize empty list for populating with parameter values
    params_list = (;)
    
    #Go through each parameter
    for param_name in fieldnames(typeof(node.params))

        #If the paramater is a value coupling strength
        if param_name in [:value_coupling, :volatility_coupling]

            #Go through each of the parents
            for (coupling_parent_name, coupling) in getproperty(node.params, param_name)
                #Set the full param name which also includes the node's name and the parent's name
                full_param_name = Symbol(node.name * "_" * coupling_parent_name * "__" * String(param_name))
                #Add the coupling strength to the parameter list
                params_list = merge(params_list, (Symbol(full_param_name) => coupling,))
            end

        #For other parameters
        else
            #Set the full param name which also includes the node's name
            full_param_name = node.name * "__" * String(param_name)
            #Add it to the parameter list
            params_list = merge(params_list, (Symbol(full_param_name) => getfield(node.params, param_name),))
        end
    end

    return params_list
end
