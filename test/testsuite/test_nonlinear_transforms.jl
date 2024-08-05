using Test
using HierarchicalGaussianFiltering
using Distributions

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

        set_parameters!(
            hgf,
            Dict(
                ("u", "input_noise") => 4,
                ("x1", "autoconnection_strength") => 0
            ),
        )

        inputs = sin.(collect(0:1/20:1000/20))

        #Add gaussian noise
        inputs = rand(Normal(0, 0.5), length(inputs)) + inputs

        give_inputs!(hgf, inputs)
    end
end
