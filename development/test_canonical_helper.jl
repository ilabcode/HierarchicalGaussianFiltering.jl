# using HGF
# using DataFrames

# # Testing function: print all the values different from the target value for a selected feature

# function canonical_test_print_error(
#     HGF_struct::HGF.HGFStruct,
#     input::Vector{Float64},
#     target::DataFrame,
#     feature::String,
#     rounding::Int,
# )
#     feat = split(feature, "_")
#     sym = Symbol("posterior_" * feat[2])
#     failed_tests = []
#     for i in range(1, length(input))
#         test =
#             round(
#                 getproperty(HGF_struct.state_nodes[feat[1]].state, sym),
#                 digits = rounding,
#             ) == round(target[!, feature][i], digits = rounding)
#         if !test
#             push!(
#                 failed_tests,
#                 (
#                     getproperty(HGF_struct.state_nodes[feat[1]].state, sym),
#                     target[!, feature][i],
#                 ),
#             )
#         end
#         HGF.update_hgf!(HGF_struct, input[i])
#     end
#     return failed_tests
# end

# # Testing function: print the index of the first value different from the target value for a selected feature

# function canonical_test_index(
#     HGF_struct::HGF.HGFStruct,
#     input::Vector{Float64},
#     target::DataFrame,
#     feature::String,
#     rounding::Int,
# )
#     feat = split(feature, "_")
#     sym = Symbol("posterior_" * feat[2])
#     for i in range(1, length(input))
#         test =
#             round(
#                 getproperty(HGF_struct.state_nodes[feat[1]].state, sym),
#                 digits = rounding,
#             ) == round(target[!, feature][i], digits = rounding)
#         HGF.update_hgf!(HGF_struct, input[i])
#         if !test
#             return i
#         end
#     end
#     return "success!!!"
# end

# # Testing function: gives the number of failed test against a target dataframe for the selected features

# function canonical_test(
#     HGF_struct::HGF.HGFStruct,
#     input::Vector{Float64},
#     target::DataFrame,
#     features::Vector{String},
#     rounding::Int,
# )
#     failed_tests = Dict()
#     for feature in features
#         failed_tests[feature] = []
#     end
#     for i in range(1, length(input))
#         for feature in features
#             feat = split(feature, "_")
#             test =
#                 round(
#                     getproperty(
#                         HGF_struct.state_nodes[feat[1]].state,
#                         Symbol("posterior_" * feat[2]),
#                     ),
#                     digits = rounding,
#                 ) == round(target[!, feature][i], digits = rounding)
#             if !test
#                 push!(
#                     failed_tests[feature],
#                     (
#                         getproperty(
#                             HGF_struct.state_nodes[feat[1]].state,
#                             Symbol("posterior_" * feat[2]),
#                         ),
#                         target[!, feature][i],
#                     ),
#                 )
#             end
#         end
#         HGF.update_hgf!(HGF_struct, input[i])
#     end
#     for feature in features
#         if length(failed_tests[feature]) == 0
#             println(feature, ": Test passed")
#         else
#             println(feature, ": ", length(failed_tests[feature]), " tests failed")
#         end
#     end
# end


# # ### Run tests ###
# # #checking for first wrong value in a feature
# # canonical_test_index(test_hgf, input, target, "x1_mean", 7)

# # #resetting the hgf and printing all the failed comparisons
# # my_hgf = HGF.premade_hgf("continuous_2level", params_list, starting_state_list);
# # canonical_test_print_error(my_hgf, input_trajectory, target, "x1_mean", 7)

# # #resetting the hgf and testing all the properties in features
# # my_hgf = HGF.premade_hgf("continuous_2level", params_list, starting_state_list);
# # features = ["x1_mean", "x1_precision", "x2_mean", "x2_precision"]
# # canonical_test(my_hgf, input, target, features, 7)