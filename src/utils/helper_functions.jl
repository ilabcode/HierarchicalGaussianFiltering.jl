# Function to calculate the exponential of a number, but capped
function capped_exp(x::T) where {T<:Real}
    return exp(max(min(x, 700), -700))
end
