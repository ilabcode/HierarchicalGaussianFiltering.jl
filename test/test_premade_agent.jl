using ActionModels
using HierarchicalGaussianFiltering
using Test

@testset "Premade Action Models" begin

    @testset "hgf_gaussian_action" begin

        #Create an HGF agent with the gaussian response
        test_agent = premade_agent(
            "hgf_gaussian_action",
            premade_hgf("continuous_2level", verbose = false),
            verbose = false,
        )

        #Give inputs to the agent
        actions = give_inputs!(test_agent, [1.01, 1.02, 1.03])

        #Check that actions are floats
        @test actions isa Vector{Any}

        #Check that get_surprise works
        @test get_surprise(test_agent.substruct) isa Real
    end

    @testset "hgf_binary_softmax_action" begin

        #Create HGF agent with binary softmax action
        test_agent = premade_agent(
            "hgf_binary_softmax_action",
            premade_hgf("binary_3level", verbose = false),
            verbose = false,
        )

        #Give inputs to the agent
        actions = give_inputs!(test_agent, [1, 0, 1])

        #Check that actions are floats
        @test actions isa Vector{Any}

        #Check that get_surprise works
        @test get_surprise(test_agent.substruct) isa Real
    end


    @testset "hgf_unit_square_sigmoid_action" begin

        #Create HGF agent with binary softmax action
        test_agent = premade_agent(
            "hgf_unit_square_sigmoid_action",
            premade_hgf("binary_3level", verbose = false),
            verbose = false,
        )

        #Give inputs to the agent
        actions = give_inputs!(test_agent, [1, 0, 1])

        #Check that actions are floats
        @test actions isa Vector{Any}

        #Check that get_surprise works
        @test get_surprise(test_agent.substruct) isa Real
    end

end
#