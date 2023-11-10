"""
    premade_continuous_2level(config::Dict; verbose::Bool = true)

The standard 2 level continuous HGF, which filters a continuous input.
It has a continous input node u, with a single value parent x, which in turn has a single volatility parent xvol.

# Config defaults:
 - ("u", "input_noise"): -2
 - ("x", "volatility"): -2
 - ("xvol", "volatility"): -2
 - ("u", "x", "value_coupling"): 1
 - ("x", "xvol", "volatility_coupling"): 1
 - ("x", "initial_mean"): 0
 - ("x", "initial_precision"): 1
 - ("xvol", "initial_mean"): 0
 - ("xvol", "initial_precision"): 1
"""
function premade_continuous_2level(config::Dict; verbose::Bool = true)

    #Defaults
    spec_defaults = Dict(
        ("u", "input_noise") => -2,
        
        ("x", "volatility") => -2,
        ("x", "drift") => 0,
        ("x", "autoregression_target") => 0,
        ("x", "autoregression_strength") => 0,
        ("x", "initial_mean") => 0,
        ("x", "initial_precision") => 1,

        ("xvol", "volatility") => -2,
        ("xvol", "drift") => 0,
        ("xvol", "autoregression_target") => 0,
        ("xvol", "autoregression_strength") => 0,
        ("xvol", "initial_mean") => 0,
        ("xvol", "initial_precision") => 1,

        ("u", "x", "value_coupling") => 1,
        ("x", "xvol", "volatility_coupling") => 1,
       
        "update_type" => EnhancedUpdate(),
    )

    #Warn the user about used defaults and misspecified keys
    if verbose
        warn_premade_defaults(spec_defaults, config)
    end

    #Merge to overwrite defaults
    config = merge(spec_defaults, config)


    #List of input nodes to create
    input_nodes = Dict(
        "name" => "u",
        "type" => "continuous",
        "input_noise" => config[("u", "input_noise")],
    )

    #List of state nodes to create
    state_nodes = [
        Dict(
            "name" => "x",
            "type" => "continuous",
            "volatility" => config[("x", "volatility")],
            "drift" => config[("x", "drift")],
            "autoregression_target" => config[("x", "autoregression_target")],
            "autoregression_strength" => config[("x", "autoregression_strength")],
            "initial_mean" => config[("x", "initial_mean")],
            "initial_precision" => config[("x", "initial_precision")],
        ),
        Dict(
            "name" => "xvol",
            "type" => "continuous",
            "volatility" => config[("xvol", "volatility")],
            "drift" => config[("xvol", "drift")],
            "autoregression_target" => config[("xvol", "autoregression_target")],
            "autoregression_strength" => config[("xvol", "autoregression_strength")],
            "initial_mean" => config[("xvol", "initial_mean")],
            "initial_precision" => config[("xvol", "initial_precision")],
        ),
    ]

    #List of child-parent relations
    edges = [
        Dict(
            "child" => "u",
            "value_parents" => ("x", config[("u", "x", "value_coupling")]),
        ),
        Dict(
            "child" => "x",
            "volatility_parents" => ("xvol", config[("x", "xvol", "volatility_coupling")]),
        ),
    ]

    #Initialize the HGF
    init_hgf(
        input_nodes = input_nodes,
        state_nodes = state_nodes,
        edges = edges,
        verbose = false,
        update_type = config["update_type"],
    )
end


