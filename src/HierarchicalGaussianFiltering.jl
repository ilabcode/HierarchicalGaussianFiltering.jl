module HierarchicalGaussianFiltering

#Load packages
using ActionModels, Distributions, RecipesBase

#Export functions
export init_node, init_hgf, premade_hgf, check_hgf, check_node, update_hgf!
export get_prediction, get_surprise, hgf_multiple_actions
export premade_agent,
    init_agent,
    multiple_actions,
    plot_predictive_simulation,
    plot_trajectory,
    plot_trajectory!
export get_history, get_parameters, get_states, set_parameters!, reset!, give_inputs!
export EnhancedUpdate, ClassicUpdate

#Add premade agents to shared dict at initialization
function __init__()
    ActionModels.premade_agents["hgf_gaussian_action"] = premade_hgf_gaussian
    ActionModels.premade_agents["hgf_binary_softmax_action"] = premade_hgf_binary_softmax
    ActionModels.premade_agents["hgf_unit_square_sigmoid_action"] =
        premade_hgf_unit_square_sigmoid
    ActionModels.premade_agents["hgf_predict_category_action"] =
        premade_hgf_predict_category
end

#Types for HGFs
include("structs.jl")

#Overloading ActionModels functions
include("ActionModels_variations/core/create_premade_agent.jl")
include("ActionModels_variations/core/plot_predictive_simulation.jl")
include("ActionModels_variations/core/plot_trajectory.jl")
include("ActionModels_variations/utils/get_history.jl")
include("ActionModels_variations/utils/get_parameters.jl")
include("ActionModels_variations/utils/get_states.jl")
include("ActionModels_variations/utils/give_inputs.jl")
include("ActionModels_variations/utils/reset.jl")
include("ActionModels_variations/utils/set_parameters.jl")

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
include("utils/pretty_printing.jl")

end
