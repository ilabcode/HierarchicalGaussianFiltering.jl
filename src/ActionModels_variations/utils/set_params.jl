#For parameters other than coupling strengths
function ActionModels.set_params!(hgf::HGF, target_param::Tuple{String,String}, param_value::Any)

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
    if !(Symbol(param_name) in fieldnames(typeof(node.params)))
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
    setfield!(node.params, Symbol(param_name), param_value)
end


#For coupling strengths
function ActionModels.set_params!(
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


    #If the param does not exist in the node
    if !(Symbol(param_name) in fieldnames(typeof(node.params)))
        #Throw an error
        throw(
            ArgumentError(
                "The node $node_name does not have the parameter $param_name in its parameters",
            ),
        )
    end


    #Get coupling_strengths
    coupling_strengths = getfield(node.params, Symbol(param_name))

    #If the specified parent is not in the dictionary
    if !(parent_name in keys(coupling_strengths))
        #Throw an error
        throw(
            ArgumentError(
                "The node $node_name does not have a $param_name to a parent called $parent_name",
            ),
        )
    end

    #Set the coupling strength to the specified parent to the specified value
    coupling_strengths[parent_name] = param_value

end


### For setting multiple parameters ###
"""
"""
function ActionModels.set_params!(hgf::HGF, params::Dict)

    #For each parameter to set
    for (param_key, param_value) in params
        #Set that parameter
        set_params!(hgf, param_key, param_value)
    end
end
