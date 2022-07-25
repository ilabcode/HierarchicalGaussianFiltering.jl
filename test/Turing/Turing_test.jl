using HGF
using Test
using Turing
@testset "Turing Tests" begin
    
    @testset "Continuous 2level" begin

        ###set input and responses

        test_input = [1.,2,3,4,5]
        test_responses = [1.1,2.2,3.3,4.4,5.5]
    
        ### Set up Agent ###

        #Create HGF
        test_hgf = HGF.premade_hgf("continuous_2level")
        
        #Create Agent
        agent_params_list = (;
        hgf = test_hgf,
        action_precision = 1,
        target_node = "x1",
        target_state = "posterior_mean");
        
        #Create an agent with the gaussian response
        test_agent = HGF.premade_agent(
        "hgf_gaussian_action",
        agent_params_list);

        test_fixed_params_list = ( 
        u_x1_coupling_strenght = 1.0, 
        x1_x2_coupling_strenght = 1.0,
        action_noise =0.01,
        x2_posterior_mean = 1.,
        x1_posterior_precision = 100,
        x2_posterior_precision = 600.
        )

        test_params_prior_list = (
        u_evolution_rate = Normal(log(100.),2),
        x1_evolution_rate = Normal(log(100.),4),
        x2_evolution_rate = Normal(-4,4),
        x1_posterior_mean = Normal(1,sqrt(100.)),
        )

        #Fit inputs and responses
       
        #Fit inputs and responses
        HGF.fit_model(test_agent, test_input, test_responses,test_params_prior_list,test_fixed_params_list)
        @test  true
        HGF.fit_model(test_agent, test_input, test_responses,test_params_prior_list,test_fixed_params_list,NUTS(),1000)
        @test  true
        HGF.fit_model(test_agent, test_input, test_responses,test_params_prior_list,test_fixed_params_list,HMC(0.01, 5),2000)
        @test  true
    end
    

    @testset "Canonical Binary 3level" begin

        binary_test_input = [1.,0,0,1,1]
        binary_test_responses = [0.7,0.8,0.2,0.3,0.9]
        
        #Create HGF
        binary_test_hgf = HGF.premade_hgf("binary_3level")

        binary_agent_params_list = (;
        hgf = binary_test_hgf,
        action_precision = 1,
        target_node = "x1",
        target_state = "posterior_mean");

        binary_test_agent = HGF.premade_agent(
        "hgf_gaussian_action",
        binary_agent_params_list);
        
        binary_test_fixed_params_list = (u_x1_coupling_strenght = 1.0,
        u_x3_coupling_strenght = 1.0, x1_posterior_mean = 1.,
        x1_posterior_precision = exp(-1.0986), x1_x2_coupling_strenght = 1.0,  
        x4_posterior_mean = 1.0, x4_posterior_precision = exp(2.306), 
        x2_posterior_mean = 3., x2_posterior_precision = exp(2.306),  
        x4_evolution_rate = -10.0, x3_posterior_mean = 3.2189, 
        x3_posterior_precision = exp(-1.0986), x3_x4_coupling_strenght = 1.0,
        u_evolution_rate = 1.0,
        )

        binary_test_params_prior_list = (
            action_noise = Truncated(Normal(100,20), 0, Inf),
            x1_evolution_rate = Normal(-3,5),
            x2_evolution_rate = Normal(-7,5),
            x3_evolution_rate = Normal(-3,5),
        )

        HGF.fit_model(binary_test_agent, binary_test_input, binary_test_responses,binary_test_params_prior_list,binary_test_fixed_params_list)
        @test  true
        HGF.fit_model(binary_test_agent, binary_test_input, binary_test_responses,binary_test_params_prior_list,binary_test_fixed_params_list,NUTS(),1000)
        @test  true
        HGF.fit_model(binary_test_agent, binary_test_input, binary_test_responses,binary_test_params_prior_list,binary_test_fixed_params_list,HMC(0.01, 5),2000)
        @test  true
    end
end