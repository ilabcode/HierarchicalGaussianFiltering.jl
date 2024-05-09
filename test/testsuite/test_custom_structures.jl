using Test
using HierarchicalGaussianFiltering


@testset "test custom structures" begin

    @testset "Many continuous nodes" begin
        nodes = [
            ContinuousInput(name = "u"),
            ContinuousInput(name = "u2"),
            ContinuousState(name = "x1"),
            ContinuousState(name = "x2"),
            ContinuousState(name = "x3"),
            ContinuousState(name = "x4"),
            ContinuousState(name = "x5"),
        ]

        edges = Dict(
            ("u", "x1") => ObservationCoupling(),
            ("u2", "x2") => ObservationCoupling(),
            ("x1", "x2") => DriftCoupling(),
            ("x1", "x3") => VolatilityCoupling(),
            ("u2", "x3") => NoiseCoupling(),
            ("x2", "x4") => VolatilityCoupling(),
            ("x3", "x5") => DriftCoupling(),
        )

        hgf = init_hgf(nodes = nodes, edges = edges, verbose = false)

        update_hgf!(hgf, [1, 1])
    end
end
