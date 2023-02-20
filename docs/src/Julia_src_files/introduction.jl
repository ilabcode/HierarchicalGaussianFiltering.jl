# # Welcome to The Hierarchical Gaussian Filtering Package!

# Hierarchical Gaussian Filtering (HGF) is a novel and adaptive package for doing cognitive and behavioral modelling. With the HGF you can fit time series data fit participant-level individual parameters, measure group differences based on model-specific parameters or use the model for any time series with underlying change in uncertainty.

# The HGF consists of a network of probabilistic nodes hierarchically structured. The hierarchy is determined by the coupling between nodes. A node (child node) in the network can inheret either its value or volatility sufficient statistics from a node higher in the hierarchy (a parent node). 

# The presentation of a new observation at the lower level of the hierarchy (i.e. the input node) trigger a recursuve update of the nodes belief throught the bottom-up propagation of precision-weigthed prediction error.

# The HGF will be explained in more detail in the theory section of the documentation

# It is also recommended to check out the ActionModels.jl pacakge for stronger intuition behind the use of agents and action models. 

# ## Getting started

# The last official release can be downloaded from Julia with "Add HierarchicalGaussianFiltering"

# We provide a script for getting started with commonly used functions and use cases

# load packages 
using HierarchicalGaussianFiltering
using ActionModels

# Get premade agent
premade_agent("help")

# Create agent
agent = premade_agent("hgf_binary_softmax_action")

# Get states and parameters
get_states(agent)

get_parameters(agent)

# Set a new parameter for initial precision of x2
set_parameters!(agent, ("x2", "initial_precision"), 0.9)

# define inputs
inputs = [1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0]

# Give inputs
actions = give_inputs!(agent, inputs)


using StatsPlots
using Plots
# Plot state trajectories of input and prediction
plot_trajectory(agent, ("u", "input_value"))
plot_trajectory!(agent, ("x1", "prediction"))

# Plot state trajectory of input value, action and prediction of x1
plot_trajectory(agent, ("u", "input_value"))
plot_trajectory!(agent, "action")
plot_trajectory!(agent, ("x1", "prediction"))


# Fitting parameter

using Distributions
prior = Dict(("x2", "evolution_rate") => Normal(1, 0.5))

model = fit_model(agent, prior, inputs, actions, n_iterations = 20)

#-

#plot chains
plot(model)

#- 

#plot prior angainst posterior
plot_parameter_distribution(model, prior)

# get posterior
get_posteriors(model)
