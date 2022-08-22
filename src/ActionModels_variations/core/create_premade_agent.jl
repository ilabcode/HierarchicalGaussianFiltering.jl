"""
    premade_agent(model_name::String, hgf::HGFStruct, params_list::NamedTuple = (;))

Function for making a premade agent, where a HGF is passed as a separate argument.
"""
function ActionModels.premade_agent(model_name::String, hgf::HGFStruct, params::Dict = Dict())

    #Add the HGF to the params list
    params = merge(params, Dict("HGF" => hgf))

    #Make the agent as usual
    return premade_agent(model_name, params)
end

