"""
    hgf_gaussian(agent::Agent, input)

Action model which reports a given HGF state with Gaussian noise.

In addition to the HGF substruct, the following must be present in the agent:
Parameters: "gaussian_action_precision"
Settings: "target_state"
"""
function hgf_gaussian(agent::Agent, input)

    #Extract HGF, settings and parameters
    hgf = agent.substruct
    target_state = agent.settings["target_state"]
    action_noise = agent.parameters["action_noise"]

    #Update the HGF
    update_hgf!(agent.substruct, input)

    #Extract specified belief state
    action_mean = get_states(hgf, target_state)

    #If the gaussian mean becomes a NaN
    if isnan(action_mean)
        #Throw an error that will reject samples when fitted
        throw(
            RejectParameters(
                "With these parameters and inputs, the mean of the gaussian action became $action_mean, which is invalid. Try other parameter settings",
            ),
        )
    end

    #Create normal distribution with mean of the target value and a standard deviation from parameters
    distribution = Distributions.Normal(action_mean, action_noise)

    #Return the action distribution
    return distribution
end


"""
    premade_hgf_gaussian(config::Dict)

Create an agent suitable for the HGF Gaussian action model.

# Config defaults:
 - "HGF": "continuous_2level"
 - "gaussian_action_precision": 1
 - "target_state": ("x", "posterior_mean")
"""
function premade_hgf_gaussian(config::Dict)

    ## Combine defaults and user settings

    #Default parameters and settings
    defaults = Dict(
        "action_noise" => 1,
        "target_state" => ("x", "posterior_mean"),
        "HGF" => "continuous_2level",
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
    action_model = hgf_gaussian

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
        action_model;
        substruct = hgf,
        parameters = parameters,
        states = states,
        settings = settings,
    )
end
