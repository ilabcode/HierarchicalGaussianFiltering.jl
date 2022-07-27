function posterior_trajectory_plot(agent::AgentStruct, chain::Chains, state::String, iterations::Int, input; color = "red", title = "", alpha = 0.1)
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
    set_params!(agent, sampled_pars_list)
    reset!(agent)
    give_inputs!(agent, input)
    hgf_trajectory_plot(agent, node, state_name; color = "gray", alpha = 0.1, label = "", title=title)
    for i in 1:iterations-1
        sampled_pars_list = (;)
        for par in sampled_pars
            sampled_pars_list = merge(sampled_pars_list, (par => Turing.sample(chain[:,par,:]),))
        end
        set_params!(agent, sampled_pars_list)
        reset!(agent)
        give_inputs!(agent, input)
        hgf_trajectory_plot!(agent, node, state_name; color = "gray", alpha = alpha, label = "", title=title,)
    end
    set_params!(agent, median_list)
    reset!(agent)
    give_inputs!(agent, input)
    hgf_trajectory_plot!(agent, node, state_name; color = color, label = "", title=title, linewidth = 2)
end