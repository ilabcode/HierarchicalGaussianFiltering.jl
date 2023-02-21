"""
    get_parameters(hgf::HGF, target_param::Tuple{String,String})

Gets a single parameter value from a specific node in an HGF. A vector of parameters can also be passed.

    get_parameters(hgf::HGF, node_name::String)

Gets all parameter values for a specific node in an HGF. If only a node object is passed, returns all parameters in that node. If only an HGF object is passed, returns all parameters of all nodes in the HGF.
"""
function ActionModels.get_parameters() end

### For getting a specific parameter from a specific node ###
#For parameters other than coupling strengths
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

    #Get the parameter from that node
    param = getproperty(node.parameters, Symbol(param_name))

    return param
end

##For coupling strengths
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
    coupling_strengths = getproperty(node.parameters, Symbol(param_name))

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

function ActionModels.get_parameters(hgf::HGF, target_parameter::String)

    #If the target parameter is a shared parameter
    if target_parameter in keys(hgf.shared_parameters)
        #Acess the parameter value in shared_parameters
        return hgf.shared_parameters[target_parameter].value
        #If the target parameter is a node
    elseif target_parameter in keys(hgf.all_nodes)
        #Take out the node
        node = hgf.all_nodes[target_parameter]
        #Get its parameters
        return get_parameters(node)
    else
        #If the target parameter is neither a node nor in the shared parameters throw an error
        throw(ArgumentError("The node or parameter $target_parameter does not exist in the HGF or in shared parameters"))
    end
end


### For getting multiple parameters ###
function ActionModels.get_parameters(hgf::HGF, target_parameters::Vector)

    #Initialize tuple for storing parameters
    parameters = Dict()

    #Go through each param
    for target_param in target_parameters

        #If the parameter is from a node
        if target_param isa Tuple

            #Get the target parameter of that node and add it to the dict
            parameters[target_param] = get_parameters(hgf, target_param)

            #If the target parameter is a string (a node or shared parameter)
        elseif target_param isa String

            #Get out the parameter value 
            parameter_value = get_parameters(hgf, target_param)

            #Check if the parameter value is a Dict 
            if parameter_value isa Dict
                #Merge the Dict with parameter Dict
                parameters = merge(parameters, parameter_value)

                #If the parameter value is a Real, add to parameter dict
            elseif parameter_value isa Real
                parameters[target_param] = parameter_value

            end
        end
    end

    return parameters
end


### For getting all parameters ###

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

    #If there are shared parameters
    if length(hgf.shared_parameters) > 0
        #Go through each shared parameter
        for (shared_parameter_key, shared_parameter_value) in hgf.shared_parameters
            #Remove derived parameters from the list
            filter!(x -> x[1] ∉ shared_parameter_value.derived_parameters, parameters)
            #Set the shared parameter value
            parameters[shared_parameter_key] = shared_parameter_value.value
        end
    end

    return parameters
end


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