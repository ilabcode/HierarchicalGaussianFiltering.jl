using HGF
using Test
using CSV
using DataFrames

# Test that the HGF gives canonical outputs
include("hgf_perception_model/test_canonical.jl")

# Test initialization
include("hgf_perception_model/test_initialization.jl")

# Test update equations
# include("HGF_perception_model/test_update_equations.jl")

# Test premade HGF models
include("hgf_perception_model/test_premade_models.jl")

# Test premade action models
include("action_models/test_premade_models.jl")

# Test update_hgf
# Test node_update
# Test action models
# Test Turing
# Test 