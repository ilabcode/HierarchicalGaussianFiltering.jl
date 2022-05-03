function get_responses(chain::Chains)
    table = describe(chain)[1]
    last_par = string(last(table.nt.parameters))
    l = parse(Int,(split(last_par,('[',']'))[2]))
    responses = last(table.nt.mean,l)
    return responses
end