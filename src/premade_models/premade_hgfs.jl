"""
    premade_continuous_2level(params_list, starting_state_list)

The standard 2 level HGF. It has a continous input node U, with a single value parent x1, which in turn has a single volatility parent x2.
"""
function premade_continuous_2level(config::Dict; verbose::Bool = true)

    #Defaults
    spec_defaults = Dict(
        ("u", "evolution_rate") => 0.0,
        ("x1", "evolution_rate") => -12.0,
        ("x2", "evolution_rate") => -2.0,
        ("u", "x1", "value_coupling") => 1.0,
        ("x1", "x2", "volatility_coupling") => 1.0,
        ("x1", "initial_mean") => 1.04,
        ("x1", "initial_precision") => Inf,
        ("x2", "initial_mean") => 1.0,
        ("x2", "initial_precision") => Inf,
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
        "evolution_rate" => config[("u", "evolution_rate")],
    )

    #List of state nodes to create
    state_nodes = [
        Dict(
            "name" => "x1",
            "type" => "continuous",
            "evolution_rate" => config[("x1", "evolution_rate")],
            "initial_mean" => config[("x1", "initial_mean")],
            "initial_precision" => config[("x1", "initial_precision")],
        ),
        Dict(
            "name" => "x2",
            "type" => "continuous",
            "evolution_rate" => config[("x2", "evolution_rate")],
            "initial_mean" => config[("x2", "initial_mean")],
            "initial_precision" => config[("x2", "initial_precision")],
        ),
    ]

    #List of child-parent relations
    edges = [
        Dict(
            "child" => "u",
            "value_parents" => ("x1", config[("u", "x1", "value_coupling")]),
        ),
        Dict(
            "child" => "x1",
            "volatility_parents" => ("x2", config[("x1", "x2", "volatility_coupling")]),
        ),
    ]

    #Initialize the HGF
    init_hgf(
        input_nodes = input_nodes,
        state_nodes = state_nodes,
        edges = edges,
        verbose = false,
    )
end


"""
    premade_JGET(params_list, starting_state_list)

The JGET model. It has a single continuous input node u, with a value parent x1, and a volatility parent x3. x1 has volatility parent x2, and x3 has a volatility parent x4.
"""
function premade_JGET(config::Dict; verbose::Bool = true)

    #Defaults
    spec_defaults = Dict(
        ("u", "evolution_rate") => 0.0,
        ("x1", "evolution_rate") => -12.0,
        ("x2", "evolution_rate") => -2.0,
        ("x3", "evolution_rate") => -2.0,
        ("x4", "evolution_rate") => -2.0,
        ("u", "x1", "value_coupling") => 1.0,
        ("u", "x3", "volatility_coupling") => 1.0,
        ("x1", "x2", "volatility_coupling") => 1.0,
        ("x3", "x4", "volatility_coupling") => 1.0,
        ("x1", "initial_mean") => 1.0,
        ("x1", "initial_precision") => Inf,
        ("x2", "initial_mean") => 1.0,
        ("x2", "initial_precision") => Inf,
        ("x3", "initial_mean") => 1.04,
        ("x3", "initial_precision") => Inf,
        ("x4", "initial_mean") => 1.0,
        ("x4", "initial_precision") => Inf,
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
        "evolution_rate" => config[("u", "evolution_rate")],
    )

    #List of state nodes to create
    state_nodes = [
        Dict(
            "name" => "x1",
            "type" => "continuous",
            "evolution_rate" => config[("x1", "evolution_rate")],
            "initial_mean" => config[("x1", "initial_mean")],
            "initial_precision" => config[("x1", "initial_precision")],
        ),
        Dict(
            "name" => "x2",
            "type" => "continuous",
            "evolution_rate" => config[("x2", "evolution_rate")],
            "initial_mean" => config[("x2", "initial_mean")],
            "initial_precision" => config[("x2", "initial_precision")],
        ),
        Dict(
            "name" => "x3",
            "type" => "continuous",
            "evolution_rate" => config[("x3", "evolution_rate")],
            "initial_mean" => config[("x3", "initial_precision")],
            "initial_precision" => config[("x3", "initial_precision")],
        ),
        Dict(
            "name" => "x4",
            "type" => "continuous",
            "evolution_rate" => config[("x4", "evolution_rate")],
            "initial_mean" => config[("x4", "initial_mean")],
            "initial_precision" => config[("x4", "initial_precision")],
        ),
    ]

    #List of child-parent relations
    edges = [
        Dict(
            "child" => "u",
            "value_parents" => ("x1", config[("u", "x1", "value_coupling")]),
            "volatility_parents" => ("x3", config[("u", "x3", "volatility_coupling")]),
        ),
        Dict(
            "child" => "x1",
            "volatility_parents" => ("x2", config[("x1", "x2", "volatility_coupling")]),
        ),
        Dict(
            "child" => "x3",
            "volatility_parents" => ("x4", config[("x3", "x4", "volatility_coupling")]),
        ),
    ]

    #Initialize the HGF
    init_hgf(
        input_nodes = input_nodes,
        state_nodes = state_nodes,
        edges = edges,
        verbose = false,
    )
