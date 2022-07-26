function get_states(agent::AgentStruct)
    hgf = agent.perception_struct
    state_list =  merge(get_states(agent, collect(keys(agent.state))),get_states(hgf))
    return state_list
end

function get_states(agent::AgentStruct, state_names::Array{String})
    state_list = (;)
    for state_name in state_names
        state_list = merge(state_list,(Symbol(state_name) => get_states(agent,state_name),))
    end
    return state_list
end

function get_states(agent::AgentStruct, state_name::String)
    if state_name in keys(agent.state)
        state =  get_states(agent.state,state_name)
    else
        hgf = agent.perception_struct
        state = get_states(hgf, state_name)
    end
    return state
end

function get_states(hgf::HGFStruct)
    state_list= (;)
    for node in keys(hgf.state_nodes)
        state_list = merge(state_list,get_states(hgf, node))
    end
    for node in keys(hgf.input_nodes)
        state_list = merge(state_list,get_states(hgf, node))
    end
    return state_list
end

function get_states(hgf::HGFStruct, feats::Array{String})
    state_list = (;)
    for feat in feats
        state_list = merge(state_list,(Symbol(feat) => get_states(hgf,feat),))
    end
    return state_list
end

function get_states(hgf::HGFStruct, feat::String)
    if feat in keys(hgf.all_nodes)
        node = hgf.all_nodes[feat]
        state_list = get_states(hgf, node)   
        return state_list        
    else
        node_name = split(feat, "__", limit = 2)[1]
        if length(split(feat, "__", limit = 2))==2    
            state_name = split(feat, "__", limit = 2)[2]
            state = get_states(hgf, string(node_name), string(state_name))
            return state
        else
            error(node_name *" is not a valid node")
        end
    end
end

function get_states(hgf::HGFStruct, node::StateNode)
    state_name_list = String[]
    for state_name in fieldnames(StateNodeState)
        push!(state_name_list,node.name*"__"*String(state_name))
    end
    state_list = get_states(hgf,state_name_list)
    return state_list        
end

function get_states(hgf::HGFStruct, node::BinaryStateNode)
    state_name_list = String[]
    for state_name in fieldnames(BinaryStateNodeState)
        push!(state_name_list,node.name*"__"*String(state_name))
    end
    state_list = get_states(hgf,state_name_list)
    return state_list        
end

function get_states(hgf::HGFStruct, node::InputNode)
    state_name_list = String[]
    for state_name in fieldnames(InputNodeState)
        push!(state_name_list,node.name*"__"*String(state_name))
    end
    state_list = get_states(hgf,state_name_list)
    return state_list        
end

function get_states(hgf::HGFStruct, node::BinaryInputNode)
    state_name_list = String[]
    for state_name in fieldnames(BinaryInputNodeState)
        push!(state_name_list,node.name*"__"*String(state_name))
    end
    state_list = get_states(hgf,state_name_list)
    return state_list        
end

function get_states(hgf::HGFStruct, node_name::String, state_name::String)
    if node_name in keys(hgf.state_nodes)
        state = getproperty(hgf.state_nodes[node_name].state,Symbol(state_name))
    elseif node_name in keys(hgf.input_nodes)
        state = getproperty(hgf.input_nodes[node_name].state,Symbol(state_name))
    else
        error(node *" is not a valid node")
    end
    return state
end