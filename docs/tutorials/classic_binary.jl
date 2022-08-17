# This tutorial is a copy of the 3 level binary hgf tutorial in MATLAB
#

# First load packages
using Turing
using HGF
using Plots
using StatsPlots
# pyplot()

# Load the data 
inputs = Float64[]
open("tutorials/data/classic_binary_inputs.dat") do f
    for ln in eachline(f)
        push!(inputs, parse(Float64, ln))
    end
end

# Create an HGF
my_hgf = HGF.premade_hgf("binary_3level");
my_agent = HGF.premade_agent("hgf_unit_square_sigmoid_action", my_hgf);

# Set parameters
HGF.get_params(my_agent)

params = Dict(
    "sigmoid_action_precision" => 5,
    ("u", "category_means") => Real[0.0, 1.0],
    ("u", "input_precision") => Inf,
    ("x2", "evolution_rate") => -2.5,
    ("x2", "initial_mean") => 0,
    ("x2", "initial_precision") => 1,
    ("x3", "evolution_rate") => -6.0,
    ("x3", "initial_mean") => 1,
    ("x3", "initial_precision") => 1,
    ("u", "x1", "value_coupling") => 1.0,
    ("x1", "x2", "value_coupling") => 1.0,
    ("x2", "x3", "volatility_coupling") => 1.0,
);

HGF.set_params!(my_agent, params)
HGF.reset!(my_agent)

# Evolve agent and save responses
responses = HGF.give_inputs!(my_agent, inputs);

#Remove the initial state
popfirst!(responses)

# Plot the trajectory of the agent
HGF.trajectory_plot(my_agent, ("x1", "prediction"))
HGF.trajectory_plot!(my_agent, ("u", "input_value"))

# Set fixed parameters (uses the agent as default)
fixed_params = Dict(
    "sigmoid_action_precision" => 5,
    ("u", "category_means") => Real[0.0, 1.0],
    ("u", "input_precision") => Inf,
    ("x2", "initial_mean") => 0,
    ("x2", "initial_precision") => 1,
    ("x3", "initial_mean") => 1,
    ("x3", "initial_precision") => 1,
    ("u", "x1", "value_coupling") => 1.0,
    ("x1", "x2", "value_coupling") => 1.0,
    ("x2", "x3", "volatility_coupling") => 1.0,
);

# Set priors for parameter recovery
param_priors = Dict(
    ("x2", "evolution_rate") => Normal(-3.0, 2),
    ("x3", "evolution_rate") => Normal(-6.0, 2),
);

# Prior predictive plot
HGF.predictive_simulation_plot(
    my_agent,
    param_priors,
    ("x1", "prediction_mean"),
    inputs;
    n_simulations = 1000,
)

# Fit the responses
chain = HGF.fit_model(my_agent, inputs, responses, param_priors, fixed_params)

# Posterior predictive plot
HGF.predictive_simulation_plot(
    my_agent,
    chain,
    ("x1", "prediction_mean"),
    inputs;
    n_simulations = 1000,
)

# Plot the posterior
parameter_distribution_plot(chain, param_priors)
