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
    Dict{String, AbstractFloat}("x1" => 0.5, "x3" => 0.5),
    Dict{String, AbstractFloat}("x4" => 0.5),
    # State estimates
    0.5,
    0.5,
    0.5,
    0.5,
    0.5, 
    0.5, 
    0.5,
    # History
    HGF.NodeHistory(),
)





