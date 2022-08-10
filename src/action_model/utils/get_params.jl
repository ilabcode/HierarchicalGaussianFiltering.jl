"""
"""
function get_params(agent::AgentStruct)

    #Initialize tuple for populating with parameter values
    params_list = (;)

    #Go through each of the agent's parameter
    for param in keys(agent.params)
        #And add it to the tuple
        params_list = merge(params_list,(Symbol(param)=>agent.params[param],))
    end

    #Get parameters from the substruct
    substruct_params = get_params(agent.substruct)

    #Merge substruct parameters and agent parameters
    params_list = merge(params_list, substruct_params)

    return params_list
end

function get_params(substruct::Any)
    #If the substruct is empty, return an empty named tuple
    return (;)
end





"""
"""
function get_params(chain::Chains) 

    #Get parameter names from the chain
    param_names = describe(distributions)[2].nt.parameters

    #Initialize tuple for storing parameter medians
    param_medians = (;)

    #For each parameter
    for param_name = param_names
        #Add the median and the corresponding parameter name to the named tuple
        param_medians = merge(
            param_medians,
            (param_name => extract_param(param_name, distributions, "median"),),
        )
    end

    return param_medians
end