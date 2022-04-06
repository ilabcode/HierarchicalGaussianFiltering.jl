#single feature helper test functions
using HGF
using DataFrames

function benchmark_printing(HGF_struct::HGF.HGFStruct,input::Vector{Float64},benchmark::DataFrame,feature::String,rounding::Int)
    feat = split(feature,"_")
    sym = Symbol("posterior_"*feat[2])
    failed_tests=[]
    for i in range(1, length(input))
        test = round(getproperty(HGF_struct.state_nodes[feat[1]].state,sym),digits=rounding) == round(benchmark[!,feature][i],digits=rounding)
        if !test
            push!(failed_tests,(getproperty(HGF_struct.state_nodes[feat[1]].state,sym),benchmark[!,feature][i]))
        end
        HGF.update_HGF(HGF_struct, input[i])
    end
    return failed_tests
end

function benchmark_testing(HGF_struct::HGF.HGFStruct,input::Vector{Float64},benchmark::DataFrame,feature::String,rounding::Int)
    feat = split(feature,"_")
    sym = Symbol("posterior_"*feat[2])    
    for i in range(1, length(input))
        test = round(getproperty(HGF_struct.state_nodes[feat[1]].state,sym),digits=rounding) == round(benchmark[!,feature][i],digits=rounding)
        HGF.update_HGF(HGF_struct, input[i])
        if !test
            return i
        end
    end
    return "success!!!"
end

# not working yet
# function benchmark_testing_all(HGF_struct::HGF.HGFStruct,input::Vector{Float64},benchmark::DataFrame, features::Vector{String},rounding::Int)
#     failed_tests=[]
#     for feature in features
#         push!(failed_tests,benchmark_printing(HGF_struct,input,benchmark,feature,rounding))
#         #need for a reset function
#     end
#     results=[]
#     for test in failed_tests
#         if length(test)==0
#             push!(results,"Passed!")
#         else 
#             push!(results, string(length(test))*" failed tests")
#         end
#     end
#     for i in range(1, length(results))
#         println(features[i],": ",results[i])
#     end
# end

#multi feature test function

function benchmark_printing_all(HGF_struct::HGF.HGFStruct,input::Vector{Float64},benchmark::DataFrame,features::Vector{String},rounding::Int)
    failed_tests=Dict()
    for feature in features
        failed_tests[feature]=[]
    end
    for i in range(1, length(input))
        for feature in features
            feat=split(feature,"_")        
            test = round(getproperty(HGF_struct.state_nodes[feat[1]].state,Symbol("posterior_"*feat[2])),digits=rounding) == round(benchmark[!,feature][i],digits=rounding)
            if !test
                push!(failed_tests[feature],(getproperty(HGF_struct.state_nodes[feat[1]].state,Symbol("posterior_"*feat[2])),benchmark[!,feature][i]))
            end
        end
    HGF.update_HGF(HGF_struct, input[i])
    end
    for feature in features
        if length(failed_tests[feature])==0
            println(feature,": Test passed")
        else
            println(feature,": ",length(failed_tests[feature])," tests failed")
        end
    end
end