using ActionModels
using HierarchicalGaussianFiltering
using Test
using Plots
using StatsPlots
using Distributions
using Turing

@testset "Model fitting" begin

    @testset "Continuous 2level" begin

        #Set inputs and responses
        test_input = [1.0, 2, 3, 4, 5]
        test_responses = [1.1, 2.2, 3.3, 4.4, 5.5]

        #Create HGF
        test_hgf = premade_hgf("continuous_2level", verbose = false)

        #Create agent
        test_agent = premade_agent("hgf_gaussian_action", test_hgf, verbose = false)

        # Set fixed parsmeters and priors for fitting
        test_fixed_parameters = Dict(
            ("x1", "initial_mean") => 100,
            ("x2", "initial_mean") => 1.0,
            ("x2", "initial_precision") => 600,
            ("u", "x1", "value_coupling") => 1.0,
            ("x1", "x2", "volatility_coupling") => 1.0,
            "gaussian_action_precision" => 100,
            ("x2", "evolution_rate") => -4,
            ("u", "input_noise") => 4,
            ("x2", "drift") => 1,
        )

        test_param_priors = Dict(
            ("x1", "evolution_rate") => Normal(log(100.0), 4),
            ("x1", "initial_mean") => Normal(1, sqrt(100.0)),
            ("x1", "drift") => Normal(0, 1),
        )

        #Fit single chain with defaults
        fitted_model = fit_model(
            test_agent,
            test_param_priors,
            test_input,
            test_responses;
            fixed_parameters = test_fixed_parameters,
            verbose = false,
            n_iterations = 10,
        )
        @test fitted_model isa Turing.Chains

        #Fit with multiple chains and HMC
        fitted_model = fit_model(
            test_agent,
            test_param_priors,
            test_input,
            test_responses;
            fixed_parameters = test_fixed_parameters,
            sampler = HMC(0.01, 5),
            n_chains = 4,
            verbose = false,
            n_iterations = 10,
        )
        @test fitted_model isa Turing.Chains

        #Plot the parameter distribution
        plot_parameter_distribution(fitted_model, test_param_priors)

        # Posterior predictive plot
        plot_predictive_simulation(
            fitted_model,
            test_agent,
            test_input,
            ("x1", "posterior_mean");
            verbose = false,
            n_simulations = 3,
        )
    end


    @testset "Canonical Binary 3level" begin

        #Set inputs and responses 
        test_input = [1, 0, 0, 1, 1]
        test_responses = [1, 0, 1, 1, 0]

        #Create HGF
        test_hgf = premade_hgf("binary_3level", verbose = false)

        #Create agent 
        test_agent = premade_agent("hgf_binary_softmax_action", test_hgf, verbose = false)

        #Set fixed parameters and priors
        test_fixed_parameters = Dict(
            ("u", "category_means") => Real[0.0, 1.0],
            ("u", "input_precision") => Inf,
            ("x2", "initial_mean") => 3.0,
            ("x2", "initial_precision") => exp(2.306),
            ("x3", "initial_mean") => 3.2189,
            ("x3", "initial_precision") => exp(-1.0986),
            ("x1", "x2", "value_coupling") => 1.0,
            ("x2", "x3", "volatility_coupling") => 1.0,
            ("x3", "evolution_rate") => -3,
        )

        test_param_priors = Dict(
            "softmax_action_precision" => Truncated(Normal(100, 20), 0, Inf),
            ("x2", "evolution_rate") => Normal(-7, 5),
        )

        #Fit single chain with defaults
        fitted_model = fit_model(
            test_agent,
            test_param_priors,
            test_input,
            test_responses;
            fixed_parameters = test_fixed_parameters,
            verbose = false,
            n_iterations = 10,
        )
        @test fitted_model isa Turing.Chains

        #Fit with multiple chains and HMC
        fitted_model = fit_model(
            test_agent,
            test_param_priors,
            test_input,
            test_responses;
            fixed_parameters = test_fixed_parameters,
            sampler = HMC(0.01, 5),
            n_chains = 4,
            verbose = false,
            n_iterations = 10,
        )
        @test fitted_model isa Turing.Chains

        #Plot the parameter distribution
        plot_parameter_distribution(fitted_model, test_param_priors)

        # Posterior predictive plot
        plot_predictive_simulation(
            fitted_model,
            test_agent,
            test_input,
            ("x1", "posterior_mean"),
            verbose = false,
            n_simulations = 3,
        )
    end
end
