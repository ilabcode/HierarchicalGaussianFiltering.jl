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