"""
    premade_continuous_2level(params_list, starting_state_list)

The standard 2 level HGF. It has a continous input node U, with a single value parent x1, which in turn has a single volatility parent x2.
"""
function premade_continuous_2level(config::Dict; verbose::Bool = true)

    #Defaults
    spec_defaults = Dict(
        ("u", "evolution_rate") => 0,
        ("x1", "evolution_rate") => 0,
        ("x2", "evolution_rate") => 0,
        ("u", "x1", "value_coupling") => 1,
        ("x1", "x2", "volatility_coupling") => 1,
        ("x1", "initial_mean") => 0,
        ("x1", "initial_precision") => 1,
        ("x2", "initial_mean") => 0,
        ("x2", "initial_precision") => 1,
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
        ("u", "evolution_rate") => 0,
        ("x1", "evolution_rate") => 0,
        ("x2", "evolution_rate") => 0,
        ("x3", "evolution_rate") => 0,
        ("x4", "evolution_rate") => 0,
        ("u", "x1", "value_coupling") => 1,
        ("u", "x3", "volatility_coupling") => 1,
        ("x1", "x2", "volatility_coupling") => 1,
        ("x3", "x4", "volatility_coupling") => 1,
        ("x1", "initial_mean") => 0,
        ("x1", "initial_precision") => 1,
        ("x2", "initial_mean") => 0,
        ("x2", "initial_precision") => 1,
        ("x3", "initial_mean") => 0,
        ("x3", "initial_precision") => 1,
        ("x4", "initial_mean") => 0,
        ("x4", "initial_precision") => 1,
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
        ("u", "category_means") => [0, 1],
        ("u", "input_precision") => Inf,
        ("x2", "evolution_rate") => 0,
        ("x1", "x2", "value_coupling") => 1,
        ("x2", "initial_mean") => 0,
        ("x2", "initial_precision") => 1,
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
        Dict("child" => "u", "value_parents" => "x1"),
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
        ("u", "category_means") => [0, 1],
        ("u", "input_precision") => Inf,
        ("x2", "evolution_rate") => 0,
        ("x3", "evolution_rate") => 0,
        ("x1", "x2", "value_coupling") => 1,
        ("x2", "x3", "volatility_coupling") => 1,
        ("x2", "initial_mean") => 0,
        ("x2", "initial_precision") => 1,
        ("x3", "initial_mean") => 0,
        ("x3", "initial_precision") => 1,
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
        Dict("child" => "u", "value_parents" => "x1"),
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

function premade_categorical_3level(config::Dict; verbose::Bool = true)

    #Defaults
    defaults = Dict(
        "n_categories" => 4,
        ("x2", "evolution_rate") => 0,
        ("x2", "initial_mean") => 0,
        ("x2", "initial_precision") => 1,
        ("x3", "evolution_rate") => 0,
        ("x3", "initial_mean") => 0,
        ("x3", "initial_precision") => 1,
        ("x1", "x2", "value_coupling") => 1,
        ("x2", "x3", "volatility_coupling") => 1,
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
    #Populate the above vectors with node names
    for category_number = 1:config["n_categories"]
        push!(category_binary_parent_names, "x1_" * string(category_number))
        push!(binary_continuous_parent_names, "x2_" * string(category_number))
    end


    ##List of input nodes
    input_nodes = Dict("name" => "u", "type" => "categorical")

    ##List of state nodes
    state_nodes = [Dict{String,Any}("name" => "x1", "type" => "categorical")]

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
                "evolution_rate" => config[("x2", "evolution_rate")],
                "initial_mean" => config[("x2", "initial_mean")],
                "initial_precision" => config[("x2", "initial_precision")],
            ),
        )
    end

    #Add volatility parent
    push!(
        state_nodes,
        Dict(
            "name" => "x3",
            "type" => "continuous",
            "evolution_rate" => config[("x3", "evolution_rate")],
            "initial_mean" => config[("x3", "initial_mean")],
            "initial_precision" => config[("x3", "initial_precision")],
        ),
    )


    ##List of child-parent relations
    edges = [
        Dict("child" => "u", "value_parents" => "x1"),
        Dict("child" => "x1", "value_parents" => category_binary_parent_names),
    ]

    #Add relations between binary nodes and their parents
    for (child_name, parent_name) in
        zip(category_binary_parent_names, binary_continuous_parent_names)
        push!(
            edges,
            Dict(
                "child" => child_name,
                "value_parents" => (parent_name, config[("x1", "x2", "value_coupling")]),
            ),
        )
    end

    #Add relations between binary node parents and the volatility parent
    for child_name in binary_continuous_parent_names
        push!(
            edges,
            Dict(
                "child" => child_name,
                "volatility_parents" => ("x3", config[("x2", "x3", "volatility_coupling")]),
            ),
        )
    end

    #Initialize the HGF
    init_hgf(
        input_nodes = input_nodes,
        state_nodes = state_nodes,
        edges = edges,
        verbose = false,
    )
