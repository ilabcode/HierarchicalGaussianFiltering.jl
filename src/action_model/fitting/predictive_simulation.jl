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
        for param_name in fitted_param_names
            
            #Sample a value from the posterior
            sampled_param = Turing.sample(chain[:,param_name,:])
            
            #Add it to the tuple
            sampled_parameters = merge(sampled_parameters, (param_name => sampled_param,))
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

    #Make empty list for populating with simulation results
    predictive_simulation_list=[]

    #Do as many simulations as specified
    for iteration in 1:iterations

        #Create named tuple for populating with sampled parameters
        sampled_parameters = (;)

        #Go through each parameter to amples
        for param_name in fitted_param_names

            #Sample a value from the prior
            sampled_param = rand(getproperty(prior_list,par))

            #Add it to the tuple
            sampled_parameters = merge(sampled_parameters, (param_name => sampled_param,))
        end

        #Set sampled parameters to agent
        set_params!(agent, sampled_parameters)
        reset!(agent)

        #Evolve agent
        give_inputs!(agent, input)

        #Get trajectory of the specified state
        simulated_trajectory = (; [(Symbol(state), get_history(agent,state))]...)

        #Combine sampled parameters and simulated trajectory into a higher level tuple
        predictive_simulation = (; sampled_params = sampled_parameters, simulated_trajectory = simulated_trajectory)

        #Add that tuple to the list of simulation results
        push!(predictive_simulation_list, predictive_simulation)
    end

    return predictive_simulation_list
end