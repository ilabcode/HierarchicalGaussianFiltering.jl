using HierarchicalGaussianFiltering

hgf = premade_hgf("continuous_2level", verbose = false)

give_inputs!(hgf, [0.01, 0.02, 0.06])

get_states(hgf)
