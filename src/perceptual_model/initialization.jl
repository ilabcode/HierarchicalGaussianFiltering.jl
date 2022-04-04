"""
    function init_HGF(
        default_params,
        input_nodes,
        state_nodes,
        child_parent_relations,
        update_order = false,
    )

Function for initializing the structure of an HGF model.
"""
function init_HGF(
    node_defaults,
    input_nodes,
    state_nodes,
    child_parent_relations;
    update_order = false,
    verbose = true,
)

    ### Defaults ###
    defaults = (
        params = (; evolution_rate = 0),
        starting_state = (; posterior_mean = 0, posterior_precision = 1),
        coupling_strengths = (; value_coupling_strength = 1, volatility_coupling_strength = 1)
    )

    ### Checks ###

    # Check that all input nodes have at least one value parent
    # Check that no input nodes have more than one value parent (TEMPORARY)

    ### Warnings ###
    if verbose

        ## Check for unspecified node defaults
        #For each parameter in the defaults
        for param_key in keys(defaults.coupling_strengths)
            #If it is not in the node defaults set by the user
            if !(param_key in keys(node_defaults.coupling_strengths))
                #Get the value used instead
                param_value = defaults.coupling_strengths[param_key]
                #Raise a warning
                @warn "node coupling parameter $param_key is not specified in node_defaults. Using $param_value as default."
            end
        end
        #For each parameter in the defaults
        for param_key in keys(defaults.params)
            #If it is not in the node defaults set by the user
            if !(param_key in keys(node_defaults.params))
                #Get the value used instead
                param_value = defaults.params[param_key]
                #Raise a warning
                @warn "node parameter $param_key is not specified in node_defaults. Using $param_value as default."
            end
        end
        #For each starting state in the defaults
        for state_key in keys(defaults.starting_state)
            #If it is not in the node defaults set by the user
            if !(state_key in keys(node_defaults.starting_state))
                #Get the value used instead
                state_value = defaults.starting_state[state_key]
                #Raise a warning
                @warn "node starting state $state_key is not specified in node_defaults. Using $state_value as default."
            end
        end

    end

    ### Initialize nodes ###
    #Initialize empty dictionary for storing nodes
    nodes_dict = Dict()

    ## Input nodes
    #For each specified input node
    for node_info in input_nodes

        #Initialize it, passing global params and specific params
        node = InputNode(
            name = node_info.name,
            params = InputNodeParams(;
                defaults.params...,
                node_defaults.params...,
                node_info.params...,
            ),
            state = InputNodeState(),
        )

        #Add it to the dictionary
        nodes_dict[node.name] = node
    end

    ## State nodes
    #For each specified state node
    for node_info in state_nodes

        #Initialize it, passing global params and specific params
        node = StateNode(
            name = node_info.name,
            params = NodeParams(;
                defaults.params...,
                node_defaults.params...,
                node_info.params...,
            ),
            state = NodeState(;
                defaults.starting_state...,
                node_defaults.starting_state...,
                node_info.starting_state...,
            ),
        )

        #Add it to the dictionary
        nodes_dict[node.name] = node
    end

    ### Set up child-parent relations ###
    #Get node defaults for coupling strengths
    default_coupling_strengths = merge(defaults.coupling_strengths, node_defaults.coupling_strengths)

    #For each child
    for relationship_set in child_parent_relations

        #Find corresponding child node
        child_node = nodes_dict[relationship_set.child_node]

        #For each value parent
        for parent_info in relationship_set.value_parents

            #Check if it is a Tuple or a strind and find corresponding parent node 
            if typeof(parent_info) == String
                parent = nodes_dict[parent_info]
            else
                parent = nodes_dict[parent_info[1]]
            end

            #Add the parent to the child node
            push!(child_node.value_parents, parent)

            #Add the child node to the parent node
            push!(parent.value_children, child_node)

            #Add coupling strength to child node
            if typeof(parent_info) == String
                #If the parent is a string, no coupling strength has been specified. Use the default
                child_node.params.value_coupling[parent_info] = default_coupling_strengths.value_coupling_strength
            else
                #If the parent is a tuple, use the second value, which is the coupling strength
                child_node.params.value_coupling[parent_info[1]] = parent_info[2]
            end
        end

        #For each volatility parent
        for parent_info in relationship_set.volatility_parents

            #Find corresponding parent node
            if typeof(parent_info) == String
                #If its a string just use it to look up
                parent = nodes_dict[parent_info]
            else
                #If its a tuple, the name is the first entry
                parent = nodes_dict[parent_info[1]]
            end
            #Add the parent to the child node
            push!(child_node.volatility_parents, parent)

            #Add the child node to the parent node
            push!(parent.volatility_children, child_node)

            #Add coupling strengths
            if typeof(parent_info) == String
                #If the parent is a string, no coupling strength has been specified. Use the default
                child_node.params.volatility_coupling[parent_info] = default_coupling_strengths.volatility_coupling_strength
            else
                #If the parent is a tuple, use the second value, which is the coupling strength
                child_node.params.volatility_coupling[parent_info[1]] = parent_info[2]
            end
        end
    end

    ### Update order ###
    ## Determine Update order
    #If update order has not been specified
    if .!update_order
        #Initialize empty vector for storing the update order
        update_order = []
        #For each state node, in the order inputted
        for node_info in state_nodes
            #Add the node name to the vector
            push!(update_order, nodes_dict[node_info.name])
        end
    end

    ## Order input nodes
    #Initialize empty vector for storing properly ordered input nodes
    ordered_input_nodes = []

    #For each specified input node, in the order inputted by the user 
    for node_info in input_nodes
        #Add the node to the vector
        push!(ordered_input_nodes, nodes_dict[node_info.name])
    end

    ## Order state nodes
    #Initialize empty vector for storing properly ordered state nodes
    ordered_state_nodes = []

    #For each specified state node, in the order inputted by the user 
    for node_info in state_nodes
        #Add the node to the vector
        push!(ordered_state_nodes, nodes_dict[node_info.name])
    end

    ### Create HGF structure ###
    #Initialize lists
    input_nodes_dict = Dict{String,InputNode}()
    state_nodes_dict = Dict{String,StateNode}()

    #Go through each node
    for (node_name, node) in nodes_dict
        #Put input nodes in one dictionary
        if typeof(node) == InputNode
            input_nodes_dict[node_name] = node

            #Put state nodes in another
        elseif typeof(node) == StateNode
            state_nodes_dict[node_name] = node
        end
    end

    #Create HGF structure containing the lists of nodes
    HGF = HGFStruct(
        update_HGF,
        input_nodes_dict,
        state_nodes_dict,
        ordered_input_nodes,
        ordered_state_nodes,
    )

    ### Initialize predictions and node history ###
    #For each state node
    for node in HGF.ordered_state_nodes

        #Save posterior to node history
        push!(node.history.posterior_mean, node.state.posterior_mean)
        push!(node.history.posterior_precision, node.state.posterior_precision)

        #Calculate predictions and save to node history
        update_node_prediction(node)
    end

    #For each input node
    for node in HGF.ordered_input_nodes
        #Update its prediction
        update_node_prediction(node)
    end

    return HGF
end