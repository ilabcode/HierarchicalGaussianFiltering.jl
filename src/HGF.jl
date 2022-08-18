module HGF

#Load packages
using Turing, Distributions, RecipesBase, Logging, ActionModels

### HGF.jl ###
#Types for HGFs
include("structs.jl")

#Overloading ActionModels functions
include("ActionModels_variations/core/create_premade_agent.jl")
include("ActionModels_variations/core/init_agent.jl")
include("ActionModels_variations/core/predictive_simulation_plot.jl")
include("ActionModels_variations/core/trajectory_plot.jl")
include("ActionModels_variations/utils/get_history.jl")
include("ActionModels_variations/utils/get_params.jl")
include("ActionModels_variations/utils/get_states.jl")
include("ActionModels_variations/utils/give_inputs.jl")
include("ActionModels_variations/utils/reset.jl")
include("ActionModels_variations/utils/set_params.jl")

#Functions for creating HGFs
include("create_hgf/check_hgf.jl")
include("create_hgf/init_hgf.jl")
include("create_hgf/create_premade_hgf.jl")

#Plotting functions

#Functions for updating HGFs based on inputs
include("update_hgf/update_equations.jl")
include("update_hgf/update_hgf.jl")
include("update_hgf/update_node.jl")

#Functions for premade agents
include("premade_models/premade_action_models.jl")
include("premade_models/premade_agents.jl")
include("premade_models/premade_hgfs.jl")

#Utility functions for HGFs
include("utils/get_prediction.jl")
include("utils/get_surprise.jl")

end