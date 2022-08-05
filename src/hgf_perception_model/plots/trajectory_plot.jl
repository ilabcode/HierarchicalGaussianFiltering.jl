@userplot HGF_Trajectory_Plot #just a trajectory plot [use same get_states syntax as everywhere]

@recipe function f(pl::HGF_Trajectory_Plot)

    #Sort between agent and hgfs
    if typeof(pl.args[1]) == AgentStruct
        agent = pl.args[1]
        hgf = agent.substruct
    else
        hgf = pl.args[1]
    end
    #Check type of specified node
    if pl.args[2] in keys(hgf.state_nodes)
        node = pl.args[2]
        #If you only wrote the node, it's the same as just writing posterior
        if length(pl.args) <= 2
            property = "posterior"
        else
            property = pl.args[3]
        end

        #If full dist specified
        if property in ["posterior", "prediction"]

            #replace missings with NaN, get the history of the state's mean [called means]
            mean = replace(getproperty(hgf.state_nodes[node].history, Symbol(property * "_mean")),missing=>NaN)
            #get precisions
            precision =
            replace(getproperty(hgf.state_nodes[node].history, Symbol(property * "_precision")),missing=>NaN)
            #transform precicions into sds
            sd = sqrt.(1 ./ precision)

            @series begin

                # Should be keyword, specify whether to use sd or CI
                if length(pl.args)<4
                    coeff = 1
                else
                    if pl.args[4] == "standard deviation"
                        coeff = 1
                    elseif pl.args[4] == "confidence interval"
                        coeff = 1.96
                    else
                        error(pl.args[4] * " is not a supported keyword.")
                    end
                end

                #Creates the ribbon
                ribbon := coeff*sd
                #color
                c := "red"
                #legend label
                label --> node * " " * property * " mean"
                #plot the history of means
                mean
            end
        
        #If single state specified
        elseif property in [
            "value_prediction_error",
            "volatility_prediction_error",
            "posterior_precision",
            "prediction_precision",
            "posterior_mean",
            "prediction_mean",
            "prediction_volatility",
            "auxiliary_prediction_precision",
        ]
            #Get history of state
            value = replace(getproperty(hgf.state_nodes[node].history, Symbol(property)),missing=>NaN)
            #plot it
            @series begin
                label --> node * " " * property
                value
            end
        else
            error(property * " is not a state in state nodes.")
        end


    #For input nodes
    elseif pl.args[2] in keys(hgf.input_nodes)
        node = pl.args[2]
        if length(pl.args) <= 2
            property = "input_value"
        else
            property = pl.args[3]
        end
        if property in ["input_value"]
            input = replace(getproperty(hgf.input_nodes[node].history, Symbol(property)),missing=>NaN)
            @series begin
                #Use scatterplot instead
                seriestype := :scatter
                label --> node * " " * property
                markersize --> 5
                input
            end
        elseif property in [
            "value_prediction_error",
            "volatility_prediction_error",
            "prediction_precision",
            "prediction_volatility",
            "auxiliary_prediction_precision",
        ]
            input = replace(getproperty(hgf.input_nodes[node].history, Symbol(property)),missing=>NaN)
            @series begin
                label --> node * " " * property
                input
            end
        else
            error(property * " is not an input node property")
        end
    #If its in the agents history
    elseif pl.args[2] in keys(agent.history)
        property = pl.args[2]
        #Get history
        response = replace(agent.history[property],missing=>NaN)
        @series begin
            seriestype := :scatter #make plot type into an argument
            label --> property
            markersize --> 5
            response
        end
    else
        error(node * " is not an HGF node or an agent property")
    end
end
