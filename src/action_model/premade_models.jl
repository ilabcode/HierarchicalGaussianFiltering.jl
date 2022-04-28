#Dummy function for action model
function gaussian_response(action_struct, input)

    ### Perceptual part ###
    #Get out the HGF
    my_HGF = action_struct.perceptual_struct
    #Update the HGF
    my_HGF.perceptual_model(my_HGF, input)
    #Extract the poestrior belief about x1
    μ1 = my_HGF.state_nodes["x1"].state.posterior_mean
    
    #Create normal distribution with mean μ1 and a standard deviation from parameters
    distribution = Distributions.Normal(μ1, action_struct.params["standard_deviation"])

    return distribution
end