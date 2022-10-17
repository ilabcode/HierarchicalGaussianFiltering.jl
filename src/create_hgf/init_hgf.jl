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
function init_hgf(;
    input_nodes::Union{String, Dict, Vector},
    state_nodes::Union{String, Dict, Vector},
    edges::Union{Vector{<:Dict}, Dict},
    node_defaults::Dict = Dict(),
    update_order::Union{Nothing, Vector{String}} = nothing,
    verbose::Bool = true,
)
    ### Defaults ###
    preset_node_defaults = Dict(
        "type" => "continuous",
        "evolution_rate" => 0,
        "initial_mean" => 0,
        "initial_precision" => 1,
        "value_coupling" => 1,
        "volatility_coupling" => 1,
        "category_means" => [0, 1],
        "input_precision" => Inf,
    )

    #If verbose
    if verbose
        #If some node defaults have been specified
        if length(node_defaults) > 0
            #Warn the user of unspecified defaults and errors
            warn_premade_defaults(preset_node_defaults, node_defaults, "in the node defaults,")
        end
    end

    #Use presets wherever node defaults were not given
    node_defaults = merge(preset_node_defaults, node_defaults)


    ### Initialize nodes ###
    #Initialize empty dictionaries for storing nodes
    all_nodes_dict = Dict{String,AbstractNode}()
    input_nodes_dict = Dict{String,AbstractInputNode}()
    state_nodes_dict = Dict{String,AbstractStateNode}()

    ## Input nodes ##

    #If user has only specified a single node and not in a vector
    if input_nodes isa Dict
        #Put it in a vector
        input_nodes = [input_nodes]
    end

    #For each specified input node
    for node_info in input_nodes

        #If only the node's name was specified as a string
        if node_info isa String
            #Make it into a dictionary
            node_info = Dict("name" => node_info)
        end

        #Create the node
        node = init_node("input_node", node_defaults, node_info)

        #Add it to the dictionary
        all_nodes_dict[node.name] = node
        input_nodes_dict[node.name] = node
    end

    ## State nodes ##
    #If user has only specified a single node and not in a vector
    if state_nodes isa Dict
        #Put it in a vector
        state_nodes = [state_nodes]
    end

    #For each specified state node
    for node_info in state_nodes

        #If only the node's name was specified as a string
        if node_info isa String
            #Make it into a named tuple
            node_info = Dict("name" => node_info)
        end

        #Create the node
        node = init_node("state_node", node_defaults, node_info)

        #Add it to the dictionary
        all_nodes_dict[node.name] = node
        state_nodes_dict[node.name] = node
    end


    ### Set up edges ###

    #If user has only specified a single edge and not in a vector
    if edges isa Dict
        #Put it in a vector
        edges = [edges]
    end

    #For each child
    for edge in edges

        #Find corresponding child node
        child_node = all_nodes_dict[edge["child"]]

        #Add empty vectors for when the user has not specified any
        edge =
            merge(Dict("value_parents" => [], "volatility_parents" => []), edge)

        #If there are any value parents
        if length(edge["value_parents"]) > 0
            #Get out value parents
            value_parents = edge["value_parents"]

            #If the value parents were not specified as a vector
            if .!isa(value_parents, Vector)
                #Make it into one
                value_parents = [value_parents]
            end

            #For each value parent
            for parent_info in value_parents

                #If only the node's name was specified as a string
                if parent_info isa String
                    #Make it a tuple, and give it the default coupling strength
                    parent_info = (parent_info, node_defaults["value_coupling"])
                end

                #Find the corresponding parent
                parent_node = all_nodes_dict[parent_info[1]]

                #Add the parent to the child node
                push!(child_node.value_parents, parent_node)

                #Add the child node to the parent node
                push!(parent_node.value_children, child_node)

                #Except for binary input nodes
                if !(child_node isa BinaryInputNode)
                    #Add coupling strength to child node
                    child_node.params.value_coupling[parent_node.name] =
                    parent_info[2]
                end
            end
        end

        #If there are any volatility parents
        if length(edge["volatility_parents"]) > 0
            #Get out volatility parents
            volatility_parents = edge["volatility_parents"]

            #If the volatility parents were not specified as a vector
            if .!isa(volatility_parents, Vector)
                #Make it into one
                volatility_parents = [volatility_parents]
            end

            #For each volatility parent
            for parent_info in volatility_parents

                #If only the node's name was specified as a string
                if parent_info isa String
                    #Make it a tuple, and give it the default coupling strength
                    parent_info = (parent_info, node_defaults["volatility_coupling"])
                end

                #Find the corresponding parent
                parent_node = all_nodes_dict[parent_info[1]]

                #Add the parent to the child node
                push!(child_node.volatility_parents, parent_node)

                #Add the child node to the parent node
                push!(parent_node.volatility_children, child_node)

                #Add coupling strength to child node
                child_node.params.volatility_coupling[parent_node.name] =
                    parent_info[2]
            end
        end
    end

    ## Determine Update order ##
    #If update order has not been specified
    if update_order == nothing

        #If verbose
        if verbose
            #Warn that automaitc update order is used
            @warn "No update order specified. Using the order in which nodes were inputted"
        end

        #Initialize empty vector for storing the update order
        update_order = []

        #For each input node, in the order inputted
        for node_info in input_nodes

            #If only the node's name was specified as a string
            if node_info isa String
                #Make it into a named tuple
                node_info = Dict("name" => node_info)
            end

            #Add the node to the vector
            push!(update_order, all_nodes_dict[node_info["name"]])
        end

        #For each state node, in the order inputted
        for node_info in state_nodes

            #If only the node's name was specified as a string
            if node_info isa String
                #Make it into a named tuple
                node_info = Dict("name" => node_info)
            end

            #Add the node to the vector
            push!(update_order, all_nodes_dict[node_info["name"]])
        end
    end

    ## Order nodes ##
    #Initialize empty struct for storing nodes in correct update order
    ordered_nodes = OrderedNodes()

    #For each node, in the specified update order
    for node in update_order

        #Have a field for all nodes
        push!(ordered_nodes.all_nodes, node)

        #Put input nodes in one field
        if node isa AbstractInputNode
            push!(ordered_nodes.input_nodes, node)
        end

        #Put state nodes in another field
        if node isa AbstractStateNode
            push!(ordered_nodes.all_state_nodes, node)

            #If any of the nodes' value children are continuous input nodes
            if any(isa.(node.value_children, ContinuousInputNode))
                #Add it to the early update list
                push!(ordered_nodes.early_update_state_nodes, node)
            else
                #Otherwise to the late update list
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

    ### Create HGF struct ###
    hgf = HGFStruct(all_nodes_dict, input_nodes_dict, state_nodes_dict, ordered_nodes)

    ### Check that the HGF has been specified properly ###
    check_hgf(hgf)

    ### Initialize node history ###
    #For each state node
    for node in hgf.ordered_nodes.all_state_nodes
        #Save posterior to node history
        push!(node.history.posterior_mean, node.states.posterior_mean)
        push!(node.history.posterior_precision, node.states.posterior_precision)
    end

    return hgf
