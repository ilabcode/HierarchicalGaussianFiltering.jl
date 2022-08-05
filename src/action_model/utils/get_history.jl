"""
"""
function get_history(agent::AgentStruct, feat::String)
    if feat in keys(agent.history)
        state = agent.history[feat]
    else
        state = get_history(agent.perception_struct,feat) #should be an error if the substruct also gives nothing
    end
    return state
end

"""
"""
function get_history(agent::AgentStruct, feats::Array{String}) #make it just call the agent many times
    state_list = (;)

    hgf_feat_list = String[]

    hgf = agent.perception_struct

    for feat in feats

        if feat in keys(agent.history)
            state_list = merge(state_list,(Symbol(feat) => get_history(agent,feat),))
        else
            push!(hgf_feat_list,feat)
        end
    end

    state_list = merge(state_list,
    get_history(hgf,hgf_feat_list))
    return state_list
end

"""
"""
function get_history(agent::AgentStruct)
    feat_list = String[]
    for feat in keys(agent.history)
        push!(feat_list,feat)
    end
    state_list = get_history(agent,feat_list)
    return state_list
end

"""
"""
function get_history()
   return nothing
end