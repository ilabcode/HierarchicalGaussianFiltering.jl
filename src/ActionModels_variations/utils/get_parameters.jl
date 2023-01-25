### For getting a specific parameters from a specific node ###
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
    if !(Symbol(param_name) in fieldnames(typeof(node.parameters)))
        #Throw an error
        throw(
            ArgumentError(
                "The node $node_name does not have the parameter $param_name in its parameters",
            ),
        )
    end

        #If the target parameter is in the agents's shared parameters
    if target_param in keys(hgf.shared_parameters)
            #Extract it, take only the value
            param = hgf.shared_parameters[target_param].value
    else      #Get the parameter from that node
        param = getproperty(node.parameters, Symbol(param_name))

    end

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
    if !(Symbol(param_name) in fieldnames(typeof(node.parameters)))
        #Throw an error
        throw(
            ArgumentError(
                "The node $node_name does not have the parameter $param_name in its parameters",
            ),
        )
    end

    #Get out the dictionary of coupling strengths
    coupling_strengths = getpropery(node.parameters, Symbol(param_name))


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

    #Initialize tuple for storing parameters
    parameters = Dict()

    #Go through each param
    for target_param in target_parameters

        #If a specific parameter has been requested
        if target_param isa Tuple

            #Get the parameters of that param and add it to the dict
            parameters[target_param] = get_parameters(hgf, target_param)

            #If all parameters are requested
        elseif target_param isa String

            #Get out all the parameters from the node
            node_parameters = get_parameters(hgf, target_param)

            #And merge them with the dict
            parameters = merge(parameters, node_parameters)
        end
    end

    return parameters
end


### For getting all parameters ###
"""
"""
function ActionModels.get_parameters(hgf::HGF)

    #Initialize dict for parameters
    parameters = Dict()

    #For each node
    for node in hgf.ordered_nodes.all_nodes
        #Get out the parameters of the node
        node_parameters = get_parameters(node)
        #And merge them with the dict
        parameters = merge(parameters, node_parameters)
    end

    return parameters
end


"""
"""
function ActionModels.get_parameters(node::AbstractNode)

    #Initialize dictionary
    parameters = Dict()

    #Go through all parameters in the node's parameters
    for param_key in fieldnames(typeof(node.parameters))

        #If the parameter is a coupling strength
        if param_key in (:value_coupling, :volatility_coupling)

            #Get out the dict with coupling strengths
            coupling_strengths = getproperty(node.parameters, param_key)

            #Go through each parent
            for parent_name in keys(coupling_strengths)

                #Add the coupling strength to the ouput dict
                parameters[(node.name, parent_name, string(param_key))] =
                    coupling_strengths[parent_name]

            end
        else
            #And add their values to the dictionary
            parameters[(node.name, String(param_key))] =
                getproperty(node.parameters, param_key)
        end
    end

    return parameters
end
