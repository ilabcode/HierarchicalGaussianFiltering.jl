###Function for setting a single parameter ###
"""
"""
function set_params!(agent::AgentStruct, target_param::String, param_value::Any)

    #If the parameter exists in the agent
    if target_param in keys(agent.params)
        #Set it
        agent.params[target_param] = param_value
    else
        #Otherwise, look in the substruct
        set_params!(agent.substruct, target_param::String, param_value::Any)
    end
end

"""
"""
function set_params!(substruct::Any, target_param::String, param_value::Any)
    throw(ArgumentError("The specified parameter $target_param does not exist in the agent or its substructure"))
end



### Function for setting multiple parameters
"""
"""
function set_params!(agent::AgentStruct, params_list::NamedTuple = (;))

    #For each parameter to set
    for (target_param, param_value) in zip(keys(params_list), params_list)
        #Set that parameter
        set_params!(agent, String(target_param), param_value)
    end
end
