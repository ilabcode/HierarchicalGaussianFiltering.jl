using HierarchicalGaussianFiltering
using Test

@testset "Initialization" begin
    #Parameter values to be used for all nodes unless other values are given
    node_defaults = Dict(
        "evolution_rate" => 3,
        "category_means" => [0, 1],
        "input_precision" => Inf,
        "initial_mean" => 1,
        "initial_precision" => 2,
        "value_coupling" => 1,
        "drift" => 2,
    )

    #List of input nodes to create
    input_nodes = [Dict("name" => "u1", "evolution_rate" => 2), "u2"]

    #List of state nodes to create
    state_nodes = [
        "x1",
        "x2",
        "x3",
        Dict("name" => "x4", "evolution_rate" => 2),
        Dict(
            "name" => "x5",
            "evolution_rate" => 2,
            "initial_mean" => 4,
            "initial_precision" => 3,
            "drift" => 5
        ),
    ]

    #List of child-parent relations
    edges = [
        Dict("child" => "u1", "value_parents" => "x1"),
        Dict("child" => "u2", "value_parents" => "x2", "volatility_parents" => "x3"),
        Dict(
            "child" => "x1",
            "value_parents" => ("x3", 2),
            "volatility_parents" => [("x4", 2), "x5"],
        ),
    ]

    #Initialize an HGF
    test_hgf = init_hgf(
        input_nodes = input_nodes,
        state_nodes = state_nodes,
        edges = edges,
        node_defaults = node_defaults,
        verbose = false,
    )

    @testset "Check if inputs were placed the right places" begin
        @test test_hgf.input_nodes["u1"].parameters.evolution_rate == 2
        @test test_hgf.input_nodes["u2"].parameters.evolution_rate == 3

        @test test_hgf.state_nodes["x1"].parameters.evolution_rate == 3
        @test test_hgf.state_nodes["x2"].parameters.evolution_rate == 3
        @test test_hgf.state_nodes["x3"].parameters.evolution_rate == 3
        @test test_hgf.state_nodes["x4"].parameters.evolution_rate == 2
        @test test_hgf.state_nodes["x5"].parameters.evolution_rate == 2

        @test test_hgf.state_nodes["x1"].parameters.evolution_rate == 2
        @test test_hgf.state_nodes["x5"].parameters.evolution_rate == 5

        @test test_hgf.input_nodes["u1"].parameters.value_coupling["x1"] == 1
        @test test_hgf.input_nodes["u2"].parameters.value_coupling["x2"] == 1
        @test test_hgf.input_nodes["u2"].parameters.volatility_coupling["x3"] == 1
        @test test_hgf.state_nodes["x1"].parameters.value_coupling["x3"] == 2
        @test test_hgf.state_nodes["x1"].parameters.volatility_coupling["x4"] == 2
        @test test_hgf.state_nodes["x1"].parameters.volatility_coupling["x5"] == 1

        @test test_hgf.state_nodes["x1"].states.posterior_mean == 1
        @test test_hgf.state_nodes["x1"].states.posterior_precision == 2
        @test test_hgf.state_nodes["x2"].states.posterior_mean == 1
        @test test_hgf.state_nodes["x2"].states.posterior_precision == 2
        @test test_hgf.state_nodes["x3"].states.posterior_mean == 1
        @test test_hgf.state_nodes["x3"].states.posterior_precision == 2
        @test test_hgf.state_nodes["x4"].states.posterior_mean == 1
        @test test_hgf.state_nodes["x4"].states.posterior_precision == 2
        @test test_hgf.state_nodes["x5"].states.posterior_mean == 4
        @test test_hgf.state_nodes["x5"].states.posterior_precision == 3
    end
end
