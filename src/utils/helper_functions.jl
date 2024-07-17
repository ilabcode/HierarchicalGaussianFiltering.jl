# Function to calculate the exponential of a number, but capped to avoid numerical instability
function capped_exp(x::T) where {T<:Real}
    return exp(max(min(x, 700), -700))
end

# Capped logistic transform, to avoid numerical instability
function capped_logistic(x::T) where {T<:Real}

    #Do the logistic transform with a capped exp
    out = 1 / (1 + capped_exp(-x))

    #Ensure numerical stability by avoiding extremes
    return min(max(out, 0 + eps(T)), 1 - eps(T))
end
