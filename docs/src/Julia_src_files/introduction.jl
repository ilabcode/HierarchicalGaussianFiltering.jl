# # Welcome to The Hierarchical Gaussian Filtering Package!

# Hierarchical Gaussian Filtering is a novel and adaptive package for doing cognitive and behavioral modelling. You will be introducted to all nessecary theory and information in order to be prepared to use the package. 

# It is recommended to check out the ActionModels.jl pacakge for stronger intuition behind our use of agents and action models. 

# ## Getting started

# We provide a script for getting started with commonly used functions for you to get started with

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
set_parameters!(agent,("x2", "initial_precision"),0.9)

# define inputs
inputs = [1,0,1,1,1,0,1,0,1,0,1,0,1,1,1,1,1,0,0,1,0,0,0,0,]

# Give inputs
actions = give_inputs!(agent,inputs)

# Plot state trajectories of input and prediction
plot_trajectory(agent,("u","input_value"))
plot_trajectory!(agent,("x1","prediction"))

# Plot state trajectory of input value, action and prediction of x1
plot_trajectory(agent,("u","input_value"))
plot_trajectory!(agent,"action")
plot_trajectory!(agent,("x1","prediction"))


# Fitting parameter

using Distributions
prior = Dict(("x2", "evolution_rate")=>Normal(1,0.5))

model=fit_model(
    agent,
    prior,
    inputs,
    actions,
    n_iterations = 20
)

#-

#plot chains
using Plots
using StatsPlots

plot(model)

#- 

#plot prior angainst posterior
plot_parameter_distribution(model,prior)

# get posterior
get_posteriors(model)