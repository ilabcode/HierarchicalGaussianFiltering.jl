"""
    premade_continuous_2level(params_list, starting_state_list)

The standard 2 level HGF. It has a continous input node U, with a single value parent x1, which in turn has a single volatility parent x2.
"""
function premade_continuous_2level(specs::Dict; verbose::Bool = true)

    #Defaults
    defaults = Dict(
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
        warn_premade_defaults(defaults, specs)
    end

    #Merge to overwrite defaults
    specs = merge(defaults, specs)


    #Parameter values to be used for all nodes unless other values are given
    node_defaults = (;)

    #List of input nodes to create
    input_nodes = [(name = "u", params = (; evolution_rate = specs[("u", "evolution_rate")]))]

    #List of state nodes to create
    state_nodes = [
        (
            name = "x1",
            params = (;
                evolution_rate = specs[("x1", "evolution_rate")],
                initial_mean = specs[("x1", "initial_mean")],
                initial_precision = specs[("x1", "initial_precision")],
            ),
        ),
        (
            name = "x2",
            params = (;
                evolution_rate = specs[("x2", "evolution_rate")],
                initial_mean = specs[("x2", "initial_mean")],
                initial_precision = specs[("x2", "initial_precision")],
            ),
        ),
    ]

    #List of child-parent relations
    edges = [
        (
            child_node = "u",
            value_parents = [(
                name = "x1",
                value_coupling = specs[("u", "x1", "value_coupling")],
            )],
            volatility_parents = Dict(),
        ),
        (
            child_node = "x1",
            value_parents = Dict(),
            volatility_parents = [(
                name = "x2",
                volatility_coupling = specs[("x1", "x2", "volatility_coupling")],
            )],
        ),
    ]

    #Initialize the HGF
    HGF.init_hgf(node_defaults, input_nodes, state_nodes, edges, verbose = false)
end


"""
    premade_JGET(params_list, starting_state_list)

The JGET model. It has a single continuous input node u, with a value parent x1, and a volatility parent x3. x1 has volatility parent x2, and x3 has a volatility parent x4.
"""
function premade_JGET(specs::Dict; verbose::Bool = true)

    #Defaults
    defaults = Dict(
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
        warn_premade_defaults(defaults, specs)
    end

    #Merge to overwrite defaults
    specs = merge(defaults, specs)


    #Parameter values to be used for all nodes unless other values are given
    node_defaults = (;)

    #List of input nodes to create
    input_nodes = [(name = "u", params = (; evolution_rate = specs[("u", "evolution_rate")]))]

    #List of state nodes to create
    state_nodes = [
        (
            name = "x1",
            params = (;
                evolution_rate = specs[("x1", "evolution_rate")],
                initial_mean = specs[("x1", "initial_mean")],
                initial_precision = specs[("x1", "initial_precision")],
            ),
        ),
        (
            name = "x2",
            params = (;
                evolution_rate = specs[("x2", "evolution_rate")],
                initial_mean = specs[("x2", "initial_mean")],
                initial_precision = specs[("x2", "initial_precision")],
            ),
        ),
        (
            name = "x3",
            params = (;
                evolution_rate = specs[("x3", "evolution_rate")],
                initial_mean = specs[("x3", "initial_precision")],
                initial_precision = specs[("x3", "initial_precision")],
            ),
        ),
        (
            name = "x4",
            params = (;
                evolution_rate = specs[("x4", "evolution_rate")],
                initial_mean = specs[("x4", "initial_mean")],
                initial_precision = specs[("x4", "initial_precision")],
            ),
        ),
    ]

    #List of child-parent relations
    edges = [
        (
            child_node = "u",
            value_parents = [(
                name = "x1",
                value_coupling = specs[("u", "x1", "value_coupling")],
            )],
            volatility_parents = [(
                name = "x3",
                volatility_coupling = specs[("u", "x3", "volatility_coupling")],
            )],
        ),
        (
            child_node = "x1",
            volatility_parents = [(
                name = "x2",
                volatility_coupling = specs[("x1", "x2", "volatility_coupling")],
            )],
        ),
        (
            child_node = "x3",
            volatility_parents = [(
                name = "x4",
                volatility_coupling = specs[("x3", "x4", "volatility_coupling")],
            )],
        ),
    ]

    #Initialize the HGF
    HGF.init_hgf(node_defaults, input_nodes, state_nodes, edges, verbose = false)
end


"""
    premade_binary_2level(params_list, starting_state_list)

The standard binary 2 level HGF model
"""
function premade_binary_2level(specs::Dict; verbose::Bool = true)

    #Defaults
    defaults = Dict(
        ("u", "category_means") => [0.0, 1.0],
        ("u", "input_precision") => Inf,
        ("x2", "evolution_rate") => -2.0,
        ("u", "x1", "value_coupling") => 1.0,
        ("x1", "x2", "value_coupling") => 1.0,
        ("x2", "initial_mean") => 0.0,
        ("x2", "initial_precision") => 1.0,
    )

    #Warn the user about used defaults and misspecified keys
    if verbose
        warn_premade_defaults(defaults, specs)
    end

    #Merge to overwrite defaults
    specs = merge(defaults, specs)


    #No node defaults
    node_defaults = (;)

    #List of input nodes to create
    input_nodes = [(
        name = "u",
        type = "binary",
        params = (;
            category_means = specs[("u", "category_means")],
            input_precision = specs[("u", "input_precision")],
        ),
    )]

    #List of state nodes to create
    state_nodes = [
        (name = "x1", type = "binary", params = (;)),
        (
            name = "x2",
            type = "continuous",
            params = (;
                evolution_rate = specs[("x2", "evolution_rate")],
                initial_mean = specs[("x2", "initial_mean")],
                initial_precision = specs[("x2", "initial_precision")],
            ),
        ),
    ]

    #List of child-parent relations
    edges = [
        (
            child_node = "u",
            value_parents = [(
                name = "x1",
                value_coupling = specs[("u", "x1", "value_coupling")],
            )],
            volatility_parents = Dict(),
        ),
        (
            child_node = "x1",
            value_parents = [(
                name = "x2",
                value_coupling = specs[("x1", "x2", "value_coupling")],
            )],
            volatility_parents = Dict(),
        ),
    ]

    #Initialize the HGF
    HGF.init_hgf(node_defaults, input_nodes, state_nodes, edges, verbose = false)
end


"""
    premade_binary_3level(params_list, starting_state_list)

The standard binary 3 level HGF model
"""
function premade_binary_3level(specs::Dict; verbose::Bool = true)

    #Defaults
    defaults = Dict(
        ("u", "category_means") => [0.0, 1.0],
        ("u", "input_precision") => Inf,
        ("x2", "evolution_rate") => -2.5,
        ("x3", "evolution_rate") => -6.0,
        ("u", "x1", "value_coupling") => 1.0,
        ("x1", "x2", "value_coupling") => 1.0,
        ("x2", "x3", "volatility_coupling") => 1.0,
        ("x2", "initial_mean") => 0.0,
        ("x2", "initial_precision") => 1.0,
        ("x3", "initial_mean") => 1.0,
        ("x3", "initial_precision") => 1.0,
    )

    #Warn the user about used defaults and misspecified keys
    if verbose
        warn_premade_defaults(defaults, specs)
    end

    #Merge to overwrite defaults
    specs = merge(defaults, specs)


    #Parameter values to be used for all nodes unless other values are given
    node_defaults = (;)

    #List of input nodes to create
    input_nodes = [(
        name = "u",
        type = "binary",
        params = (;
            category_means = specs[("u", "category_means")],
            input_precision = specs[("u", "input_precision")],
        ),
    )]

    #List of state nodes to create
    state_nodes = [
        (name = "x1", type = "binary", params = (;)),
        (
            name = "x2",
            type = "continuous",
            params = (;
                evolution_rate = specs[("x2", "evolution_rate")],
                initial_mean = specs[("x2", "initial_mean")],
                initial_precision = specs[("x2", "initial_precision")],
            ),
        ),
        (
            name = "x3",
            type = "continuous",
            params = (;
                evolution_rate = specs[("x3", "evolution_rate")],
                initial_mean = specs[("x3", "initial_mean")],
                initial_precision = specs[("x3", "initial_precision")],
            ),
        ),
    ]

    #List of child-parent relations
    edges = [
        (
            child_node = "u",
            value_parents = [(
                name = "x1",
                value_coupling = specs[("u", "x1", "value_coupling")],
            )],
            volatility_parents = Dict(),
        ),
        (
            child_node = "x1",
            value_parents = [(
                name = "x2",
                value_coupling = specs[("x1", "x2", "value_coupling")],
            )],
            volatility_parents = Dict(),
        ),
        (
            child_node = "x2",
            value_parents = Dict(),
            volatility_parents = [(
                name = "x3",
                volatility_coupling = specs[("x2", "x3", "volatility_coupling")],
            )],
        ),
    ]

    #Initialize the HGF
    HGF.init_hgf(node_defaults, input_nodes, state_nodes, edges, verbose = false)
end

