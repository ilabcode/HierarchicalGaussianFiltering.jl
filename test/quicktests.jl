using HierarchicalGaussianFiltering

hgf = premade_hgf("continuous_2level")

update_hgf!(hgf, [1.0, 1.02, 1.06])