"""
    premade_hgf_gaussian(
        hgf = HGF.premade_hgf("continuous_2level"),
        action_precision = 1,
        target_node = "x1",
        target_state = "posterior_mean",
    )

Function that initializes as premade HGF gaussian action agent
"""
function premade_hgf_gaussian(specs::Dict; verbose::Bool = true)

    ## Combine defaults and user settings

    #Default parameters and settings
    defaults = Dict(
        "gaussian_action_precision" => 1,
        "target_node" => "x1",
        "target_state" => "posterior_mean",
        "HGF" => "continuous_2level",
    )

    #If there is no HGF in the user-set parameters
    if !("HGF" in keys(specs))
        HGF_name = defaults["HGF"]
        #Make a default HGF
        defaults["HGF"] = HGF.premade_hgf(HGF_name)
        #And warn them
        if verbose
            @warn "an HGF was not set by the user. using the default: a $HGF_name HGF with default settings"
        end
    end

    #Warn the user about used defaults and misspecified keys
    if verbose
        warn_premade_defaults(defaults, specs)
    end

    #Merge to overwrite defaults
    specs = merge(defaults, specs)


    ## Create agent 
    #Set the action model
    action_model = hgf_gaussian_action

    #Set the HGF
    hgf = specs["HGF"]

    #Set parameters
    params = Dict("gaussian_action_precision" => specs["gaussian_action_precision"])
    #Set states
    states = Dict()
    #Set settings
    settings =
        Dict("target_node" => specs["target_node"], "target_state" => specs["target_state"])

    #Create the agent
    return HGF.init_agent(action_model, hgf, params, states, settings)
end


"""
    premade_hgf_binary_softmax(
        hgf = HGF.premade_hgf("binary_3level"),
        action_precision = 1,
        target_node = "x1",
        target_state = "posterior_mean",
    )

Function that initializes as premade HGF binary softmax action agent
"""
function premade_hgf_binary_softmax(specs::Dict; verbose::Bool = true)

    ## Combine defaults and user settings

    #Default parameters and settings
    defaults = Dict(
        "softmax_action_precision" => 1,
        "target_node" => "x1",
        "target_state" => "prediction_mean",
        "HGF" => "binary_3level",
    )

    #If there is no HGF in the user-set parameters
    if !("HGF" in keys(specs))
        HGF_name = defaults["HGF"]
        #Make a default HGF
        defaults["HGF"] = HGF.premade_hgf(HGF_name)
        #And warn them
        if verbose
            @warn "an HGF was not set by the user. using the default: a $HGF_name HGF with default settings"
        end
    end

    #Warn the user about used defaults and misspecified keys
    if verbose
        warn_premade_defaults(defaults, specs)
    end

    #Merge to overwrite defaults
    specs = merge(defaults, specs)


    ## Create agent 
    #Set the action model
    action_model = hgf_binary_softmax_action

    #Set the HGF
    hgf = specs["HGF"]

    #Set parameters
    params = Dict("softmax_action_precision" => specs["softmax_action_precision"])
    #Set states
    states = Dict()
    #Set settings
    settings =
        Dict("target_node" => specs["target_node"], "target_state" => specs["target_state"])

    #Create the agent
    return HGF.init_agent(action_model, hgf, params, states, settings)
end


"""
    premade_hgf_unit_square_sigmoid(
        hgf = HGF.premade_hgf("binary_3level"),
        action_precision = 1,
        target_node = "x1",
        target_state = "posterior_mean",
    )

Function that initializes as premade HGF binary softmax action agent
"""
function premade_hgf_unit_square_sigmoid(specs::Dict; verbose::Bool = true)

    ## Combine defaults and user settings

    #Default parameters and settings
    defaults = Dict(
        "sigmoid_action_precision" => 1,
        "target_node" => "x1",
        "target_state" => "prediction_mean",
        "HGF" => "binary_3level",
    )

    #If there is no HGF in the user-set parameters
    if !("HGF" in keys(specs))
        HGF_name = defaults["HGF"]
        #Make a default HGF
        defaults["HGF"] = HGF.premade_hgf(HGF_name)
        #And warn them
        if verbose
            @warn "an HGF was not set by the user. using the default: a $HGF_name HGF with default settings"
        end
    end

    #Warn the user about used defaults and misspecified keys
    if verbose
        warn_premade_defaults(defaults, specs)
    end

    #Merge to overwrite defaults
    specs = merge(defaults, specs)


    ## Create agent 
    #Set the action model
    action_model = hgf_unit_square_sigmoid_action

    #Set the HGF
    hgf = specs["HGF"]

    #Set parameters
    params = Dict("sigmoid_action_precision" => specs["sigmoid_action_precision"])
    #Set states
    states = Dict()
    #Set settings
    settings =
        Dict("target_node" => specs["target_node"], "target_state" => specs["target_state"])

    #Create the agent
    return HGF.init_agent(action_model, hgf, params, states, settings)
end