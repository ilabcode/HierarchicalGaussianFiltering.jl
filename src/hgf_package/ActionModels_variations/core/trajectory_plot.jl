### If only a node was specified ###
"""
"""
function trajectory_plot(hgf::HGFStruct, node_name::String; kwargs...)

    #If the target node is not in in the HGF
    if !(node_name in keys(hgf.all_nodes))
        #Throw an error
        throw(ArgumentError("The node $node_name does not exist"))
    end

    #Get out the node
    node = hgf.all_nodes[node_name]

    #For continuous state nodes
    if node isa StateNode

        #Plot the full posterior
        state_name = "posterior"

        #FOr binary state nodes
    elseif node isa BinaryStateNode

        #Plot the full prediction
        state_name = "prediction"

        #For input nodes
    elseif node isa AbstractInputNode

        #Plot the input value
        state_name = "input_value"
    end

    #Make a trajectory plot
    hgf_trajectory_plot(hgf, node_name, state_name; kwargs...)

end


"""
"""
function trajectory_plot!(hgf::HGFStruct, node_name::String; kwargs...)

    #If the target node is not in in the HGF
    if !(node_name in keys(hgf.all_nodes))
        #Throw an error
        throw(ArgumentError("The node $node_name does not exist"))
    end

    #Get out the node
    node = hgf.all_nodes[node_name]

    #For continuous state nodes
    if node isa StateNode

        #Plot the full posterior
        state_name = "posterior"

        #FOr binary state nodes
    elseif node isa BinaryStateNode

        #Plot the full prediction
        state_name = "prediction"

        #For input nodes
    elseif node isa AbstractInputNode

        #Plot the input value
        state_name = "input_value"
    end

    #Make a trajectory plot
    hgf_trajectory_plot!(hgf, node_name, state_name; kwargs...)

end



### If both a node and a state was specified ###
"""
"""
function trajectory_plot(hgf::HGFStruct, target_state::Tuple{String,String}; kwargs...)

    #Get out the target node
    (node_name, state_name) = target_state

    #If the target node is not in in the HGF
    if !(node_name in keys(hgf.all_nodes))
        #Throw an error
        throw(ArgumentError("The node $node_name does not exist"))
    end

    #Unless a whole distribution has been specified
    if !(state_name in ["posterior", "prediction"])
        #If the state does not exist in the node
        if !(Symbol(state_name) in fieldnames(typeof(hgf.all_nodes[node_name].states)))
            #throw an error
            throw(ArgumentError("The node $node_name does not have the state $state_name"))
        end
    end

    #Make a trajectory plot
    hgf_trajectory_plot(hgf, node_name, state_name; kwargs...)

end


"""
"""
function trajectory_plot!(hgf::HGFStruct, target_state::Tuple{String,String}; kwargs...)

    #Get out the target node
    (node_name, state_name) = target_state

    #If the target node is not in in the HGF
    if !(node_name in keys(hgf.all_nodes))
        #Throw an error
        throw(ArgumentError("The node $node_name does not exist"))
    end

    #Unless a whole distribution has been specified
    if !(state_name in ["posterior", "prediction"])
        #If the state does not exist in the node
        if !(Symbol(state_name) in fieldnames(typeof(hgf.all_nodes[node_name].states)))
            #throw an error
            throw(ArgumentError("The node $node_name does not have the state $state_name"))
        end
    end

    #Make a trajectory plot
    hgf_trajectory_plot!(hgf, node_name, state_name; kwargs...)

end





@userplot HGF_Trajectory_Plot

@recipe function f(pl::HGF_Trajectory_Plot)

    #Get the hgf, the node name and the state name
    hgf = pl.args[1]
    node_name = pl.args[2]
    state_name = pl.args[3]

    #Get the node
    node = hgf.all_nodes[node_name]

    #If the entire distribution is to be plotted
    if state_name in ["posterior", "prediction"]

        #Get the history of the mean
        history_mean = getproperty(node.history, Symbol(state_name * "_mean"))
        #Replace missings with NaN's for plotting
        history_mean = replace(history_mean, missing => NaN)

        #Get the history of precisions
        history_precision = getproperty(node.history, Symbol(state_name * "_precision"))
        #Replace missings with NaN's for plotting
        history_precision = replace(history_precision, missing => NaN)
        #Transform precisions into standard deviations
        history_sd = sqrt.(1 ./ history_precision)

        @series begin
            #Set legend label
            label --> node_name * " " * state_name
            #The ribbon is the standard deviations
            ribbon := history_sd
            #Plot the history of means
            history_mean
        end

        #If single state is specified
    else
        #Get history of state
        state_history = getproperty(node.history, Symbol(state_name))
        #Replace missings with NaNs for plotting
        state_history = replace(state_history, missing => NaN)

        #Begin the plot
        @series begin

            #For input values
            if state_name == "input_value"
                #Default to scatterplots
                seriestype --> :scatter
            else
                #Lineplots for others
                seriestype --> :path
            end

            #Set label
            label --> node_name * " " * state_name
            #Plot the history
            state_history
        end
    end
end
