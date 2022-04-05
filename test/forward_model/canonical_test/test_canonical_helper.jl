

function benchmark_testing(HGF_struct::HGF.HGFStruct,input::Vector{Float64},benchmark::DataFrame#=,features::Array{String}=#)
    for i in range(1, length(input))
        test = round(HGF_struct.state_nodes["x1"].state.posterior_mean,digits=3) == round(benchmark[!,"x1_mean"][i],digits=3)
        HGF.update_HGF!(HGF_struct, input[i])
        if !test
            return i
        end
    end
    return "success!!!"
end

function benchmark_printing(HGF_struct::HGF.HGFStruct,input::Vector{Float64},benchmark::DataFrame#=,features::Array{String}=#)
    failed_tests=[]
    for i in range(1, length(input))
        test = round(HGF_struct.state_nodes["x1"].state.posterior_precision,digits=9) == round(benchmark[!,"x1_precision"][i],digits=9)
        if !test
            push!(failed_tests,(HGF_struct.state_nodes["x1"].state.posterior_precision,benchmark[!,"x1_precision"][i]))
        end
        HGF.update_HGF!(HGF_struct, input[i])
    end
    return failed_tests
end

# function benchmark_testing(HGF_struct::HGF.HGFStruct,input::Vector{Float64},benchmark::DataFrame,feature::String)    
#     for i in range(1, length(input))
#         test = round(getproperty(HGF_struct.state_nodes[SubString(feature,1:2)].state,:"posterior"*SubString(feature,2)),digits=3) == round(benchmark[!,feature][i],digits=3)
#         HGF.update_HGF(HGF_struct, input[i])
#         if !test
#             return i
#         end
#     end
#     return "success!!!"
# end

function benchmark_testing_all(HGF_struct::HGF.HGFStruct,input::Vector{Float64},benchmark::DataFrame, rounding#=,features::Array{String}=#)
    failed_tests=[[],[],[],[]]
    for i in range(1, length(input))
        test = round(HGF_struct.state_nodes["x1"].state.posterior_mean,digits=rounding) == round(benchmark[!,"x1_mean"][i],digits=rounding)
        if !test
            push!(failed_tests[1],(HGF_struct.state_nodes["x1"].state.posterior_mean,benchmark[!,"x1_mean"][i]))
        end
        test = round(HGF_struct.state_nodes["x1"].state.posterior_precision,digits=rounding) == round(benchmark[!,"x1_precision"][i],digits=rounding)
        if !test
            push!(failed_tests[2],(HGF_struct.state_nodes["x1"].state.posterior_precision,benchmark[!,"x1_precision"][i]))
        end
        test = round(HGF_struct.state_nodes["x2"].state.posterior_mean,digits=rounding) == round(benchmark[!,"x2_mean"][i],digits=rounding)
        if !test
            push!(failed_tests[3],(HGF_struct.state_nodes["x2"].state.posterior_mean,benchmark[!,"x2_mean"][i]))
        end
        test = round(HGF_struct.state_nodes["x2"].state.posterior_precision,digits=rounding) == round(benchmark[!,"x2_precision"][i],digits=rounding)
        if !test
            push!(failed_tests[4],(HGF_struct.state_nodes["x2"].state.posterior_precision,benchmark[!,"x2_precision"][i]))
        end
        HGF.update_HGF(HGF_struct, input[i])
    end
    results=[]
    for i in failed_tests
        if length(i)==0
            push!(results,"Passed!")
        else 
            push!(results, string(length(i))*" failed tests")
        end
    end
    print("x1 mean: ",results[1],"\n","x1 precision: ",results[2],"\n","x2 mean: ",results[3],"\n","x2 precision: ",results[4])
end