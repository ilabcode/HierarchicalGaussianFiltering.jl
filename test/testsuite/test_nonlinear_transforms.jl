using Test
using HierarchicalGaussianFiltering

@testset "Testing nonlinear transforms" begin

    @testset "Sinoid transform" begin
        nodes = [
            ContinuousInput(name = "u"),
            ContinuousState(name = "x1"),
            ContinuousState(name = "x2"),
        ]

        base = function (x, parameters::Dict)
            sin(x)
        end
        first_derivative = function (x, parameters::Dict)
            cos(x)
        end
        second_derivative = function (x, parameters::Dict)
            -sin(x)
        end
        transform_parameters = Dict()

        edges = Dict(
            ("u", "x1") => ObservationCoupling(),
            ("x1", "x2") => DriftCoupling(
                2,
                NonlinearTransform(
                    base,
                    first_derivative,
                    second_derivative,
                    transform_parameters,
                ),
            ),
        )

        hgf = init_hgf(nodes = nodes, edges = edges, verbose = false)

        update_hgf!(hgf, 1)
    end
end
