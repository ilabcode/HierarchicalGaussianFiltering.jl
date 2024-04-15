using HierarchicalGaussianFiltering
using Test

@testset "Grouped parameters" begin

    # Test of custom HGF with shared parameters

    #List of nodes
    nodes = [
        ContinuousInput(name = "u", input_noise = 2),
        ContinuousState(
            name = "x1",
            volatility = 2,
            initial_mean = 1,
            initial_precision = 1,
        ),
        ContinuousState(
            name = "x2",
            volatility = 2,
            initial_mean = 1,
            initial_precision = 1,
        ),
    ]

    #List of child-parent relations
    edges =
        Dict(("u", "x1") => ObservationCoupling(), ("x1", "x2") => VolatilityCoupling(1))

    # one shared parameter
    parameter_groups_1 =
        [ParameterGroup("volatilities", [("x1", "volatility"), ("x2", "volatility")], 9)]

    #Initialize the HGF
    hgf_1 = init_hgf(nodes = nodes, edges = edges, parameter_groups = parameter_groups_1)

    #get shared parameter
    get_parameters(hgf_1)

    @test get_parameters(hgf_1, "volatilities") == 9

    #set shared parameter
    set_parameters!(hgf_1, "volatilities", 2)

    parameter_groups_2 = [
        ParameterGroup(
            "initial_means",
            [("x1", "initial_mean"), ("x2", "initial_mean")],
            9,
        ),
        ParameterGroup("volatilities", [("x1", "volatility"), ("x2", "volatility")], 9),
    ]

    #Initialize the HGF
    hgf_2 = init_hgf(nodes = nodes, edges = edges, parameter_groups = parameter_groups_2)

    #get all parameters
    get_parameters(hgf_2)

    #get shared parameter
    @test get_parameters(hgf_2, "volatilities") == 9

    #set shared parameter
    set_parameters!(hgf_2, Dict("volatilities" => -2, "initial_means" => 1))

    @test get_parameters(hgf_2, "volatilities") == -2
    @test get_parameters(hgf_2, "initial_means") == 1


end
