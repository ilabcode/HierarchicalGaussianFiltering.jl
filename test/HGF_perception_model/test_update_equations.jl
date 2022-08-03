@testset "Update equations" begin
    #Test node 
    x_main = HGF.StateNode(name = "x_main")
    #Value Children
    x_value_child_1 = HGF.StateNode(name = "x_value_child_1")
    x_value_child_2 = HGF.StateNode(name = "x_value_child_2")
    #Volatility Children
    x_volatility_child_1 = HGF.StateNode(name = "x_volatility_child_1")
    x_volatility_child_2 = HGF.StateNode(name = "x_volatility_child_2")
    #Value Parents
    x_value_parent_1 = HGF.StateNode(name = "x_value_parent_1")
    x_value_parent_2 = HGF.StateNode(name = "x_value_parent_2")
    #Volatility Parents
    x_volatility_parent_1 = HGF.StateNode(name = "x_volatility_parent_1")
    x_volatility_parent_2 = HGF.StateNode(name = "x_volatility_parent_2")
    #Connections
    x_main.value_children = [x_value_child_1, x_value_child_2]
    x_main.volatility_children = [x_volatility_child_1, x_volatility_child_2]
    x_main.value_parents = [x_value_parent_1, x_value_parent_2]
    x_main.volatility_parents = [x_volatility_parent_1, x_volatility_parent_2]
    #Coupling strengths
    x_value_child_1.params.value_coupling["x_main"] = 0.5
    x_value_child_2.params.value_coupling["x_main"] = 0.5
    x_volatility_child_1.params.volatility_coupling["x_main"] = 0.5
    x_volatility_child_2.params.volatility_coupling["x_main"] = 0.5
    x_main.params.value_coupling["x_value_parent_1"] = 0.5
    x_main.params.value_coupling["x_value_parent_2"] = 0.5
    x_main.params.volatility_coupling["x_volatility_parent_1"] = 0.5
    x_main.params.volatility_coupling["x_volatility_parent_2"] = 0.5

    @testset "Prediction updates" begin
        #Prediction mean
        @test HGF.calculate_prediction_mean(x_main, []) ≈ 0.5
        @test HGF.calculate_prediction_mean(x_main, [x_value_parent_1]) ≈ 0.75
        @test HGF.calculate_prediction_mean(x_main, [x_value_parent_1, x_value_parent_2]) ≈
              1.0
        #Prediction volatility
        @test HGF.calculate_prediction_volatility(x_main, []) ≈ 1.64872127
        @test HGF.calculate_prediction_volatility(x_main, [x_volatility_parent_1]) ≈
              2.1170000
        @test HGF.calculate_prediction_volatility(
            x_main,
            [x_volatility_parent_1, x_volatility_parent_2],
        ) ≈ 2.71828182
        #Prediction precision
        @test HGF.calculate_prediction_precision(x_main) ≈ 0.4
        #Auxiliary prediction precision
        @test HGF.calculate_auxiliary_prediction_precision(x_main) ≈ 0.25
    end

    @testset "Posterior precision updates" begin
        #VAPE update
        @test HGF.calculate_posterior_precision_vape(
            x_main.state.posterior_precision,
            x_main,
            [],
        ) ≈ 0.5
        @test HGF.calculate_posterior_precision_vape(
            x_main.state.posterior_precision,
            x_main,
            [x_value_child_1],
        ) ≈ 0.75
        @test HGF.calculate_posterior_precision_vape(
            x_main.state.posterior_precision,
            x_main,
            [x_value_child_1, x_value_child_2],
        ) ≈ 1.0
        #VOPE helper function
        @test HGF.calculate_posterior_precision_vope_helper(
            x_main.state.auxiliary_prediction_precision,
            x_volatility_child_1.params.volatility_coupling["x_main"],
            x_volatility_child_1.state.volatility_prediction_error,
        ) ≈ 0.03125
        #VOPE update
        @test HGF.calculate_posterior_precision_vope(
            x_main.state.posterior_precision,
            x_main,
            [],
        ) ≈ 0.5
        @test HGF.calculate_posterior_precision_vope(
            x_main.state.posterior_precision,
            x_main,
            [x_volatility_child_1],
        ) ≈ 0.53125
        @test HGF.calculate_posterior_precision_vope(
            x_main.state.posterior_precision,
            x_main,
            [x_volatility_child_1, x_volatility_child_2],
        ) ≈ 0.5625
        #Full function
        @test HGF.calculate_posterior_precision(x_main, [], []) ≈ 0.5
        @test HGF.calculate_posterior_precision(x_main, [], [x_volatility_child_1]) ≈
              0.53125
        @test HGF.calculate_posterior_precision(
            x_main,
            [],
            [x_volatility_child_1, x_volatility_child_2],
        ) ≈ 0.5625
        @test HGF.calculate_posterior_precision(x_main, [x_value_child_1], []) ≈ 0.75
        @test HGF.calculate_posterior_precision(
            x_main,
            [x_value_child_1],
            [x_volatility_child_1],
        ) ≈ 0.78125
        @test HGF.calculate_posterior_precision(
            x_main,
            [x_value_child_1],
            [x_volatility_child_1, x_volatility_child_2],
        ) ≈ 0.8125
        @test HGF.calculate_posterior_precision(
            x_main,
            [x_value_child_1, x_value_child_2],
            [],
        ) ≈ 1.0
        @test HGF.calculate_posterior_precision(
            x_main,
            [x_value_child_1, x_value_child_2],
            [x_volatility_child_1],
        ) ≈ 1.03125
        @test HGF.calculate_posterior_precision(
            x_main,
            [x_value_child_1, x_value_child_2],
            [x_volatility_child_1, x_volatility_child_2],
        ) ≈ 1.0625
    end

    @testset "Posterior mean updates" begin
        #VAPE update
        @test HGF.calculate_posterior_mean_vape(x_main.state.posterior_mean, x_main, []) ≈
              0.5
        @test HGF.calculate_posterior_mean_vape(
            x_main.state.posterior_mean,
            x_main,
            [x_value_child_1],
        ) ≈ 0.75
        @test HGF.calculate_posterior_mean_vape(
            x_main.state.posterior_mean,
            x_main,
            [x_value_child_1, x_value_child_2],
        ) ≈ 1.0
        #VOPE update
        @test HGF.calculate_posterior_mean_vope(x_main.state.posterior_mean, x_main, []) ≈
              0.5
        @test HGF.calculate_posterior_mean_vope(
            x_main.state.posterior_mean,
            x_main,
            [x_volatility_child_1],
        ) ≈ 0.625
        @test HGF.calculate_posterior_mean_vope(
            x_main.state.posterior_mean,
            x_main,
            [x_volatility_child_1, x_volatility_child_2],
        ) ≈ 0.75
        #Full function
        @test HGF.calculate_posterior_mean(x_main, [], []) ≈ 0.5
        @test HGF.calculate_posterior_mean(x_main, [], [x_volatility_child_1]) ≈ 0.625
        @test HGF.calculate_posterior_mean(
            x_main,
            [],
            [x_volatility_child_1, x_volatility_child_2],
        ) ≈ 0.75
        @test HGF.calculate_posterior_mean(x_main, [x_value_child_1], []) ≈ 0.75
        @test HGF.calculate_posterior_mean(
            x_main,
            [x_value_child_1],
            [x_volatility_child_1],
        ) ≈ 0.875
        @test HGF.calculate_posterior_mean(
            x_main,
            [x_value_child_1],
            [x_volatility_child_1, x_volatility_child_2],
        ) ≈ 1.0
        @test HGF.calculate_posterior_mean(x_main, [x_value_child_1, x_value_child_2], []) ≈
              1.0
        @test HGF.calculate_posterior_mean(
            x_main,
            [x_value_child_1, x_value_child_2],
            [x_volatility_child_1],
        ) ≈ 1.125
        @test HGF.calculate_posterior_mean(
            x_main,
            [x_value_child_1, x_value_child_2],
            [x_volatility_child_1, x_volatility_child_2],
        ) ≈ 1.25
    end

    @testset "Prediction error updates" begin
        #VAPE
        @test HGF.calculate_value_prediction_error(x_main) ≈ 0.0
        #VOPE
        @test HGF.calculate_volatility_prediction_error(x_main) ≈ 0.125
    end
end
