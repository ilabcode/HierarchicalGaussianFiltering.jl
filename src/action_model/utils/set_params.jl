#Function to change Agent parameters in a more user-friendly way

# function set_params!(agent::AgentStruct, params_list::NamedTuple = (;))
#     hgf_params_list = (;)
#     hgf = agent.perception_struct
#     for feat in keys(params_list)
#         #Check if the feature is an agent parameter
#         if string(feat) in keys(agent.params)
#             agent.params[string(feat)] = getfield(params_list, feat)
#             #Check if the feature is an agent state
#         elseif string(feat) in keys(agent.state)
#             agent.state[string(feat)] = getfield(params_list, feat)
#             #Else it's an action model parameter or starting state
#         else
#             hgf_params_list = merge(hgf_params_list, (Symbol(feat)=>getfield(params_list, feat),))
#         end
#     end
#     set_params!(hgf,hgf_params_list)
# end


"""
"""
function set_params!(agent::AgentStruct, params_list::NamedTuple = (;))
    hgf_params_list = (;)
    hgf = agent.perception_struct
    for feat in keys(params_list)
        #Check if the feature is an agent parameter
        if string(feat) in keys(agent.params)
            agent.params[string(feat)] = getfield(params_list, feat)
            #Else it's an action model parameter or starting state
        else
            hgf_params_list = merge(hgf_params_list, (Symbol(feat)=>getfield(params_list, feat),))
        end
    end
    set_params!(hgf,hgf_params_list)
end
