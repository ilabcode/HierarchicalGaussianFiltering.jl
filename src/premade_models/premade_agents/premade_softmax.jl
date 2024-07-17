"""
    hgf_binary_softmax_action(agent, input)

Action model which gives a binary action. The action probability is the softmax of a specified state of a node.

In addition to the HGF substruct, the following must be present in the agent:
Parameters: "softmax_action_precision"
Settings: "target_state"
"""
function hgf_binary_softmax_action(agent::Agent, input)

    #Get out HGF, settings and parameters
    hgf = agent.substruct
    target_state = agent.settings["target_state"]
    action_noise = agent.parameters["action_noise"]

    #Update the HGF
    update_hgf!(hgf, input)

    #Get the specified state
    target_value = get_states(hgf, target_state)

    #Use sotmax to get the action probability 
    action_probability = 1 / (1 + capped_exp(action_noise * target_value))

    #If the action probability is not between 0 and 1
    if !(0 <= action_probability <= 1)
        #Throw an error that will reject samples when fitted
        throw(
            RejectParameters(
                "With these parameters and inputs, the action probability became $action_probability, which should be between 0 and 1. Try other parameter settings",
            ),
        )
    end

    #Create Bernoulli normal distribution with mean of the target value and a standard deviation from parameters
    distribution = Distributions.Bernoulli(action_probability)

    #Return the action distribution
    return distribution
end





"""
    premade_hgf_binary_softmax(config::Dict)

Create an agent suitable for the HGF binary softmax model.

# Config defaults:
 - "HGF": "binary_3level"
 - "softmax_action_precision": 1
 - "target_state": ("xbin", "prediction_mean")
"""
function premade_hgf_binary_softmax(config::Dict)

    ## Combine defaults and user settings

    #Default parameters and settings
    defaults = Dict(
        "action_noise" => 1,
        "target_state" => ("xbin", "prediction_mean"),
        "HGF" => "binary_3level",
    )

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
    action_model = hgf_binary_softmax_action

    #Set the HGF
    hgf = config["HGF"]

    #Set parameters
    parameters = Dict("action_noise" => config["action_noise"])
    #Set states
    states = Dict()
    #Set settings
    settings = Dict("target_state" => config["target_state"])

    #Create the agent
    return init_agent(
        action_model,
        substruct = hgf,
        parameters = parameters,
        states = states,
        settings = settings,
    )
end
