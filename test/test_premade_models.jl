using HGF
using Test

@testset "Premade_models" begin
    params_list_2level = (; evolution_rate_in1 = 2, evolution_rate_1 = 2, coupling_1_in1=2)
    starting_state_list_2level = (;starting_state_1 = (;
    posterior_mean = 1,
    posterior_precision = 1,),
    )
    params_list_3level = (; evolution_rate_in1 = 2, evolution_rate_1 = 2, coupling_1_in1=2, evolution_rate_2 = 2, coupling_2_in1=2)
    starting_state_list_3level = (;starting_state_1 = (;
    posterior_mean = 1,
    posterior_precision = 1,), starting_state_2 = (;
    posterior_mean = 1,
    posterior_precision = 1,),
    )

    HGF_test1 = HGF.premade_HGF(
        "Standard2level",
        params_list_2level,
        starting_state_list_2level,
    )

    HGF_test2 = HGF.premade_HGF(
        "Standard3level",
        params_list_3level,
        starting_state_list_3level,
    )

    HGF_test3 = HGF.premade_HGF(
        "Typo",
        params_list_2level,
        starting_state_list_2level,
    )

    HGF_test4 = HGF.standard_function_2level(
        params_list_2level,
        starting_state_list_2level,
    )

    HGF_test5 = HGF.standard_function_3level(
        params_list_3level,
        starting_state_list_3level,
    )
    @testset "Check if output matches input" begin
        @test HGF_test1.state_nodes["x_1"].params.evolution_rate == 2
        @test HGF_test2.state_nodes["x_2"].params.evolution_rate == 2
        @test HGF_test3 == "error"
        @test HGF_test4.state_nodes["x_1"].params.evolution_rate == 2
        @test HGF_test5.state_nodes["x_2"].params.evolution_rate == 2
    end
end

