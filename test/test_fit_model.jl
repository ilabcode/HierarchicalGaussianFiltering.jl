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
            ("x", "initial_mean") => 100,
            ("xvol", "initial_mean") => 1.0,
            ("xvol", "initial_precision") => 600,
            ("u", "x", "value_coupling") => 1.0,
            ("x", "xvol", "volatility_coupling") => 1.0,
            "gaussian_action_precision" => 100,
            ("xvol", "volatility") => -4,
            ("u", "input_noise") => 4,
            ("xvol", "drift") => 1,
        )

        test_param_priors = Dict(
            ("x", "volatility") => Normal(log(100.0), 4),
            ("x", "initial_mean") => Normal(1, sqrt(100.0)),
            ("x", "drift") => Normal(0, 1),
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
            ("x", "posterior_mean");
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
            ("xprob", "initial_mean") => 3.0,
            ("xprob", "initial_precision") => exp(2.306),
            ("xvol", "initial_mean") => 3.2189,
            ("xvol", "initial_precision") => exp(-1.0986),
            ("xbin", "xprob", "value_coupling") => 1.0,
            ("xprob", "xvol", "volatility_coupling") => 1.0,
            ("xvol", "volatility") => -3,
        )

        test_param_priors = Dict(
            "softmax_action_precision" => truncated(Normal(100, 20), 0, Inf),
            ("xprob", "volatility") => Normal(-7, 5),
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
            ("xbin", "posterior_mean"),
            verbose = false,
            n_simulations = 3,
        )
    end
end
