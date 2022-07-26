"""
    function init_hgf(
        default_params,
        input_nodes,
        state_nodes,
        edges,
        update_order = false,
    )

Function for initializing the structure of an HGF model.
"""
function init_hgf(
    node_defaults::NamedTuple,
    input_nodes::Vector,
    state_nodes::Vector,
    edges::Vector;
    update_order::Bool = false,
    verbose::Bool = true,
)
    ### Checks ###
    # Check that params and starting_state and coupling_strength inputs are always named tuples


    ### Defaults ###
    defaults = (;
        evolution_rate = 0,
        category_means = [0, 1],
        input_precision = Inf,
        initial_mean = 0,
        initial_precision = 1,
        value_coupling_strength = 1,
        volatility_coupling_strength = 1,
    )
    #Use preset defaults wherever user didn't specify a node default
    node_param_defaults = merge(defaults, node_defaults)


    ### Initialize nodes ###
    #Initialize empty dictionaries for storing nodes
    all_nodes_dict = Dict{String,AbstractNode}()
    input_nodes_dict = Dict{String,AbstractInputNode}()
    state_nodes_dict = Dict{String,AbstractStateNode}()

    ## Input nodes ##
    #For each specified input node
    for node_info in input_nodes

        #If only the node's name was specified as a string
        if typeof(node_info) == String
            #Make it into a named tuple
            node_info = (; name = node_info)
        end

        #Make empty named tuples wherever the user didn't specify anything. Default to continuous nodes.
        node_info = merge((; type = "continuous", params = (;)), node_info)

        #Create the node
        node = init_node("input_node", node_param_defaults, node_info)

        #Add it to the dictionary
        all_nodes_dict[node.name] = node
        input_nodes_dict[node.name] = node
    end

    ## State nodes ##
    #For each specified state node
    for node_info in state_nodes

        #If only the node's name was specified as a string
        if typeof(node_info) == String
            #Make it into a named tuple
            node_info = (; name = node_info)
        end

        #Make empty named tuples wherever the user didn't specify anything
        node_info = merge((; type = "continuous", params = (;)), node_info)

        #Create the node
        node = init_node("state_node", node_param_defaults, node_info)

        #Add it to the dictionary
        all_nodes_dict[node.name] = node
        state_nodes_dict[node.name] = node
    end


    ### Set up child-parent relations ###
    #For each child
    for relationship_set in edges

        #Find corresponding child node
        child_node = all_nodes_dict[relationship_set.child_node]

        #Fill the named tuple in case only one type of parentage was specified
        relationship_set =
            merge((; value_parents = [], volatility_parents = []), relationship_set)

        #If there are any value parents
        if length(relationship_set.value_parents) > 0
            #Get out value parents
            value_parents = relationship_set.value_parents

            #If the value parents were not specified as a vector
            if .!isa(value_parents, Vector)
                #Make it into one
                value_parents = [value_parents]
            end

            #For each value parent
            for parent_info in value_parents

                #If only the node's name was specified as a string
                if typeof(parent_info) == String
                    #Make it into a named tuple
                    parent_info = (; name = parent_info)
                end

                #Use the default coupling strength unless it was specified by the user
                parent_info = merge(
                    (; coupling_strength = node_param_defaults.value_coupling_strength),
                    parent_info,
                )

                #Find the corresponding parent
                parent = all_nodes_dict[parent_info.name]

                #Add the parent to the child node
                push!(child_node.value_parents, parent)

                #Add the child node to the parent node
                push!(parent.value_children, child_node)

                #Add coupling strength to child node
                child_node.params.value_coupling[parent_info.name] =
                    parent_info.coupling_strength
            end
        end

        #If there are any volatility parents
        if length(relationship_set.volatility_parents) > 0
            #Get out value parents
            volatility_parents = relationship_set.volatility_parents

            #If the value parents were not specified as a vector
            if .!isa(volatility_parents, Vector)
                #Make it into one
                volatility_parents = [volatility_parents]
            end

            #For each volatility parent
            for parent_info in volatility_parents

                #If only the node's name was specified as a string
                if typeof(parent_info) == String
                    #Make it into a named tuple
                    parent_info = (; name = parent_info)
                end

                #Use the default coupling strength unless it was specified by the user
                parent_info = merge(
                    (; coupling_strength = node_param_defaults.volatility_coupling_strength),
                    parent_info,
                )

                #Find the corresponding parent
                parent = all_nodes_dict[parent_info.name]

                #Add the parent to the child node
                push!(child_node.volatility_parents, parent)

                #Add the child node to the parent node
                push!(parent.volatility_children, child_node)

                #Add coupling strength to child node
                child_node.params.volatility_coupling[parent_info.name] =
                    parent_info.coupling_strength
            end
        end
    end

    ## Determine Update order ##
    #If update order has not been specified
    if .!update_order
        #Initialize empty vector for storing the update order
        update_order = []

        #For each input node, in the order inputted
        for node_info in input_nodes

            #If only the node's name was specified as a string
            if typeof(node_info) == String
                #Make it into a named tuple
                node_info = (; name = node_info)
            end

            #Add the node to the vector
            push!(update_order, all_nodes_dict[node_info.name])
        end

        #For each state node, in the order inputted
        for node_info in state_nodes

            #If only the node's name was specified as a string
            if typeof(node_info) == String
                #Make it into a named tuple
                node_info = (; name = node_info)
            end

            #Add the node to the vector
            push!(update_order, all_nodes_dict[node_info.name])
        end
    end

    ## Order nodes ##
    #Initialize empty struct for storing nodes in correct update order
    ordered_nodes = OrderedNodes()

    #For each node, in the specified update order
    for node in update_order

        #Put input nodes in one vector
        if node isa AbstractInputNode
            push!(ordered_nodes.input_nodes, node)
        end

        #Put state nodes in another vector
        if node isa AbstractStateNode
            push!(ordered_nodes.all_state_nodes, node)

            #If any of the nodes' value children are continuous input nodes
            if any(isa.(node.value_children, InputNode))
                #Add it to the early update list
                push!(ordered_nodes.early_update_state_nodes, node)
            else
                #Otherwise tot he late update list
                push!(ordered_nodes.late_update_state_nodes, node)
            end

            #If any of the node's value vhildren are binary state nodes
            if any(isa.(node.value_children, BinaryStateNode))
                #Add it to the early prediction list
                push!(ordered_nodes.early_prediction_state_nodes, node)
            else
                #Add it to the early prediction list
                push!(ordered_nodes.late_prediction_state_nodes, node)
            end
        end
    end

    ## Order state nodes ##
    #Initialize empty vector for storing properly ordered state nodes
    ordered_state_nodes = []

    #For each specified state node, in the order inputted by the user 
    for node_info in state_nodes

        #If only the node's name was specified as a string
        if typeof(node_info) == String
            #Make it into a named tuple
            node_info = (; name = node_info)
        end

        #Add the node to the vector
        push!(ordered_state_nodes, all_nodes_dict[node_info.name])
    end

    ### Create HGF struct ###
    hgf = HGFStruct(update_hgf!, all_nodes_dict, input_nodes_dict, state_nodes_dict, ordered_nodes)

    ### Check that the HGF has been specified properly ###
    check_hgf(hgf)

    ### Initialize node history ###
    #For each state node
    for node in hgf.ordered_nodes.all_state_nodes
        #Save posterior to node history
        push!(node.history.posterior_mean, node.state.posterior_mean)
        push!(node.history.posterior_precision, node.state.posterior_precision)
    end

    ### Warnings ###
    if verbose
        ## Check for unspecified node defaults ##
        #For each parameter in the defaults
        for param_key in keys(defaults)
            #If it is not in the node defaults set by the user
            if !(param_key in keys(node_defaults))
                #Get the value used instead
                param_value = defaults[param_key]
                #Raise a warning
                @warn "node parameter $param_key is not specified in node_defaults. Using $param_value as default."
            end
        end
    end

    return hgf