"""
premade_JGET(config::Dict; verbose::Bool = true)

The HGF used in the JGET model. It has a single continuous input node u, with a value parent x, and a volatility parent xnoise. x has volatility parent xvol, and xnoise has a volatility parent xnoise_vol.

# Config defaults:
 - ("u", "input_noise"): -2
 - ("x", "volatility"): -2
 - ("xvol", "volatility"): -2
 - ("xnoise", "volatility"): -2
 - ("xnoise_vol", "volatility"): -2
 - ("u", "x", "value_coupling"): 1
 - ("u", "xnoise", "value_coupling"): 1
 - ("x", "xvol", "volatility_coupling"): 1
 - ("xnoise", "xnoise_vol", "volatility_coupling"): 1
 - ("x", "initial_mean"): 0
 - ("x", "initial_precision"): 1
 - ("xvol", "initial_mean"): 0
 - ("xvol", "initial_precision"): 1
 - ("xnoise", "initial_mean"): 0
 - ("xnoise", "initial_precision"): 1
 - ("xnoise_vol", "initial_mean"): 0
 - ("xnoise_vol", "initial_precision"): 1
"""
function premade_JGET(config::Dict; verbose::Bool = true)

    #Defaults
    spec_defaults = Dict(
        ("u", "input_noise") => -2,

        ("x", "volatility") => -2,
        ("x", "drift") => 0,
        ("x", "autoregression_target") => 0,
        ("x", "autoregression_strength") => 0,
        ("x", "initial_mean") => 0,
        ("x", "initial_precision") => 1,

        ("xvol", "volatility") => -2,
        ("xvol", "drift") => 0,
        ("xvol", "autoregression_target") => 0,
        ("xvol", "autoregression_strength") => 0,
        ("xvol", "initial_mean") => 0,
        ("xvol", "initial_precision") => 1,

        ("xnoise", "volatility") => -2,
        ("xnoise", "drift") => 0,
        ("xnoise", "autoregression_target") => 0,
        ("xnoise", "autoregression_strength") => 0,
        ("xnoise", "initial_mean") => 0,
        ("xnoise", "initial_precision") => 1,

        ("xnoise_vol", "volatility") => -2,
        ("xnoise_vol", "drift") => 0,
        ("xnoise_vol", "autoregression_target") => 0,
        ("xnoise_vol", "autoregression_strength") => 0,
        ("xnoise_vol", "initial_mean") => 0,
        ("xnoise_vol", "initial_precision") => 1,

        ("u", "x", "value_coupling") => 1,
        ("u", "xnoise", "volatility_coupling") => 1,
        ("x", "xvol", "volatility_coupling") => 1,
        ("xnoise", "xnoise_vol", "volatility_coupling") => 1,
       
        "update_type" => EnhancedUpdate(),
    )

    #Warn the user about used defaults and misspecified keys
    if verbose
        warn_premade_defaults(spec_defaults, config)
    end

    #Merge to overwrite defaults
    config = merge(spec_defaults, config)


    #List of input nodes to create
    input_nodes = Dict(
        "name" => "u",
        "type" => "continuous",
        "input_noise" => config[("u", "input_noise")],
    )

    #List of state nodes to create
    state_nodes = [
        Dict(
            "name" => "x",
            "type" => "continuous",
            "volatility" => config[("x", "volatility")],
            "drift" => config[("x", "drift")],
            "autoregression_target" => config[("x", "autoregression_target")],
            "autoregression_strength" => config[("x", "autoregression_strength")],
            "initial_mean" => config[("x", "initial_mean")],
            "initial_precision" => config[("x", "initial_precision")],
        ),
        Dict(
            "name" => "xvol",
            "type" => "continuous",
            "volatility" => config[("xvol", "volatility")],
            "drift" => config[("xvol", "drift")],
            "autoregression_target" => config[("xvol", "autoregression_target")],
            "autoregression_strength" => config[("xvol", "autoregression_strength")],
            "initial_mean" => config[("xvol", "initial_mean")],
            "initial_precision" => config[("xvol", "initial_precision")],
        ),
        Dict(
            "name" => "xnoise",
            "type" => "continuous",
            "volatility" => config[("xnoise", "volatility")],
            "drift" => config[("xnoise", "drift")],
            "autoregression_target" => config[("xnoise", "autoregression_target")],
            "autoregression_strength" => config[("xnoise", "autoregression_strength")],
            "initial_mean" => config[("xnoise", "initial_precision")],
            "initial_precision" => config[("xnoise", "initial_precision")],
        ),
        Dict(
            "name" => "xnoise_vol",
            "type" => "continuous",
            "volatility" => config[("xnoise_vol", "volatility")],
            "drift" => config[("xnoise_vol", "drift")],
            "autoregression_target" => config[("xnoise_vol", "autoregression_target")],
            "autoregression_strength" => config[("xnoise_vol", "autoregression_strength")],
            "initial_mean" => config[("xnoise_vol", "initial_mean")],
            "initial_precision" => config[("xnoise_vol", "initial_precision")],
        ),
    ]

    #List of child-parent relations
    edges = [
        Dict(
            "child" => "u",
            "value_parents" => ("x", config[("u", "x", "value_coupling")]),
            "volatility_parents" => ("xnoise", config[("u", "xnoise", "volatility_coupling")]),
        ),
        Dict(
            "child" => "x",
            "volatility_parents" => ("xvol", config[("x", "xvol", "volatility_coupling")]),
        ),
        Dict(
            "child" => "xnoise",
            "volatility_parents" => ("xnoise_vol", config[("xnoise", "xnoise_vol", "volatility_coupling")]),
        ),
    ]

    #Initialize the HGF
    init_hgf(
        input_nodes = input_nodes,
        state_nodes = state_nodes,
        edges = edges,
        verbose = false,
        update_type = config["update_type"],
    )
