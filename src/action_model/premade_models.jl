

#Dummy function for action model
function dummy_action(action_struct, input)

    ### Perceptual part ###
    #Get out the HGF
    HGF_struct = action_struct.perceptual_struct
    #Update the HGF
    HGF_struct.perceptual_model(HGF_struct, input)

    ### Action part ###
    #An arbitrary state is the precision on an x1 node
    action_struct.state["dummystate_1"] = HGF_struct.state_nodes["x1"].state.posterior_precision
    #Add it to the state history
    push!(action_struct.history["dummystate_1"], action_struct.state["dummystate_1"])
    
    #The action is always 0
    action = 0

    return action
end

