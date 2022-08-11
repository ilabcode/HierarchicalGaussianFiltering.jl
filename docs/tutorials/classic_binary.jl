# This tutorial is a copy of the 3 level binary hgf tutorial in MATLAB
#

# First load packages
using Turing
using HGF
using Plots
using StatsPlots
pyplot()

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

params_list = (
    sigmoid_action_precision = 5,
    u__category_means = Real[0.0, 1.0],
    u__input_precision = Inf,
    u_x1__value_coupling_strength = 1.0,
    x1_x2__value_coupling_strength = 1.0,
    x2__evolution_rate = -2.5,
    x2_x3__volatility_coupling_strength = 1.0,
    x2__initial_mean = 0,
    x2__initial_precision = 1,
    x3__evolution_rate = -6.0,
    x3__initial_mean = 1,
    x3__initial_precision = 1,
);

HGF.set_params!(my_agent, params_list)
HGF.reset!(my_agent)

# Evolve agent and save responses
responses = HGF.give_inputs!(my_agent, inputs);

# Plot the trajectory of the agent
HGF.trajectory_plot(my_agent, "x1__prediction")
HGF.trajectory_plot!(my_agent, "u__input_value", markersize = 4)

# Set fixed parameters (uses the agent as default)
fixed_params_list = (
    sigmoid_action_precision = 5,
    u__category_means = Real[0.0, 1.0],
    u__input_precision = Inf,
    u_x1__value_coupling_strength = 1.0,
    x1_x2__value_coupling_strength = 1.0,
    x2_x3__volatility_coupling_strength = 1.0,
    x2__initial_mean = 0,
    x2__initial_precision = 1,
    x3__initial_mean = 1,
    x3__initial_precision = 1,
);

# Set priors for parameter recovery
params_prior_list =
    (x2__evolution_rate = Normal(-3.0, 16), x3__evolution_rate = Normal(-6.0, 16));

# Prior predictive plot
HGF.predictive_simulation_plot(
    my_agent,
    params_prior_list,
    "x1__prediction_mean",
    inputs;
    n_simulations = 1000,
)

# Fit the responses
chain = HGF.fit_model(my_agent, inputs, responses, params_prior_list, fixed_params_list)

# Posterior predictive plot
HGF.predictive_simulation_plot(
    my_agent,
    chain,
    "x1__prediction_mean",
    inputs;
    n_simulations = 1000,
)

# Plot the posterior
parameter_distribution_plot(chain, params_prior_list)