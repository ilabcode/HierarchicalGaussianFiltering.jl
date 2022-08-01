"""
"""
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

"""
"""
function get_history(hgf::HGFStruct, feats::Array{String})
    state_list = (;)
    for feat in feats
        state_list = merge(state_list,(Symbol(feat) => get_history(hgf,feat),))
    end
    return state_list
end

"""
"""
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