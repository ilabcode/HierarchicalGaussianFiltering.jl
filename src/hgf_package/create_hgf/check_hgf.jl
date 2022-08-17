"""

Function for checking if the specified HGF structure is valid
"""
function check_hgf(hgf::HGFStruct)

    #Check each node
    for node in hgf.ordered_nodes.all_nodes
        check_hgf(node)
    end
end

"""
    check_hgf(node::StateNode)

Function for checking the validity of a single continous state node
"""
function check_hgf(node::StateNode)

    #Disallow binary input node value children
    if any(isa.(node.value_children, BinaryInputNode))
        throw(ArgumentError("The continuous state node $node.name has a value child which is a binary input node. This is not supported."))
    end

    #Disallow binary input node volatility children
    if any(isa.(node.volatility_children, BinaryInputNode))
        throw(ArgumentError("The continuous state node $node.name has a volatility child which is a binary input node. This is not supported."))
    end

    #Disallow having volatility children if a value child is a continuous inputnode 
    if any(isa.(node.value_children, InputNode))
        if length(node.volatility_children) > 0
            throw(ArgumentError("The state node $node.name has a continuous input node as a value child. It also has volatility children, which disrupts the update order. This is not supported."))
        end
    end
    
    return nothing
end

"""
    check_hgf(node::BinaryStateNode)

Function for checking the validity of a single binary state node
"""
function check_hgf(node::BinaryStateNode)
    
    #Disallow volatility parents
    if length(node.volatility_parents) > 0
        throw(ArgumentError("The binary state node $node.name has a volatility parent. This is not supported."))
    end

    #Disallow volatility children
    if length(node.volatility_children) > 0
        throw(ArgumentError("The binary state node $node.name has a volatility child. This is not supported."))
    end

    #Allow only binary input node children
    if any(.!isa.(node.value_children, BinaryInputNode))
        throw(ArgumentError("The binary state node $node.name has a child which is not a binary input node. This is not supported."))
    end

    #Allow only continuous state node node parents
    if any(.!isa.(node.value_parents, StateNode))
        throw(ArgumentError("The binary state node $node.name has a parent which is not a continuous state node. This is not supported."))
    end

    return nothing
end

"""
    check_hgf(node::InputNode)

Function for checking the validity of a single continuous input node
"""
function check_hgf(node::InputNode)
    
    #Allow only continuous state node node parents
    if any(.!isa.(node.value_parents, StateNode))
        throw(ArgumentError("The continuous input node $node.name has a parent which is not a continuous state node. This is not supported."))
    end

    #Require at least one value parent
    if length(node.value_parents) == 0
        throw(ArgumentError("The input node $node.name does not have any value parents. This is not supported."))
    end
    
    #Disallow multiple value parents if there are volatility parents
    if length(node.volatility_parents) > 0
        if length(node.value_parents) > 1
            throw(ArgumentError("The input node $node.name has multiple value parents and at least one volatility parent. This is not supported."))
        end
    end

    return nothing
end

"""
    check_hgf(node::BinaryInputNode)

Function for checking the validity of a single binary input node
"""
function check_hgf(node::BinaryInputNode)

    #Disallow volatility parents
    if length(node.volatility_parents) > 0
        throw(ArgumentError("The binary input node $node.name has a volatility parent. This is not supported."))
    end

    #Require exactly one value parent
    if length(node.value_parents) != 1
        throw(ArgumentError("The binary input node $node.name does not have exactly one value parent. This is not supported."))
    end

    #Allow only binary state nodes as parents
    if any(.!isa.(node.value_parents, BinaryStateNode))
        throw(ArgumentError("The binary input node $node.name has a parent which is not a binary state node. This is not supported."))
    end

    return nothing
end