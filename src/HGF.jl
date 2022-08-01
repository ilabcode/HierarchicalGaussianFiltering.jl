module HGF

#Load packages
using Distributions, RecipesBase, Turing
#using DataFrames

#Function for reading in a folder
function include_folder(folder_name)
    for filename in readdir("src/" * folder_name)
        if endswith(filename, ".jl")
            include(folder_name * "/" * filename)
        end
    end
end


### Types ###
#Types for HGFs
include("hgf_perception_model/structs.jl")
#Types for agents
include("action_model/structs.jl")

### The HGF forward model ###
#Functions for creating HGFs
include_folder("hgf_perception_model/create_hgf")
#Functions for updating HGFs based on inputs
include_folder("hgf_perception_model/update_hgf")
#Plotting functions for HGFs
include_folder("hgf_perception_model/plots")
#Utility functions for HGFs
include_folder("hgf_perception_model/utils")

### Action model agents ###
#Functions for creating agents with action models
include_folder("action_model/create_agent")
#Functions for fitting agents to data
include_folder("action_model/fitting")
#Plotting functions for agents
include_folder("action_model/plots")
#Utility functions for agents
include_folder("action_model/utils")

end