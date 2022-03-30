using HGF
using DataFrames
function benchmark_testing(HGF_struct::HGF.HGFStruct,input::Vector{Float64},benchmark::DataFrame#=,features::Array{String}=#)
    for i in range(1, length(input))
        test = HGF_struct.state_nodes["x1"].state.posterior_mean == benchmark[!,"X1_mean"][i]
        HGF.update_HGF(HGF_struct, input[i])
        if !test
            return i
        end
    end
    return "success!!!"
end

function benchmark_printing(HGF_struct::HGF.HGFStruct,input::Vector{Float64},benchmark::DataFrame#=,features::Array{String}=#)
    failed_tests=[]
    for i in range(1, length(input))
        test = HGF_struct.state_nodes["x1"].state.posterior_mean == benchmark[!,"X1_mean"][i]
        HGF.update_HGF(HGF_struct, input[i])
        if !test
            push!(failed_tests,(HGF_struct.state_nodes["x1"].state.posterior_mean,benchmark[!,"X1_mean"][i]))
        end
    end
    return failed_tests
end