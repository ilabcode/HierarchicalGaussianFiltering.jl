"""
"""
function set_params!(hgf::HGFStruct, params_list::NamedTuple = (;))


    for feat in keys(params_list)


        first_arg = split(string(feat), "__")[1] #node name
        second_arg = split(split(string(feat), "__")[2], '_')[1] #state name

        #If it is an Input node
        if first_arg in keys(hgf.input_nodes)
            #check if it is a value_coupling
            if second_arg in [
                hgf.input_nodes[first_arg].value_parents[i].name for ###INSTEAD: check if the state is a coupling, if so, split the node into two and look for the second 
                i =1:length( #Change to double underscores between nodes and 
                        hgf.input_nodes[first_arg].value_parents,
                    )
            ]
                hgf.input_nodes[first_arg].params.value_coupling[second_arg] =
                    getfield(params_list, feat)
                #check if it is a volatility_coupling
            elseif second_arg in [
                hgf.input_nodes[first_arg].volatility_parents[i].name
                for i =
                    1:length(
                        hgf.input_nodes[first_arg].volatility_parents,
                    )
            ]
                hgf.input_nodes[first_arg].params.volatility_coupling[second_arg] =
                    getfield(params_list, feat)
                #It is a single node parameter
            else
                param_name = split(string(feat), "__", limit = 2)[2]
                setproperty!(
                    hgf.input_nodes[first_arg].params,
                    Symbol(param_name),
                    getfield(params_list, feat),
                )
            end
            #If it is a state node
        elseif first_arg in keys(hgf.state_nodes)
            #check if it is a value_coupling
            if second_arg in [
                hgf.state_nodes[first_arg].value_parents[i].name for
                i =
                    1:length(
                        hgf.state_nodes[first_arg].value_parents,
                    )
            ]
            hgf.state_nodes[first_arg].params.value_coupling[second_arg] =
                    getfield(params_list, feat)
                #check if it is a volatility_coupling
            elseif second_arg in [
                hgf.state_nodes[first_arg].volatility_parents[i].name
                for i =
                    1:length(
                        hgf.state_nodes[first_arg].volatility_parents,
                    )
            ]
            hgf.state_nodes[first_arg].params.volatility_coupling[second_arg] =
                    getfield(params_list, feat)
            else
                param_name = split(string(feat), "__", limit = 2)[2]
                setproperty!(
                    hgf.state_nodes[first_arg].params,
                    Symbol(param_name),
                    getfield(params_list, feat),
                )
            end
        end
    end
end