end

function premade_categorical_3level_state_transitions(config::Dict; verbose::Bool = true)

    #Defaults
    defaults = Dict(
        "n_categories" => 4,
        ("x2", "evolution_rate") => 0,
        ("x2", "initial_mean") => 0,
        ("x2", "initial_precision") => 1,
        ("x3", "evolution_rate") => 0,
        ("x3", "initial_mean") => 0,
        ("x3", "initial_precision") => 1,
        ("x1", "x2", "value_coupling") => 1,
        ("x2", "x3", "volatility_coupling") => 1,
    )

    #Warn the user about used defaults and misspecified keys
    if verbose
        warn_premade_defaults(defaults, config)
    end

    #Merge to overwrite defaults
    config = merge(defaults, config)


    ##Prepare node names
    #Empty lists
    categorical_input_node_names = Vector{String}()
    categorical_state_node_names = Vector{String}()
    categorical_node_binary_parent_names = Vector{String}()
    binary_node_continuous_parent_names = Vector{String}()

    #Go through each category that the transition may have been from
    for category_from = 1:config["n_categories"]
        #One input node and its state node parent for each                             
        push!(categorical_input_node_names, "u" * string(category_from))
        push!(categorical_state_node_names, "x1_" * string(category_from))
        #Go through each category that the transition may have been to
        for category_to = 1:config["n_categories"]
            #Each categorical state node has a binary parent for each
            push!(
                categorical_node_binary_parent_names,
                "x1_" * string(category_from) * "_" * string(category_to),
            )
            #And each binary parent has a continuous parent of its own
            push!(
                binary_node_continuous_parent_names,
                "x2_" * string(category_from) * "_" * string(category_to),
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
                "evolution_rate" => config[("x2", "evolution_rate")],
                "initial_mean" => config[("x2", "initial_mean")],
                "initial_precision" => config[("x2", "initial_precision")],
            ),
        )
    end

    #Add the shared volatility parent of the continuous nodes
    push!(
        state_nodes,
        Dict(
            "name" => "x3",
            "type" => "continuous",
            "evolution_rate" => config[("x3", "evolution_rate")],
            "initial_mean" => config[("x3", "initial_mean")],
            "initial_precision" => config[("x3", "initial_precision")],
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
                "value_parents" => (parent_name, config[("x1", "x2", "value_coupling")]),
            ),
        )
    end

    #Add the shared continuous node volatility parent to the continuous nodes
    for child_name in binary_node_continuous_parent_names
        push!(
            edges,
            Dict(
                "child" => child_name,
                "volatility_parents" => ("x3", config[("x2", "x3", "volatility_coupling")]),
            ),
        )
    end

    #Initialize the HGF
    init_hgf(
        input_nodes = input_nodes,
        state_nodes = state_nodes,
        edges = edges,
        verbose = false,
    )
end
