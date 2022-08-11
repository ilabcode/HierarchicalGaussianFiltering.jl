"""
"""
function trajectory_plot(hgf::HGFStruct, target_state::String; kwargs...)

    #Get out the target node
    target_node = split(target_state, "__")[1]

    #If the target node is in the HGF
    if target_node in keys(hgf.all_nodes)
        #Make a trajectory plot
        hgf_trajectory_plot(hgf, target_state; kwargs...)
    else
        #Throw an error
        throw(ArgumentError("The specified state does not beign with a valid node name, bnefore double underscores"))
    end
end

"""
"""
function trajectory_plot!(hgf::HGFStruct, target_state::String; kwargs...)

    #Get out the target node
    target_node = split(target_state, "__")[1]

    #If the target node is in the HGF
    if target_node in keys(hgf.all_nodes)
        #Make a trajectory plot
        hgf_trajectory_plot!(hgf, target_state; kwargs...)
    else
        #Throw an error
        throw(ArgumentError("The specified state does not beign with a valid node name, bnefore double underscores"))
    end
end


@userplot HGF_Trajectory_Plot 

@recipe function f(pl::HGF_Trajectory_Plot)

    #Get the hgf and the target state out
    hgf = pl.args[1]
    target_state = pl.args[2]

    #Split the target state
    target_state_split = split(target_state, "__")

    #If only a node name was specified
    if length(target_state_split) == 1
        #Extract node name
        node_name = target_state
        #If the specified node is an input node
        if node_name in keys(hgf.input_nodes)
            #Set the plotted state to the input value
            state_name = "input_value"
        #If the node is a state node
        else
            #Set plotted state to full posterior
            state_name = "posterior"
        end
    else
        #Extract node name
        node_name = target_state_split[1]
        #Extract state name
        state_name = target_state_split[2]
    end

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
        history_precision = replace(history_precision,missing=>NaN)
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
    elseif Symbol(state_name) in fieldnames(typeof(node.history))

            #Get history of state
            state_history = getproperty(node.history, Symbol(state_name))
            #replace missings with NaNs for plotting
            state_history = replace(state_history,missing=>NaN)

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
    else
        #If the state does not exist in the node, raise an error
        throw(ArgumentError("The specified state does not exist in the specified node's history"))
    end
end
