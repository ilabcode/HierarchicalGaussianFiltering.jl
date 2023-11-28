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
    input_nodes::Union{String,Dict,Vector},
    state_nodes::Union{String,Dict,Vector},
    edges::Dict{Tuple{String,String},<:CouplingType},
    shared_parameters::Dict = Dict(),
    node_defaults::Dict = Dict(),
    update_type::HGFUpdateType = EnhancedUpdate(),
    update_order::Union{Nothing,Vector{String}} = nothing,
    verbose::Bool = true,
)
    ### Defaults ###
    preset_node_defaults = Dict(
        "type" => "continuous",
        "volatility" => -2,
        "drift" => 0,
        "autoregression_target" => 0,
        "autoregression_strength" => 0,
        "initial_mean" => 0,
        "initial_precision" => 1,
        "coupling_strength" => 1,
        "category_means" => [0, 1],
        "input_precision" => Inf,
        "input_noise" => -2,
    )

    #If verbose
    if verbose
        #If some node defaults have been specified
        if length(node_defaults) > 0
            #Warn the user of unspecified defaults and errors
            warn_premade_defaults(
                preset_node_defaults,
                node_defaults,
                "in the node defaults,",
            )
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
    #For each specified edge
    for (node_names, coupling_type) in edges

        #Extract the child and parent names
        child_name, parent_name = node_names

        #Find corresponding child node and parent node
        child_node = all_nodes_dict[child_name]
        parent_node = all_nodes_dict[parent_name]

        #Create the edge
        init_edge!(child_node, parent_node, coupling_type, update_type, node_defaults)
    end

    ## Determine Update order ##
    #If update order has not been specified
    if isnothing(update_order)

        #If verbose
        if verbose
            #Warn that automatic update order is used
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
    shared_parameters_dict = Dict()

    #Go through each specified shared parameter
    for (shared_parameter_key, dict_value) in shared_parameters
        #Unpack the shared parameter value and the derived parameters
        (shared_parameter_value, derived_parameters) = dict_value
        #check if the name of the shared parameter is part of its own derived parameters
        if shared_parameter_key in derived_parameters
            throw(
                ArgumentError(
                    "The shared parameter is part of the list of derived parameters",
                ),
            )
        end

        #Add as a SharedParameter to the shared parameter dictionary
        shared_parameters_dict[shared_parameter_key] = SharedParameter(
            value = shared_parameter_value,
            derived_parameters = derived_parameters,
        )
    end

    ### Create HGF struct ###
    hgf = HGF(
        all_nodes_dict,
        input_nodes_dict,
        state_nodes_dict,
        ordered_nodes,
        shared_parameters_dict,
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



"""
    init_node(input_or_state_node, node_defaults, node_info)

Function for creating a node, given specifications
"""
function init_node(input_or_state_node, node_defaults, node_info)

    #Get parameters and starting state. Specific node settings supercede node defaults, which again supercede the function's defaults.
    parameters = merge(node_defaults, node_info)

    #For an input node
    if input_or_state_node == "input_node"
        #If it is continuous
        if parameters["type"] == "continuous"
            #Initialize it
            node = ContinuousInputNode(
                name = parameters["name"],
                parameters = ContinuousInputNodeParameters(
                    input_noise = parameters["input_noise"],
                ),
                states = ContinuousInputNodeState(),
            )
            #If it is binary
        elseif parameters["type"] == "binary"
            #Initialize it
            node = BinaryInputNode(
                name = parameters["name"],
                parameters = BinaryInputNodeParameters(
                    category_means = parameters["category_means"],
                    input_precision = parameters["input_precision"],
                ),
                states = BinaryInputNodeState(),
            )
            #If it is categorical
        elseif parameters["type"] == "categorical"
            #Initialize it
            node = CategoricalInputNode(
                name = parameters["name"],
                parameters = CategoricalInputNodeParameters(),
                states = CategoricalInputNodeState(),
            )
        else
            #The node has been misspecified. Throw an error
            throw(
                ArgumentError("the type of node $parameters['name'] has been misspecified"),
            )
        end

        #For a state node
    elseif input_or_state_node == "state_node"
        #If it is continuous
        if parameters["type"] == "continuous"
            #Initialize it
            node = ContinuousStateNode(
                name = parameters["name"],
                #Set parameters
                parameters = ContinuousStateNodeParameters(
                    volatility = parameters["volatility"],
                    drift = parameters["drift"],
                    initial_mean = parameters["initial_mean"],
                    initial_precision = parameters["initial_precision"],
                    autoregression_target = parameters["autoregression_target"],
                    autoregression_strength = parameters["autoregression_strength"],
                ),
                #Set states
                states = ContinuousStateNodeState(
                    posterior_mean = parameters["initial_mean"],
                    posterior_precision = parameters["initial_precision"],
                ),
            )

            #If it is binary
        elseif parameters["type"] == "binary"
            #Initialize it
            node = BinaryStateNode(
                name = parameters["name"],
                parameters = BinaryStateNodeParameters(),
                states = BinaryStateNodeState(),
            )

            #If it categorical
        elseif parameters["type"] == "categorical"

            #Initialize it
            node = CategoricalStateNode(
                name = parameters["name"],
                parameters = CategoricalStateNodeParameters(),
                states = CategoricalStateNodeState(),
            )

        else
            #The node has been misspecified. Throw an error
            throw(
                ArgumentError("the type of node $parameters['name'] has been misspecified"),
            )
        end
    end

    return node
end

### Function for initializing and edge ###
function init_edge!(
    child_node::AbstractNode,
    parent_node::AbstractStateNode,
    coupling_type::CouplingType,
    update_type::HGFUpdateType,
    node_defaults::Dict,
)

    #Get correct field for storing parents
    if coupling_type isa DriftCoupling
        parents_field = :drift_parents
        children_field = :drift_children

    elseif coupling_type isa ObservationCoupling
        parents_field = :observation_parents
        children_field = :observation_children

    elseif coupling_type isa CategoryCoupling
        parents_field = :category_parents
        children_field = :category_children

    elseif coupling_type isa ProbabilityCoupling
        parents_field = :probability_parents
        children_field = :probability_children

    elseif coupling_type isa VolatilityCoupling
        parents_field = :volatility_parents
        children_field = :volatility_children

    elseif coupling_type isa NoiseCoupling
        parents_field = :noise_parents
        children_field = :noise_children
    end

    #Add the parent to the child node
    push!(getfield(child_node.edges, parents_field), parent_node)

    #Add the child node to the parent node
    push!(getfield(parent_node.edges, children_field), child_node)

    #If the coupling type has a coupling strength
    if hasproperty(coupling_type, :strength)
        #If the user has not specified a coupling strength
        if isnothing(coupling_type.strength)
            #Use the defaults coupling strength
            coupling_strength = node_defaults["coupling_strength"]

            #Otherwise
        else
            #Use the specified coupling strength 
            coupling_strength = coupling_type.strength
        end

        #And set it as a parameter for the child
        child_node.parameters.coupling_strengths[parent_node.name] = coupling_strength
    end

    #If the enhanced HGF update is used, and if it is a precision coupling (volatility or noise)
    if update_type isa EnhancedUpdate && coupling_type isa PrecisionCoupling
        #Set the node to use the enhanced HGF update
        parent_node.update_type = update_type
    end
end
