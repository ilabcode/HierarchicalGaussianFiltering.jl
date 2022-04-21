######
using HGF
#Parameter values to be used for all nodes unless other values are given
node_defaults = (
    params = (; evolution_rate = 3),
    starting_state = (; posterior_precision = 1),
    coupling_strengths = (; value_coupling_strength = 1)
)

#List of input nodes to create
input_nodes = [
    (name = "u1", params = (; evolution_rate = 2)),
    "u2",
]

#List of state nodes to create
state_nodes = [
    "x1",
    "x2",
    "x3",
    (name = "x4", params = (; evolution_rate = 2)),
    (
        name = "x5",
        params = (; evolution_rate = 2),
        starting_state = (; posterior_mean = 1, posterior_precision = 2),
    ),
]

#List of child-parent relations
child_parent_relations = [
    (
        child_node = "u1",
        value_parents = "x1",
    ),
    (
        child_node = "u2",
        value_parents = "x2",
        volatility_parents = ["x1", "x2"],
    ),
    (
        child_node = "x1",
        value_parents = (name = "x3", coupling_strength = 2),
        volatility_parents = [(name = "x4", coupling_strength = 2), "x5"],
    ),
]

#Initialize an HGF
test_hgf_2 = HGF.init_hgf(
    node_defaults,
    input_nodes,
    state_nodes,
    child_parent_relations,
);

#Single input
HGF.update_hgf!(test_hgf_2, Dict("u1" => 1.05, "u2" => 1.07))

#Wrong input format
HGF.give_inputs!(test_hgf_2, [1. 1. 1.2; 2. 1. 1.5])

#Multiple inputs
HGF.give_inputs!(test_hgf_2, [1. 1.; 1. 1.5; 1. 2.; 2. 5.])

#Check inside
test_hgf_2.state_nodes["x2"].history.posterior_mean