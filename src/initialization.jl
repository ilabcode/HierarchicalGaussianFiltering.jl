
#Function for initializing an HGF structure
function init_HGF(
    global_params,
    input_nodes,
    state_nodes,
    child_parent_relations,
    update_order = false,
)
    ### Decide update order ###
    #If update order is not ambiguous
    #If update order has not been specified
    #Use the non-ambiguous order
    #If update order has been specified
    #If the two are different
    #Throw an error
    #If they are the same
    #Use the specified order
    #If update order is ambiguous
    #If update order has not been specified
    #Throw an error
    #If update order has been specified
    #If update order is suitable
    #Use the specified order 
    #If it is not suitable
    #Throw an error


    ### Reorder the specified state nodes in the update order ###

    ### Initialize nodes ###
    #Initialize empty dictionary for storing nodes
    nodes_dict = Dict()

    ## Input nodes
    #For each specified input node
    for node_info in input_nodes

        #Initialize it, passing global params and specific params
        node = InputNode(
            name = node_info.name,
            params = NodeParams(; global_params.params..., node_info.params...),
            state = NodeStates(; global_params.starting_state..., node_info.starting_state...),
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
            params = NodeParams(; global_params.params..., node_info.params...),
            state = NodeStates(; global_params.starting_state..., node_info.starting_state...),
        )

        #Add it to the dictionary
        nodes_dict[node.name] = node
    end

    ### Set up child-parent relations ###
    #For each child
    for relationship_set in child_parent_relations

        #Find corresponding child node
        child_node = nodes_dict[relationship_set.child_node]

        #For each value parent
        for parent_info in relationship_set.value_parents

            #Find corresponding parent node 
            parent = nodes_dict[parent_info[1]]

            #Add the parent to the child node
            push!(child_node.value_parents, parent)

            #Add the child node to the parent node
            push!(parent.value_children, child_node)

            #Add coupling strength to child node
            child_node.value_coupling[parent_info[1]] = parent_info[2]
        end

        #For each volatility parent
        for parent_info in relationship_set.volatility_parents

            #Find corresponding parent node 
            parent = nodes_dict[parent_info[1]]

            #Add the parent to the child node
            push!(child_node.volatility_parents, parent)

            #Add the child node to the parent node
            push!(parent.volatility_children, child_node)

            #Add coupling strengths
            child_node.volatility_coupling[parent_info[1]] = parent_info[2]
        end
    end

    ### Create HGF structure ###
    ##Put contents of dictionary into two lists
    #Initialize lists
    input_nodes_dict = Dict{String,InputNode}()
    state_nodes_dict = Dict{String,StateNode}()

    #Go through each node
    for node in nodes_dict
        #Put input nodes in one dict
        if typeof(node) == InputNode
            input_nodes_dict[node.name] = node

            #Put state ndoes in another
        elseif typeof(node) == StateNode
            state_nodes_dict[node.name] = node
        end
    end

    #Create HGF structure containing the lists of nodes
    HGF_struct = HGFModel(input_nodes_dict, state_nodes_dict)

    return HGF_struct
end

### Example input
#Set parameter values to be used for all nodes unless other values are given
global_params = (
    params = (omega = 3, value_coupling_strength = 5, volatility_coupling_strength = 5),
    starting_state = (
        posterior_mean = 1,
        posterior_precision = 1,
        prediction_mean = 1,
        prediction_precision = 1,
    ),
)

#Define list of input nodes
input_nodes = [(name = "x_in1", type = "continuous", params = (omega = 2))]

#Define list of state nodes
state_nodes = [
    (name = "x_1", params = (omega = 2)),
    (name = "x_2", params = (omega = 2)),
    (name = "x_3", params = (omega = 2)),
    (name = "x_4", params = (omega = 2)),
    (
        name = "x_5",
        params = (omega = 2),
        starting_state = (
            posterior_mean = 1,
            posterior_precision = 1,
            prediction_mean = 1,
            prediction_precision = 1,
        ),
    ),
]

#Set child-parent relations between node
child_parent_relations = [
    (
        child_node = "x_in1",
        value_parents = Dict("x_1" => 2),
        volatility_parents = Dict("x_2" => 2),
    ),
    (
        child_node = "x_1",
        value_parents = Dict("x_3" => 2),
        volatility_parents = Dict("x_4" => 2, "x_5" => 2),
    ),
]

#Set update order. Only required if update order is ambiguous
update_order = ["x_1", "x_2", "x_3", "x_4", "x_5"]
