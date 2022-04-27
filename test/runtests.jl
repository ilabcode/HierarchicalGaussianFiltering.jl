using HGF
using Test
using CSV
using DataFrames

# Test that the HGF gives canonical outputs
include("HGF_perception_model/test_canonical.jl")

# Test initialization
include("HGF_perception_model/test_initialization.jl")

# Test premade models
include("HGF_perception_model/test_premade_models.jl")

# Test update equations
# include("HGF_perception_model/test_update_equations.jl")

# Test update_hgf
# Test node_update