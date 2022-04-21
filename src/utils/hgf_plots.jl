using RecipesBase
@userplot HGF_Trajectory_Plot
@recipe function f(pl::HGF_Trajectory_Plot)
    hgf = pl.args[1]
    node = pl.args[2]
    if node in keys(hgf.state_nodes)
        if length(pl.args)<=2
            property = "posterior"
        else
            property = pl.args[3]
        end
        if property in ["posterior", "prediction"]
            mean = getproperty(hgf.state_nodes[node].history, Symbol(property * "_mean"))
            precision = getproperty(hgf.state_nodes[node].history, Symbol(property * "_precision"))
            sd = 1.96*sqrt.(1 / precision)
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
    elseif node in keys(hgf.input_nodes)
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
    else
        error(node*" is not an HGF node")
    end
end