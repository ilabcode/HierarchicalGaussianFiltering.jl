"""
"""
function extract_param(param_name::Union{String, Symbol}, priors::NamedTuple, type = "sample")

    if type == "sample"
        return rand(getproperty(priors, Symbol(param_name)))
    elseif type == "median"
        return median(getproperty(priors, Symbol(param_name)))
    else
        throw(ArgumentError("Argument type is misspecified"))
    end

end

"""
"""
function extract_param(param_name::Union{String, Symbol}, chain::Chains, type = "sample")

    if type == "sample"
        return Turing.sample(chain[:, Symbol(param_name), :])
    elseif type == "median"
        return median(chain[:, Symbol(param_name), :])
    else
        throw(ArgumentError("Argument type is misspecified"))
    end

end