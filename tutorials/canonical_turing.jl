using Turing
using HGF

my_hgf = HGF.premade_hgf("continuous_2level");
my_action_model = HGF.gaussian_response
my_pars = Dict("standard_deviation" => 0.5)
starting_state = Dict("action" => 0.)
my_agent = HGF.init_agent(
    my_hgf,
    my_action_model,
    my_pars,
    starting_state
);

input = Float64[]
open("data//canonical_input_trajectory.dat") do f
    for ln in eachline(f)
        push!(input, parse(Float64, ln))
    end
end

