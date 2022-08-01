using HGF
using Test

@testset "Premade Action Models" begin

    @testset "hgf_gaussian_action" begin

        #Set HGF parameters
        hgf_params_list = (;
            u_evolution_rate = log(1e-4),
            x1_evolution_rate = -13.0,
            x2_evolution_rate = -2.0,
            x1_x2_coupling_strength = 1,
            x1_initial_mean = 1.04,
            x1_initial_precision = 1e4,
            x2_initial_mean = 1.0,
            x2_initial_precision = 1e1,
        );

        #Initialize HGF
        test_hgf = HGF.premade_hgf("continuous_2level", hgf_params_list);

        #Set action model parameters
        agent_params_list = (;
            hgf = test_hgf,
            gaussian_action_precision = 1,
            target_node = "x1",
            target_state = "posterior_mean");

        #Create an agent with the gaussian response
        test_agent = HGF.premade_agent(
            "hgf_gaussian_action",
            agent_params_list);

        #Give inputs to the agent
        actions = HGF.give_inputs!(test_agent, [1.01, 1.02, 1.03])

        #Check that actions are floats
        @test actions isa Vector{Any}

        #Check that get_surprise works
        @test HGF.get_surprise(test_agent) isa Real
    end

    @testset "hgf_binary_softmax_action" begin
        
        #Set parameters for the action model
        params_list = (; hgf = HGF.premade_hgf("binary_3level"));

        #Create agent with binary softmax action
        test_agent = HGF.premade_agent(
            "hgf_binary_softmax_action",
            params_list,
        );

        #Give inputs to the agent
        actions = HGF.give_inputs!(test_agent, [1, 0, 1])

        #Check that actions are floats
        @test actions isa Vector{Any}

        #Check that get_surprise works
        @test HGF.get_surprise(test_agent) isa Real
    end

    
    @testset "hgf_unit_square_sigmoid_action" begin
        
        #Initialize HGF
        params_list = (; hgf = HGF.premade_hgf("binary_3level"));

        #Create agent with binary softmax action
        test_agent = HGF.premade_agent(
            "hgf_unit_square_sigmoid_action",
            params_list
        );

        #Give inputs to the agent
        actions = HGF.give_inputs!(test_agent, [1, 0, 1])

        #Check that actions are floats
        @test actions isa Vector{Any}

        #Check that get_surprise works
        @test HGF.get_surprise(test_agent) isa Real
    end

end
#