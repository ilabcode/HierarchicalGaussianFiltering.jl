
#####
#Initialize action model
action_model = HGF.init_action_struct(
    HGF.premade_hgf("continuous_2level"),
    HGF.gaussian_response,
    Dict("standard_deviation" => 0.5),
    Dict("action" => 0),
);

#Provide inputs, responses are printed
HGF.give_inputs(action_model, [1.0, 1.1, 1.2, 1.5])

action_model.history["action"]
