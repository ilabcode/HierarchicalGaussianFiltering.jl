"""
    init_hgf(;
        input_nodes::Union{String,Dict,Vector},
        state_nodes::Union{String,Dict,Vector},
        edges::Union{Vector{<:Dict},Dict},
        node_defaults::Dict = Dict(),
        update_order::Union{Nothing,Vector{String}} = nothing,
        verbose::Bool = true,
    )

Initialize an HGF.
Node information includes 'name' and 'type' as keys, as well as any other parameters that are specific to the node type.
Edge information includes 'child', as well as 'value_parents' and/or 'volatility_parents' as keys. Parents are vectors of either node name strings, or tuples with node names and coupling strengths.

# Arguments
 - 'input_nodes::Union{String,Dict,Vector}': Input nodes to be created. Can either be a string with a node name, a dictionary with node information, or a vector of strings and/or dictionaries.
 - 'state_nodes::Union{String,Dict,Vector}': State nodes to be created. Can either be a string with a node name, a dictionary with node information, or a vector of strings and/or dictionaries.
 - 'edges::Union{Vector{<:Dict},Dict}': Edges to be created. Can either be a dictionary with edge information, or a vector of dictionaries.
 - 'node_defaults::Dict = Dict()': A dictionary with default values for the nodes. If a node is created without specifying a value for a parameter, the default value is used.
 - 'update_order::Union{Nothing,Vector{String}} = nothing': The order in which the nodes are updated. If set to nothing, the update order is determined automatically.
 - 'verbose::Bool = true': If set to false, warnings are hidden.

# Examples
```julia
##Create a simple 2level continuous HGF##

#Set defaults for nodes
node_defaults = Dict(
    "volatility" => -2,
    "input_noise" => -2,
    "initial_mean" => 0,
    "initial_precision" => 1,
    "coupling_strength" => 1,
)

#List of input nodes
input_nodes = Dict(
    "name" => "u",
    "type" => "continuous",
    "input_noise" => -2,
)

#List of state nodes
state_nodes = [
    Dict(
        "name" => "x",
        "type" => "continuous",
        "volatility" => -2,
        "initial_mean" => 0,
        "initial_precision" => 1,
    ),
    Dict(
        "name" => "xvol",
        "type" => "continuous",
        "volatility" => -2,
        "initial_mean" => 0,
        "initial_precision" => 1,
    ),
]

#List of child-parent relations
edges = Dict(
    ("u", "x") -> ObservationCoupling()
    ("x", "xvol") -> VolatilityCoupling()
)

hgf = init_hgf(
    input_nodes = input_nodes,
    state_nodes = state_nodes,
    edges = edges,
    node_defaults = node_defaults,
)
```
"""
function init_hgf(;
    nodes::Vector{<:AbstractNodeInfo},
    edges::Dict{Tuple{String,String},<:CouplingType},
    node_defaults::NodeDefaults = NodeDefaults(),
    parameter_groups::Vector{ParameterGroup} = Vector{ParameterGroup}(),
    update_order::Union{Nothing,Vector{String}} = nothing,
    verbose::Bool = true,
    save_history::Bool = true,
)

    ### Initialize nodes ###
    #Initialize empty dictionaries for storing nodes
    all_nodes_dict = Dict{String,AbstractNode}()
    input_nodes_dict = Dict{String,AbstractInputNode}()
    state_nodes_dict = Dict{String,AbstractStateNode}()
    input_nodes_inputted_order = Vector{String}()
    state_nodes_inputted_order = Vector{String}()

    #For each specified input node
    for node_info in nodes
        #For each field in the node info
        for fieldname in fieldnames(typeof(node_info))
            #If it hasn't been specified by the user
            if isnothing(getfield(node_info, fieldname))
                #Set the node_defaults' value instead
                setfield!(node_info, fieldname, getfield(node_defaults, fieldname))
            end
        end

        #Create the node
        node = init_node(node_info)

        #Add it to the large dictionary
        all_nodes_dict[node_info.name] = node

        #If it is an input node
        if node isa AbstractInputNode
            #Add it to the input node dict
            input_nodes_dict[node_info.name] = node
            #Store its name in the inputted order
            push!(input_nodes_inputted_order, node_info.name)

            #If it is a state node
        elseif node isa AbstractStateNode
            #Add it to the state node dict
            state_nodes_dict[node_info.name] = node
            #Store its name in the inputted order
            push!(state_nodes_inputted_order, node_info.name)
        end
    end

    ### Set up edges ###
    #For each specified edge
    for (node_names, coupling_type) in edges

        #Extract the child and parent names
        child_name, parent_name = node_names

        #Find corresponding child node and parent node
        child_node = all_nodes_dict[child_name]
        parent_node = all_nodes_dict[parent_name]

        #Create the edge
        init_edge!(child_node, parent_node, coupling_type, node_defaults)
    end

    ## Determine Update order ##
    #If update order has not been specified
    if isnothing(update_order)

        #If verbose
        if verbose
            #Warn that automatic update order is used
            @warn "No update order specified. Using the order in which nodes were inputted"
        end

        #Use the order that the nodes were specified in
        update_order = append!(input_nodes_inputted_order, state_nodes_inputted_order)
    end

    ## Order nodes ##
    #Initialize empty struct for storing nodes in correct update order
    ordered_nodes = OrderedNodes()

    #For each node, in the specified update order
    for node_name in update_order

        #Extract node
        node = all_nodes_dict[node_name]

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
            if any(isa.(node.edges.observation_children, ContinuousInputNode))
                #Add it to the early update list
                push!(ordered_nodes.early_update_state_nodes, node)
            else
                #Otherwise to the late update list
                push!(ordered_nodes.late_update_state_nodes, node)
            end
        end
    end

    #initializing shared parameters
    parameter_groups_dict = Dict()

    #Go through each specified shared parameter
    for parameter_group in parameter_groups

        #Add as a GroupedParameters to the shared parameter dictionary
        parameter_groups_dict[parameter_group.name] = ActionModels.GroupedParameters(
            value = parameter_group.value,
            grouped_parameters = parameter_group.parameters,
        )
    end

    ### Create HGF struct ###
    hgf = HGF(
        all_nodes_dict,
        input_nodes_dict,
        state_nodes_dict,
        ordered_nodes,
        parameter_groups_dict,
        save_history,
        [0],
    )

    ### Check that the HGF has been specified properly ###
    check_hgf(hgf)

    ### Initialize states and history ###
    #For each state node
    for node in hgf.ordered_nodes.all_state_nodes
        #If it is a categorical state node
        if node isa CategoricalStateNode

            #Make vector with ordered category parents
            for parent in node.edges.category_parents
                push!(node.edges.category_parent_order, parent.name)
            end

            #Set posterior to vector of missing with length equal to the number of categories
            node.states.posterior =
                Vector{Union{Real,Missing}}(missing, length(node.edges.category_parents))

            #Set posterior to vector of missing with length equal to the number of categories
            node.states.value_prediction_error =
                Vector{Union{Real,Missing}}(missing, length(node.edges.category_parents))

            #Set parent predictions from last timestep to be agnostic
            node.states.parent_predictions = repeat(
                [1 / length(node.edges.category_parents)],
                length(node.edges.category_parents),
            )

            #Set predictions from last timestep to be agnostic
            node.states.prediction = repeat(
                [1 / length(node.edges.category_parents)],
                length(node.edges.category_parents),
            )
        end
    end

    #Reset the hgf, initializing states and history
    reset!(hgf)

    return hgf
end
