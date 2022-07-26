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
        u__x1_coupling_strenght = 1.0, 
        x1__x2_coupling_strenght = 1.0,
        action_precision = 100,
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

        #Fit inputs and responses
       
        #Fit inputs and responses
        chn = HGF.fit_model(test_agent, test_input, test_responses,test_params_prior_list,test_fixed_params_list)
        @test  chn isa Turing.Chains
        chn = HGF.fit_model(test_agent, test_input, test_responses,test_params_prior_list,test_fixed_params_list,NUTS(),100)
        @test  chn isa Turing.Chains
        chn = HGF.fit_model(test_agent, test_input, test_responses,test_params_prior_list,test_fixed_params_list,HMC(0.01, 5),200)
        @test  chn isa Turing.Chains
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
        
        binary_test_fixed_params_list = (u__x1_coupling_strenght = 1.0,
        x1__x2_coupling_strenght = 1.0,  
        x2__initial_mean = 3., x2__initial_precision = exp(2.306),
        x3__initial_mean = 3.2189, 
        x3__initial_precision = exp(-1.0986),
        )

        binary_test_params_prior_list = (
            action_precision = Truncated(Normal(100,20), 0, Inf),
            x2__evolution_rate = Normal(-7,5),
            x3__evolution_rate = Normal(-3,5),
        )

        chn=HGF.fit_model(binary_test_agent, binary_test_input, binary_test_responses,binary_test_params_prior_list,binary_test_fixed_params_list)
        @test  chn isa Turing.Chains
        chn=HGF.fit_model(binary_test_agent, binary_test_input, binary_test_responses,binary_test_params_prior_list,binary_test_fixed_params_list,NUTS(),100)
        @test  chn isa Turing.Chains
        chn=HGF.fit_model(binary_test_agent, binary_test_input, binary_test_responses,binary_test_params_prior_list,binary_test_fixed_params_list,HMC(0.01, 5),200)
        @test  chn isa Turing.Chains
    end
end