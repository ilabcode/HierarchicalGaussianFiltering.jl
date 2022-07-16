# using HGF
# using Test

@testset "Premade_models" begin
    @testset "Errors and utilities" begin

        #Get the error for misspecified input strings
        try
            HGF_test = HGF.premade_hgf("Typo")
            #Get out the error text
        catch error
            buffer = IOBuffer()
            showerror(buffer, error)
            message = String(take!(buffer))
            #And check it is right
            @test message ==
                  "ArgumentError: the specified string does not match any model. Type premade_hgf('help') to see a list of valid input strings"
        end

        #Check that the help function returns nothing
        @test typeof(HGF.premade_hgf("help")) == Nothing
    end

    @testset "Standard 2 level HGF" begin
        #Set parameters and states
        params_list = (;
            u_evolution_rate = log(1e-4),
            x1_evolution_rate = -13.0,
            x2_evolution_rate = -2.0,
            x1_x2_coupling_strength = 1,
            x1_initial_mean = 1.04,
            x1_initial_precision = 1e4,
            x2_initial_mean = 1.0,
            x2_initial_precision = 1.05,
        )

        #Initialize HGF
        HGF_test = HGF.premade_hgf("continuous_2level", params_list)

        #Check parameters
        @test HGF_test.input_nodes["u"].params.evolution_rate == log(1e-4)
        @test HGF_test.state_nodes["x1"].params.evolution_rate == -13.0
        @test HGF_test.state_nodes["x2"].params.evolution_rate == -2.0
        @test HGF_test.state_nodes["x1"].params.volatility_coupling["x2"] == 1

        #Check states
        @test HGF_test.state_nodes["x1"].state.posterior_mean == 1.04
        @test HGF_test.state_nodes["x1"].state.posterior_precision == 1e4
        @test HGF_test.state_nodes["x2"].state.posterior_mean == 1.0
        @test HGF_test.state_nodes["x2"].state.posterior_precision == 1.05

        #Check history
        @test HGF_test.state_nodes["x1"].history.posterior_mean == [1.04]
        @test HGF_test.state_nodes["x1"].history.posterior_precision == [1e4]
        @test HGF_test.state_nodes["x2"].history.posterior_mean == [1.0]
        @test HGF_test.state_nodes["x2"].history.posterior_precision == [1.05]
    end
end
