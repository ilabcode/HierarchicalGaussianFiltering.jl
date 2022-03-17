using HGF
using Test

# Test initialization
include("test_initialization.jl")

# Test hierarchy update
include("test_update_hierarchy.jl")

# Test update equations
include("test_update_equations.jl")

# Test single node update
include("test_update_node.jl")