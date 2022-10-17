function Base.show(io::IO, hgf::HGFStruct)

    ##Get information from HGF struct
    #Input nodes
    n_continuous_input_nodes = count(node -> isa(node, InputNode), hgf.ordered_nodes.input_nodes)
    n_binary_input_nodes = count(node -> isa(node, BinaryInputNode), hgf.ordered_nodes.input_nodes)
    n_input_nodes = n_continuous_input_nodes + n_binary_input_nodes

    #State nodes
    n_continuous_state_nodes = count(node -> isa(node, StateNode), hgf.ordered_nodes.all_state_nodes)
    n_binary_state_nodes = count(node -> isa(node, BinaryStateNode), hgf.ordered_nodes.all_state_nodes)
    n_state_nodes = n_continuous_state_nodes + n_binary_state_nodes

    #Number of observations
    n_observations = length(hgf.ordered_nodes.input_nodes[1].history) - 1

    ##Print information
    #Title
    println("-- HGF struct --")

    #Input nodes
    println("Number of input nodes: $n_input_nodes")
    println("($n_continuous_input_nodes continuous and $n_binary_input_nodes binary)")

    #State nodes
    println("Number of state nodes: $n_state_nodes")
    println("($n_continuous_state_nodes continuous and $n_binary_state_nodes binary)")

    #Number of observations
    println("This HGF has received $n_observations inputs")
    
end
