using HGF

###
#Set parameters
params_list = (;
    u_evolution_rate = log(1e-4),
    x1_evolution_rate = -13.0,
    x2_evolution_rate = -2.0,
    x1_x2_coupling_strength = 1,
)

# Set starting states
starting_state_list = (;
    x1_posterior_mean = 1.04,
    x1_posterior_precision = 1e4,
    x2_posterior_mean = 1.0,
    x2_posterior_precision = 1e1,
)

#Initialize HGF
test_HGF = HGF.premade_HGF("continuous_2level", params_list, starting_state_list);

test_HGF.state_nodes["x1"].history.posterior_mean

#Single input
HGF.update_HGF!(test_HGF, 1.037)

#Multiple inputs
HGF.give_inputs(test_HGF, [1.037, 1.035, 1022])

#See inside
test_HGF.state_nodes["x2"].params.evolution_rate



######
using HGF
#Parameter values to be used for all nodes unless other values are given
node_defaults = (
    params = (; evolution_rate = 3),
    starting_state = (; posterior_precision = 1),
    coupling_strengths = (; value_coupling_strength = 1)
)

#List of input nodes to create
input_nodes = [
    (name = "u1", params = (; evolution_rate = 2)),
    "u2",
]

#List of state nodes to create
state_nodes = [
    "x1",
    "x2",
    "x3",
    (name = "x4", params = (; evolution_rate = 2)),
    (
        name = "x5",
        params = (; evolution_rate = 2),
        starting_state = (; posterior_mean = 1, posterior_precision = 2),
    ),
]

#List of child-parent relations
child_parent_relations = [
    (
        child_node = "u1",
        value_parents = "x1",
    ),
    (
        child_node = "u2",
        value_parents = "x2",
        volatility_parents = ["x1", "x2"],
    ),
    (
        child_node = "x1",
        value_parents = (name = "x3", coupling_strength = 2),
        volatility_parents = [(name = "x4", coupling_strength = 2), "x5"],
    ),
]

#Initialize an HGF
test_HGF_2 = HGF.init_HGF(
    node_defaults,
    input_nodes,
    state_nodes,
    child_parent_relations,
);

#Single input
HGF.update_HGF!(test_HGF_2, Dict("u1" => 1.05, "u2" => 1.07))

#Wrong input format
HGF.give_inputs(test_HGF_2, [1. 1. 1.2; 2. 1. 1.5])

#Multiple inputs
HGF.give_inputs(test_HGF_2, [1. 1.; 1. 1.5; 1. 2.; 2. 5.])

#Check inside
test_HGF_2.state_nodes["x2"].history.posterior_mean



#####
#Initialize action model
action_model = HGF.init_action_struct(
    HGF.premade_HGF("continuous_2level"),
    HGF.gaussian_response,
    Dict("standard_deviation" => 0.5),
    Dict("action" => 0),
);

#Provide inputs, responses are printed
HGF.give_inputs(action_model, [1.0, 1.1, 1.2, 1.5])

action_model.history["action"]






###

#Create HGF
params_list =
    (; u_evolution_rate = log(1e-4), x1_evolution_rate = -13.0, x2_evolution_rate=-2.0, x1_x2_coupling_strength = 1)
starting_state_list =
    (; x1_posterior_mean = 1.04, x1_posterior_precision = 1e4, x2_posterior_mean = 1.0, x2_posterior_precision=10,)
my_hgf=HGF.premade_HGF("continuous_2level",params_list,starting_state_list)

#Get inputs from data
input=Float64[]
open("data//canonical_input_trajectory.dat") do f
    for ln in eachline(f)
        push!(input,parse(Float64, ln))
    end
end

#Input to HGF
for i in range(1, length(input))
    HGF.update_HGF!(my_hgf, input[i])
end

#Plot
using Plots
trajectory_plot(my_hgf)







