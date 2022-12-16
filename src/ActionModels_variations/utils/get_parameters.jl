### For getting a specific params from a specific node ###
#For parameters other than coupling strengths
"""
"""
function ActionModels.get_parameters(hgf::HGF, target_param::Tuple{String,String})

    #Unpack node name and param name
    (node_name, param_name) = target_param


    #If the node does not exist
    if !(node_name in keys(hgf.all_nodes))
        #Throw an error
        throw(ArgumentError("The node $node_name does not exist"))
    end

    #Get out the node
    node = hgf.all_nodes[node_name]


    #If the param does not exist in the node
    if !(Symbol(param_name) in fieldnames(typeof(node.params)))
        #Throw an error
        throw(
            ArgumentError(
                "The node $node_name does not have the parameter $param_name in its parameters",
            ),
        )
    end

    #Get the parameter from that node
    param = getproperty(node.params, Symbol(param_name))

    return param
end

#For coupling strengths
"""
"""
function ActionModels.get_parameters(hgf::HGF, target_param::Tuple{String,String,String})

    #Unpack node name, parent name and param name
    (node_name, parent_name, param_name) = target_param


    #If the node does not exist
    if !(node_name in keys(hgf.all_nodes))
        #Throw an error
        throw(ArgumentError("The node $node_name does not exist"))
    end

    #Get out the node
    node = hgf.all_nodes[node_name]


    #If the parameter does not exist in the node
    if !(Symbol(param_name) in fieldnames(typeof(node.params)))
        #Throw an error
        throw(
            ArgumentError(
                "The node $node_name does not have the parameter $param_name in its parameters",
            ),
        )
    end

    #Get out the dictionary of coupling strengths
    coupling_strengths = getpropery(node.params, Symbol(param_name))


    #If the specified parent is not in the dictionary
    if !(parent_name in keys(coupling_strengths))
        #Throw an error
        throw(
            ArgumentError(
                "The node $node_name does not have a $param_name to a parent called $parent_name",
            ),
        )
    end

    #Get the coupling strength for that given parent
    param = coupling_strengths[parent_name]

    return param
end



### For getting all parameters of a specific node ###
"""
"""
function ActionModels.get_parameters(hgf::HGF, node_name::String)

    #If the node does not exist
    if !(node_name in keys(hgf.all_nodes))
        #Throw an error
        throw(ArgumentError("The node $node_name does not exist"))
    end

    #Get out the node
    node = hgf.all_nodes[node_name]

    #Get its parameters
    return get_parameters(node)
end


### For getting multiple parameters ###
"""
"""
function ActionModels.get_parameters(hgf::HGF, target_parameters::Vector)

    #Initialize tuple for storing params
    params = Dict()

    #Go through each param
    for target_param in target_parameters

        #If a specific parameter has been requested
        if target_param isa Tuple

            #Get the params of that param and add it to the dict
            params[target_param] = get_parameters(hgf, target_param)

            #If all params are requested
        elseif target_param isa String

            #Get out all the parameters from the node
            node_parameters = get_parameters(hgf, target_param)

            #And merge them with the dict
            params = merge(params, node_parameters)
        end
    end

    return params
end


### For getting all parameters ###
"""
"""
function ActionModels.get_parameters(hgf::HGF)

    #Initialize dict for parameters
    params = Dict()

    #For each node
    for node in hgf.ordered_nodes.all_nodes
        #Get out the params of the node
        node_parameters = get_parameters(node)
        #And merge them with the dict
        params = merge(params, node_parameters)
    end

    return params
end


"""
"""
function ActionModels.get_parameters(node::AbstractNode)

    #Initialize dictionary
    params = Dict()

    #Go through all params in the node's params
    for param_key in fieldnames(typeof(node.params))

        #If the parameter is a coupling strength
        if param_key in (:value_coupling, :volatility_coupling)

            #Get out the dict with coupling strengths
            coupling_strengths = getproperty(node.params, param_key)

            #Go through each parent
            for parent_name in keys(coupling_strengths)

                #Add the coupling strength to the ouput dict
                params[(node.name, parent_name, string(param_key))] =
                    coupling_strengths[parent_name]

            end
        else
            #And add their values to the dictionary
            params[(node.name, String(param_key))] = getproperty(node.params, param_key)
        end
    end

    return params
end