module HGF

#Load packages
using Distributions,  RecipesBase
#using Turing, DataFrames,

### The HGF ###
#Structures and types
include("perceptual_model/structs.jl")

#Functions for initializing the HGF structure
include("perceptual_model/init_hgf.jl")

#Functions implementing update equations
include("perceptual_model/update_equations.jl")

#Functions for updating single nodes
include("perceptual_model/update_node.jl")

#Functions for updating a full HGF
include("perceptual_model/update_hgf.jl")

#Get premade models
include("perceptual_model/premade_models.jl")


### Model handling ###
#Structures and types
include("action_model/structs.jl")

#Premade action models
include("action_model/premade_models.jl")

#Function for inputting data
include("action_model/initialization.jl")

#Fitting function
include("fit_model.jl")


### Utility Code ###

#Get miscanellous utility
include("utils/input.jl")

include("utils/hgf_plots.jl")

include("utils/reset.jl")

#End of module
end