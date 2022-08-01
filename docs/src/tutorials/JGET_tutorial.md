```@meta
EditURL = "<unknown>/tutorials/JGET_tutorial.jl"
```

using HGF

using CSV
using DataFrames

using Turing

df = DataFrame(CSV.File("data/R_trialdata.csv"))

subject_20_inputs = Dict("1"=>Float64[],"2"=>Float64[],"3"=>Float64[],"4"=>Float64[])
subject_20_responses = Dict("1"=>Float64[],"2"=>Float64[],"3"=>Float64[],"4"=>Float64[])

subject_20_inputs

df.ID[1]

for row in eachrow(df)
    if row.ID == 20
        push!(subject_20_inputs[string(row.session)],row.outcome)
    end
end

for row in eachrow(df)
    if row.ID == 20
        push!(subject_20_responses[string(row.session)],row.response)
    end
end

subject_20_inputs
subject_20_responses

my_hgf = HGF.premade_hgf("JGET");

my_agent = HGF.premade_agent(
    "hgf_gaussian_response",
    my_hgf,
    Dict("action_noise" => 1),
    Dict(),
    (; node = "x1", state = "posterior_mean"),
);

HGF.get_params(my_agent)

inputs = subject_20_inputs["1"]
responses = subject_20_responses["1"]
firstinput = inputs[1]
first20_variance = Turing.Statistics.var(inputs[1:20])

fixed_params_list = (u_x1_coupling_strenght = 1.0,
u_x3_coupling_strenght = 1.0, x1_posterior_mean = firstinput,
x1_posterior_precision = exp(-1.0986), x1_x2_coupling_strenght = 1.0,
x4_posterior_mean = 1.0, x4_posterior_precision = exp(2.306),
x2_posterior_mean = 3., x2_posterior_precision = exp(2.306),
x4_evolution_rate = -10.0, x3_posterior_mean = 3.2189,
x3_posterior_precision = exp(-1.0986), x3_x4_coupling_strenght = 1.0,
u_evolution_rate = 1.0,
)

prior_params_list = (
    action_noise = Truncated(Normal(100,20), 0, Inf),
    x1_evolution_rate = Normal(-3,5),
    x2_evolution_rate = Normal(-7,5),
    x3_evolution_rate = Normal(-3,5),
)

chain = HGF.fit_model(my_agent,inputs,responses,prior_params_list,fixed_params_list,NUTS(),1000)

using Plots
using StatsPlots

posterior_parameter_plot(chain,prior_params_list; distributions = true)

fitted_params = HGF.get_params(chain)

HGF.set_params(my_agent,fitted_params)
HGF.set_params(my_agent,fixed_params_list)
HGF.reset!(my_agent)

HGF.give_inputs!(my_agent, inputs)

pyplot()

hgf_trajectory_plot(
    my_agent,
    "u",
    size = (1300, 500),
    xlims = (0, 240),
    markerstrokecolor = :auto,
    markersize = 3,
    markercolor = "green2",
    xlabel="trial",
    title = "Agent simulation"
)
hgf_trajectory_plot!(my_agent, "x1", "posterior_mean", color = "red", linewidth = 1.5)
hgf_trajectory_plot!(
    my_agent,
    "action",
    size = (1300, 500),
    markerstrokecolor = :auto,
    markersize = 3,
    markercolor = "orange",
    xlabel="trial",
)

using LaTeXStrings

hgf_trajectory_plot(
    my_agent,
    "x2",
    color = "blue",
    size = (1300, 500),
    xlims = (0, 240),
    title = L"Posterior\:expectation\,of\,x_{2}",
)

inputs_dict = Dict()
responses_dict = Dict()
chains_dict = Dict()

for row in eachrow(df)
    if !haskey(inputs_dict,row.ID)
        inputs_dict[string(row.ID)]=Dict("1"=>Float64[],"2"=>Float64[],"3"=>Float64[],"4"=>Float64[])
        chains_dict[string(row.ID)]=Dict()
    end
    if !haskey(responses_dict,row.ID)
        responses_dict[string(row.ID)]=Dict("1"=>Float64[],"2"=>Float64[],"3"=>Float64[],"4"=>Float64[])
    end
end

for row in eachrow(df)
    push!(inputs_dict[string(row.ID)][string(row.session)],row.outcome)
end

for row in eachrow(df)
    push!(responses_dict[string(row.ID)][string(row.session)],row.response)
end

#chains_dict["60"]

#HGF.get_params(chain)

for ID in keys(inputs_dict)
    for session in keys(inputs_dict[ID])
        if length(inputs_dict[ID][session])>0
            inputs = inputs_dict[ID][session]
            responses = responses_dict[ID][session]
            firstinput = inputs[1]
            fixed_params_list = (u_x1_coupling_strenght = 1.0,
                u_x3_coupling_strenght = 1.0, x1_posterior_mean = firstinput,
                x1_posterior_precision = exp(-1.0986), x1_x2_coupling_strenght = 1.0,
                x4_posterior_mean = 1.0, x4_posterior_precision = exp(2.306),
                x2_posterior_mean = 3., x2_posterior_precision = exp(2.306),
                x4_evolution_rate = -10.0, x3_posterior_mean = 3.2189,
                x3_posterior_precision = exp(-1.0986), x3_x4_coupling_strenght = 1.0,
                u_evolution_rate = 1.0,
            )
            prior_params_list = (
                action_noise = Truncated(Normal(100,20), 0, Inf),
                x1_evolution_rate = Normal(-3,5),
                x2_evolution_rate = Normal(-7,5),
                x3_evolution_rate = Normal(-3,5),
            )

            @time chain = HGF.fit_model(my_agent,inputs,responses,prior_params_list,fixed_params_list,NUTS(0.65),1000)
            chains_dict[ID][session] = chain
        end
    end
end

chains_dict["20"]

chains_dict["32"]["1"]

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

