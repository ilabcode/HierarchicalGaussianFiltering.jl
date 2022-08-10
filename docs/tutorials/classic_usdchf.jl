# This is a replication of the tutorial from the MATLAB toolbox, using an HGF to filter the exchange rates between USD and CHF

# First load packages
using Turing
using HGF
using Plots
using StatsPlots
# Select the plotting backend
pyplot()

# Load the data
inputs = Float64[]
open("tutorials/data/classic_usdchf_inputs.dat") do f
    for ln in eachline(f)
        push!(inputs, parse(Float64, ln))
    end
end

#Create HGF
my_hgf = HGF.premade_hgf("continuous_2level");

agent_params_list = (; target_node = "x1", target_state = "posterior_mean");

my_agent = HGF.premade_agent("hgf_gaussian_action", my_hgf, agent_params_list);

# Set (optimal) parameters
HGF.get_params(my_agent)

params_list = (
    u_x1__value_coupling_strength = 1.0,
    x1_x2__volatility_coupling_strength = 1.0,
    u__evolution_rate = -log(9.39e6),
    x1__evolution_rate = -11.8557,
    x2__evolution_rate = -5.9085,
    x1__initial_mean = 1.0315,
    x1__initial_precision = 1 / (3.2889e-5),
    x2__initial_mean = 1.0,
    x2__initial_precision = 1 / 0.0697,
    gaussian_action_precision = 100,
)

HGF.set_params!(my_agent, params_list)
HGF.reset!(my_agent)

# Evolve agent
HGF.give_inputs!(my_agent, inputs);

# Plot trajectories
HGF.trajectory_plot(
    my_agent,
    "u",
    size = (1300, 500),
    xlims = (0, 615),
    markerstrokecolor = :auto,
    markersize = 3,
    markercolor = "green2",
)
HGF.trajectory_plot!(my_agent, "x1__posterior_mean", color = "red", linewidth = 1.5)

HGF.trajectory_plot(
    my_agent,
    "x2",
    color = "blue",
    size = (1300, 500),
    xlims = (0, 615),
    title = "Posterior",
)

# Set parameters for parameter recovyer
params_list_2 = (
    u_x1__value_coupling_strength = 1.0,
    x1_x2__volatility_coupling_strength = 1.0,
    u__evolution_rate = -log(1e4),
    x1__evolution_rate = -13,
    x2__evolution_rate = -2,
    x1__initial_mean = 1.04,
    x1__initial_precision = 1 / (0.0001),
    x2__initial_mean = 1.0,
    x2__initial_precision = 1 / 0.1,
    gaussian_action_precision = 100,
)

HGF.set_params!(my_agent, params_list_2)
HGF.reset!(my_agent)

# Evolve agent
responses = HGF.give_inputs!(my_agent, inputs);

# Plot trajectories
HGF.trajectory_plot(
    my_agent,
    "u",
    size = (1300, 500),
    xlims = (0, 615),
    markerstrokecolor = :auto,
    markersize = 3,
    markercolor = "green2",
    title = "Agent simulation",
    ylabel = "CHF-USD exchange rate",
    xlabel = "Trading days since 1 January 2010",
)

HGF.trajectory_plot!(my_agent, "x1__posterior_mean", color = "red", linewidth = 1.5)
HGF.trajectory_plot!(
    my_agent,
    "action",
    size = (1300, 500),
    xlims = (0, 614),
    markerstrokecolor = :auto,
    markersize = 3,
    markercolor = "orange",
)

HGF.trajectory_plot(
    my_agent,
    "x2",
    color = "blue",
    size = (1300, 500),
    xlims = (0, 615),
    xlabel = "Trading days since 1 January 2010",
)

# Set priors for turing fitting
fixed_params_list = (
    x1__initial_mean = inputs[1],
    u_x1__value_coupling_strength = 1.0,
    x1_x2__volatility_coupling_strength = 1.0,
    gaussian_action_precision = 100,
    x2__initial_mean = 1.0,
    x1__initial_precision = 1 / Turing.Statistics.var(inputs[1:20]),
    x2__initial_precision = 600.0,
)

params_prior_list = (
    u__evolution_rate = Normal(log(first20_variance), 2),
    x1__evolution_rate = Normal(log(first20_variance), 4),
    x2__evolution_rate = Normal(-4, 4)
)

# Prior predictive simulation plot
HGF.predictive_simulation_plot(
    my_agent,
    params_prior_list,
    "x1__posterior_mean",
    inputs;
    n_simulations = 1000,
    title = "x1__posterior_mean",
)

# Do parameter recovery
chain = HGF.fit_model(
    my_agent,
    inputs,
    responses,
    params_prior_list,
    fixed_params_list,
    NUTS(),
    1000,
)

# Plot prior posterior distributions
parameter_distribution_plot(chain, params_prior_list)

# Posterior predictive plot
HGF.predictive_simulation_plot(
    my_agent,
    chain,
    "x1__posterior_mean",
    inputs;
    n_simulations = 1000,
    title = "x1__posterior_mean",
)


# Get median of the sampled parameters 
fitted_params = HGF.get_params(chain)

# Set them on the agent
HGF.set_params!(my_agent, fitted_params)
HGF.reset!(my_agent)

# Evolve agent with fitted parameters
responses = HGF.give_inputs!(my_agent, inputs);

# Plot trajectories
HGF.trajectory_plot(
    my_agent,
    "u",
    size = (1300, 500),
    xlims = (0, 615),
    markerstrokecolor = :auto,
    markersize = 3,
    markercolor = "green2",
)

HGF.trajectory_plot!(my_agent, "x1__posterior_mean", color = "red", linewidth = 1.5)
HGF.trajectory_plot!(
    my_agent,
    "action",
    size = (1300, 500),
    xlims = (0, 614),
    markerstrokecolor = :auto,
    markersize = 3,
    markercolor = "orange",
)

HGF.trajectory_plot(
    my_agent,
    "x2__prediction",
    color = "blue",
    size = (1300, 500),
    xlims = (0, 615),
)