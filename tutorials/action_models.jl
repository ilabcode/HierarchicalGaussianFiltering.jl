
#####
#Initialize action model
action_model = HGF.init_agent(
    HGF.premade_hgf("continuous_2level"),
    HGF.gaussian_response,
    Dict("standard_deviation" => 0.5),
    Dict("action" => 0),
);

#Provide inputs, responses are printed
HGF.give_inputs!(action_model, 2.0)

action_model.state["action"]

HGF.reset!(action_model)