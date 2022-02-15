module HGF

export dummy_function

"""
    dummy_function(input)

For Int64: 
Returns double the number `x` plus `1`.

For BitArrays:
Return 1 if there is a 1 in the array, otherwise 0

For Vector{Float64}:
Return the sum of the vector

For Vector{Int64}:
Return the first number in the vector
"""

#For Int64
function dummy_function(dummy_in::Int64)

    dummy_out = dummy_in * 2
    return dummy_out
end

#For BitArrays
function dummy_function(dummy_in::BitArray)
    if dummy_in[1] == true
        dummy_out = 1
    else
        dummy_out = 2
    end
    return dummy_out
end

#For vectors of floats
function dummy_function(dummy_in::Vector{Float64})
    dummy_out = sum(dummy_in)
    return dummy_out
end

#For vectors of integers
function dummy_function(dummy_in::Vector{Int64})
    dummy_out = dummy_in[1]
    return dummy_out
end

end
