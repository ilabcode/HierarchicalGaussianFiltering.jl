
#####
#Initialize action model
agent = HGF.init_agent(
    HGF.premade_hgf("continuous_2level"),
    HGF.gaussian_response,
    Dict("standard_deviation" => 0.5),
    Dict("action" => 0),
);

#Provide inputs, responses are printed
HGF.give_inputs!(agent, [1.0, 1.1, 1.2, 1.5])
