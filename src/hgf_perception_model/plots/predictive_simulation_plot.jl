"""
"""
function predictive_simulation_plot(hgf::HGFStruct, chain::Chains, state::String, iterations::Int, input; color = "red", title = "", alpha = 0.1, linewidth=2)
    sampled_pars = describe(chain)[2].nt.parameters
    medians = getfield(describe(chain)[2].nt,Symbol("50.0%"))
    node = split(state, "__", limit =2)[1]
    state_name = split(state, "__", limit =2)[2]
    median_list = (;)
    for i in 1:length(sampled_pars)
        median_list = merge(median_list, (sampled_pars[i] => medians[i],))
    end
    sampled_pars_list = (;)
        for par in sampled_pars
            sampled_pars_list = merge(sampled_pars_list, (par => Turing.sample(chain[:,par,:]),))
        end
    set_params!(hgf, sampled_pars_list)
    reset!(hgf)
    give_inputs!(hgf, input)
    hgf_trajectory_plot(hgf, node, state_name; color = "gray", alpha = 0.1, label = "sampled trajectories",)
    for i in 1:iterations-1
        sampled_pars_list = (;)
        for par in sampled_pars
            sampled_pars_list = merge(sampled_pars_list, (par => Turing.sample(chain[:,par,:]),))
        end
        set_params!(hgf, sampled_pars_list)
        reset!(hgf)
        give_inputs!(hgf, input)
        hgf_trajectory_plot!(hgf, node, state_name; color = "gray", alpha = alpha, label = "",)
    end
    set_params!(hgf, median_list)
    reset!(hgf)
    give_inputs!(hgf, input)
    hgf_trajectory_plot!(hgf, node, state_name; color = color, label = "median", title=title, linewidth = linewidth)
end

"""
"""
function predictive_simulation_plot(hgf::HGFStruct, prior_list::NamedTuple, state::String, iterations::Int, input; color = "red", title = "", alpha = 0.1, linewidth=2)
    node = split(state, "__", limit =2)[1]
    state_name = split(state, "__", limit =2)[2]
    median_list = (;)
    for par in keys(prior_list)
        median_list = merge(median_list, (par => median(getproperty(prior_list,par)),))
    end
    sampled_pars_list = (;)
        for par in keys(prior_list)
            sampled_pars_list = merge(sampled_pars_list, (par => rand(getproperty(prior_list,par)),))
        end
    set_params!(hgf, sampled_pars_list)
    reset!(hgf)
    give_inputs!(hgf, input)
    hgf_trajectory_plot(hgf, node, state_name; color = "gray", alpha = 0.1, label = "", title=title)
        for i in 1:iterations-1
            sampled_pars_list = (;)
            for par in keys(prior_list)
                sampled_pars_list = merge(sampled_pars_list, (par => rand(getproperty(prior_list,par)),))
            end
        set_params!(hgf, sampled_pars_list)
        reset!(hgf)
        give_inputs!(hgf, input)
        hgf_trajectory_plot!(hgf, node, state_name; color = "gray", alpha = alpha, label = "", title=title,)
    end
    set_params!(hgf, median_list)
    reset!(hgf)
    give_inputs!(hgf, input)
    hgf_trajectory_plot!(hgf, node, state_name; color = color, label = "", title=title, linewidth = linewidth)
end