using ActionModels
using HierarchicalGaussianFiltering
using Test

@testset "Unit tests" begin

    # Test the quick tests that are used as pre-commit tests
    include("quicktests.jl")

    # Test that the HGF gives canonical outputs
    include("test_canonical.jl")

    # Test initialization
    include("test_initialization.jl")

    # Test premade HGF models
    include("test_premade_hgf.jl")

    # Test shared parameters
    include("test_shared_parameters.jl")

    # Test premade action models
    include("test_premade_agent.jl")

    #Run fitting tests
    include("test_fit_model.jl")

    # Test update_hgf
    # Test node_update
    # Test action models
    # Test update equations

end


@testset "Documentation" begin

    #Set up path for the documentation folder
    hgf_path = dirname(dirname(pathof(HierarchicalGaussianFiltering)))
    documentation_path = hgf_path * "/docs/src/"

    @testset "tutorials" begin
        
        #Get path for the tutorials subfolder
        tutorials_path = documentation_path * "tutorials/"
        
        #Classic tutorials
        include(tutorials_path * "classic_binary.jl")
        include(tutorials_path * "classic_usdchf.jl")
    end

    @testset "sourcefiles" begin
        
        #Get path for the tutorials subfolder
        sourcefiles_path = documentation_path * "Julia_src_files/"

    end
end
