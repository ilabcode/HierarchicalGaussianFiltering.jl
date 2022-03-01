module HGF

#Get fundamental structures and types
include("structure.jl")

#Get functions for initializing the HGF structure
include("initialization.jl")

#Get functions for updating single nodes
include("update_node.jl")

#Get functions for updating the full HGF
include("update_HGF.jl")

#Dummy functions
include("dummy_functions.jl")

#End of module
end