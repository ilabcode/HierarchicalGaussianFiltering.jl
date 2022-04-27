# using HGF
# using Test
# using CSV
# using DataFrames

@testset "Canonical Test" begin
    ### Setup ###
    #Flag for specifying if this is run manually from the test project, or as a git hook
    run_as_git_hook = true

    #Set paths accordingly
    if run_as_git_hook
        input_trajectory_path = "test/forward_model/data/canonical_input_trajectory.dat"
        python_output_trajectory_path = "test/forward_model/data/canonical_python_trajectory.csv"
    else
        input_trajectory_path = "forward_model/data/canonical_input_trajectory.dat"
        python_output_trajectory_path = "forward_model/data/canonical_python_trajectory.csv"
    end


    ### Import trajectories ###
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
    target_outputs = CSV.read(python_output_trajectory_path, DataFrame);


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
    test_hgf = HGF.premade_hgf("continuous_2level", params_list, starting_state_list);

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
        for i in 1:nrow(result_outputs)
            @test result_outputs.x1_mean[i] ≈ target_outputs.x1_mean[i]
            @test result_outputs.x1_precision[i] ≈ target_outputs.x1_precision[i]
            @test result_outputs.x2_mean[i] ≈ target_outputs.x2_mean[i]
            @test result_outputs.x2_precision[i] ≈ target_outputs.x2_precision[i]
        end
    end
end