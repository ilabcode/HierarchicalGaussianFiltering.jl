### If only a node was specified ###
"""
    plot_trajectory(hgf::HGF, node_name::String; kwargs...)

Plots the trajectory of a node in an HGF. See the ActionModels documentation for more information.
"""
function ActionModels.plot_trajectory(hgf::HGF, node_name::String; kwargs...)

    #If the target node is not in in the HGF
    if !(node_name in keys(hgf.all_nodes))
        #Throw an error
        throw(ArgumentError("The node $node_name does not exist"))
    end

    #Get out the node
    node = hgf.all_nodes[node_name]

    #For continuous state nodes
    if node isa ContinuousStateNode

        #Plot the full posterior
        state_name = "posterior"

        #For binary state nodes
    elseif node isa BinaryStateNode

        #Plot the full prediction
        state_name = "prediction"

        #For categorical state nodes
    elseif node isa CategoricalStateNode

        #Plot the prediction
        state_name = "prediction"

        #For input nodes
    elseif node isa AbstractInputNode

        #Plot the input value
        state_name = "input_value"
    end

    #Make a trajectory plot
    plot_trajectory_hgf(hgf, node_name, state_name; kwargs...)

end

function ActionModels.plot_trajectory!(hgf::HGF, node_name::String; kwargs...)

    #If the target node is not in in the HGF
    if !(node_name in keys(hgf.all_nodes))
        #Throw an error
        throw(ArgumentError("The node $node_name does not exist"))
    end

    #Get out the node
    node = hgf.all_nodes[node_name]

    #For continuous state nodes
    if node isa ContinuousStateNode

        #Plot the full posterior
        state_name = "posterior"

        #For binary state nodes
    elseif node isa BinaryStateNode

        #Plot the full prediction
        state_name = "prediction"

        #For categorical state nodes
    elseif node isa CategoricalStateNode

        #Plot the prediction
        state_name = "prediction"

        #For input nodes
    elseif node isa AbstractInputNode

        #Plot the input value
        state_name = "input_value"
    end

    #Make a trajectory plot
    plot_trajectory_hgf!(hgf, node_name, state_name; kwargs...)

end



### If both a node and a state was specified ###
function ActionModels.plot_trajectory(
    hgf::HGF,
    target_state::Tuple{String,String};
    kwargs...,
)

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
    plot_trajectory_hgf(hgf, node_name, state_name; kwargs...)

end

function ActionModels.plot_trajectory!(
    hgf::HGF,
    target_state::Tuple{String,String};
    kwargs...,
)

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
    plot_trajectory_hgf!(hgf, node_name, state_name; kwargs...)

end


@userplot Plot_Trajectory_HGF

@recipe function f(pl::Plot_Trajectory_HGF)

    #Get the hgf, the node name and the state name
    hgf = pl.args[1]
    node_name = pl.args[2]
    state_name = pl.args[3]

    #Get the node
    node = hgf.all_nodes[node_name]

    #Get the timesteps
    timesteps = hgf.timesteps

    #If the entire distribution is to be plotted
    if state_name in ["posterior", "prediction"] && !(node isa CategoricalStateNode)

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
            title --> "State trajectory"

            #Unless its a binary state node
            if !(node isa BinaryStateNode)
                #The ribbon is the standard deviations
                ribbon := history_sd
            end

            #Plot the history of means
            (timesteps, history_mean)
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

            #The categorical state node has a vector fo vectors as history
            if node isa CategoricalStateNode
                #So it needs to be collapsed into a matrix
                state_history = reduce(vcat, transpose.(state_history))

                #Set the labels to be the category numbers
                category_numbers = collect(1:size(state_history, 2))
                category_labels = "Category " .* string.(category_numbers)
                label --> permutedims(category_labels)
            else
                #Set label
                label --> node_name * " " * state_name
            end

            #Set title
            title --> "State trajectory"

            #Plot the history
            (timesteps, state_history)
        end
    end
end
