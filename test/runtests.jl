using ActionModels
using HGF
using Test
using CSV
using DataFrames
using Turing
using Plots
using StatsPlots

@testset "Unit tests" begin

    # Test that the HGF gives canonical outputs
    include("test_canonical.jl")

    # Test initialization
    include("test_initialization.jl")

    # Test premade HGF models
    include("test_premade_hgf.jl")

    # Test premade action models
    include("test_premade_agent.jl")

    #Run turing tests
    include("test_fit_model.jl")

    # Test update_hgf
    # Test node_update
    # Test action models
    # Test update equations

end


@testset "Tutorials" begin

    #Set up path for tutorials
    hgf_path = dirname(dirname(pathof(HGF)))
    tutorials_path = hgf_path * "/docs/tutorials/" 

    #Classic tutorials
    include(tutorials_path * "classic_binary.jl")
    include(tutorials_path * "classic_usdchf.jl")
end