end


"""
    premade_binary_2level(params_list, starting_state_list)

The standard binary 2 level HGF model
"""
function premade_binary_2level(config::Dict; verbose::Bool = true)

    #Defaults
    spec_defaults = Dict(
        ("u", "category_means") => [0.0, 1.0],
        ("u", "input_precision") => Inf,
        ("x2", "evolution_rate") => -2.0,
        ("x1", "x2", "value_coupling") => 1.0,
        ("x2", "initial_mean") => 0.0,
        ("x2", "initial_precision") => 1.0,
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
        Dict("name" => "x1", "type" => "binary"),
        Dict(
            "name" => "x2",
            "type" => "continuous",
            "evolution_rate" => config[("x2", "evolution_rate")],
            "initial_mean" => config[("x2", "initial_mean")],
            "initial_precision" => config[("x2", "initial_precision")],
        ),
    ]

    #List of child-parent relations
    edges = [
        Dict(
            "child" => "u",
            "value_parents" => "x1",
        ),
        Dict(
            "child" => "x1",
            "value_parents" => ("x2", config[("x1", "x2", "value_coupling")]),
        ),
    ]

    #Initialize the HGF
    init_hgf(
        input_nodes = input_nodes,
        state_nodes = state_nodes,
        edges = edges,
        verbose = false,
    )
end


"""
    premade_binary_3level(params_list, starting_state_list)

The standard binary 3 level HGF model
"""
function premade_binary_3level(config::Dict; verbose::Bool = true)

    #Defaults
    defaults = Dict(
        ("u", "category_means") => [0.0, 1.0],
        ("u", "input_precision") => Inf,
        ("x2", "evolution_rate") => -2.5,
        ("x3", "evolution_rate") => -6.0,
        ("x1", "x2", "value_coupling") => 1.0,
        ("x2", "x3", "volatility_coupling") => 1.0,
        ("x2", "initial_mean") => 0.0,
        ("x2", "initial_precision") => 1.0,
        ("x3", "initial_mean") => 1.0,
        ("x3", "initial_precision") => 1.0,
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
        Dict("name" => "x1", "type" => "binary"),
        Dict(
            "name" => "x2",
            "type" => "continuous",
            "evolution_rate" => config[("x2", "evolution_rate")],
            "initial_mean" => config[("x2", "initial_mean")],
            "initial_precision" => config[("x2", "initial_precision")],
        ),
        Dict(
            "name" => "x3",
            "type" => "continuous",
            "evolution_rate" => config[("x3", "evolution_rate")],
            "initial_mean" => config[("x3", "initial_mean")],
            "initial_precision" => config[("x3", "initial_precision")],
        ),
    ]

    #List of child-parent relations
    edges = [
        Dict(
            "child" => "u",
            "value_parents" => "x1",
        ),
        Dict(
            "child" => "x1",
            "value_parents" => ("x2", config[("x1", "x2", "value_coupling")]),
        ),
        Dict(
            "child" => "x2",
            "volatility_parents" => ("x3", config[("x2", "x3", "volatility_coupling")]),
        ),
    ]

    #Initialize the HGF
    init_hgf(
        input_nodes = input_nodes,
        state_nodes = state_nodes,
        edges = edges,
        verbose = false,
    )
end

