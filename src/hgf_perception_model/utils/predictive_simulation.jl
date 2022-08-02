"""
"""
function predictive_simulation(hgf::HGFStruct, chain::Chains, state::String, iterations::Int, input)
    sampled_pars = describe(chain)[2].nt.parameters
    sampling_complete_list=[]
    for i in 1:iterations
        sampling_list = (;)
        for par in sampled_pars
            sampling_list = merge(sampling_list, (par => Turing.sample(chain[:,par,:]),))
        end
        set_params!(hgf, sampling_list)
        reset!(hgf)
        give_inputs!(hgf, input)
        sampling_list = merge(sampling_list, (Symbol(state) => get_history(hgf,state),))
        push!(sampling_complete_list, sampling_list)
    end
    return sampling_complete_list
end

"""
"""
function predictive_simulation(hgf::HGFStruct, prior_list::NamedTuple, state::String, iterations::Int, input)
    sampling_complete_list=[]
    for i in 1:iterations
        sampling_list = (;)
        for par in keys(prior_list)
            sampling_list = merge(sampling_list, (par => rand(getproperty(prior_list,par)),))
        end
        set_params!(hgf, sampling_list)
        reset!(hgf)
        give_inputs!(hgf, input)
        sampling_list = merge(sampling_list, (Symbol(state) => get_history(hgf,state),))
        push!(sampling_complete_list, sampling_list)
    end
    return sampling_complete_list
end