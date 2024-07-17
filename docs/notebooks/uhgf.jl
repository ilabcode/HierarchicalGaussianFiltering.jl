### A Pluto.jl notebook ###
# v0.19.42

using Markdown
using InteractiveUtils

# ╔═╡ 4aa60710-27bc-11ef-3c69-fb6843531225
begin
    import Pkg
    # activate the shared project environment
    Pkg.activate(Base.current_project())
    # instantiate, i.e. make sure that all packages are downloaded
    Pkg.instantiate()
    using ActionModels
    using HierarchicalGaussianFiltering
    using CSV
    using DataFrames
    using Plots
    using StatsPlots
    using Distributions
end


# ╔═╡ 17cd12ca-907e-4346-a01a-83d905a195a4
md"# Testing the uHGF"

# ╔═╡ cf614e5a-a713-4400-9144-60c7887b3a46
md"## Define a standard binary 3-level HGF"

# ╔═╡ aa28184d-9773-4fad-bc01-7962d22fac78
hgf_parameters = Dict(
    ("u", "category_means") => Real[0.0, 1.0],
    ("u", "input_precision") => Inf,
    ("xprob", "volatility") => 2.0,
    ("xprob", "initial_mean") => 0,
    ("xprob", "initial_precision") => 1,
    ("xvol", "volatility") => -3.0,
    ("xvol", "initial_mean") => 1,
    ("xvol", "initial_precision") => 1,
    ("xbin", "xprob", "coupling_strength") => 1.0,
    ("xprob", "xvol", "coupling_strength") => 1.0,
);

# ╔═╡ f962d241-48f9-4110-83fb-45726579c709
hgf = premade_hgf("binary_3level", hgf_parameters, verbose = false)

# ╔═╡ dd1a3a31-29b0-4791-84bf-a9affa9df3f2
md"## Create an agent"

# ╔═╡ f1b4804c-c867-46ad-8cd1-e0cfba2ade45
agent_parameters = Dict("action_noise" => 0.2);

# ╔═╡ 25844c3b-c4ee-46a7-b6bb-e3ad876c785a
agent = premade_agent("hgf_unit_square_sigmoid", hgf, agent_parameters, verbose = false)

# ╔═╡ b00a41be-7050-4b4f-a188-57e840acb53a
md"## Get inputs and evolve the agent"

# ╔═╡ df44d01d-4297-43ac-9b0d-627a6a17de21
md"## Trajectories"

# ╔═╡ b641bdc2-30c4-4cbd-bc8d-369d8912e182
begin
    plot_trajectory(agent, ("u", "input_value"))
    plot_trajectory!(agent, ("xbin", "prediction"))
end

# ╔═╡ f2d9b80e-41cf-425d-a1ce-c3c3316ecd1d
plot_trajectory(agent, ("xprob", "posterior"))

# ╔═╡ 4c4956a7-d9b4-42ce-85fe-4f156d180224
plot_trajectory(agent, ("xvol", "posterior"))

# ╔═╡ acfc9fe9-e557-4882-8e9e-b567916661a7
md"## Configuration"

# ╔═╡ 6eacb1dc-074c-4eae-81d4-73e078f1dbb7
data_path = "../julia_files/tutorials/data/"

# ╔═╡ 292e9b1d-0281-4e9f-b0db-d220cd29b322
inputs = CSV.read(data_path * "classic_binary_inputs.csv", DataFrame)[!, 1];

# ╔═╡ ce870931-2a2b-4f5c-98ea-847fc652a69f
actions = give_inputs!(agent, inputs)

# ╔═╡ Cell order:
# ╟─17cd12ca-907e-4346-a01a-83d905a195a4
# ╟─cf614e5a-a713-4400-9144-60c7887b3a46
# ╠═aa28184d-9773-4fad-bc01-7962d22fac78
# ╠═f962d241-48f9-4110-83fb-45726579c709
# ╟─dd1a3a31-29b0-4791-84bf-a9affa9df3f2
# ╠═f1b4804c-c867-46ad-8cd1-e0cfba2ade45
# ╠═25844c3b-c4ee-46a7-b6bb-e3ad876c785a
# ╟─b00a41be-7050-4b4f-a188-57e840acb53a
# ╠═292e9b1d-0281-4e9f-b0db-d220cd29b322
# ╠═ce870931-2a2b-4f5c-98ea-847fc652a69f
# ╟─df44d01d-4297-43ac-9b0d-627a6a17de21
# ╠═b641bdc2-30c4-4cbd-bc8d-369d8912e182
# ╠═f2d9b80e-41cf-425d-a1ce-c3c3316ecd1d
# ╠═4c4956a7-d9b4-42ce-85fe-4f156d180224
# ╟─acfc9fe9-e557-4882-8e9e-b567916661a7
# ╠═6eacb1dc-074c-4eae-81d4-73e078f1dbb7
# ╠═4aa60710-27bc-11ef-3c69-fb6843531225