end


"""
    premade_binary_2level(config::Dict; verbose::Bool = true)

The standard binary 2 level HGF model, which takes a binary input, and learns the probability of either outcome.
It has one binary input node u, with a binary value parent xbin, which in turn has a continuous value parent xprob.

# Config defaults:
 - ("u", "category_means"): [0, 1]
 - ("u", "input_precision"): Inf
 - ("xprob", "volatility"): -2
 - ("xbin", "xprob", "value_coupling"): 1
 - ("xprob", "initial_mean"): 0
 - ("xprob", "initial_precision"): 1
"""
function premade_binary_2level(config::Dict; verbose::Bool = true)

    #Defaults
    spec_defaults = Dict(
        ("u", "category_means") => [0, 1],
        ("u", "input_precision") => Inf,

        ("xprob", "volatility") => -2,
        ("xprob", "drift") => 0,
        ("xprob", "autoregression_target") => 0,
        ("xprob", "autoregression_strength") => 0,
        ("xprob", "initial_mean") => 0,
        ("xprob", "initial_precision") => 1,

        ("xbin", "xprob", "value_coupling") => 1,
        
        "update_type" => EnhancedUpdate(),
    )

    #Warn the user about used defaults and misspecified keys
    if verbose
        warn_premade_defaults(spec_defaults, config)
    end

    #Merge to overwrite defaults
    config = merge(spec_defaults, config)


    #List of input nodes to create
    input_nodes = Dict(
        "name" => "u",
        "type" => "binary",
        "category_means" => config[("u", "category_means")],
        "input_precision" => config[("u", "input_precision")],
    )

    #List of state nodes to create
    state_nodes = [
        Dict("name" => "xbin", "type" => "binary"),
        Dict(
            "name" => "xprob",
            "type" => "continuous",
            "volatility" => config[("xprob", "volatility")],
            "drift" => config[("xprob", "drift")],
            "autoregression_target" => config[("xprob", "autoregression_target")],
            "autoregression_strength" => config[("xprob", "autoregression_strength")],
            "initial_mean" => config[("xprob", "initial_mean")],
            "initial_precision" => config[("xprob", "initial_precision")],
        ),
    ]

    #List of child-parent relations
    edges = [
        Dict("child" => "u", "value_parents" => "xbin"),
        Dict(
            "child" => "xbin",
            "value_parents" => ("xprob", config[("xbin", "xprob", "value_coupling")]),
        ),
    ]

    #Initialize the HGF
    init_hgf(
        input_nodes = input_nodes,
        state_nodes = state_nodes,
        edges = edges,
        verbose = false,
        update_type = config["update_type"],
    )
end


