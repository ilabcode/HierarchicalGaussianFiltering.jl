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
    shared_parameters::Dict = Dict(),
    update_order::Union{Nothing,Vector{String}} = nothing,
    verbose::Bool = true,
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




function init_node(node_info::ContinuousState)
    ContinuousStateNode(
        name = node_info.name,
        parameters = ContinuousStateNodeParameters(
            volatility = node_info.volatility,
            drift = node_info.drift,
            initial_mean = node_info.initial_mean,
            initial_precision = node_info.initial_precision,
            autoconnection_strength = node_info.autoconnection_strength,
        ),
    )
end

function init_node(node_info::ContinuousInput)
    ContinuousInputNode(
        name = node_info.name,
        parameters = ContinuousInputNodeParameters(input_noise = node_info.input_noise),
    )
end

function init_node(node_info::BinaryState)
    BinaryStateNode(name = node_info.name)
end

function init_node(node_info::BinaryInput)
    BinaryInputNode(name = node_info.name)
end

function init_node(node_info::CategoricalState)
    CategoricalStateNode(name = node_info.name)
end

function init_node(node_info::CategoricalInput)
    CategoricalInputNode(name = node_info.name)
end


### Function for initializing and edge ###
function init_edge!(
    child_node::AbstractNode,
    parent_node::AbstractStateNode,
    coupling_type::CouplingType,
    node_defaults::NodeDefaults,
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
            coupling_strength = node_defaults.coupling_strength

            #Otherwise
        else
            #Use the specified coupling strength 
            coupling_strength = coupling_type.strength
        end

        #And set it as a parameter for the child
        child_node.parameters.coupling_strengths[parent_node.name] = coupling_strength
    end


    #If the enhanced HGF update is the defaults, and if it is a precision coupling (volatility or noise)
    if node_defaults.update_type isa EnhancedUpdate && coupling_type isa PrecisionCoupling
        #Set the node to use the enhanced HGF update
        parent_node.update_type = node_defaults.update_type
    end
end
