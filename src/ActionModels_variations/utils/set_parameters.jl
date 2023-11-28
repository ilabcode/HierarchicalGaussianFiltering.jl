"""
    set_parameters!(hgf::HGF, target_param::Tuple, param_value::Any)

Setting a single parameter value for an HGF. 

    set_parameters!(hgf::HGF, parameter_values::Dict)

Set mutliple parameters values for an HGF. Takes a dictionary of parameter names and values.
"""
function ActionModels.set_parameters!() end

### For setting a single parameter ###

##For parameters other than coupling strengths
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

    #If the param is a vector of category_means
    if param_value isa Vector
        #Convert it to a vector of reals
        param_value = convert(Vector{Real}, param_value)
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

    #If the specified parameter is not a coupling strength
    if !(param_name == "coupling_strength")
        throw(
            ArgumentError(
                "the parameter $target_param is specified as three strings, but is not a coupling strength",
            ),
        )
    end

    #If the node does not exist
    if !(node_name in keys(hgf.all_nodes))
        #Throw an error
        throw(ArgumentError("The node $node_name does not exist"))
    end

    #Get the child node
    node = hgf.all_nodes[node_name]

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

end

### For setting a single parameter ###
function ActionModels.set_parameters!(hgf::HGF, target_param::String, param_value::Any)
    #If the target parameter is not in the shared parameters
    if !(target_param in keys(hgf.shared_parameters))
        throw(
            ArgumentError(
                "the parameter $target_param is passed to the HGF but is not in the HGF's shared parameters. Check that it is specified correctly",
            ),
        )
    end

    #Get out the shared parameter struct
    shared_parameter = hgf.shared_parameters[target_param]

    #Set the value in the shared parameter
    setfield!(shared_parameter, :value, param_value)

    #Get out the derived parameters
    derived_parameters = shared_parameter.derived_parameters

    #For each derived parameter
    for derived_parameter_key in derived_parameters
        #Set the parameter
        set_parameters!(hgf, derived_parameter_key, param_value)
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
