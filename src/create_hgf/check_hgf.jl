"""
    check_hgf(hgf::HGF)
    
Check whether an HGF has specified correctly. A single node can also be passed.
"""
function check_hgf(hgf::HGF)

    ## Check for duplicate names ##
    #Get node names
    node_names = getfield.(hgf.ordered_nodes.all_nodes, :name)
    #If there are any duplicate names
    if length(node_names) > length(unique(node_names))
        #Throw an error
        throw(
            ArgumentError(
                "Some nodes have been given identical names. This is not supported",
            ),
        )
    end

    #If there are shared parameters
    if length(hgf.shared_parameters) > 0

        ## Check for the same derived parameter in multiple shared parameters ##

        #Get all derived parameters
        derived_parameters = [
            parameter for list_of_derived_parameters in [
                hgf.shared_parameters[parameter_key].derived_parameters for
                parameter_key in keys(hgf.shared_parameters)
            ] for parameter in list_of_derived_parameters
        ]
        #Check for duplicate names
        if length(derived_parameters) > length(unique(derived_parameters))
            #Throw an error
            throw(
                ArgumentError(
                    "At least one parameter is set by multiple shared parameters. This is not supported.",
                ),
            )
        end

        ## Check if the shared parameter is part of own derived parameters ##
        #Go through each specified shared parameter
        for (shared_parameter_key, dict_value) in hgf.shared_parameters
            #check if the name of the shared parameter is part of its own derived parameters
            if shared_parameter_key in dict_value.derived_parameters
                throw(
                    ArgumentError(
                        "The shared parameter is part of the list of derived parameters",
                    ),
                )
            end
        end

    end

    ### Check each node ###
    for node in hgf.ordered_nodes.all_nodes
        check_hgf(node)
    end
end

### State Nodes ###
function check_hgf(node::ContinuousStateNode)

    #Extract node name for error messages
    node_name = node.name

    #If there are observation children, disallow noise and volatility children
    if length(node.edges.observation_children) > 0 &&
       (length(node.edges.volatility_children) > 0 || length(node.edges.noise_children) > 0)
        throw(
            ArgumentError(
                "The state node $node_name has observation children. It is not supported for it to also have volatility or noise children, because it disrupts the update order.",
            ),
        )
    end

    #Disallow having the same node as multiple types of connections

    return nothing
end

function check_hgf(node::BinaryStateNode)

    #Extract node name for error messages
    node_name = node.name

    #Require exactly one probability parent
    if length(node.edges.probability_parents) != 1
        throw(
            ArgumentError(
                "The binary state node $node_name does not have exactly one probability parent. This is not supported.",
            ),
        )
    end

    #Require exactly one observation child or category child
    if length(node.edges.observation_children) + length(node.edges.category_children) != 1
        throw(
            ArgumentError(
                "The binary state node $node_name does not have exactly one observation child. This is not supported.",
            ),
        )
    end

    return nothing
end

function check_hgf(node::CategoricalStateNode)

    #Extract node name for error messages
    node_name = node.name

    #Require exactly one value child
    if length(node.edges.observation_children) != 1
        throw(
            ArgumentError(
                "The categorical state node $node_name does not have exactly one observation child. This is not supported.",
            ),
        )
    end

    return nothing
end

### Input Nodes ###
function check_hgf(node::ContinuousInputNode)

    #Extract node name for error messages
    node_name = node.name

    #Disallow multiple observation parents if there are noise parents
    if length(node.edges.noise_parents) > 0 && length(node.edges.observation_parents) > 1
        throw(
            ArgumentError(
                "The input node $node_name has multiple value parents and at least one volatility parent. This is not supported.",
            ),
        )
    end

    return nothing
end

function check_hgf(node::BinaryInputNode)

    #Extract node name for error messages
    node_name = node.name

    #Require exactly one value parent
    if length(node.edges.observation_parents) != 1
        throw(
            ArgumentError(
                "The binary input node $node_name does not have exactly one observation parent. This is not supported.",
            ),
        )
    end

    return nothing
end

function check_hgf(node::CategoricalInputNode)

    #Extract node name for error messages
    node_name = node.name

    #Require exactly one value parent
    if length(node.edges.observation_parents) != 1
        throw(
            ArgumentError(
                "The categorical input node $node_name does not have exactly one observation parent. This is not supported.",
            ),
        )
    end

end
