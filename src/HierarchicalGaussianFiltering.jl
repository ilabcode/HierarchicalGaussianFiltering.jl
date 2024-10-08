module HierarchicalGaussianFiltering

#Load packages
using ActionModels, Distributions, RecipesBase

#Export functions
export init_node, init_hgf, premade_hgf, check_hgf, update_hgf!
export get_prediction, get_surprise
export premade_agent,
    init_agent, plot_trajectory, plot_trajectory!
export get_history,
    get_parameters, get_states, set_parameters!, reset!, give_inputs!, set_save_history!
export ParameterGroup
export EnhancedUpdate, ClassicUpdate
export NodeDefaults
export ContinuousState,
    ContinuousInput, BinaryState, BinaryInput, CategoricalState, CategoricalInput
export DriftCoupling,
    ObservationCoupling,
    CategoryCoupling,
    ProbabilityCoupling,
    VolatilityCoupling,
    NoiseCoupling,
    LinearTransform,
    NonlinearTransform

#Add premade agents to shared dict at initialization
function __init__()
    ActionModels.premade_agents["hgf_gaussian"] = premade_hgf_gaussian
    ActionModels.premade_agents["hgf_binary_softmax"] = premade_hgf_binary_softmax
    ActionModels.premade_agents["hgf_unit_square_sigmoid"] = premade_hgf_unit_square_sigmoid
    ActionModels.premade_agents["hgf_predict_category"] = premade_hgf_predict_category
end

#Types for HGFs
include("create_hgf/hgf_structs.jl")

#Overloading ActionModels functions
include("ActionModels_variations/create_premade_agent.jl")
include("ActionModels_variations/plot_trajectory.jl")
include("ActionModels_variations/get_history.jl")
include("ActionModels_variations/get_parameters.jl")
include("ActionModels_variations/get_states.jl")
include("ActionModels_variations/give_inputs.jl")
include("ActionModels_variations/reset.jl")
include("ActionModels_variations/set_parameters.jl")
include("ActionModels_variations/set_save_history.jl")

#Functions for updating the HGF
include("update_hgf/update_hgf.jl")
include("update_hgf/nonlinear_transforms.jl")
include("update_hgf/node_updates/continuous_input_node.jl")
include("update_hgf/node_updates/continuous_state_node.jl")
include("update_hgf/node_updates/binary_input_node.jl")
include("update_hgf/node_updates/binary_state_node.jl")
include("update_hgf/node_updates/categorical_input_node.jl")
include("update_hgf/node_updates/categorical_state_node.jl")

#Functions for creating HGFs
include("create_hgf/check_hgf.jl")
include("create_hgf/init_hgf.jl")
include("create_hgf/init_node_edge.jl")
include("create_hgf/create_premade_hgf.jl")

#Functions for premade agents
include("premade_models/premade_agents/premade_gaussian.jl")
include("premade_models/premade_agents/premade_predict_category.jl")
include("premade_models/premade_agents/premade_sigmoid.jl")
include("premade_models/premade_agents/premade_softmax.jl")

include("premade_models/premade_hgfs/premade_binary_2level.jl")
include("premade_models/premade_hgfs/premade_binary_3level.jl")
include("premade_models/premade_hgfs/premade_categorical_3level.jl")
include("premade_models/premade_hgfs/premade_categorical_transitions_3level.jl")
include("premade_models/premade_hgfs/premade_continuous_2level.jl")
include("premade_models/premade_hgfs/premade_JGET.jl")

#Utility functions for HGFs
include("utils/get_prediction.jl")
include("utils/get_surprise.jl")
include("utils/pretty_printing.jl")

end
