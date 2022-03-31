using GR

function trajectory_plot(HGF::HGFStruct, node_names::Array{String})
    for node in node_names
        node_name=node.name

