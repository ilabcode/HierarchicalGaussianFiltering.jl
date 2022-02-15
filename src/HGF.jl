module HGF

export dummy_function

"""
    dummy_function(dummy_in::Int64)

Returns double the number `x` plus `1`.

'''jldoctest
julia> dummy_function(2)
5
'''

"""
function dummy_function(dummy_in::Int64)

    dummy_out = dummy_in * 2
    return dummy_out
end

"""
    dummy_function(dummy_in::BitArray)

Returns 1 if there is a 1 in the array, otherwise 0

'''jldoctest
dummy_function([1,0,0,1])

# output

true
'''

"""
function dummy_function(dummy_in::BitArray)
    if dummy_in[1] == true
        dummy_out = 1
    else
        dummy_out = 2
    end
    return dummy_out
end

"""
    dummy_function(dummy_in::Vector{Float64})

Returns the sum of the vector   
"""
function dummy_function(dummy_in::Vector{Float64})
    dummy_out = sum(dummy_in)
    return dummy_out
end

"""
    dummy_function(dummy_in::Vector{Int64})

Returns the first number in the vector
"""
function dummy_function(dummy_in::Vector{Int64})
    dummy_out = dummy_in[1]
    return dummy_out
end

end