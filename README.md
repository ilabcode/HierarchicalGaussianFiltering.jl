# HGF
[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://ilabcode.github.io/HierarchicalGaussianFiltering.jl)
[![Build Status](https://github.com/ilabcode/HierarchicalGaussianFiltering.jl/actions/workflows/CI_full.yml/badge.svg?branch=main)](https://github.com/ilabcode/HierarchicalGaussianFiltering.jl/actions/workflows/CI_full.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/ilabcode/HierarchicalGaussianFiltering.jl/branch/main/graph/badge.svg?token=NVFiiPydFA)](https://codecov.io/gh/ilabcode/HierarchicalGaussianFiltering.jl)
[![License: GNU](https://img.shields.io/badge/License-GNU-yellow)](<https://www.gnu.org/licenses/>)


# Welcome to The Hierarchical Gaussian Filtering Package!

Hierarchical Gaussian Filtering is a novel and adaptive package for doing cognitive and behavioral modelling. You will be introducted to all nessecary theory and information in order to be prepared to use the package.

It is recommended to check out the ActionModels.jl pacakge for stronger intuition behind our use of agents and action models.

## Getting started

We provide a script for getting started with commonly used functions for you to get started with

load packages

````@example introduction
using HierarchicalGaussianFiltering
using ActionModels
````

Get premade agent

````@example introduction
premade_agent("help")
````

Create agent

````@example introduction
agent = premade_agent("hgf_binary_softmax_action")
````

Get states and parameters

````@example introduction
get_states(agent)

get_parameters(agent)
````

Set a new parameter for initial precision of x2

````@example introduction
set_parameters!(agent,("x2", "initial_precision"),0.9)
````

define inputs

````@example introduction
inputs = [1,0,1,1,1,0,1,0,1,0,1,0,1,1,1,1,1,0,0,1,0,0,0,0,]
````

Give inputs

````@example introduction
actions = give_inputs!(agent,inputs)
````

Plot state trajectories of input and prediction

````@example introduction
plot_trajectory(agent,("u","input_value"))
plot_trajectory!(agent,("x1","prediction"))
````

Plot state trajectory of input value, action and prediction of x1

````@example introduction
plot_trajectory(agent,("u","input_value"))
plot_trajectory!(agent,"action")
plot_trajectory!(agent,("x1","prediction"))
````

Fitting parameter

````@example introduction
using Distributions
prior = Dict(("x2", "evolution_rate")=>Normal(1,0.5))

model=fit_model(
    agent,
    prior,
    inputs,
    actions,
    n_iterations = 20
)
````

````@example introduction
#plot chains
using Plots
using StatsPlots

plot(model)
````

````@example introduction
#plot prior angainst posterior
plot_parameter_distribution(model,prior)
````

get posterior

````@example introduction
get_posteriors(model)
````

---
