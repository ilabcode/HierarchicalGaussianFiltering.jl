module HGF

#Load packages
using Turing, Distributions, RecipesBase, Logging, ActionModels

#Export functions
export init_node, init_hgf, premade_hgf, check_hgf, check_node, update_hgf!
export get_prediction, get_surprise, hgf_multiple_actions
export premade_agent, init_agent, multiple_actions, predictive_simulation_plot, trajectory_plot, trajectory_plot!
export get_history, get_params, get_states, set_params!, reset!, give_inputs!

#Add premade agents to shared dict at initialization
function __init__()
    ActionModels.premade_agents["hgf_gaussian_action"] = premade_hgf_gaussian
    ActionModels.premade_agents["hgf_binary_softmax_action"] = premade_hgf_binary_softmax
    ActionModels.premade_agents["hgf_unit_square_sigmoid_action"] = premade_hgf_unit_square_sigmoid
end

### HGF.jl ###
#Types for HGFs
include("structs.jl")

#Overloading ActionModels functions
include("ActionModels_variations/core/create_premade_agent.jl")
include("ActionModels_variations/core/init_agent.jl")
include("ActionModels_variations/core/predictive_simulation_plot.jl")
include("ActionModels_variations/core/trajectory_plot.jl")
include("ActionModels_variations/core/multiple_actions.jl")
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