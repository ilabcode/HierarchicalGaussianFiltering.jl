# using HGF
# using Test
# using CSV
# using DataFrames

@testset "Canonical Tests" begin

    ### Setup ###
    #Get the path for the HGF superfolder
    hgf_path = dirname(dirname(pathof(HGF)))
    #Add the path to the data files
    data_path = hgf_path * "/test/hgf_perception_model/data/"
    
    @testset "Canonical Continuous 2level" begin

        ### Import trajectories ###
        #Create paths to required data files
        input_trajectory_path = data_path * "canonical_continuous2level_inputs.dat"
        canonical_trajectory_path = data_path * "canonical_continuous2level_states.csv"
    
        ##Import the input trajectory
        #Make empty list
        input_trajectory = Float64[]
    
        #Open the file
        open(input_trajectory_path) do f
            for ln in eachline(f)
                push!(input_trajectory, parse(Float64, ln))
            end
        end
    
        #Import the python trajectory, which the julia implementation is compared to
        target_outputs = CSV.read(canonical_trajectory_path, DataFrame)
    
    
        ### Set up HGF ###
        #set parameters and starting states
        params_list = (;
            u_evolution_rate = log(1e-4),
            x1_evolution_rate = -13.0,
            x2_evolution_rate = -2.0,
            x1_x2_coupling_strength = 1,
        )
        starting_state_list = (;
            x1_posterior_mean = 1.04,
            x1_posterior_precision = 1e4,
            x2_posterior_mean = 1.0,
            x2_posterior_precision = 10,
        )
    
        #Create HGF
        test_hgf = HGF.premade_hgf("continuous_2level", params_list, starting_state_list)
    
        #Give inputs
        HGF.give_inputs!(test_hgf, input_trajectory)
    
        #Construct result output dataframe
        result_outputs = DataFrame(
            x1_mean = test_hgf.state_nodes["x1"].history.posterior_mean,
            x1_precision = test_hgf.state_nodes["x1"].history.posterior_precision,
            x2_mean = test_hgf.state_nodes["x2"].history.posterior_mean,
            x2_precision = test_hgf.state_nodes["x2"].history.posterior_precision,
        )
    
        #Test if the values are approximately the same
        @testset "compare output trajectories" begin
            for i = 1:nrow(result_outputs)
                @test result_outputs.x1_mean[i] ≈ target_outputs.x1_mean[i]
                @test result_outputs.x1_precision[i] ≈ target_outputs.x1_precision[i]
                @test result_outputs.x2_mean[i] ≈ target_outputs.x2_mean[i]
                @test result_outputs.x2_precision[i] ≈ target_outputs.x2_precision[i]
            end
        end
    end
    

    @testset "Canonical Binary 3level" begin
        ### Import trajectories ###
        #Create path to required data files
        canonical_trajectory_path = data_path * "canonical_binary3level.csv"
    
        #Import the canonical trajectory of states
        canonical_trajectory = CSV.read(canonical_trajectory_path, DataFrame)

        ### Set up HGF ###
        #set parameters and starting states
        params_list = (;)
        starting_state_list = (;)
    
        #Create HGF
        test_hgf = HGF.premade_hgf("binary_3level", params_list, starting_state_list)

        #Give inputs (mu1's are equal to the inputs in a binary HGF without sensory noise)
        HGF.give_inputs!(test_hgf, canonical_trajectory.mu1)

        #Construct result output dataframe
        result_outputs = DataFrame(
            x1_mean = test_hgf.state_nodes["x1"].history.posterior_mean,
            x1_precision = test_hgf.state_nodes["x1"].history.posterior_precision,
            x2_mean = test_hgf.state_nodes["x2"].history.posterior_mean,
            x2_precision = test_hgf.state_nodes["x2"].history.posterior_precision,
            x3_mean = test_hgf.state_nodes["x3"].history.posterior_mean,
            x3_precision = test_hgf.state_nodes["x3"].history.posterior_precision, 
        )
    
        #Test if the values are approximately the same
        # @testset "compare output trajectories" begin
        #     for i = 1:nrow(result_outputs)
        #         @test result_outputs.x1_mean[i] ≈ target_outputs.mu1[i]
        #         @test result_outputs.x1_precision[i] ≈ target_outputs.sa1[i]
        #         @test result_outputs.x2_mean[i] ≈ target_outputs.mu2[i]
        #         @test result_outputs.x2_precision[i] ≈ target_outputs.sa2[i]
        #         @test result_outputs.x3_mean[i] ≈ target_outputs.mu3[i]
        #         @test result_outputs.x3_precision[i] ≈ target_outputs.sa3[i]
        #     end
        # end
    end
end


