using HGF
using Test
using CSV
using DataFrames
include("test_canonical_helper.jl")
input=Float64[]
open("forward_model//canonical_test//data//canonical_input_trajectory.dat") do f
    for ln in eachline(f)
        push!(input,parse(Float64, ln))
    end
end
input[1]
length(input)
params_list =
    (; u_evolution_rate = log(1e-4), x1_evolution_rate = -13.0, x2_evolution_rate=-2.0, x1_x2_coupling_strength = 1)
starting_state_list =
    (; x1_posterior_mean = 1.04, x1_posterior_precision = 1e4, x2_posterior_mean = 1.0, x2_posterior_precision=10,)

my_hgf = HGF.premade_hgf("continuous_2level", params_list, starting_state_list);
benchmark=CSV.read("forward_model//canonical_test//data//canonical_python_trajectory.csv", DataFrame)
#benchmark[!,"X1_mean"]
benchmark_testing(my_hgf,input,benchmark,"x1_mean",10)
my_hgf = HGF.premade_hgf("continuous_2level", params_list, starting_state_list);
benchmark_printing(my_hgf,input,benchmark, "x1_mean",10)
my_hgf = HGF.premade_hgf("continuous_2level", params_list, starting_state_list);
features = ["x1_mean","x1_precision", "x2_mean","x2_precision"]
benchmark_testing_all(my_hgf,input,benchmark, features, 10)