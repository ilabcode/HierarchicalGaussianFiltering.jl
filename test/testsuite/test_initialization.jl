using HierarchicalGaussianFiltering
using Test

@testset "Initialization" begin
    #Parameter values to be used for all nodes unless other values are given
    node_defaults = NodeDefaults(
        volatility = 3,
        input_noise = -2,
        initial_mean = 1,
        initial_precision = 2,
        coupling_strength = 1,
        drift = 2,
    )

    #List of nodes
    nodes = [
        ContinuousInput(name = "u1", input_noise = 2),
        ContinuousInput(name = "u2"),
        ContinuousState(name = "x1"),
        ContinuousState(name = "x2"),
        ContinuousState(name = "x3"),
        ContinuousState(name = "x4", volatility = 2),
        ContinuousState(
            name = "x5",
            volatility = 2,
            initial_mean = 4,
            initial_precision = 3,
            drift = 5,
        ),
    ]

    #List of child-parent relations
    edges = Dict(
        ("u1", "x1") => ObservationCoupling(),
        ("u2", "x2") => ObservationCoupling(),
        ("u2", "x3") => NoiseCoupling(),
        ("x1", "x3") => DriftCoupling(strength = 2),
        ("x1", "x4") => VolatilityCoupling(strength = 2),
        ("x1", "x5") => VolatilityCoupling(),
    )

    #Initialize an HGF
    test_hgf = init_hgf(
        nodes = nodes,
        edges = edges,
        node_defaults = node_defaults,
        verbose = false,
    )

    @testset "Check if inputs were placed the right places" begin
        @test test_hgf.input_nodes["u1"].parameters.input_noise == 2
        @test test_hgf.input_nodes["u2"].parameters.input_noise == -2

        @test test_hgf.state_nodes["x1"].parameters.volatility == 3
        @test test_hgf.state_nodes["x2"].parameters.volatility == 3
        @test test_hgf.state_nodes["x3"].parameters.volatility == 3
        @test test_hgf.state_nodes["x4"].parameters.volatility == 2
        @test test_hgf.state_nodes["x5"].parameters.volatility == 2

        @test test_hgf.state_nodes["x1"].parameters.drift == 2
        @test test_hgf.state_nodes["x5"].parameters.drift == 5

        @test test_hgf.state_nodes["x1"].parameters.coupling_strengths["x3"] == 2
        @test test_hgf.state_nodes["x1"].parameters.coupling_strengths["x4"] == 2
        @test test_hgf.state_nodes["x1"].parameters.coupling_strengths["x5"] == 1

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
