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
test_hgf = HGF.premade_hgf("continuous_2level", params_list, starting_state_list);

#Create an agent with the gaussian response
test_agent = HGF.premade_agent(
    "hgf_gaussian_response",
    test_hgf,
    Dict("action_noise" => 1),
    Dict(),
    (; node = "x1", state = "posterior_mean"),
);

#Give inputs to the agent
HGF.give_inputs!(test_agent, 1.01)

HGF.give_inputs!(test_agent, [1.01, 1.02, 1.03])


#Do fitting