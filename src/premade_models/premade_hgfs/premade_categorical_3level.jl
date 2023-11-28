

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
 - ("xbin", "xprob", "coupling_strength"): 1
 - ("xprob", "xvol", "coupling_strength"): 1
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
        ("xbin", "xprob", "coupling_strength") => 1,
        ("xprob", "xvol", "coupling_strength") => 1,
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
    category_parent_names = Vector{String}()
    #Vector for binary node continuous parent names
    probability_parent_names = Vector{String}()

    #Empty lists for derived parameters
    derived_parameters_xprob_initial_precision = []
    derived_parameters_xprob_initial_mean = []
    derived_parameters_xprob_volatility = []
    derived_parameters_xprob_drift = []
    derived_parameters_xprob_autoregression_target = []
    derived_parameters_xprob_autoregression_strength = []
    derived_parameters_xbin_xprob_coupling_strength = []
    derived_parameters_xprob_xvol_coupling_strength = []

    #Populate the category node vectors with node names
    for category_number = 1:config["n_categories"]
        push!(category_parent_names, "xbin_" * string(category_number))
        push!(probability_parent_names, "xprob_" * string(category_number))
    end

    ##List of input nodes
    input_nodes = Dict("name" => "u", "type" => "categorical")

    ##List of state nodes
    state_nodes = [Dict{String,Any}("name" => "xcat", "type" => "categorical")]

    #Add category node binary parents
    for node_name in category_parent_names
        push!(state_nodes, Dict("name" => node_name, "type" => "binary"))
    end

    #Add binary node continuous parents
    for node_name in probability_parent_names
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
        push!(
            derived_parameters_xprob_autoregression_strength,
            (node_name, "autoregression_strength"),
        )
        push!(
            derived_parameters_xprob_autoregression_target,
            (node_name, "autoregression_target"),
        )
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
    #Set the input node coupling
    edges = Dict{Tuple{String,String},CouplingType}(("u", "xcat") => ObservationCoupling())

    #For each set of categroy parents and their probability parents
    for (category_parent_name, probability_parent_name) in
        zip(category_parent_names, probability_parent_names)

        #Connect the binary category parents to the categorical state node
        edges[("xcat", category_parent_name)] = CategoryCoupling()

        #Connect each category parent to its probability parent
        edges[(category_parent_name, probability_parent_name)] =
            ProbabilityCoupling(config[("xbin", "xprob", "coupling_strength")])

        #Connect the probability parents to the shared volatility parent
        edges[(probability_parent_name, "xvol")] =
            VolatilityCoupling(config[("xprob", "xvol", "coupling_strength")])

        #Add the coupling strengths to the lists of derived parameters
        push!(
            derived_parameters_xbin_xprob_coupling_strength,
            (category_parent_name, probability_parent_name, "coupling_strength"),
        )
        push!(
            derived_parameters_xprob_xvol_coupling_strength,
            (probability_parent_name, "xvol", "coupling_strength"),
        )
    end

    #Create dictionary with shared parameter information
    shared_parameters = Dict()

    shared_parameters["xprob_volatility"] =
        (config[("xprob", "volatility")], derived_parameters_xprob_volatility)

    shared_parameters["xprob_initial_precision"] =
        (config[("xprob", "initial_precision")], derived_parameters_xprob_initial_precision)

    shared_parameters["xprob_initial_mean"] =
        (config[("xprob", "initial_mean")], derived_parameters_xprob_initial_mean)

    shared_parameters["xprob_drift"] =
        (config[("xprob", "drift")], derived_parameters_xprob_drift)

    shared_parameters["xprob_autoregression_strength"] = (
        config[("xprob", "autoregression_strength")],
        derived_parameters_xprob_autoregression_strength,
    )

    shared_parameters["xprob_autoregression_target"] = (
        config[("xprob", "autoregression_target")],
        derived_parameters_xprob_autoregression_target,
    )

    shared_parameters["xbin_xprob_coupling_strength"] = (
        config[("xbin", "xprob", "coupling_strength")],
        derived_parameters_xbin_xprob_coupling_strength,
    )

    shared_parameters["xprob_xvol_coupling_strength"] = (
        config[("xprob", "xvol", "coupling_strength")],
        derived_parameters_xprob_xvol_coupling_strength,
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
