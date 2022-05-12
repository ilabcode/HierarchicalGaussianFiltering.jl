using RecipesBase
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
        if length(pl.args)<=2
            property = "posterior"
        else
            property = pl.args[3]
        end
        if property in ["posterior", "prediction"]
            mean = getproperty(hgf.state_nodes[node].history, Symbol(property * "_mean"))
            precision = getproperty(hgf.state_nodes[node].history, Symbol(property * "_precision"))
            sd = sqrt.(1 ./ precision)
            @series begin
                ribbon := sd
                c:="red"
                mean
            end
        elseif property in ["value_prediction_error", "volatility_prediction_error","posterior_precision","prediction_precision","posterior_mean","prediction_mean", "prediction_volatility", "auxiliary_prediction_precision"]
            value = getproperty(hgf.state_nodes[node].history, Symbol(property))
            @series begin
                value
            end
        else
            error(property*" is not a supported property for state nodes.")
        end
    elseif pl.args[2] in keys(hgf.input_nodes)
        node = pl.args[2]
        if length(pl.args)<=2
            property = "input_value"
        else
            property = pl.args[3]
        end
        if property in ["input_value"]
            input = getproperty(hgf.input_nodes[node].history,Symbol(property))
            @series begin
                seriestype := :scatter
                input
            end
        elseif property in ["value_prediction_error", "volatility_prediction_error", "prediction_precision","prediction_volatility", "auxiliary_prediction_precision"]
            input = getproperty(hgf.input_nodes[node].history,Symbol(property))
            @series begin
                input
            end
        else
            error(property*" is not an input node property")
        end
    elseif pl.args[2] in keys(agent.history)
        property = pl.args[2]
        response = agent.history[property]
        @series begin
            seriestype := :scatter
            response
        end
    else
        error(node*" is not an HGF node or an agent property")
    end
end