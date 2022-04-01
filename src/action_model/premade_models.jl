using Distributions

#Dummy function for action model
function gaussian_response(action_struct, input)

    ### Perceptual part ###
    #Get out the HGF
    HGF = action_struct.perceptual_struct
    #Update the HGF
    HGF.perceptual_model(HGF, input)
    #Extract the poestrior belief about x1
    μ1 = HGF.state_nodes["x1"].state.posterior_mean
    
    #Create normal distribution with mean μ1 and a standard deviation from parameters
    distribution = Normal(μ1, action_struct.params["standard_deviation"])

    #Sample the action from the distribution
    action = rand(distribution, 1)[1]

    return action
end