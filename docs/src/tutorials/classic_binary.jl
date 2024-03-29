# # Tutorial on 3-level binary

# This tutorial is a copy of the 3 level binary hgf tutorial in MATLAB

# First load packages
using ActionModels
using HierarchicalGaussianFiltering
using CSV
using DataFrames
using Plots
using StatsPlots
using Distributions

# Get the path for the HGF superfolder
hgf_path = dirname(dirname(pathof(HierarchicalGaussianFiltering)))
# Add the path to the data files
data_path = hgf_path * "/docs/src/tutorials/data/"

# Load the data 
inputs = CSV.read(data_path * "classic_binary_inputs.csv", DataFrame)[!, 1];

# Create an HGF
hgf_parameters = Dict(
    ("u", "category_means") => Real[0.0, 1.0],
    ("u", "input_precision") => Inf,
    ("x2", "volatility") => -2.5,
    ("x2", "initial_mean") => 0,
    ("x2", "initial_precision") => 1,
    ("x3", "volatility") => -6.0,
    ("x3", "initial_mean") => 1,
    ("x3", "initial_precision") => 1,
    ("x1", "x2", "value_coupling") => 1.0,
    ("x2", "x3", "volatility_coupling") => 1.0,
);

hgf = premade_hgf("binary_3level", hgf_parameters, verbose = false);

# Create an agent
agent_parameters = Dict("sigmoid_action_precision" => 5);
agent =
    premade_agent("hgf_unit_square_sigmoid_action", hgf, agent_parameters, verbose = false);

# Evolve agent and save actions
actions = give_inputs!(agent, inputs);

# Plot the trajectory of the agent
plot_trajectory(agent, ("u", "input_value"))
plot_trajectory!(agent, ("x1", "prediction"))


# -

plot_trajectory(agent, ("x2", "posterior"))
plot_trajectory(agent, ("x3", "posterior"))

# Set fixed parameters
fixed_parameters = Dict(
    "sigmoid_action_precision" => 5,
    ("u", "category_means") => Real[0.0, 1.0],
    ("u", "input_precision") => Inf,
    ("x2", "initial_mean") => 0,
    ("x2", "initial_precision") => 1,
    ("x3", "initial_mean") => 1,
    ("x3", "initial_precision") => 1,
    ("x1", "x2", "value_coupling") => 1.0,
    ("x2", "x3", "volatility_coupling") => 1.0,
    ("x3", "volatility") => -6.0,
);

# Set priors for parameter recovery
param_priors = Dict(("x2", "volatility") => Normal(-3.0, 0.5));
#-
# Prior predictive plot
plot_predictive_simulation(
    param_priors,
    agent,
    inputs,
    ("x1", "prediction_mean"),
    n_simulations = 100,
)
#-
# Get the actions from the MATLAB tutorial
actions = CSV.read(data_path * "classic_binary_actions.csv", DataFrame)[!, 1];
#-
# Fit the actions
fitted_model = fit_model(
    agent,
    param_priors,
    inputs,
    actions,
    fixed_parameters = fixed_parameters,
    verbose = true,
    n_iterations = 10,
)
#-
#Plot the chains
plot(fitted_model)
#-
# Plot the posterior
plot_parameter_distribution(fitted_model, param_priors)
#-
# Posterior predictive plot
plot_predictive_simulation(
    fitted_model,
    agent,
    inputs,
    ("x1", "prediction_mean"),
    n_simulations = 3,
)
