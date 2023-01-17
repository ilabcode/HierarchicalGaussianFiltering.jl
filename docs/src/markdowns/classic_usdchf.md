```@meta
EditURL = "<unknown>/src/tutorials/classic_usdchf.jl"
```

# This is a replication of the tutorial from the MATLAB toolbox, using an HGF to filter the exchange rates between USD and CHF

First load packages

````@example classic_usdchf
using ActionModels
using HierarchicalGaussianFiltering
using Plots
using StatsPlots
using Distributions
````

Get the path for the HGF superfolder

````@example classic_usdchf
hgf_path = dirname(dirname(pathof(HierarchicalGaussianFiltering)))
````

Add the path to the data files

````@example classic_usdchf
data_path = hgf_path * "/docs/tutorials/data/"
````

Load the data

````@example classic_usdchf
inputs = Float64[]
open(data_path * "classic_usdchf_inputs.dat") do f
    for ln in eachline(f)
        push!(inputs, parse(Float64, ln))
    end
end

#Create HGF
hgf = premade_hgf("continuous_2level", verbose = false);
agent = premade_agent("hgf_gaussian_action", hgf, verbose = false);
nothing #hide
````

Set parameters for parameter recovyer

````@example classic_usdchf
parameters = Dict(
    ("u", "x1", "value_coupling") => 1.0,
    ("x1", "x2", "volatility_coupling") => 1.0,
    ("u", "evolution_rate") => -log(1e4),
    ("x1", "evolution_rate") => -13,
    ("x2", "evolution_rate") => -2,
    ("x1", "initial_mean") => 1.04,
    ("x1", "initial_precision") => 1 / (0.0001),
    ("x2", "initial_mean") => 1.0,
    ("x2", "initial_precision") => 1 / 0.1,
    "gaussian_action_precision" => 100,
);

set_parameters!(agent, parameters)
reset!(agent)
````

Evolve agent

````@example classic_usdchf
actions = give_inputs!(agent, inputs);
nothing #hide
````

Plot trajectories

````@example classic_usdchf
plot_trajectory(
    agent,
    "u",
    size = (1300, 500),
    xlims = (0, 615),
    markersize = 3,
    markercolor = "green2",
    title = "HGF trajectory",
    ylabel = "CHF-USD exchange rate",
    xlabel = "Trading days since 1 January 2010",
)

plot_trajectory!(agent, ("x1", "posterior"), color = "red")
plot_trajectory!(
    agent,
    "action",
    size = (1300, 500),
    xlims = (0, 614),
    markersize = 3,
    markercolor = "orange",
)

plot_trajectory(
    agent,
    "x2",
    color = "blue",
    size = (1300, 500),
    xlims = (0, 615),
    xlabel = "Trading days since 1 January 2010",
    title = "Volatility parent trajectory",
)
````

Set priors for fitting

````@example classic_usdchf
fixed_parameters = Dict(
    ("u", "x1", "value_coupling") => 1.0,
    ("x1", "x2", "volatility_coupling") => 1.0,
    ("x1", "initial_mean") => 0,
    ("x1", "initial_precision") => 2000,
    ("x2", "initial_mean") => 1.0,
    ("x2", "initial_precision") => 600.0,
    "gaussian_action_precision" => 100,
);

param_priors = Dict(
    ("u", "evolution_rate") => Normal(-10, 2),
    ("x1", "evolution_rate") => Normal(-10, 4),
    ("x2", "evolution_rate") => Normal(-4, 4),
);
nothing #hide
````

Prior predictive simulation plot

````@example classic_usdchf
plot_predictive_simulation(
    param_priors,
    agent,
    inputs,
    ("x1", "posterior_mean");
    n_simulations = 3,
)
````

Do parameter recovery

````@example classic_usdchf
fitted_model = fit_model(
    agent,
    param_priors,
    inputs,
    actions,
    fixed_parameters = fixed_parameters,
    verbose = true,
    n_iterations = 10,
)
````

Plot the chains

````@example classic_usdchf
plot(fitted_model)
````

Plot prior posterior distributions

````@example classic_usdchf
plot_parameter_distribution(fitted_model, param_priors)
````

Posterior predictive plot

````@example classic_usdchf
plot_predictive_simulation(
    fitted_model,
    agent,
    inputs,
    ("x1", "posterior_mean");
    n_simulations = 3,
)
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

