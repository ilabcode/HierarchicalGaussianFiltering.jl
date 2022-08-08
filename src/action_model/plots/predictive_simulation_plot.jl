"""
"""
function predictive_simulation_plot(
    agent::AgentStruct,
    distributions::Union{Chains,NamedTuple},
    target_state::String,
    input;
    n_simulations::Int = 1000,
    median_color = "red",
    title = "",
    alpha = 0.1,
    linewidth = 2,
)

    ##Get list of parameter names
    #If a Turing Chains has been inputted
    if distributions isa Chains
        #Get names with describe function
        sampled_params_names = describe(distributions)[2].nt.parameters
        #If a NamedTuple of priors have been inputted
    elseif distributions isa NamedTuple
        #Get keys from the distribution
        sampled_params_names = collect(keys(distributions))
    end

    ### Plot single simulations with sampled parameters ###
    #Go through each simulation
    for simulation_number = 1:n_simulations

        #Create empty tuple for populating with sampled parameter values
        sampled_params = (;)

        #For each specified parameter 
        for param_name in sampled_params_names
            #Sample the parameter
            sampled_param = extract_param(param_name, distributions, "sample")
            #Add it to the tuple
            sampled_params = merge(sampled_params, (param_name => sampled_param,))
        end

        #Set parameters
        set_params!(agent, sampled_params)
        reset!(agent)

        #Evolve agent
        give_inputs!(agent, input)

        #For the first simulation
        if simulation_number == 1
            #Initialize the trajectory plot
            trajectory_plot(
                agent,
                target_state;
                color = "gray",
                alpha = alpha,
                label = "",
                title = title,
            )
            #For other simulations
        else
            #Add trajectories to the same plot
            trajectory_plot!(
                agent,
                target_state;
                color = "gray",
                alpha = alpha,
                label = "",
                title = title,
            )
        end
    end

    ### Plot simulation with parameter medians ###
    #Create empty list for parameter medians
    param_medians = (;)

    #For each parameter
    for param_name = sampled_params_names
        #Add the median and the corresponding parameter name to the named tuple
        param_medians = merge(
            param_medians,
            (param_name => extract_param(param_name, distributions, "median"),),
        )
    end

    #Set parameters
    set_params!(agent, param_medians)
    reset!(agent)

    #Evolve agent
    give_inputs!(agent, input)

    #Plot the median
    trajectory_plot!(
        agent,
        target_state;
        color = median_color,
        label = "",
        title = title,
        linewidth = linewidth,
    )
end