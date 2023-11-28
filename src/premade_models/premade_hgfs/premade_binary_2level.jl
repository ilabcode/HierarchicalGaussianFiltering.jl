
"""
    premade_binary_2level(config::Dict; verbose::Bool = true)

The standard binary 2 level HGF model, which takes a binary input, and learns the probability of either outcome.
It has one binary input node u, with a binary value parent xbin, which in turn has a continuous value parent xprob.

# Config defaults:
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
        ("xbin", "xprob", "coupling_strength") => 1,
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

    #List of edges
    edges = Dict(
        ("u", "xbin") => ObservationCoupling(),
        ("xbin", "xprob") =>
            ProbabilityCoupling(config[("xbin", "xprob", "coupling_strength")]),
    )

    #Initialize the HGF
    init_hgf(
        input_nodes = input_nodes,
        state_nodes = state_nodes,
        edges = edges,
        verbose = false,
        update_type = config["update_type"],
    )
end
