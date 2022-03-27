module HGF

#Get fundamental structures and types
include("forward_model/structure.jl")

#Get functions for initializing the HGF structure
include("forward_model/initialization.jl")

#Update equation functions
include("forward_model/update_equations.jl")

#Get functions for updating single nodes
include("forward_model/update_node.jl")

#Get functions for updating the full HGF
include("forward_model/update_hierarchy.jl")

#Get premade models
include("utils/premade_models.jl")

#End of module
end