"""
    premade_hgf_gaussian(
        hgf = premade_hgf("continuous_2level"),
        action_precision = 1,
        target_node = "x1",
        target_state = "posterior_mean",
    )

Function that initializes as premade HGF gaussian action agent
"""
function premade_hgf_gaussian(config::Dict)

    ## Combine defaults and user settings

    #Default parameters and settings
    defaults = Dict(
        "gaussian_action_precision" => 1,
        "target_state" => ("x1", "posterior_mean"),
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
    action_model = hgf_gaussian_action

    #Set the HGF
    hgf = config["HGF"]

    #Set parameters
    params = Dict("gaussian_action_precision" => config["gaussian_action_precision"])
    #Set states
    states = Dict()
    #Set settings
    settings =
        Dict("target_state" => config["target_state"])

    #Create the agent
    return init_agent(action_model; substruct = hgf, params = params, states = states, settings = settings)
end

"""
    premade_hgf_binary_softmax(
        hgf = premade_hgf("binary_3level"),
        action_precision = 1,
        target_node = "x1",
        target_state = "posterior_mean",
    )

Function that initializes as premade HGF binary softmax action agent
"""
function premade_hgf_binary_softmax(config::Dict)

    ## Combine defaults and user settings

    #Default parameters and settings
    defaults = Dict(
        "softmax_action_precision" => 1,
        "target_state" => ("x1", "prediction_mean"),
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
    params = Dict("softmax_action_precision" => config["softmax_action_precision"])
    #Set states
    states = Dict()
    #Set settings
    settings =
        Dict("target_state" => config["target_state"])

    #Create the agent
    return init_agent(action_model, substruct = hgf, params = params, states = states, settings = settings)
end

"""
    premade_hgf_unit_square_sigmoid(
        hgf = premade_hgf("binary_3level"),
        action_precision = 1,
        target_node = "x1",
        target_state = "posterior_mean",
    )

Function that initializes as premade HGF binary softmax action agent
"""
function premade_hgf_unit_square_sigmoid(config::Dict)

    ## Combine defaults and user settings

    #Default parameters and settings
    defaults = Dict(
        "sigmoid_action_precision" => 1,
        "target_state" => ("x1", "prediction_mean"),
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
    action_model = hgf_unit_square_sigmoid_action

    #Set the HGF
    hgf = config["HGF"]

    #Set parameters
    params = Dict("sigmoid_action_precision" => config["sigmoid_action_precision"])
    #Set states
    states = Dict()
    #Set settings
    settings =
        Dict("target_state" => config["target_state"])

    #Create the agent
    return init_agent(action_model, substruct = hgf, params = params, states = states, settings = settings)
end