#Test node updates
test_node = HGF.Node(
    # Index information
    "x2",
    false,
    false,
    false,
    false,
    # Parameters
    0.5,
    Dict{String, AbstractFloat}("x1" => 2, "x3" => 2),
    Dict{String, AbstractFloat}("x4" => 2),
    # State estimates
    0.5,
    0.5,
    0.5,
    0.5,
    0.5, 
    0.5, 
    0.5,
    # History
    HGF.NodeHistory(
        [0.5],
        [0.5],
        [0.5],
        [0.5],
        [0.5], 
        [0.5], 
        [0.5]),
)