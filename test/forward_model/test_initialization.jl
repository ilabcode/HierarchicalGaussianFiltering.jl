using HGF
using Test

@testset "Initialization" begin
    #Parameter values to be used for all nodes unless other values are given
    default_params = (
        params = (; evolution_rate = 3),
        starting_state = (;
            posterior_mean = 1,
            posterior_precision = 1,
        ),
    )

    #List of input nodes to create
    input_nodes = [(
        name = "x_in1",
        params = (; evolution_rate = 2),
    )]

    #List of state nodes to create
    state_nodes = [
        (name = "x_1", params = (; evolution_rate = 2), starting_state = (;)),
        (name = "x_2", params = (; evolution_rate = 2), starting_state = (;)),
        (name = "x_3", params = (; evolution_rate = 2), starting_state = (;)),
        (name = "x_4", params = (; evolution_rate = 2), starting_state = (;)),
        (
            name = "x_5",
            params = (; evolution_rate = 2),
            starting_state = (;
                posterior_mean = 1,
                posterior_precision = 1
            ),
        ),
    ]

    #List of child-parent relations
    child_parent_relations = [
        (
            child_node = "x_in1",
            value_parents = Dict("x_1" => 2),
            volatility_parents = Dict("x_2" => 2),
        ),
        (
            child_node = "x_1",
            value_parents = Dict("x_3" => 2),
            volatility_parents = Dict("x_4" => 2, "x_5" => 2),
        ),
    ]

    #Update order. Only required if update order is ambiguous
    update_order = false

    #Initialize an HGF
    HGF_test1 = HGF.init_HGF(
        default_params,
        input_nodes,
        state_nodes,
        child_parent_relations,
        update_order,
    )

    @testset "Check if output matches input" begin 
        @test HGF_test1.state_nodes["x_1"].params.evolution_rate == 2
    end
end
