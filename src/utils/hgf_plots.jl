@userplot Trajectory_Plot
@recipe function f(pl::Trajectory_Plot)
    mean = pl.args[1].state_nodes["x1"].history.posterior_mean
    precision = pl.args[1].state_nodes["x1"].history.posterior_precision
    input = pl.args[1].input_nodes["u"].history.input_value
    sd = sqrt.(1/(precision))
    @series begin
        seriestype := :scatter
        input
    end

    ribbon := sd
    mean
end

# @recipe function f(pl::Trajectory_Plot)
#     node = pl.args[2]
#     mean = pl.args[1].state_nodes[node].history.posterior_mean
#     precision = pl.args[1].state_nodes[node].history.posterior_precision

#     input = pl.args[1].input_nodes["u"].history.input_value
#     sd = sqrt.(1/(precision))
#     @series begin
#         seriestype := :scatter
#         input
#     end

#     ribbon := sd
#     mean
# end