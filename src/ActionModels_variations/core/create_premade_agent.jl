"""
    premade_agent(model_name::String, hgf::HGF, config::Dict = Dict(); verbose = true)

Create an agent fom the list of premade agents. If an HGF is passed as a separate argument, add it to the config dictionary.
"""
function ActionModels.premade_agent(
    model_name::String,
    hgf::HGF,
    config::Dict = Dict();
    verbose = true,
)

    #Add the HGF to the parameters list
    parameters = merge(config, Dict("HGF" => hgf))

    #Make the agent as usual
    return premade_agent(model_name, parameters, verbose = verbose)
end
