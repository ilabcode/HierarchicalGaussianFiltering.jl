@userplot HGF_Trajectory_Plot

@recipe function f(pl::HGF_Trajectory_Plot)
    if typeof(pl.args[1]) == AgentStruct
        agent = pl.args[1]
        hgf = agent.perception_struct
    else
        hgf = pl.args[1]
    end
    if pl.args[2] in keys(hgf.state_nodes)
        node = pl.args[2]
        if length(pl.args) <= 2
            property = "posterior"
        else
            property = pl.args[3]
        end
        if property in ["posterior", "prediction"]
            mean = replace(getproperty(hgf.state_nodes[node].history, Symbol(property * "_mean")),missing=>NaN)
            precision =
            replace(getproperty(hgf.state_nodes[node].history, Symbol(property * "_precision")),missing=>NaN)
            sd = sqrt.(1 ./ precision)
            @series begin
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
                ribbon := coeff*sd
                c := "red"
                label --> node * " " * property * " mean"
                mean
            end
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
            value = replace(getproperty(hgf.state_nodes[node].history, Symbol(property)),missing=>NaN)
            @series begin
                label --> node * " " * property
                value
            end
        else
            error(property * " is not a supported property for state nodes.")
        end
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
    elseif pl.args[2] in keys(agent.history)
        property = pl.args[2]
        response = replace(agent.history[property],missing=>NaN)
        @series begin
            seriestype := :scatter
            label --> property
            markersize --> 5
            response
        end
    else
        error(node * " is not an HGF node or an agent property")
    end
end
