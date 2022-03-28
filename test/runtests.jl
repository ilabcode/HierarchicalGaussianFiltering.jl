using HGF
using Test

include("utility_functions.jl")

# Test initialization
include("forward_model/test_initialization.jl")

# Test premade models
# include("utils/test_premade_models.jl")

# Test update equations
# include("forward_model/test_update_equations.jl")

# Test single node update
include("forward_model/test_update_node.jl")

# Test hierarchy update
include("forward_model/test_update_hierarchy.jl")