end



"""
    init_node(input_or_state_node, node_defaults, node_info)

Function for creating a node, given specifications
"""
function init_node(input_or_state_node, node_param_defaults, node_info)

    #Get parameters and starting state. Specific node settings supercede node defaults, which again supercede the function's defaults.
    params = merge(node_param_defaults, node_info.params)

    #For an input node
    if input_or_state_node == "input_node"
        #If it is continuous
        if node_info.type == "continuous"
            #Initialize it
            node = InputNode(
                name = node_info.name,
                params = InputNodeParams(evolution_rate = params.evolution_rate),
                state = InputNodeState(),
            )
            #If it is binary
        elseif node_info.type == "binary"
            #Initialize it
            node = BinaryInputNode(
                name = node_info.name,
                params = BinaryInputNodeParams(
                    category_means = params.category_means,
                    input_precision = params.input_precision,
                ),
                state = BinaryInputNodeState(),
            )

        else
            #The node has been misspecified. Throw an error
            throw(ArgumentError("the type of node $node_info.name has been misspecified"))
        end

        #For a state node
    elseif input_or_state_node == "state_node"
        #If it is continuous
        if node_info.type == "continuous"
            #Initialize it
            node = StateNode(
                name = node_info.name,
                #Pass global and specific parameters
                params = StateNodeParams(
                    evolution_rate = params.evolution_rate,
                    initial_mean = params.initial_mean,
                    initial_precision = params.initial_precision,
                ),
                #Pass global and specific starting states
                state = StateNodeState(
                    posterior_mean = params.initial_mean,
                    posterior_precision = params.initial_precision,
                ),
            )

            #If it is binary
        elseif node_info.type == "binary"
            #Initialize it
            node = BinaryStateNode(
                name = node_info.name,
                #Pass global and specific parameters
                params = BinaryStateNodeParams(),
                #Pass global and specific starting states
                state = BinaryStateNodeState(),
            )
        else
            #The node has been misspecified. Throw an error
            throw(ArgumentError("the type of node $node_info.name has been misspecified"))
        end
    end

    return node
end