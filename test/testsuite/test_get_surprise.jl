using Test
using HierarchicalGaussianFiltering


@testset "Test get_surprise" begin

    @testset "Test for state-transition HGF" begin

        #Set up test inputs
        test_inputs = [
            missing missing 2 missing
            missing 1 missing missing
            missing missing missing 3
            missing missing missing missing
            3 missing missing missing
        ]

        #Initialize HGF
        HGF_test = premade_hgf("categorical_state_transitions", verbose = false)

        #Give inputs
        give_inputs!(HGF_test, test_inputs)

        #Get surprise
        @test get_surprise(HGF_test) isa Real

    end
end