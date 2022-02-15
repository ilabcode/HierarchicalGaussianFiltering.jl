module HGF

#Dummy function 
function dummy_function(dummy_in::Int64)
    #Just multiplies input by 2
    dummy_out = dummy_in * 2
    return dummy_out
end

function dummy_funtion(dummy_in::BitArray)
    if dummy_in[1]==true
        dummy_out = 1
    else
        dummy_out = 2
    end
    return dummy_out
end

function dummy_funtion(dummy_in::Vector{Float64})
    dummy_out = sum(dummy_in)
    return dummy_out
end

function dummy_funtion(dummy_in::Vector{Int64})
    dummy_out = dummy_in[1]
    return dummy_out
end


export dummy_function

#End of script
end
