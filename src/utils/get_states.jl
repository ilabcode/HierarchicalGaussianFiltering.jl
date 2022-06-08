function get_states(hgf::HGFStruct, feat::String)
    node = split(feat, "_", limit = 2)[1]
    state_name = split(feat, "_", limit = 2)[2]
    if node in keys(hgf.state_nodes)
        state = getproperty(hgf.state_nodes[node].state,Symbol(state_name))
    elseif node in keys(hgf.input_nodes)
        state = getproperty(hgf.input_nodes[node].state,Symbol(state_name))
    else
        error(node *" is not a valid node")
    end
    return state
end

function get_states(hgf::HGFStruct, feats::Array{String})
    state_list = (;)
    for feat in feats
        state_list = merge(state_list,(Symbol(feat) => get_states(hgf,feat),))
    end
    return state_list
end

function get_states(hgf::HGFStruct)
    feat_list = String[]
    for node in keys(hgf.state_nodes)
        for feat in fieldnames(NodeState)
            push!(feat_list,node*"_"*String(feat))
        end
    end
    for node in keys(hgf.input_nodes)
        for feat in fieldnames(InputNodeState)
            push!(feat_list,node*"_"*String(feat))
        end
    end
    state_list = get_states(hgf,feat_list)
    return state_list
end



function get_states(agent::AgentStruct, feat::String)
    if feat in keys(agent.state)
        state = agent.state(feat)
    else
        state = get_states(agent.perception_struct,feat)
    end
    return state
end

function get_states(agent::AgentStruct, feats::Array{String})
    state_list = (;)
    hgf_feat_list = String[]
    hgf = agent.perception_struct
    for feat in feats
        if feat in keys(agent.state)
            state_list = merge(state_list,(Symbol(feat) => get_states(agent,feat),))
        else
            push!(hgf_feat_list,feat)
        end
    end
    state_list = merge(state_list,get_states(hgf,hgf_feat_list))
    return state_list
end

function get_states(agent::AgentStruct)
    feat_list = String[]
    for feat in keys(agent.state)
        push!(feat_list,feat)
    end
    state_list = get_states(agent,feat_list)
    hgf = agent.perception_struct
    state_list = merge(state_list,get_states(hgf))
    return state_list
end

function get_states()
   return nothing
end