"""
    premade_binary_3level(config::Dict; verbose::Bool = true)

The standard binary 3 level HGF model, which takes a binary input, and learns the probability of either outcome.
It has one binary input node u, with a binary value parent xbin, which in turn has a continuous value parent xprob. This then has a continunous volatility parent xvol.

This HGF has five shared parameters: 
"xprob_volatility"
"xprob_initial_precisions"
"xprob_initial_means"
"value_couplings_xbin_xprob"
"volatility_couplings_xprob_xvol"

# Config defaults:
 - ("u", "category_means"): [0, 1]
 - ("u", "input_precision"): Inf
 - ("xprob", "volatility"): -2
 - ("xvol", "volatility"): -2
 - ("xbin", "xprob", "value_coupling"): 1
 - ("xprob", "xvol", "volatility_coupling"): 1
 - ("xprob", "initial_mean"): 0
 - ("xprob", "initial_precision"): 1
 - ("xvol", "initial_mean"): 0
 - ("xvol", "initial_precision"): 1
"""
function premade_binary_3level(config::Dict; verbose::Bool = true)

    #Defaults
    defaults = Dict(
        ("u", "category_means") => [0, 1],
        ("u", "input_precision") => Inf,

        ("xprob", "volatility") => -2,
        ("xprob", "drift") => 0,
        ("xprob", "autoregression_target") => 0,
        ("xprob", "autoregression_strength") => 0,
        ("xprob", "initial_mean") => 0,
        ("xprob", "initial_precision") => 1,

        ("xvol", "volatility") => -2,
        ("xvol", "drift") => 0,
        ("xvol", "autoregression_target") => 0,
        ("xvol", "autoregression_strength") => 0,
        ("xvol", "initial_mean") => 0,
        ("xvol", "initial_precision") => 1,

        ("xbin", "xprob", "value_coupling") => 1,
        ("xprob", "xvol", "volatility_coupling") => 1,

        "update_type" => EnhancedUpdate(),
    )

    #Warn the user about used defaults and misspecified keys
    if verbose
        warn_premade_defaults(defaults, config)
    end

    #Merge to overwrite defaults
    config = merge(defaults, config)


    #List of input nodes to create
    input_nodes = Dict(
        "name" => "u",
        "type" => "binary",
        "category_means" => config[("u", "category_means")],
        "input_precision" => config[("u", "input_precision")],
    )

    #List of state nodes to create
    state_nodes = [
        Dict("name" => "xbin", "type" => "binary"),
        Dict(
            "name" => "xprob",
            "type" => "continuous",
            "volatility" => config[("xprob", "volatility")],
            "drift" => config[("xprob", "drift")],
            "autoregression_target" => config[("xprob", "autoregression_target")],
            "autoregression_strength" => config[("xprob", "autoregression_strength")],
            "initial_mean" => config[("xprob", "initial_mean")],
            "initial_precision" => config[("xprob", "initial_precision")],
        ),
        Dict(
            "name" => "xvol",
            "type" => "continuous",
            "volatility" => config[("xvol", "volatility")],
            "drift" => config[("xvol", "drift")],
            "autoregression_target" => config[("xvol", "autoregression_target")],
            "autoregression_strength" => config[("xvol", "autoregression_strength")],
            "initial_mean" => config[("xvol", "initial_mean")],
            "initial_precision" => config[("xvol", "initial_precision")],
        ),
    ]

    #List of child-parent relations
    edges = [
        Dict("child" => "u", "value_parents" => "xbin"),
        Dict(
            "child" => "xbin",
            "value_parents" => ("xprob", config[("xbin", "xprob", "value_coupling")]),
        ),
        Dict(
            "child" => "xprob",
            "volatility_parents" => ("xvol", config[("xprob", "xvol", "volatility_coupling")]),
        ),
    ]

    #Initialize the HGF
    init_hgf(
        input_nodes = input_nodes,
        state_nodes = state_nodes,
        edges = edges,
        verbose = false,
        update_type = config["update_type"],
    )
end

