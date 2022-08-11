
"""
Custom error type whcih will result in rejection of a sample
"""
struct ParamError <: Exception 
    errortext
end
