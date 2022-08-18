module HGF

#Load packages
using Turing, Distributions, RecipesBase, Logging

### ActionModels.jl ###
#Types for agents
include("ActionModels/structs.jl")

#Functions for creating agents
include("ActionModels/create_agent/init_agent.jl")
include("ActionModels/create_agent/create_premade_agent.jl")

#Functions for fitting agents to data
include("ActionModels/fitting/fit_model.jl")

#Plotting functions for agents
include("ActionModels/plots/predictive_simulation_plot.jl")
include("ActionModels/plots/parameter_distribution_plot.jl")
include("ActionModels/plots/trajectory_plot.jl")

#Functions for making premade agent
include("ActionModels/premade_models/premade_agents.jl")
include("ActionModels/premade_models/premade_action_models.jl")

#Utility functions for agents
include("ActionModels/utils/get_history.jl")
include("ActionModels/utils/get_params.jl")
include("ActionModels/utils/get_states.jl")
include("ActionModels/utils/give_inputs.jl")
include("ActionModels/utils/reset.jl")
include("ActionModels/utils/set_params.jl")
include("ActionModels/utils/warn_premade_defaults.jl")
include("ActionModels/utils/get_posteriors.jl")




### HGF.jl ###
#Types for HGFs
include("hgf_package/structs.jl")

#Overloading ActionModels functions
include("hgf_package/ActionModels_variations/core/create_premade_agent.jl")
include("hgf_package/ActionModels_variations/core/init_agent.jl")
include("hgf_package/ActionModels_variations/core/predictive_simulation_plot.jl")
include("hgf_package/ActionModels_variations/core/trajectory_plot.jl")
include("hgf_package/ActionModels_variations/utils/get_history.jl")
include("hgf_package/ActionModels_variations/utils/get_params.jl")
include("hgf_package/ActionModels_variations/utils/get_states.jl")
include("hgf_package/ActionModels_variations/utils/give_inputs.jl")
include("hgf_package/ActionModels_variations/utils/reset.jl")
include("hgf_package/ActionModels_variations/utils/set_params.jl")

#Functions for creating HGFs
include("hgf_package/create_hgf/check_hgf.jl")
include("hgf_package/create_hgf/init_hgf.jl")
include("hgf_package/create_hgf/create_premade_hgf.jl")

#Plotting functions

#Functions for updating HGFs based on inputs
include("hgf_package/update_hgf/update_equations.jl")
include("hgf_package/update_hgf/update_hgf.jl")
include("hgf_package/update_hgf/update_node.jl")

#Functions for premade agents
include("hgf_package/premade_models/premade_action_models.jl")
include("hgf_package/premade_models/premade_agents.jl")
include("hgf_package/premade_models/premade_hgfs.jl")

#Utility functions for HGFs
include("hgf_package/utils/get_prediction.jl")
include("hgf_package/utils/get_surprise.jl")

end