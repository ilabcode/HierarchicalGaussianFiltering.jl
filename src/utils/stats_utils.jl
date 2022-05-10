function lognormal_params(μ, σ)
    sigmalog = sqrt(log(((σ^2)/μ)+1))
    mulog = log(μ/(exp((sigmalog^2)/2)))
    return (;mean=mulog, std=sigmalog)
end