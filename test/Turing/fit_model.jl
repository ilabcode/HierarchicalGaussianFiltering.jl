using HGF
using Test
using Turing
using Plots
using StatsPlots

@testset "Model fitting" begin
    
    @testset "Continuous 2level" begin

        #Set inputs and responses
        test_input = [1.,2,3,4,5]
        test_responses = [1.1,2.2,3.3,4.4,5.5]
    
        #Create HGF
        test_hgf = HGF.premade_hgf("continuous_2level")
        
        #Create agent
        test_agent = HGF.premade_agent(
        "hgf_gaussian_action",
        test_hgf);

        # Set fixed parsmeters and priors for fitting
        test_fixed_params_list = ( 
        u_x1__value_coupling_strength = 1.0, 
        x1_x2__volatility_coupling_strength = 1.0,
        gaussian_action_precision = 100,
        x2__initial_mean = 1.,
        x1__initial_precision = 100,
        x2__initial_precision = 600.
        )

        test_params_prior_list = (
        u__evolution_rate = Normal(log(100.),2),
        x1__evolution_rate = Normal(log(100.),4),
        x2__evolution_rate = Normal(-4,4),
        x1__initial_mean = Normal(1,sqrt(100.)),
        )
       
        #Fit single chain with defaults
        chain = HGF.fit_model(test_agent, test_input, test_responses,test_params_prior_list,test_fixed_params_list)
        @test  chain isa Turing.Chains

        #Fit with multiple chains and HMC
        chain = HGF.fit_model(test_agent, test_input, test_responses,test_params_prior_list,test_fixed_params_list,HMC(0.01, 5),200,4)
        @test  chain isa Turing.Chains

        #Plot the parameter distribution
        parameter_distribution_plot(chain, test_params_prior_list)

        # Posterior predictive plot
        HGF.predictive_simulation_plot(
            test_agent,
            chain,
            "x1__posterior_mean",
            test_input;
            n_simulations = 1000,
        )
    end
    

    @testset "Canonical Binary 3level" begin

        #Set inputs and responses 
        test_input = [1,0,0,1,1]
        test_responses = [1,0,1,1,0]
        
        #Create HGF
        test_hgf = HGF.premade_hgf("binary_3level")

        #Create agent 
        test_agent = HGF.premade_agent(
        "hgf_binary_softmax_action",
        test_hgf);
        
        #Set fixed parameters and priors
        test_fixed_params_list = (u_x1__value_coupling_strength = 1.0,
        x1_x2__value_coupling_strength = 1.0,  
        x2__initial_mean = 3., x2__initial_precision = exp(2.306),
        x3__initial_mean = 3.2189, 
        x3__initial_precision = exp(-1.0986),
        )

        test_params_prior_list = (
            softmax_action_precision = Truncated(Normal(100,20), 0, Inf),
            x2__evolution_rate = Normal(-7,5),
            x3__evolution_rate = Normal(-3,5),
        )

        #Fit single chain with defaults
        chain = HGF.fit_model(test_agent, test_input, test_responses,test_params_prior_list,test_fixed_params_list)
        @test  chain isa Turing.Chains

        #Fit with multiple chains and HMC
        chain = HGF.fit_model(test_agent, test_input, test_responses,test_params_prior_list,test_fixed_params_list,HMC(0.01, 5),200,4)
        @test  chain isa Turing.Chains

        #Plot the parameter distribution
        parameter_distribution_plot(chain, test_params_prior_list)

        # Posterior predictive plot
        HGF.predictive_simulation_plot(
            test_agent,
            chain,
            "x1__prediction_mean",
            test_input;
            n_simulations = 1000,
        )
    end
end