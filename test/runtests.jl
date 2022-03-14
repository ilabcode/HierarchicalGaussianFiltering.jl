using HGF
using Test

# Test initialization
include("test_initialization.jl")

# Test hierarchy update
include("test_hierarchy_update.jl")

# Test update equations
include("test_update_equations.jl")

# Test single node update
include("test_node_update.jl")