module HGF

#Load packages
using Distributions,  RecipesBase, Turing
#using DataFrames


### The HGF forward model ###
#Structures and types
include("HGF_perception_model/structs.jl")

#Functions for initializing the HGF structure
include("HGF_perception_model/init_hgf.jl")

#Functions implementing update equations
include("HGF_perception_model/update_equations.jl")

#Functions for updating single nodes
include("HGF_perception_model/update_node.jl")

#Functions for updating a full HGF
include("HGF_perception_model/update_hgf.jl")

#Get premade models
include("HGF_perception_model/premade_models.jl")


### Model handling ###
#Structures and types
include("action_model/structs.jl")

#Premade action models
include("action_model/premade_models.jl")

#Function for inputting data
include("action_model/initialization.jl")


### Model Fitting ###
#Fitting function
include("model_fitting/fit_model.jl")


### Plotting ###
#Trajectory plots
include("utils/hgf_plots.jl")

### Utility Code ###
#Get miscanellous utility
include("utils/input.jl")
#Reset function
include("utils/reset.jl")

#End of module
end