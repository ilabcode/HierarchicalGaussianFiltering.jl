"""""
function fit_model(
    agent::AgentStruct,
    inputs::Vector{Float64},
    responses::Union{Vector{Float64},Missing},
    params_priors_list = (;)::NamedTuple{Distribution},
    fixed_params_list = (;)::NamedTuple{String,Real},
    sampler = NUTS(),
    iterations = 1000,
)
Function to fit an agent parameters.
"""
function fit_model(
    agent::AgentStruct,
    inputs::Vector,
    responses::Vector,
    params_priors_list::NamedTuple,
    fixed_params_list = (;),
    sampler = NUTS(),
    n_iterations = 1000,
    n_chains = 1,
    ignore_warnings = true,
)

    #Store old parameters 
    old_params = get_params(agent)

    ### Run forward once as testrun ###
    #Set fixed parameters
    set_params!(agent, fixed_params_list)
    reset!(agent)

    ## Sample parameters from the priors ##
    #Initialize tuple for populating with sampled parameter values
    sampled_params = (;)

    #Go through each of the agent's parameters
    for param in keys(params_priors_list)
        #Sample a value and add it to the tuple
        sampled_params =
            merge(sampled_params, (Symbol(param) => median(params_priors_list[param]),))
    end
    #Set parameters in agent
    set_params!(agent, sampled_params)
    #Run it forwards
    give_inputs!(agent, inputs)

    ### Fit model ###
    #Initialize dictionary for storing sampled parameters
    fitted_params = Dict()

    #Create turing model macro for parameter estimation
    @model function fit_agent(responses)

        #Give Turing prior distributions for each fitted parameter
        for param_key in keys(params_priors_list)
            fitted_params[string(param_key)] ~ getfield(params_priors_list, param_key)
        end

        ## Create agent with sampled parameters ##
        #Initialize lists for storing parameter name symbols and sampled parameter values
        param_name_symbols = []
        param_sampled_values = []

        #Populate lists with names and sampled values from the priors
        for (param_name, sampled_param) in fitted_params
            push!(param_name_symbols, Symbol(param_name))
            push!(param_sampled_values, sampled_param)
        end

        #Merge into one named tuple
        sampled_params = NamedTuple{Tuple(param_name_symbols)}(param_sampled_values)

        #Set agent parameters to the sampled values
        set_params!(agent, sampled_params)
        reset!(agent)

        ## Fit model ##
        #For each input
        for input_indx in range(1, length(inputs))
            #If no errors occur
            try
                #Get the action probability distribution from the action model
                action_probability_distribution =
                    agent.action_model(agent, inputs[input_indx])

                #If only a single action probability distribution was returned
                if length(action_probability_distribution) == 1
                    #Pass it to Turing
                    responses[input_indx] ~ action_probability_distribution
                else
                    #Go throgh each returned distribution
                    for response_indx = 1:length(action_probability_distribution)
                        #Add it one at a time
                        responses[input_indx, response_indx] ~
                            action_probability_distribution[response_indx]
                    end
                end
            catch e
                #If the custom errortype ParamError occurs
                if e isa ParamError
                    #Make Turing reject the sample
                    Turing.@addlogprob!(-Inf)
                else
                    #Otherwise, just throw the error
                    throw(e)
                end
            end
        end
    end

    #If warnings are to be ignored
    if ignore_warnings
        #Create a logger which ignores messages below errors
        sampling_logger = Logging.SimpleLogger(Logging.Error)
        #Use that logger
        chains = Logging.with_logger(sampling_logger) do

            #Fit model to inputs and responses, as many separate chains as specified
            map(i -> sample(fit_agent(responses), sampler, n_iterations), 1:n_chains)

        end
    else
        #Fit model to inputs and responses, as many separate chains as specified
        chains = map(i -> sample(fit_agent(responses), sampler, n_iterations), 1:n_chains)
    end

    #Concatenate chains together
    chains = chainscat(chains...)

    ## Set readable chain names ###
    #Initialize dict for replacement names to give to Turing
    params_name = Dict()
    #For each parameter
    for param in keys(params_priors_list)
        #Set to replace the fitted_params[] version with just the parameter name
        params_name["fitted_params["*string(param)*"]"] = String(param)
    end
    #Input the dictionary to replace the names
    chains = replacenames(chains, params_name)

    #Reset the agent to its original parameters
    set_params!(agent, old_params)
    reset!(agent)

    return chains
end