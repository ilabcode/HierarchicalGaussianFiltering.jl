using HierarchicalGaussianFiltering
using Test

# Test of custom HGF with shared parameters

#List of input nodes to create
input_nodes = Dict("name" => "u", "type" => "continuous", "input_noise" => 2)

#List of state nodes to create
state_nodes = [
    Dict(
        "name" => "x1",
        "type" => "continuous",
        "volatility" => 2,
        "initial_mean" => 1,
        "initial_precision" => 1,
    ),
    Dict(
        "name" => "x2",
        "type" => "continuous",
        "volatility" => 2,
        "initial_mean" => 1,
        "initial_precision" => 1,
    ),
]

#List of child-parent relations
edges = [
    Dict("child" => "u", "value_parents" => ("x1", 1)),
    Dict("child" => "x1", "volatility_parents" => ("x2", 1)),
]


# one shared parameter
shared_parameters_1 =
    Dict("volatilitys" => (9, [("x1", "volatility"), ("x2", "volatility")]))

#Initialize the HGF
hgf_1 = init_hgf(
    input_nodes = input_nodes,
    state_nodes = state_nodes,
    edges = edges,
    shared_parameters = shared_parameters_1,
)

#get shared parameter
get_parameters(hgf_1)

@test get_parameters(hgf_1, "volatilitys") == 9

#set shared parameter
set_parameters!(hgf_1, "volatilitys", 2)

shared_parameters_2 = Dict(
    "initial_means" => (9, [("x1", "initial_mean"), ("x2", "initial_mean")]),
    "volatilitys" => (9, [("x1", "volatility"), ("x2", "volatility")]),
)


#Initialize the HGF
hgf_2 = init_hgf(
    input_nodes = input_nodes,
    state_nodes = state_nodes,
    edges = edges,
    shared_parameters = shared_parameters_2,
)

#get all parameters
get_parameters(hgf_2)

#get shared parameter
@test get_parameters(hgf_2, "volatilitys") == 9

#set shared parameter
set_parameters!(hgf_2, Dict("volatilitys" => -2, "initial_means" => 1))

@test get_parameters(hgf_2, "volatilitys") == -2
@test get_parameters(hgf_2, "initial_means") == 1
