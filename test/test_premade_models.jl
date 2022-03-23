using HGF
using Test

@testset "Premade_models" begin
    @testset "Errors and utilities" begin
        #Calling help

        #When the string is misspecified
        params_list = (;)
        starting_state_list = (;)
        HGF_test = HGF.premade_HGF("Typo", params_list, starting_state_list)
        @test HGF_test == "error"

        #When asking for help
        HGF_test = HGF.premade_HGF("help")
        @test HGF_test[3] == "2level"
    end

    @testset "Standard 2 level HGF" begin
        #Setup
        params_list = (; evolution_rate_in1 = 2, evolution_rate_1 = 2, coupling_1_in1 = 2)
        starting_state_list =
            (; starting_state_1 = (; posterior_mean = 1, posterior_precision = 1))

        #Call from superfunction
        HGF_test = HGF.premade_HGF("Standard2level", params_list, starting_state_list)
        @test HGF_test.state_nodes["x_1"].params.evolution_rate == 2

        #Call directly
        HGF_test = HGF.standard_function_2level(params_list, starting_state_list)
        @test HGF_test.state_nodes["x_1"].params.evolution_rate == 2
    end

    @testset "Standard 2 level HGF bis" begin
        #Setup
        params_list = (;
            evolution_rate_u = 0.0,
            evolution_rate_1 = -2.0,
            coupling_1_u = 2,
            evolution_rate_2 = -12.0,
            coupling_2_1 = 2,
        )
        starting_state_list = (;
            starting_state_1 = (; posterior_mean = 1.04, posterior_precision = Inf), #check if this infinity will work
            starting_state_2 = (; posterior_mean = 1.0, posterior_precision = Inf),
        )

        #Call from superfunction
        HGF_test = HGF.premade_HGF("2level", params_list, starting_state_list)
        @test HGF_test.state_nodes["x_1"].params.evolution_rate == params_list.evolution_rate_1

        #Call directly
        HGF_test = HGF.standard_2level(params_list, starting_state_list)
        @test HGF_test.state_nodes["x_2"].params.evolution_rate == params_list.evolution_rate_2
    end

    
    @testset "Standard 3 level HGF" begin
        #Setup
        params_list = (;
            evolution_rate_in1 = 2,
            evolution_rate_1 = 2,
            coupling_1_in1 = 2,
            evolution_rate_2 = 2,
            coupling_2_in1 = 2,
        )
        starting_state_list = (;
            starting_state_1 = (; posterior_mean = 1, posterior_precision = 1),
            starting_state_2 = (; posterior_mean = 1, posterior_precision = 1),
        )

        #Call from superfunction
        HGF_test = HGF.premade_HGF("Standard3level", params_list, starting_state_list)
        @test HGF_test.state_nodes["x_2"].params.evolution_rate == 2

        #Call directly
        HGF_test = HGF.standard_function_3level(params_list, starting_state_list)
        @test HGF_test.state_nodes["x_2"].params.evolution_rate == 2
    end

end

