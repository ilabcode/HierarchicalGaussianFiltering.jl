"""
"""
function predictive_simulation(agent::AgentStruct, chain::Chains, state::String, iterations::Int, input)

    #Get names for parameters that have been fitted
    fitted_param_names = describe(chain)[2].nt.parameters

    #Make empty list for populating with simulation results
    predictive_simulation_list=[]

    #Do as many simulations as specified
    for iteration in 1:iterations

        #Create named tuple for populating with sampled parameters
        sampled_parameters = (;)

        #Go through each parameter to amples
        for par in fitted_param_names
            #Sample a value from the posterior, add it to the tuple
            sampled_parameters = merge(sampled_parameters, (par => Turing.sample(chain[:,par,:]),))
        end

        #Set sampled parameters to agent
        set_params!(agent, sampled_parameters)
        reset!(agent)

        #Evolve agent
        give_inputs!(agent, input)

        #Get trajectory of specified the state
        simulated_trajectory = (; [(Symbol(state), get_history(agent,state))]...)

        #Combine sampled parameters and simulated trajectory into a higher level tuple
        predictive_simulation = (; sampled_params = sampled_parameters, simulated_trajectory = simulated_trajectory)

        #Add that tuple to the list of simulation results
        push!(predictive_simulation_list, predictive_simulation)
    end

    return predictive_simulation_list
end


"""
"""
function predictive_simulation(agent::AgentStruct, prior_list::NamedTuple, state::String, iterations::Int, input)
    
    sampling_complete_list=[]


    for i in 1:iterations

        sampling_list = (;)

        for par in keys(prior_list)
            sampling_list = merge(sampling_list, (par => rand(getproperty(prior_list,par)),))
        end

        set_params!(agent, sampling_list)
        reset!(agent)

        give_inputs!(agent, input)

        sampling_list = merge(sampling_list, (Symbol(state) => get_history(agent,state),))
        push!(sampling_complete_list, sampling_list)
    end

    return sampling_complete_list
end