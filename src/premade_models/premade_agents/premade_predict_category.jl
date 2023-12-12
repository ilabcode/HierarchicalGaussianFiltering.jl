

###### Categorical Prediction Action ######
"""
    update_hgf_predict_category_action(agent::Agent, input)

Action model that first updates the HGF, and then returns a categorical prediction of the input. The HGF used must be a categorical HGF.

In addition to the HGF substruct, the following must be present in the agent:
Settings: "target_categorical_node"
"""
function update_hgf_predict_category_action(agent::Agent, input)

    #Update the HGF
    update_hgf!(agent.substruct, input)

    #Run the action model
    action_distribution = hgf_predict_category_action(agent, input)

    return action_distribution
end

"""
    hgf_predict_category_action(agent::Agent, input)

Action model which gives a categorical prediction of the input, based on an HGF. The HGF used must be a categorical HGF.

In addition to the HGF substruct, the following must be present in the agent:
Settings: "target_categorical_node"
"""
function hgf_predict_category_action(agent::Agent, input)

    #Get out settings and parameters
    target_node = agent.settings["target_categorical_node"]

    #Get out the HGF
    hgf = agent.substruct

    #Get the specified state
    predicted_category_probabilities = get_states(hgf, (target_node, "prediction"))

    #Create Bernoulli normal distribution with mean of the target value and a standard deviation from parameters
    distribution = Distributions.Categorical(predicted_category_probabilities)

    #Return the action distribution
    return distribution
end





"""
    premade_hgf_predict_category(config::Dict)

Create an agent suitable for the HGF predict category model.

# Config defaults:
 - "HGF": "categorical_3level"
 - "target_categorical_node": "xcat"
"""
function premade_hgf_predict_category(config::Dict)

    ## Combine defaults and user settings

    #Default parameters and settings
    defaults = Dict("target_categorical_node" => "xcat", "HGF" => "categorical_3level")

    #If there is no HGF in the user-set parameters
    if !("HGF" in keys(config))
        HGF_name = defaults["HGF"]
        #Make a default HGF
        config["HGF"] = premade_hgf(HGF_name)
        #And warn them
        @warn "an HGF was not set by the user. Using the default: a $HGF_name HGF with default settings"
    end

    #Warn the user about used defaults and misspecified keys
    warn_premade_defaults(defaults, config)

    #Merge to overwrite defaults
    config = merge(defaults, config)


    ## Create agent 
    #Set the action model
    action_model = update_hgf_predict_category_action

    #Set the HGF
    hgf = config["HGF"]

    #Set parameters
    parameters = Dict()
    #Set states
    states = Dict()
    #Set settings
    settings = Dict("target_categorical_node" => config["target_categorical_node"])

    #Create the agent
    return init_agent(
        action_model,
        substruct = hgf,
        parameters = parameters,
        states = states,
        settings = settings,
    )
end