"""
    premade_categorical_3level(config::Dict; verbose::Bool = true)

The categorical 3 level HGF model, which takes an input from one of n categories and learns the probability of a category appearing.
It has one categorical input node u, with a categorical value parent xcat.
The categorical node has a binary value parent xbin_n for each category n, each of which has a continuous value parent xprob_n.
Finally, all of these continuous nodes share a continuous volatility parent xvol. 
Setting parameter values for xbin and xprob sets that parameter value for each of the xbin_n and xprob_n nodes.

# Config defaults:
 - "n_categories": 4
 - ("xprob", "volatility"): -2
 - ("xvol", "volatility"): -2
 - ("xbin", "xprob", "value_coupling"): 1
 - ("xprob", "xvol", "volatility_coupling"): 1
 - ("xprob", "initial_mean"): 0
 - ("xprob", "initial_precision"): 1
 - ("xvol", "initial_mean"): 0
 - ("xvol", "initial_precision"): 1
"""
function premade_categorical_3level(config::Dict; verbose::Bool = true)

    #Defaults
    defaults = Dict(
        "n_categories" => 4,

        ("xprob", "volatility") => -2,
        ("xprob", "drift") => 0,
        ("xprob", "autoregression_target") => 0,
        ("xprob", "autoregression_strength") => 0,
        ("xprob", "initial_mean") => 0,
        ("xprob", "initial_precision") => 1,

        ("xvol", "volatility") => -2,
        ("xvol", "drift") => 0,
        ("xvol", "autoregression_target") => 0,
        ("xvol", "autoregression_strength") => 0,
        ("xvol", "initial_mean") => 0,
        ("xvol", "initial_precision") => 1,

        ("xbin", "xprob", "value_coupling") => 1,
        ("xprob", "xvol", "volatility_coupling") => 1,

        "update_type" => EnhancedUpdate(),
    )

    #Warn the user about used defaults and misspecified keys
    if verbose
        warn_premade_defaults(defaults, config)
    end

    #Merge to overwrite defaults
    config = merge(defaults, config)


    ##Prep category node parent names
    #Vector for category node binary parent names
    category_binary_parent_names = Vector{String}()
    #Vector for binary node continuous parent names
    binary_continuous_parent_names = Vector{String}()

    #Empty lists for derived parameters
    derived_parameters_xprob_initial_precision = []
    derived_parameters_xprob_initial_mean = []
    derived_parameters_xprob_volatility = []
    derived_parameters_xprob_drift = []
    derived_parameters_xprob_autoregression_target = []
    derived_parameters_xprob_autoregression_strength = []
    derived_parameters_xprob_xvol_volatility_coupling = []
    derived_parameters_value_coupling_xbin_xprob = []

    #Populate the category node vectors with node names
    for category_number = 1:config["n_categories"]
        push!(category_binary_parent_names, "xbin_" * string(category_number))
        push!(binary_continuous_parent_names, "xprob_" * string(category_number))
    end

    ##List of input nodes
    input_nodes = Dict("name" => "u", "type" => "categorical")

    ##List of state nodes
    state_nodes = [Dict{String,Any}("name" => "xcat", "type" => "categorical")]

    #Add category node binary parents
    for node_name in category_binary_parent_names
        push!(state_nodes, Dict("name" => node_name, "type" => "binary"))
    end

    #Add binary node continuous parents
    for node_name in binary_continuous_parent_names
        push!(
            state_nodes,
            Dict(
                "name" => node_name,
                "type" => "continuous",
                "initial_mean" => config[("xprob", "initial_mean")],
                "initial_precision" => config[("xprob", "initial_precision")],
                "volatility" => config[("xprob", "volatility")],
                "drift" => config[("xprob", "drift")],
                "autoregression_target" => config[("xprob", "autoregression_target")],
                "autoregression_strength" => config[("xprob", "autoregression_strength")],
            ),
        )
        #Add the derived parameter name to derived parameters vector
        push!(derived_parameters_xprob_initial_precision, (node_name, "initial_precision"))
        push!(derived_parameters_xprob_initial_mean, (node_name, "initial_mean"))
        push!(derived_parameters_xprob_volatility, (node_name, "volatility"))
        push!(derived_parameters_xprob_drift, (node_name, "drift"))
        push!(derived_parameters_xprob_autoregression_strength, (node_name, "autoregression_strength"))
        push!(derived_parameters_xprob_autoregression_target, (node_name, "autoregression_target"))
    end

    #Add volatility parent
    push!(
        state_nodes,
        Dict(
            "name" => "xvol",
            "type" => "continuous",
            "volatility" => config[("xvol", "volatility")],
            "drift" => config[("xvol", "drift")],
            "autoregression_target" => config[("xvol", "autoregression_target")],
            "autoregression_strength" => config[("xvol", "autoregression_strength")],
            "initial_mean" => config[("xvol", "initial_mean")],
            "initial_precision" => config[("xvol", "initial_precision")],
        ),
    )


    ##List of child-parent relations
    edges = [
        Dict("child" => "u", "value_parents" => "xcat"),
        Dict("child" => "xcat", "value_parents" => category_binary_parent_names),
    ]

    #Add relations between binary nodes and their parents
    for (child_name, parent_name) in
        zip(category_binary_parent_names, binary_continuous_parent_names)
        push!(
            edges,
            Dict(
                "child" => child_name,
                "value_parents" => (parent_name, config[("xbin", "xprob", "value_coupling")]),
            ),
        )
        #Add the derived parameter name to derived parameters vector
        push!(
            derived_parameters_value_coupling_xbin_xprob,
            (child_name, parent_name, "value_coupling"),
        )
    end

    #Add relations between binary node parents and the volatility parent
    for child_name in binary_continuous_parent_names
        push!(
            edges,
            Dict(
                "child" => child_name,
                "volatility_parents" => ("xvol", config[("xprob", "xvol", "volatility_coupling")]),
            ),
        )
        #Add the derived parameter name to derived parameters vector
        push!(
            derived_parameters_xprob_xvol_volatility_coupling,
            (child_name, "xvol", "volatility_coupling"),
        )
    end

    #Create dictionary with shared parameter information
    shared_parameters = Dict()

    shared_parameters["xprob_volatility"] =
        (config[("xprob", "volatility")], derived_parameters_xprob_volatility)

    shared_parameters["xprob_initial_precisions"] =
        (config[("xprob", "initial_precision")], derived_parameters_xprob_initial_precision)

    shared_parameters["xprob_initial_means"] =
        (config[("xprob", "initial_mean")], derived_parameters_xprob_initial_mean)

    shared_parameters["xprob_drifts"] =
        (config[("xprob", "drift")], derived_parameters_xprob_drift)

    shared_parameters["xprob_autoregression_strengths"] =
        (config[("xprob", "autoregression_strength")], derived_parameters_xprob_autoregression_strength)

    shared_parameters["xprob_autoregression_targets"] =
        (config[("xprob", "autoregression_target")], derived_parameters_xprob_autoregression_target)

    shared_parameters["value_couplings_xbin_xprob"] =
        (config[("xbin", "xprob", "value_coupling")], derived_parameters_value_coupling_xbin_xprob)

    shared_parameters["volatility_couplings_xprob_xvol"] = (
        config[("xprob", "xvol", "volatility_coupling")],
        derived_parameters_xprob_xvol_volatility_coupling,
    )

    #Initialize the HGF
    init_hgf(
        input_nodes = input_nodes,
        state_nodes = state_nodes,
        edges = edges,
        shared_parameters = shared_parameters,
        verbose = false,
        update_type = config["update_type"],
    )
