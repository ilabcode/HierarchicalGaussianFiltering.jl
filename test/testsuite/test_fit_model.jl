using ActionModels
using HierarchicalGaussianFiltering
using Test
using StatsPlots
using Distributions
using ActionModels: Turing

@testset "Model fitting" begin

    @testset "Continuous 2level" begin

        #Set inputs and responses
        test_input = [1.0, 1.0, 1.0, 1.0, 1.0]
        test_responses = [1.0, 1.0, 1.0, 1.0, 1.0]

        #Create HGF
        test_hgf = premade_hgf("continuous_2level", verbose = false)

        #Create agent
        test_agent = premade_agent("hgf_gaussian", test_hgf, verbose = false)

        # Set fixed parsmeters and priors for fitting
        test_fixed_parameters = Dict(
            ("x", "initial_mean") => 1,
            ("xvol", "initial_mean") => 1.0,
            ("xvol", "initial_precision") => 1,
            ("x", "xvol", "coupling_strength") => 1.0,
            "action_noise" => 0.01,
            ("xvol", "volatility") => -10,
            ("u", "input_noise") => 4,
            ("xvol", "drift") => 1,
        )

        test_param_priors = Dict(
            ("x", "volatility") => Normal(-10, 0.1),
        )

        #Create model
        model = create_model(test_agent, test_param_priors, test_input, test_responses;)

        #Fit single chain with defaults
        fitted_model = fit_model(model; n_iterations = 10, n_chains = 1)

        chains = fitted_model.chains
        renamed_model = rename_chains(chains, model)
        #Extract agent parameters
        agent_parameters = extract_quantities(model, chains)

        estimates_df = get_estimates(agent_parameters)
        estimates_dict = get_estimates(agent_parameters, Dict)

        #Extract state trajectories
        state_trajectories = get_trajectories(model, chains, [("x", "value_prediction_error"), "action"])
        trajectory_estimates_df = get_estimates(state_trajectories)

        @test fitted_model isa ActionModels.FitModelResults

        #Plot the parameter distribution
        # plot_parameter_distribution(fitted_model, test_param_priors)

        # Posterior predictive plot
        # plot_predictive_simulation(
        #     fitted_model,
        #     test_agent,
        #     test_input,
        #     ("x", "posterior_mean");
        #     verbose = false,
        #     n_simulations = 3,
        # )
    end


    @testset "Canonical Binary 3level" begin

        #Set inputs and responses 
        test_input = [1, 0, 0, 1, 1]
        test_responses = [1, 0, 1, 1, 0]

        #Create HGF
        test_hgf = premade_hgf("binary_3level", verbose = false)

        #Create agent 
        test_agent = premade_agent("hgf_binary_softmax", test_hgf, verbose = false)

        #Set fixed parameters and priors
        test_fixed_parameters = Dict(
            ("xprob", "initial_mean") => 3.0,
            ("xprob", "initial_precision") => exp(2.306),
            ("xvol", "initial_mean") => 3.2189,
            ("xvol", "initial_precision") => exp(-1.0986),
            ("xbin", "xprob", "coupling_strength") => 1.0,
            ("xprob", "xvol", "coupling_strength") => 1.0,
            ("xvol", "volatility") => -3,
        )

        test_param_priors = Dict(
            "action_noise" => truncated(Normal(0.01, 20), 0, Inf),
            ("xprob", "volatility") => Normal(-7, 5),
        )

        #Create model
        model = create_model(test_agent, test_param_priors, test_input, test_responses;)

        #Fit single chain with defaults
        fitted_model = fit_model(model; n_iterations = 10, n_chains = 1)

        @test fitted_model isa ActionModels.FitModelResults

        #Plot the parameter distribution
        # plot_parameter_distribution(fitted_model, test_param_priors)

        # Posterior predictive plot
        # plot_predictive_simulation(
        #     fitted_model,
        #     test_agent,
        #     test_input,
        #     ("xbin", "posterior_mean"),
        #     verbose = false,
        #     n_simulations = 3,
        # )
    end
end
