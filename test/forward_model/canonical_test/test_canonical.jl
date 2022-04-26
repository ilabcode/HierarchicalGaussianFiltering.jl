using HGF
using Test
using CSV
using DataFrames

# file including the testing functions
include("test_canonical_helper.jl")
#include("forward_model/canonical_test/test_canonical_helper.jl")

#importing the canonical input data

input = Float64[]
open("forward_model//canonical_test//data//canonical_input_trajectory.dat") do f
    for ln in eachline(f)
        push!(input, parse(Float64, ln))
    end
end

#setting up the hgf

params_list =
    (; u_evolution_rate=log(1e-4), x1_evolution_rate=-13.0, x2_evolution_rate=-2.0, x1_x2_coupling_strength=1)
starting_state_list =
    (; x1_posterior_mean=1.04, x1_posterior_precision=1e4, x2_posterior_mean=1.0, x2_posterior_precision=10)
my_hgf = HGF.premade_hgf("continuous_2level", params_list, starting_state_list);

#importing the target dataframe to compare to

target = CSV.read("forward_model//canonical_test//data//canonical_python_trajectory.csv", DataFrame)


#checking for first wrong value in a feature
canonical_test_index(my_hgf, input, target, "x1_mean", 10)

#resetting the hgf and printing all the failed comparisons
my_hgf = HGF.premade_hgf("continuous_2level", params_list, starting_state_list);
canonical_test_print_error(my_hgf, input, target, "x1_mean", 10)

#resetting the hgf and testing all the properties in features
my_hgf = HGF.premade_hgf("continuous_2level", params_list, starting_state_list);
features = ["x1_mean", "x1_precision", "x2_mean", "x2_precision"]
canonical_test(my_hgf, input, target, features, 10)