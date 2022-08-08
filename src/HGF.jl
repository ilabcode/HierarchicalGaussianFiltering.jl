module HGF

export premade_hgf, premade_agent, give_inputs!, get_params, set_params!, reset!

#Load packages
using Distributions, RecipesBase, Turing
#using DataFrames

### Types ###
#Types for HGFs
include("hgf_perception_model/structs.jl")
#Types for agents
include("action_model/structs.jl")

### The HGF forward model ###
#Functions for creating HGFs
include("hgf_perception_model/create_hgf/check_hgf.jl")
include("hgf_perception_model/create_hgf/init_hgf.jl")
include("hgf_perception_model/create_hgf/premade_models.jl")

#Functions for updating HGFs based on inputs
include("hgf_perception_model/update_hgf/update_equations.jl")
include("hgf_perception_model/update_hgf/update_hgf.jl")
include("hgf_perception_model/update_hgf/update_node.jl")

#Plotting functions for HGFs
include("hgf_perception_model/plots/predictive_simulation_plot.jl")
include("hgf_perception_model/plots/trajectory_plot.jl")

#Utility functions for HGFs
include("hgf_perception_model/utils/get_history.jl")
include("hgf_perception_model/utils/get_params.jl")
include("hgf_perception_model/utils/get_prediction.jl")
include("hgf_perception_model/utils/get_states.jl")
include("hgf_perception_model/utils/get_surprise.jl")
include("hgf_perception_model/utils/give_inputs.jl")
include("hgf_perception_model/utils/predictive_simulation.jl")
include("hgf_perception_model/utils/reset.jl")
include("hgf_perception_model/utils/set_params.jl")


### Action models and agents ###
#Functions for creating agents with action models
include("action_model/create_agent/init_agent.jl")
include("action_model/create_agent/premade_action_models.jl")
include("action_model/create_agent/premade_agents.jl")

#Functions for fitting agents to data
include("action_model/fitting/fit_model.jl")
include("action_model/fitting/predictive_simulation.jl")

#Plotting functions for agents
include("action_model/plots/predictive_simulation_plot.jl")
include("action_model/plots/parameter_distribution_plot.jl")

#Utility functions for agents
include("action_model/utils/get_history.jl")
include("action_model/utils/get_params.jl")
include("action_model/utils/get_states.jl")
include("action_model/utils/give_inputs.jl")
include("action_model/utils/reset.jl")
include("action_model/utils/set_params.jl")
include("action_model/utils/extract_param.jl")

end