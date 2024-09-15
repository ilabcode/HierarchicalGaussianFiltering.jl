using HierarchicalGaussianFiltering
using Test
using CSV
using DataFrames
using Plots

@testset "Canonical Tests" begin

    ### Setup ###end
    #Get the path for the HGF superfolder
    hgf_path = dirname(dirname(pathof(HierarchicalGaussianFiltering)))
    #Add the path to the data files
    data_path = hgf_path * "/test/testsuite/data/"

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
        parameters = Dict(
            ("u", "input_noise") => log(1e-4),
            ("x", "volatility") => -13,
            ("x", "initial_mean") => 1.04,
            ("x", "initial_precision") => 1e4,
            ("xvol", "volatility") => -2,
            ("xvol", "initial_mean") => 1.0,
            ("xvol", "initial_precision") => 10,
            ("x", "xvol", "coupling_strength") => 1.0,
            "update_type" => ClassicUpdate(),
        )

        #Create HGF
        test_hgf = premade_hgf("continuous_2level", parameters, verbose = false)

        #Give inputs
        give_inputs!(test_hgf, input_trajectory)

        #Construct result output dataframe
        result_outputs = DataFrame(
            x_mean = test_hgf.state_nodes["x"].history.posterior_mean,
            x_precision = test_hgf.state_nodes["x"].history.posterior_precision,
            xvol_mean = test_hgf.state_nodes["xvol"].history.posterior_mean,
            xvol_precision = test_hgf.state_nodes["xvol"].history.posterior_precision,
        )

        #Test if the values are approximately the same
        @testset "compare output trajectories" begin
            for i = 1:nrow(result_outputs)
                @test result_outputs.x_mean[i] ≈ target_outputs.mu1[i]
                @test result_outputs.x_precision[i] ≈ target_outputs.pi1[i]
                @test result_outputs.xvol_mean[i] ≈ target_outputs.mu2[i]
                @test result_outputs.xvol_precision[i] ≈ target_outputs.pi2[i]
            end
        end

        @testset "Trajectory plots" begin
            #Make trajectory plots
            plot_trajectory(test_hgf, "u")
            plot_trajectory!(test_hgf, ("x", "posterior"))
        end
    end


    @testset "Canonical Binary 3level" begin

        ### Import trajectories ###
        #Create path to required data files
        canonical_trajectory_path = data_path * "canonical_binary3level.csv"

        #Import the canonical trajectory of states
        canonical_trajectory = CSV.read(canonical_trajectory_path, DataFrame)

        ### Set up HGF ###

        #Set parameters
        test_parameters = Dict(
            ("xprob", "volatility") => -2.5,
            ("xvol", "volatility") => -6.0,
            ("xbin", "xprob", "coupling_strength") => 1.0,
            ("xprob", "xvol", "coupling_strength") => 1.0,
            ("xprob", "initial_mean") => 0.0,
            ("xprob", "initial_precision") => 1.0,
            ("xvol", "initial_mean") => 1.0,
            ("xvol", "initial_precision") => 1.0,
            "update_type" => ClassicUpdate(),
        )

        #Create HGF
        test_hgf = premade_hgf("binary_3level", test_parameters, verbose = false)

        #Give inputs (mu1's are equal to the inputs in a binary HGF without sensory noise)
        give_inputs!(test_hgf, canonical_trajectory.mu1)

        #Construct result output dataframe
        result_outputs = DataFrame(
            xbin_mean = test_hgf.state_nodes["xbin"].history.posterior_mean,
            xbin_precision = test_hgf.state_nodes["xbin"].history.posterior_precision,
            xprob_mean = test_hgf.state_nodes["xprob"].history.posterior_mean,
            xprob_precision = test_hgf.state_nodes["xprob"].history.posterior_precision,
            xvol_mean = test_hgf.state_nodes["xvol"].history.posterior_mean,
            xvol_precision = test_hgf.state_nodes["xvol"].history.posterior_precision,
        )

        #Remove the first row
        result_outputs = result_outputs[2:end, :]

        #Test if the values are approximately the same
        @testset "compare output trajectories" begin
            for i = 1:nrow(canonical_trajectory)
                @test result_outputs.xbin_mean[i] ≈ canonical_trajectory.mu1[i]
                @test result_outputs.xbin_precision[i] ≈ 1 / canonical_trajectory.sa1[i]
                @test isapprox(
                    result_outputs.xprob_mean[i],
                    canonical_trajectory.mu2[i],
                    rtol = 0.1,
                )
                @test isapprox(
                    result_outputs.xprob_precision[i],
                    1 / canonical_trajectory.sa2[i],
                    rtol = 0.1,
                )
                @test isapprox(
                    result_outputs.xvol_mean[i],
                    canonical_trajectory.mu3[i],
                    rtol = 0.1,
                )
                @test isapprox(
                    result_outputs.xvol_precision[i],
                    1 / canonical_trajectory.sa3[i],
                    rtol = 0.1,
                )
            end
        end

        @testset "Trajectory plots" begin
            #Make trajectory plots
            plot_trajectory(test_hgf, "u")
            plot_trajectory!(test_hgf, ("xbin", "prediction"))
        end
    end
end