end

"""
    premade_categorical_3level_state_transitions(config::Dict; verbose::Bool = true)

The categorical state transition 3 level HGF model, learns state transition probabilities between a set of n categorical states.
It has one categorical input node u, with a categorical value parent xcat_n for each of the n categories, representing which category was transitioned from.
Each categorical node then has a binary parent xbin_n_m, representing the category m which the transition was towards.
Each binary node xbin_n_m has a continuous parent xprob_n_m. 
Finally, all of these continuous nodes share a continuous volatility parent xvol. 
Setting parameter values for xbin and xprob sets that parameter value for each of the xbin_n_m and xprob_n_m nodes.

This HGF has five shared parameters: 
"xprob_volatility"
"xprob_initial_precisions"
"xprob_initial_means"
"value_couplings_xbin_xprob"
"volatility_couplings_xprob_xvol"

# Config defaults:
    - "n_categories": 4
    - ("xprob", "volatility"): -2
    - ("xvol", "volatility"): -2
    - ("xbin", "xprob", "volatility_coupling"): 1
    - ("xprob", "xvol", "volatility_coupling"): 1
    - ("xprob", "initial_mean"): 0
    - ("xprob", "initial_precision"): 1
    - ("xvol", "initial_mean"): 0
    - ("xvol", "initial_precision"): 1
"""
function premade_categorical_3level_state_transitions(config::Dict; verbose::Bool = true)

    #Defaults
    defaults = Dict(
        "n_categories" => 4,

        ("xprob", "volatility") => -2,
        ("xprob", "drift") => 0,
        ("xprob", "autoregression_target") => 0,
        ("xprob", "autoregression_strength") => 0,
        ("xprob", "initial_mean") => 0,
        ("xprob", "initial_precision") => 1,

        ("xvol", "volatility") => -2,
        ("xvol", "drift") => 0,
        ("xvol", "autoregression_target") => 0,
        ("xvol", "autoregression_strength") => 0,
        ("xvol", "initial_mean") => 0,
        ("xvol", "initial_precision") => 1,

        ("xbin", "xprob", "value_coupling") => 1,
        ("xprob", "xvol", "volatility_coupling") => 1,

        "update_type" => EnhancedUpdate(),
    )

    #Warn the user about used defaults and misspecified keys
    if verbose
        warn_premade_defaults(defaults, config)
    end

    #Merge to overwrite defaults
    config = merge(defaults, config)


    ##Prepare node names
    #Empty lists for node names
    categorical_input_node_names = Vector{String}()
    categorical_state_node_names = Vector{String}()
    categorical_node_binary_parent_names = Vector{String}()
    binary_node_continuous_parent_names = Vector{String}()

    #Empty lists for derived parameters
    derived_parameters_xprob_initial_precision = []
    derived_parameters_xprob_initial_mean = []
    derived_parameters_xprob_volatility = []
    derived_parameters_xprob_drift = []
    derived_parameters_xprob_autoregression_target = []
    derived_parameters_xprob_autoregression_strength = []
    derived_parameters_value_coupling_xbin_xprob = []
    derived_parameters_xprob_xvol_volatility_coupling = []

    #Go through each category that the transition may have been from
    for category_from = 1:config["n_categories"]
        #One input node and its state node parent for each                             
        push!(categorical_input_node_names, "u" * string(category_from))
        push!(categorical_state_node_names, "xcat_" * string(category_from))
        #Go through each category that the transition may have been to
        for category_to = 1:config["n_categories"]
            #Each categorical state node has a binary parent for each
            push!(
                categorical_node_binary_parent_names,
                "xbin_" * string(category_from) * "_" * string(category_to),
            )
            #And each binary parent has a continuous parent of its own
            push!(
                binary_node_continuous_parent_names,
                "xprob_" * string(category_from) * "_" * string(category_to),
            )
        end
    end

    ##Create input nodes
    #Initialize list
    input_nodes = Vector{Dict}()

    #For each categorical input node
    for node_name in categorical_input_node_names
        #Add it to the list
        push!(input_nodes, Dict("name" => node_name, "type" => "categorical"))
    end

    ##Create state nodes
    #Initialize list
    state_nodes = Vector{Dict}()

    #For each cateogrical state node
    for node_name in categorical_state_node_names
        #Add it to the list
        push!(state_nodes, Dict("name" => node_name, "type" => "categorical"))
    end

    #For each categorical node binary parent
    for node_name in categorical_node_binary_parent_names
        #Add it to the list                                    
        push!(state_nodes, Dict("name" => node_name, "type" => "binary"))
    end

    #For each binary node continuous parent
    for node_name in binary_node_continuous_parent_names
        #Add it to the list, with parameter settings from the config
        push!(
            state_nodes,
            Dict(
                "name" => node_name,
                "type" => "continuous",
                "initial_mean" => config[("xprob", "initial_mean")],
                "initial_precision" => config[("xprob", "initial_precision")],
                "volatility" => config[("xprob", "volatility")],
                "drift" => config[("xprob", "drift")],
                "autoregression_target" => config[("xprob", "autoregression_target")],
                "autoregression_strength" => config[("xprob", "autoregression_strength")],
            ),
        )
        #Add the derived parameter name to derived parameters vector
        push!(derived_parameters_xprob_initial_precision, (node_name, "initial_precision"))
        push!(derived_parameters_xprob_initial_mean, (node_name, "initial_mean"))
        push!(derived_parameters_xprob_volatility, (node_name, "volatility"))
        push!(derived_parameters_xprob_drift, (node_name, "drift"))
        push!(derived_parameters_xprob_autoregression_strength, (node_name, "autoregression_strength"))
        push!(derived_parameters_xprob_autoregression_target, (node_name, "autoregression_target"))
    end


    #Add the shared volatility parent of the continuous nodes
    push!(
        state_nodes,
        Dict(
            "name" => "xvol",
            "type" => "continuous",
            "volatility" => config[("xvol", "volatility")],
            "drift" => config[("xvol", "drift")],
            "autoregression_target" => config[("xvol", "autoregression_target")],
            "autoregression_strength" => config[("xvol", "autoregression_strength")],
            "initial_mean" => config[("xvol", "initial_mean")],
            "initial_precision" => config[("xvol", "initial_precision")],
        ),
    )

    ##Create child-parent relations
    #Initialize list                                                     
    edges = Vector{Dict}()

    #For each categorical input node and its corresponding state node parent
    for (child_name, parent_name) in
        zip(categorical_input_node_names, categorical_state_node_names)
        #Add their relation to the list
        push!(edges, Dict("child" => child_name, "value_parents" => parent_name))
    end

    #For each categorical state node
    for child_node_name in categorical_state_node_names
        #Get the category it represents transitions from
        (child_supername, child_category_from) = split(child_node_name, "_")

        #For each potential parent node
        for parent_node_name in categorical_node_binary_parent_names
            #Get the category it represents transitions from
            (parent_supername, parent_category_from, parent_category_to) =
                split(parent_node_name, "_")

            #If these match
            if parent_category_from == child_category_from
                #Add the parent as parent of the child
                push!(
                    edges,
                    Dict("child" => child_node_name, "value_parents" => parent_node_name),
                )
            end
        end
    end

    #For each binary parent of categorical nodes and their corresponding continuous parents
    for (child_name, parent_name) in
        zip(categorical_node_binary_parent_names, binary_node_continuous_parent_names)
        #Add their relations to the list, with the same value coupling
        push!(
            edges,
            Dict(
                "child" => child_name,
                "value_parents" => (parent_name, config[("xbin", "xprob", "value_coupling")]),
            ),
        )
        #Add the derived parameter name to derived parameters vector
        push!(
            derived_parameters_value_coupling_xbin_xprob,
            (child_name, parent_name, "value_coupling"),
        )
    end


    #Add the shared continuous node volatility parent to the continuous nodes
    for child_name in binary_node_continuous_parent_names
        push!(
            edges,
            Dict(
                "child" => child_name,
                "volatility_parents" => ("xvol", config[("xprob", "xvol", "volatility_coupling")]),
            ),
        )
        #Add the derived parameter name to derived parameters vector
        push!(
            derived_parameters_xprob_xvol_volatility_coupling,
            (child_name, "xvol", "volatility_coupling"),
        )

    end

    #Create dictionary with shared parameter information

    shared_parameters = Dict()

    shared_parameters["xprob_volatility"] =
        (config[("xprob", "volatility")], derived_parameters_xprob_volatility)

    shared_parameters["xprob_initial_precisions"] =
        (config[("xprob", "initial_precision")], derived_parameters_xprob_initial_precision)

    shared_parameters["xprob_initial_means"] =
        (config[("xprob", "initial_mean")], derived_parameters_xprob_initial_mean)

    shared_parameters["xprob_drifts"] =
        (config[("xprob", "drift")], derived_parameters_xprob_drift)

    shared_parameters["xprob_autoregression_strengths"] =
        (config[("xprob", "autoregression_strength")], derived_parameters_xprob_autoregression_strength)

    shared_parameters["xprob_autoregression_targets"] =
        (config[("xprob", "autoregression_target")], derived_parameters_xprob_autoregression_target)

    shared_parameters["value_couplings_xbin_xprob"] =
        (config[("xbin", "xprob", "value_coupling")], derived_parameters_value_coupling_xbin_xprob)

    shared_parameters["volatility_couplings_xprob_xvol"] = (
        config[("xprob", "xvol", "volatility_coupling")],
        derived_parameters_xprob_xvol_volatility_coupling,
    )

    #Initialize the HGF
    init_hgf(
        input_nodes = input_nodes,
        state_nodes = state_nodes,
        edges = edges,
        shared_parameters = shared_parameters,
        verbose = false,
        update_type = config["update_type"],
    )
end
