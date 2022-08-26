"""
"""
function hgf_multiple_actions(agent, input)

    #Update the hgf
    hgf = agent.substruct
    update_hgf!(hgf, input)

    #Extract vector of action models
    action_models = agent.settings["action_models"]

    #Initialize vector for action distributions
    action_distributions = []

    #Do each action model separately
    for action_model in action_models
        #And append them to the vector of action distributions
        push!(action_distributions, action_model(agent, input; update_hgf = false))
    end

    return action_distributions
end
