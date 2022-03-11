
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
    
    ### Add input nodes ###
    #Initialize empty lists for adding nodes
    input_nodes_list = []

    #For each specified input node
    for node_info in input_nodes

        #Initialize it 
        node = InputNode()
        
        #Add it to the list
        push!(input_nodes_list, node)
    end

    ### Add state nodes ###
    #Initialize empty lists for adding nodes
    state_nodes_list = []

    #In the order 
    for node_info in state_nodes

        #Initialize it
        node = StateNode()

        #Add it to the list
        push!(state_nodes_list, node)
    end

    ### Create HGF structure ###
    #Create HGF structure containing the nodes
    HGF_struct = HGFModel(input_nodes_list, state_nodes_list)

    return HGF_struct
end


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
        value_parents = [(name = "x_1", coupling_strength = 2)],
        volatility_parents = [(name = "x_2", coupling_strength = 2)],
    ),
    (
        child_node = "x_1",
        value_parents = [(name = "x_3", coupling_strength = 2)],
        volatility_parents = [
            (name = "x_4", coupling_strength = 2),
            (name = "x_5", coupling_strength = 2),
        ],
    ),
]

#Set update order. Only required if update order is ambiguous.
update_order = ["x_1", "x_2", "x_3", "x_4", "x_5"]
