using HGF
using Test
using CSV
using DataFrames

# Test initialization
include("forward_model/test_initialization.jl")

# Test premade models
# include("forward_model/test_premade_models.jl")

# Test update equations
# include("forward_model/test_update_equations.jl")

# Test single node update
include("forward_model/test_update_node.jl")

# Test hierarchy update
include("forward_model/test_update_hierarchy.jl")

# Test that the HGF gives canonical outputs
# include("forward_model/canonical_test/test_canonical.jl")