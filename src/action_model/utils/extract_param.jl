"""
Multiple-dispatched internal utility function for extracting values from priors and posteriors
"""
function extract_param(param_name::Union{String, Symbol}, priors::NamedTuple, type = "sample")
    #If asked to sample from the distribution
    if type == "sample"
        return rand(getproperty(priors, Symbol(param_name)))
    #If asked to get the median
    elseif type == "median"
        return median(getproperty(priors, Symbol(param_name)))
    #If misspecified
    else
        throw(ArgumentError("Argument type is misspecified"))
    end
end

function extract_param(param_name::Union{String, Symbol}, chain::Chains, type = "sample")
    #If asked to sample from the distribution
    if type == "sample"
        return Turing.sample(chain[:, Symbol(param_name), :])
    #If asked to get the median
    elseif type == "median"
        return median(chain[:, Symbol(param_name), :])
    #If misspecified
    else
        throw(ArgumentError("Argument type is misspecified"))
    end
end