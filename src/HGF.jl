module HGF

#Get fundamental structures and types
include("structure.jl")

#Get functions for initializing the HGF structure
include("initialization.jl")

#Update equation functions
include("update_equations.jl")

#Get functions for updating single nodes
include("node_update.jl")

#Get functions for updating the full HGF
include("hierarchy_update.jl")

#End of module
end