end



"""
    init_node(input_or_state_node, node_defaults, node_info)

Function for creating a node, given specifications
"""
function init_node(input_or_state_node, node_defaults, node_info)

    #Get parameters and starting state. Specific node settings supercede node defaults, which again supercede the function's defaults.
    params = merge(node_defaults, node_info)

    #For an input node
    if input_or_state_node == "input_node"
        #If it is continuous
        if params["type"] == "continuous"
            #Initialize it
            node = ContinuousInputNode(
                name = params["name"],
                params = ContinuousInputNodeParams(evolution_rate = params["evolution_rate"]),
                states = ContinuousInputNodeState(),
            )
            #If it is binary
        elseif params["type"] == "binary"
            #Initialize it
            node = BinaryInputNode(
                name = params["name"],
                params = BinaryInputNodeParams(
                    category_means = params["category_means"],
                    input_precision = params["input_precision"],
                ),
                states = BinaryInputNodeState(),
            )

        else
            #The node has been misspecified. Throw an error
            throw(ArgumentError("the type of node $params['name'] has been misspecified"))
        end

        #For a state node
    elseif input_or_state_node == "state_node"
        #If it is continuous
        if params["type"] == "continuous"
            #Initialize it
            node = ContinuousStateNode(
                name = params["name"],
                #Set parameters
                params = ContinuousStateNodeParams(
                    evolution_rate = params["evolution_rate"],
                    initial_mean = params["initial_mean"],
                    initial_precision = params["initial_precision"],
                ),
                #Set states
                states = ContinuousStateNodeState(
                    posterior_mean = params["initial_mean"],
                    posterior_precision = params["initial_precision"],
                ),
            )

            #If it is binary
        elseif params["type"] == "binary"
            #Initialize it
            node = BinaryStateNode(
                name = params["name"],
                #Pass global and specific parameters
                params = BinaryStateNodeParams(),
                #Pass global and specific starting states
                states = BinaryStateNodeState(),
            )
        else
            #The node has been misspecified. Throw an error
            throw(ArgumentError("the type of node $params['name'] has been misspecified"))
        end
    end

    return node
end