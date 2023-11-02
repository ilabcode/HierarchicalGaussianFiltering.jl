using ActionModels, HierarchicalGaussianFiltering
using CSV, DataFrames
using Plots, StatsPlots
using Distributions
path = "docs/src/tutorials/data"

#Load data
data = CSV.read("$path/classic_cannonball_data.csv", DataFrame)

#Create HGF
hgf = premade_hgf("JGET", verbose = false)
#Create agent
agent = premade_agent("hgf_gaussian_action", hgf)
#Set parameters
parameters = Dict(
    "gaussian_action_precision" => 1,
    ("x1", "volatility") => -8,
    ("x2", "volatility") => -5,
    ("x3", "volatility") => -5,
    ("x4", "volatility") => -5,
    ("x1", "x2", "volatility_coupling") => 1,
    ("x3", "x4", "volatility_coupling") => 1,
)
set_parameters!(agent, parameters)

inputs = data[(data.ID.==20).&(data.session.==1), :].outcome
#Simulate updates and actions
actions = give_inputs!(agent, inputs);
#Plot belief trajectories
plot_trajectory(agent, "u")
plot_trajectory!(agent, "x1")
plot_trajectory(agent, "x2")
plot_trajectory(agent, "x3")
plot_trajectory(agent, "x4")

priors = Dict(
    "gaussian_action_precision" => LogNormal(-1, 0.1),
    ("x1", "volatility") => Normal(-8, 1),
)

data_subset = data[(data.ID.∈[[20, 21]]).&(data.session.∈[[1, 2]]), :]

using Distributed
addprocs(6, exeflags = "--project")
@everywhere @eval using HierarchicalGaussianFiltering

results = fit_model(
    agent,
    priors,
    data_subset,
    independent_group_cols = [:ID, :session],
    input_cols = [:outcome],
    action_cols = [:response],
    n_cores = 6,
)

fitted_model = results[(20, 1)]

plot_parameter_distribution(fitted_model, priors)




posterior = get_posteriors(fitted_model)

set_parameters!(agent, posterior)

reset!(agent)

give_inputs!(agent, inputs)

get_history(agent, ("x1", "value_prediction_error"))
