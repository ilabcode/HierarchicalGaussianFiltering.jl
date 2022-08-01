module HGF

#Load packages
using Distributions, RecipesBase, Turing
#using DataFrames


### The HGF forward model ###
#Structures and types
include("hgf_perception_model/structs.jl")
#Functions for initializing the HGF structure
include("hgf_perception_model/init_hgf.jl")
#Function for checking that an HGF structure has been specified correctly
include("hgf_perception_model/check_hgf.jl")
#Functions implementing update equations
include("hgf_perception_model/update_equations.jl")
#Functions for updating single nodes
include("hgf_perception_model/update_node.jl")
#Functions for updating a full HGF
include("hgf_perception_model/update_hgf.jl")
#Get premade models
include("hgf_perception_model/premade_models.jl")


### Action models ###
#Structures and types
include("action_model/structs.jl")
#Setting up action models
include("action_model/init_agent.jl")
#Premade action models
include("action_model/premade_action_models.jl")
#Premade action models
include("action_model/premade_agents.jl")


### Model Fitting ###
#Fitting function
include("model_fitting/fit_model_2.jl")
#Sampling function
include("model_fitting/predictive_simulation.jl")
#Simultaing function
include("model_fitting/get_responses.jl")


### Plotting ###
#Trajectory plots
include("plots/trajectory_plot.jl")
#Parameters plots
include("plots/turing_plot.jl")
#Posterior and posterior plots
include("plots/predictive_simulation_plot.jl")


### Utility Code ###
#Function for inputting data
include("utils/give_inputs.jl")
#Reset function
include("utils/reset.jl")
#Function to change HGF parameters
include("utils/set_params.jl")
#Function to get HGF parameters
include("utils/get_params.jl")
#Function to get HGF states
include("utils/get_states.jl")
#Function to get HGF states
include("utils/get_history.jl")
#Stat utility functions
include("utils/stats_utils.jl")
#Functions for calculating surprisal of input nodes
include("utils/get_surprise.jl")
#Function for getting the prediction of a node
include("utils/get_prediction.jl")

#End of module
end