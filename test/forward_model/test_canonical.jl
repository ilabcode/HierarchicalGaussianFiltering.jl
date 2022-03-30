using HGF
using Test
using CSV
using DataFrames
input=Float64[]
open("data\\usdchf.dat") do f
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

my_hgf = HGF.premade_HGF("continuous_2level", params_list, starting_state_list);
benchmark=CSV.read("data\\stdhgf.csv", DataFrame)
#benchmark[!,"X1_mean"]
benchmark_testing(my_hgf,input,benchmark)
my_hgf = HGF.premade_HGF("continuous_2level", params_list, starting_state_list);
benchmark_printing(my_hgf,input,benchmark)