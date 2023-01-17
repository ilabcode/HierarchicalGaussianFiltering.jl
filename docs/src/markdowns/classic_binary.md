```@meta
EditURL = "<unknown>/src/tutorials/classic_binary.jl"
```

# This tutorial is a copy of the 3 level binary hgf tutorial in MATLAB

First load packages

````@example classic_binary
using ActionModels
using HierarchicalGaussianFiltering
using CSV
using DataFrames
using Plots
using StatsPlots
using Distributions
````

Get the path for the HGF superfolder

````@example classic_binary
hgf_path = dirname(dirname(pathof(HierarchicalGaussianFiltering)))
````

Add the path to the data files

````@example classic_binary
data_path = hgf_path * "/docs/tutorials/data/"
````

Load the data

````@example classic_binary
inputs = CSV.read(data_path * "classic_binary_inputs.csv", DataFrame)[!, 1];
nothing #hide
````

Create an HGF

````@example classic_binary
hgf_parameters = Dict(
    ("u", "category_means") => Real[0.0, 1.0],
    ("u", "input_precision") => Inf,
    ("x2", "evolution_rate") => -2.5,
    ("x2", "initial_mean") => 0,
    ("x2", "initial_precision") => 1,
    ("x3", "evolution_rate") => -6.0,
    ("x3", "initial_mean") => 1,
    ("x3", "initial_precision") => 1,
    ("x1", "x2", "value_coupling") => 1.0,
    ("x2", "x3", "volatility_coupling") => 1.0,
);
hgf = premade_hgf("binary_3level", hgf_parameters, verbose = false);
nothing #hide
````

Create an agent

````@example classic_binary
agent_parameters = Dict("sigmoid_action_precision" => 5);
agent =
    premade_agent("hgf_unit_square_sigmoid_action", hgf, agent_parameters, verbose = false);
nothing #hide
````

Evolve agent and save actions

````@example classic_binary
actions = give_inputs!(agent, inputs);
nothing #hide
````

Plot the trajectory of the agent

````@example classic_binary
plot_trajectory(agent, ("u", "input_value"))
plot_trajectory!(agent, ("x1", "prediction"))

plot_trajectory(agent, ("x2", "posterior"))
plot_trajectory(agent, ("x3", "posterior"))
````

Set fixed parameters

````@example classic_binary
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
    ("x3", "evolution_rate") => -6.0,
);
nothing #hide
````

Set priors for parameter recovery

````@example classic_binary
param_priors = Dict(("x2", "evolution_rate") => Normal(-3.0, 0.5));
nothing #hide
````

Prior predictive plot

````@example classic_binary
plot_predictive_simulation(
    param_priors,
    agent,
    inputs,
    ("x1", "prediction_mean"),
    n_simulations = 100,
)
````

Get the actions from the MATLAB tutorial

````@example classic_binary
actions = CSV.read(data_path * "classic_binary_actions.csv", DataFrame)[!, 1];
nothing #hide
````

Fit the actions

````@example classic_binary
fitted_model = fit_model(
    agent,
    param_priors,
    inputs,
    actions,
    fixed_parameters = fixed_parameters,
    verbose = true,
    n_iterations = 10,
)

#Plot the chains
plot(fitted_model)
````

Plot the posterior

````@example classic_binary
plot_parameter_distribution(fitted_model, param_priors)
````

Posterior predictive plot

````@example classic_binary
plot_predictive_simulation(
    fitted_model,
    agent,
    inputs,
    ("x1", "prediction_mean"),
    n_simulations = 3,
)
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

