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

agent_params = Dict("target_node" => "x1", "target_state" => "posterior_mean");

my_agent = HGF.premade_agent("hgf_gaussian_action", my_hgf, agent_params);

# Set (optimal) parameters
HGF.get_params(my_agent)

optimal_params = Dict(
    ("u", "x1", "value_coupling") => 1.0,
    ("x1", "x2", "volatility_coupling") => 1.0,
    ("u", "evolution_rate") => -log(9.39e6),
    ("x1", "evolution_rate") => -11.8557,
    ("x2", "evolution_rate") => -5.9085,
    ("x1", "initial_mean") => 1.0315,
    ("x1", "initial_precision") => 1 / (3.2889e-5),
    ("x2", "initial_mean") => 1.0,
    ("x2", "initial_precision") => 1 / 0.0697,
    "gaussian_action_precision" => 100,
)

HGF.set_params!(my_agent, optimal_params)
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
HGF.trajectory_plot!(my_agent, ("x1", "posterior_mean"), color = "red", linewidth = 1.5)

HGF.trajectory_plot(
    my_agent,
    "x2",
    color = "blue",
    size = (1300, 500),
    xlims = (0, 615),
    title = "x2 Posterior",
)

# Set parameters for parameter recovyer
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

HGF.set_params!(my_agent, parameters)
HGF.reset!(my_agent)

# Evolve agent
responses = HGF.give_inputs!(my_agent, inputs);

#Remove initial state
popfirst!(responses)

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

HGF.trajectory_plot!(my_agent, ("x1", "posterior_mean"), color = "red", linewidth = 1.5)
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
fixed_params = Dict(
    ("u", "x1", "value_coupling") => 1.0,
    ("x1", "x2", "volatility_coupling") => 1.0,
    ("x1", "initial_mean") => inputs[1],
    ("x1", "initial_precision") => 1 / 4.276302631578957e-5,
    ("x2", "initial_mean") => 1.0,
    ("x2", "initial_precision") => 600.0,
    "gaussian_action_precision" => 100,
);


param_priors = Dict(
    ("u", "evolution_rate") => Normal(log(4.276302631578957e-5), 2),
    ("x1", "evolution_rate") => Normal(log(4.276302631578957e-5), 4),
    ("x2", "evolution_rate") => Normal(-4, 4),
);

# Prior predictive simulation plot
HGF.predictive_simulation_plot(
    my_agent,
    param_priors,
    ("x1", "posterior_mean"),
    inputs;
    n_simulations = 1000,
    title = "x1 posterior mean",
)

# Do parameter recovery
chain = HGF.fit_model(
    my_agent,
    inputs,
    responses,
    param_priors,
    fixed_params,
    NUTS(),
    1000,
)

# Plot prior posterior distributions
parameter_distribution_plot(chain, param_priors)

# Posterior predictive plot
HGF.predictive_simulation_plot(
    my_agent,
    chain,
    ("x1", "posterior_mean"),
    inputs;
    n_simulations = 1000,
    title = "x1 posterior mean",
)




# Get median of the sampled parameters 
fitted_params = HGF.get_params(chain)

# Set them on the agent
HGF.set_params!(my_agent, fitted_params)
HGF.reset!(my_agent)

# Evolve agent with fitted parameters
responses = HGF.give_inputs!(my_agent, inputs);

#Remove initial state
popfirst!(responses)

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

HGF.trajectory_plot!(my_agent, ("x1", "posterior_mean"), color = "red", linewidth = 1.5)
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
    ("x1", "prediction"),
    color = "blue",
    size = (1300, 500),
    xlims = (0, 615),
)