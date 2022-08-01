```@meta
EditURL = "<unknown>/tutorials/benchmarking.jl"
```

using HGF

function big_hgf(N)

    node_defaults = (
        params = (; evolution_rate = 3),
        starting_state = (; posterior_precision = 1),
        coupling_strengths = (; value_coupling_strength = 1),
    )

    input_nodes = ["u"]
    state_nodes = []

    for i = 1:N
        push!(state_nodes, "x_" * string(i))
        push!(state_nodes, "v_" * string(i))
    end

    edges = Any[(child_node = "u", value_parents = "x_1")]

    for i = 1:N-1
        rel = (
            child_node = "x_" * string(i),
            value_parents = "x_" * string(i + 1),
            volatility_parents = "v_" * string(i),
        )
        push!(edges, rel)
    end

    lastrel = (child_node = "x_" * string(N), volatility_parents = "v_" * string(N))

    push!(edges, lastrel)

    big_hgf = HGF.init_hgf(node_defaults, input_nodes, state_nodes, edges)
    return big_hgf
end

@time monster_hgf = big_hgf(100);

input = rand(10000)
HGF.reset!(monster_hgf)
@time HGF.give_inputs!(monster_hgf, input)

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

