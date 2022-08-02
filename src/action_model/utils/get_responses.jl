"""
"""
function get_responses(chain::Chains)
    table = describe(chain)[1]
    last_par = string(last(table.nt.parameters))
    l = parse(Int, (split(last_par, ('[', ']'))[2]))
    responses = last(table.nt.mean, l)
    return responses
end

"""
"""
function get_responses(agent::AgentStruct, inputs::Vector{Float64})
    responses = Float64[]
    for input in inputs
        HGF.give_inputs!(agent, input)
        push!(responses, agent.state["action"])
    end
    reset!(agent)
    return responses
end