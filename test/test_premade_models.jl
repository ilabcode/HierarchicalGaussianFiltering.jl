using HGF
using Test

@testset "Premade_models" begin
    # @testset "Errors and utilities" begin

    #     #When the string is misspecified
    #     # HGF_test = HGF.premade_HGF("Typo")
    #     # @test HGF_test == "error"

    #     #When asking for help
    #     # HGF_test = HGF.premade_HGF("help")
    #     # @test HGF_test[3] == "JGET"
    # end

    @testset "Standard 2 level HGF" begin
        #Setup
        params_list = (; u_evolution_rate = 2, x1_evolution_rate = 2, x1_x2_coupling_strength = 2)
        starting_state_list =
            (; x1_posterior_mean = 1, x1_posterior_precision = 1)

        #Call from superfunction
        HGF_test = HGF.premade_HGF("continuous_2level", params_list, starting_state_list)
        @test HGF_test.state_nodes["x1"].params.evolution_rate == 2

        HGF_test = HGF.premade_HGF("continuous_2level")
        @test HGF_test.state_nodes["x1"].params.evolution_rate == -12.0

        #Call directly
        #Outdated
        # HGF_test = HGF.standard_function_2level(params_list, starting_state_list)
        # @test HGF_test.state_nodes["x_1"].params.evolution_rate == 2
    end

#     @testset "Standard 2 level HGF bis" begin
#         #Setup
#         params_list = (;
#             evolution_rate_u = 0.0,
#             evolution_rate_1 = -2.0,
#             coupling_u_1 = 2,
#             evolution_rate_2 = -12.0,
#             coupling_1_2 = 2,
#         )
#         starting_state_list = (;
#             starting_state_1 = (; posterior_mean = 1.04, posterior_precision = Inf), #check if this infinity will work
#             starting_state_2 = (; posterior_mean = 1.0, posterior_precision = Inf),
#         )

#         #Call from superfunction
#         HGF_test = HGF.premade_HGF("2level", params_list, starting_state_list)
#         @test HGF_test.state_nodes["x_1"].params.evolution_rate == params_list.evolution_rate_1

#         #Call directly
#         HGF_test = HGF.standard_2level(params_list, starting_state_list)
#         @test HGF_test.state_nodes["x_2"].params.evolution_rate == params_list.evolution_rate_2
#     end

    
#     @testset "Standard 3 level HGF" begin
#         #Setup
#         params_list = (;
#             evolution_rate_u = 2,
#             evolution_rate_1 = 2,
#             coupling_u_1 = 2,
#             evolution_rate_2 = 2,
#             coupling_u_2 = 2,
#         )
#         starting_state_list = (;
#             starting_state_1 = (; posterior_mean = 1, posterior_precision = 1),
#             starting_state_2 = (; posterior_mean = 1, posterior_precision = 1),
#         )

#         #Call from superfunction
#         HGF_test = HGF.premade_HGF("Standard3level", params_list, starting_state_list)
#         @test HGF_test.state_nodes["x_2"].params.evolution_rate == 2

#         #Call directly
#         HGF_test = HGF.standard_function_3level(params_list, starting_state_list)
#         @test HGF_test.state_nodes["x_2"].params.evolution_rate == 2
#     end

# end



# using HGF






# function standard_function_2level(
#     evolution_rate_u::AbstractFloat=2.0,
#      evolution_rate_1::AbstractFloat=2.0,
#       coupling_u_1::AbstractFloat=2.0,
#        posterior_mean_1::AbstractFloat=1.0,
#         posterior_precision_1::AbstractFloat=1.0)

#     input_nodes =
#         [(name="x_u", params=(; evolution_rate=evolution_rate_u))]
#     state_nodes = [
#         (
#             name="x_1",
#             params=(; evolution_rate=evolution_rate_1),
#             starting_state=(; posterior_mean=posterior_mean_1, posterior_precision=posterior_precision_1),
#         ),
#     ]
#     child_parent_relations = [
#         (
#             child_node="x_u",
#             value_parents=[("x_1", coupling_u_1)],
#             volatility_parents=[],
#         ),
#     ]
#     default_params = (
#         params=(;),
#         starting_state=(;),
#     )
end


standard_function_2level()


GG = (; evolution_rate_1 = 2)


standard_function_2level(; GG...)