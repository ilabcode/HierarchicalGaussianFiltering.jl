```@meta
EditURL = "<unknown>/tutorials/classic_binary.jl"
```

This tutorial is a copy of the 3 level binary hgf tutorial in MATLAB

First load packages

````@example classic_binary
using Turing
using HGF
using Plots
pyplot()
````

Create an HGF

````@example classic_binary
my_hgf = HGF.premade_hgf("binary_3level");

my_agent = HGF.premade_agent("hgf_unit_square_sigmoid_action", my_hgf);
nothing #hide
````

Load the data

````@example classic_binary
inputs = Float64[]
open("tutorials/data/classic_binary_inputs.dat") do f
    for ln in eachline(f)
        push!(inputs, parse(Float64, ln))
    end
end
````

Set parameters

````@example classic_binary
HGF.get_params(my_agent)

params_list = (
    sigmoid_action_precision = 5,
    u__category_means = Real[0.0, 1.0],
    u__input_precision = Inf,
    u__x1_coupling_strenght = 1.0,
    x1__x2_coupling_strenght = 1.0,
    x2__evolution_rate = -2.5,
    x2__x3_coupling_strenght = 1.0,
    x2__initial_mean = 0,
    x2__initial_precision = 1,
    x3__evolution_rate = -6.0,
    x3__initial_mean = 1,
    x3__initial_precision = 1,
);

HGF.set_params!(my_agent, params_list)
HGF.reset!(my_agent)
````

Evolve agent and save responses

````@example classic_binary
responses = HGF.give_inputs!(my_agent, inputs);
nothing #hide
````

Plot the trajectory of the agent

````@example classic_binary
hgf_trajectory_plot(my_agent, "u", "input_value", markersize=3)
hgf_trajectory_plot!(my_agent, "x1", "prediction")
````

Set fixed parameters (uses the agent as default)

````@example classic_binary
fixed_params_list = (
    sigmoid_action_precision = 5,
    u__category_means = Real[0.0, 1.0],
    u__input_precision = Inf,
    u__x1_coupling_strenght = 1.0,
    x1__x2_coupling_strenght = 1.0,
    x2__x3_coupling_strenght = 1.0,
    x2__initial_mean = 0,
    x2__initial_precision = 1,
    x3__initial_mean = 1,
    x3__initial_precision = 1,
);
nothing #hide
````

Set priors for parameter recovery

````@example classic_binary
params_prior_list =
    (x2__evolution_rate = Normal(-3.0, 16), x3__evolution_rate = Normal(-6.0, 16));
nothing #hide
````

Fit the responses
chain = HGF.fit_model(
    my_agent,
    inputs,
    responses,
    params_prior_list,
    fixed_params_list,
    HMC(0.5, 3),
)

Plot the posterior
prior_posterior_plot(chain, params_prior_list)

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

