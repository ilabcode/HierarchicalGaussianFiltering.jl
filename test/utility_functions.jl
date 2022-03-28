using HGF
#using DataFrames
function benchmark_testing(HGF_struct::HGF.HGFModel,input::Array{AbstractFloat},benchmark#=::DataFrame,features::Array{String}=#)
    for i in range(1, length(input))
        test = HGF_struct.state_nodes["x1"].state.posterior_mean == benchmark[!,"X1_mean"][i]
        HGF.update_HGF(HGF_struct, input[i])
        if !test
            return i
        end
    end
    return "success!!!"
end