using HGF
using Test
using CSV
using DataFrames
using Plots

@testset "Canonical Tests" begin

    ### Setup ###
    #Get the path for the HGF superfolder
    hgf_path = dirname(dirname(pathof(HGF)))
    #Add the path to the data files
    data_path = hgf_path * "/test/data/"

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
        params = Dict(
            ("u", "x1", "value_coupling") => 1.0,
            ("x1", "x2", "volatility_coupling") => 1.0,
            ("u", "evolution_rate") => log(1e-4),
            ("x1", "evolution_rate") => -13,
            ("x2", "evolution_rate") => -2,
            ("x1", "initial_mean") => 1.04,
            ("x1", "initial_precision") => 1e4,
            ("x2", "initial_mean") => 1.0,
            ("x2", "initial_precision") => 10,
        )

        #Create HGF
        test_hgf = premade_hgf("continuous_2level", params)

        #Give inputs
        give_inputs!(test_hgf, input_trajectory)

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

        @testset "Trajectory plots" begin
            #Make trajectory plots
            trajectory_plot(test_hgf, "u")
            trajectory_plot!(test_hgf, ("x1", "posterior"))
        end
    end


    @testset "Canonical Binary 3level" begin

        ### Import trajectories ###
        #Create path to required data files
        canonical_trajectory_path = data_path * "canonical_binary3level.csv"

        #Import the canonical trajectory of states
        canonical_trajectory = CSV.read(canonical_trajectory_path, DataFrame)

        ### Set up HGF ###    
        #Create HGF
        test_hgf = premade_hgf("binary_3level")

        #Give inputs (mu1's are equal to the inputs in a binary HGF without sensory noise)
        give_inputs!(test_hgf, canonical_trajectory.mu1)

        #Construct result output dataframe
        result_outputs = DataFrame(
            x1_mean = test_hgf.state_nodes["x1"].history.posterior_mean,
            x1_precision = test_hgf.state_nodes["x1"].history.posterior_precision,
            x2_mean = test_hgf.state_nodes["x2"].history.posterior_mean,
            x2_precision = test_hgf.state_nodes["x2"].history.posterior_precision,
            x3_mean = test_hgf.state_nodes["x3"].history.posterior_mean,
            x3_precision = test_hgf.state_nodes["x3"].history.posterior_precision,
        )

        #Remove the first row
        result_outputs = result_outputs[2:end, :]

        #Test if the values are approximately the same
        @testset "compare output trajectories" begin
            for i = 1:nrow(canonical_trajectory)
                @test result_outputs.x1_mean[i] ≈ canonical_trajectory.mu1[i]
                @test result_outputs.x1_precision[i] ≈ 1 / canonical_trajectory.sa1[i]
                @test isapprox(
                    result_outputs.x2_mean[i],
                    canonical_trajectory.mu2[i],
                    rtol = 0.1,
                )
                @test isapprox(
                    result_outputs.x2_precision[i],
                    1 / canonical_trajectory.sa2[i],
                    rtol = 0.1,
                )
                @test isapprox(
                    result_outputs.x3_mean[i],
                    canonical_trajectory.mu3[i],
                    rtol = 0.1,
                )
                @test isapprox(
                    result_outputs.x3_precision[i],
                    1 / canonical_trajectory.sa3[i],
                    rtol = 0.1,
                )
            end
        end

        @testset "Trajectory plots" begin
            #Make trajectory plots
            trajectory_plot(test_hgf, "u")
            trajectory_plot!(test_hgf, ("x1", "prediction"))
        end
    end
end
