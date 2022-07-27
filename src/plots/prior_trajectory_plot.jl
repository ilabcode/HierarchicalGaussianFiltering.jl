function prior_trajectory_plot(agent::AgentStruct, prior_list::NamedTuple, state::String, iterations::Int, input; color = "red", title = "", alpha = 0.1, linewidth=2)
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
    set_params!(agent, sampled_pars_list)
    reset!(agent)
    give_inputs!(agent, input)
    hgf_trajectory_plot(agent, node, state_name; color = "gray", alpha = 0.1, label = "", title=title)
        for i in 1:iterations-1
            sampled_pars_list = (;)
            for par in keys(prior_list)
                sampled_pars_list = merge(sampled_pars_list, (par => rand(getproperty(prior_list,par)),))
            end
        set_params!(agent, sampled_pars_list)
        reset!(agent)
        give_inputs!(agent, input)
        hgf_trajectory_plot!(agent, node, state_name; color = "gray", alpha = alpha, label = "", title=title,)
    end
    set_params!(agent, median_list)
    reset!(agent)
    give_inputs!(agent, input)
    hgf_trajectory_plot!(agent, node, state_name; color = color, label = "", title=title, linewidth = linewidth)
end