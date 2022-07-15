@testset "Premade Action Models" begin

    @testset "hgf_gaussian_action" begin

        #Set parameters
        params_list = (;
            u_evolution_rate = log(1e-4),
            x1_evolution_rate = -13.0,
            x2_evolution_rate = -2.0,
            x1_x2_coupling_strength = 1,
        )

        # Set starting states
        starting_state_list = (;
            x1_posterior_mean = 1.04,
            x1_posterior_precision = 1e4,
            x2_posterior_mean = 1.0,
            x2_posterior_precision = 1e1,
        )

        #Initialize HGF
        test_hgf = HGF.premade_hgf("continuous_2level", params_list, starting_state_list)

        #Create an agent with the gaussian response
        test_agent = HGF.premade_agent(
            "hgf_gaussian_action",
            test_hgf,
            Dict("action_precision" => 1),
            Dict(),
            Dict("target_node" => "x1", "target_state" => "posterior_mean"),
        )

        #Give inputs to the agent
        actions = HGF.give_inputs!(test_agent, [1.01, 1.02, 1.03])

        #Check that actions are floats
        @test actions isa Vector{Any}
    end


    @testset "hgf_binary_softmax_action" begin
        
        #Initialize HGF
        test_hgf = HGF.premade_hgf("binary_3level");

        #Create agent with binary softmax action
        test_agent = HGF.premade_agent(
            "hgf_binary_softmax_action",
            test_hgf,
            Dict("action_precision" => 1),
            Dict(),
            Dict("target_node" => "x1", "target_state" => "prediction_mean"),
        );

        #Give inputs to the agent
        actions = HGF.give_inputs!(test_agent, [1, 0, 1])

        #Check that actions are floats
        @test actions isa Vector{Any}
    end

    
    @testset "hgf_unit_square_sigmoid_action" begin
        
        #Initialize HGF
        test_hgf = HGF.premade_hgf("binary_3level");

        #Create agent with binary softmax action
        test_agent = HGF.premade_agent(
            "hgf_unit_square_sigmoid_action",
            test_hgf,
            Dict("action_precision" => 1),
            Dict(),
            Dict("target_node" => "x1", "target_state" => "prediction_mean"),
        );

        #Give inputs to the agent
        actions = HGF.give_inputs!(test_agent, [1, 0, 1])

        #Check that actions are floats
        @test actions isa Vector{Any}
    end

end
