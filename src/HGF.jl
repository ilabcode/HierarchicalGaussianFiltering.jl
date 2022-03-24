module HGF

#Get fundamental structures and types
include("structure.jl")

#Get functions for initializing the HGF structure
include("initialization.jl")

#Get basic models
include("premade_models.jl")

#Update equation functions
include("update_equations.jl")

#Get functions for updating single nodes
include("update_node.jl")

#Get functions for updating the full HGF
include("update_hierarchy.jl")

#End of module 
end