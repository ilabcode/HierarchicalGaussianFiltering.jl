using HierarchicalGaussianFiltering
using ActionModels

hgf=premade_hgf("continuous_2level", verbose = false)
get_params(hgf)

##### SETTING MULTIPLE PARAMETER VALUES #########
#################################################

shared_parameters = Dict(("x2","evolution_rate")=>
                                [("x1", "evolution_rate"),
                                ("x1", "initial_mean"),
                                ("u", "evolution_rate")])


# setting the same parameter values for values in dict
for value in shared_parameters[("x2", "evolution_rate")]
    set_params!(hgf,value,10)
end
get_params(hgf)


#############################################################
##### SETTING MULTIPLE PARAMETER VALUES WITH NUMBER #########
#############################################################


shared_parameters = Dict(("x2","evolution_rate")=>
                                (9, [("x1", "evolution_rate"),
                                ("x1", "initial_mean"),
                                ("u", "evolution_rate")]))

shared_parameters[("x2","evolution_rate")]
parameter_value = shared_parameters[("x2","evolution_rate")][1]

for i in 2:length(shared_parameters[("x2","evolution_rate")])
    set_params!(hgf,shared_parameters[("x2","evolution_rate")][i],parameter_value)
end

get_params(hgf)


shared_parameter = keys(shared_parameters)