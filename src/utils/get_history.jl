function get_history(hgf::HGFStruct, feat::String)
    node = split(feat, "__", limit = 2)[1]
    state_name = split(feat, "__", limit = 2)[2]
    if node in keys(hgf.state_nodes)
        state = getproperty(hgf.state_nodes[node].history,Symbol(state_name))
    elseif node in keys(hgf.input_nodes)
        state = getproperty(hgf.input_nodes[node].history,Symbol(state_name))
    else
        error(node *" is not a valid node")
    end
    return state
end

function get_history(hgf::HGFStruct, feats::Array{String})
    state_list = (;)
    for feat in feats
        state_list = merge(state_list,(Symbol(feat) => get_history(hgf,feat),))
    end
    return state_list
end

function get_history(hgf::HGFStruct)
    feat_list = String[]
    for node in keys(hgf.state_nodes)
        if typeof(hgf.state_nodes[node]) == StateNode
            for feat in fieldnames(StateNodeHistory)
                push!(feat_list,node*"__"*String(feat))
            end
        elseif typeof(hgf.state_nodes[node]) == BinaryStateNode
            for feat in fieldnames(BinaryStateNodeHistory)
                push!(feat_list,node*"__"*String(feat))
            end
        end
    end
    for node in keys(hgf.input_nodes)
        if typeof(hgf.input_nodes[node]) == InputNode
            for feat in fieldnames(InputNodeHistory)
                push!(feat_list,node*"__"*String(feat))
            end
        elseif typeof(hgf.input_nodes[node]) == BinaryInputNode
            for feat in fieldnames(BinaryInputNodeHistory)
                push!(feat_list,node*"__"*String(feat))
            end
        end
    end
    state_list = get_history(hgf,feat_list)
    return state_list
end



function get_history(agent::AgentStruct, feat::String)
    if feat in keys(agent.history)
        state = agent.history[feat]
    else
        state = get_history(agent.perception_struct,feat)
    end
    return state
end

function get_history(agent::AgentStruct, feats::Array{String})
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
    state_list = merge(state_list,get_history(hgf,hgf_feat_list))
    return state_list
end

function get_history(agent::AgentStruct)
    feat_list = String[]
    for feat in keys(agent.history)
        push!(feat_list,feat)
    end
    state_list = get_history(agent,feat_list)
    hgf = agent.perception_struct
    state_list = merge(state_list,get_history(hgf))
    return state_list
end

function get_history()
   return nothing
end