"""
    set_parameters!(hgf::HGF, target_param::Tuple, param_value::Any)

Setting a single parameter value for an HGF. 

    set_parameters!(hgf::HGF, parameter_values::Dict)

Set mutliple parameters values for an HGF. Takes a dictionary of parameter names and values.
"""
# function ActionModels.set_parameters!() end

### For setting a single parameter ###

##For parameters other than coupling strengths and transforms
function ActionModels.set_parameters!(
    hgf::HGF,
    target_param::Tuple{String,String},
    param_value::Any,
)
    #Unpack node name and parameter name
    (node_name, param_name) = target_param

    #If the node does not exist
    if !(node_name in keys(hgf.all_nodes))
        #Throw an error
        throw(ArgumentError("The node $node_name does not exist"))
    end

    #Get out node
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

    #Set the parameter value
    setfield!(node.parameters, Symbol(param_name), param_value)

end

##For coupling strengths
function ActionModels.set_parameters!(
    hgf::HGF,
    target_param::Tuple{String,String,String},
    param_value::Real,
)

    #Unpack node name, parent name and parameter name
    (node_name, parent_name, param_name) = target_param

    #If the node does not exist
    if !(node_name in keys(hgf.all_nodes))
        #Throw an error
        throw(ArgumentError("The node $node_name does not exist"))
    end

    #Get the child node
    node = hgf.all_nodes[node_name]

    #If it is a coupling strength
    if param_name == "coupling_strength"

        #Get coupling_strengths
        coupling_strengths = node.parameters.coupling_strengths

        #If the specified parent is not in the dictionary
        if !(parent_name in keys(coupling_strengths))
            #Throw an error
            throw(
                ArgumentError(
                    "The node $node_name does not have a coupling strength parameter to a parent called $parent_name",
                ),
            )
        end

        #Set the coupling strength to the specified parent to the specified value
        coupling_strengths[parent_name] = param_value

    else

        #Get out the coupling transforms
        coupling_transforms = getproperty(node.parameters, :coupling_transforms)

        #If the specified parent is not in the dictionary
        if !(parent_name in keys(coupling_transforms))
            #Throw an error
            throw(
                ArgumentError(
                    "The node $node_name does not have a coupling transformation to a parent called $parent_name",
                ),
            )
        end

        #If the specified parameter does not exist for the transform
        if !(param_name in keys(coupling_transforms.parameters))
            throw(
                ArgumentError(
                    "There is no parameter called $param_name for the transformation function between $node_name and its parent $parent_name",
                ),
            )
        end

        #Set the parameter
        coupling_transforms.parameters[param_name] = param_value
    end
end

### For setting a single parameter ###
function ActionModels.set_parameters!(hgf::HGF, target_param::String, param_value::Real)
    #If the target parameter is not in the shared parameters
    if !(target_param in keys(hgf.parameter_groups))
        throw(
            ArgumentError(
                "the parameter $target_param is a string, but is not in the HGF's grouped parameters. Check that it is specified correctly",
            ),
        )
    end

    #Get out the shared parameter struct
    parameter_group = hgf.parameter_groups[target_param]

    #Set the value in the parameter group
    setfield!(parameter_group, :value, param_value)

    #Get out the grouped parameters
    grouped_parameters = parameter_group.grouped_parameters

    #For each grouped parameter
    for grouped_parameter_key in grouped_parameters
        #Set the parameter
        set_parameters!(hgf, grouped_parameter_key, param_value)
    end
end

### For setting multiple parameters ###
function ActionModels.set_parameters!(hgf::HGF, parameters::Dict)
    #For each parameter
    for (param_key, param_value) in parameters
        #Set the parameter
        set_parameters!(hgf, param_key, param_value)
    end
end
