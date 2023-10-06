using HierarchicalGaussianFiltering

hgf = premade_hgf("continuous_2level", verbose = true)

update_hgf!(hgf, [0.01, 0.02, 0.06])

get_states(hgf)
