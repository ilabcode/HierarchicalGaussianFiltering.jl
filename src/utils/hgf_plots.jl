@userplot Trajectory_Plot
@recipe function f(pl::Trajectory_Plot)
    hgf = pl.args[1]
    node = pl.args[2]
    if node in keys(hgf.state_nodes)
        property = pl.args[3]
        if property in ["posterior", "prediction"]
            mean = getproperty(hgf.state_nodes[node].history, Symbol(property * "_mean"))
            precision = getproperty(hgf.state_nodes[node].history, Symbol(property * "_precision"))
            sd = sqrt.(1 / (precision))
            @series begin
                ribbon := sd
                mean
            end
        elseif property in ["value_prediction_error", "volatility_prediction_error"]
            error = getproperty(hgf.state_nodes[node].history, Symbol(property))
            @series begin
                error
            end
        else
            print("error")
        end
    end
    if node in keys(hgf.input_nodes)
        input = hgf.input_nodes[node].history.input_value
        @series begin
            seriestype := :scatter
            input
        end
    end
end