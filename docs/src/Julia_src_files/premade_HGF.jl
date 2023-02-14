# # Premade HGF's in the Hierarchical Gaussian Filtering package

# For information on states and parameters of the nodes see section on HGF nodes [LINK]

# - [Continous 2-level HGF](#Continuous-2-level-HGF)
# - [JGET HGF](#JGET-HGF)
# - [Binary 2-level HGF](#Binary-2-level-HGF)
# - [Binary 3-level HGF](#Binary-3-level-HGF)
# - [Categorical 3-level HGF](#Categorical-3-level-HGF)
# - [Categorical 3-level state transition HGF](#Categorical-3-level-state-transition)


# ## Continuous 2-level HGF

# The continuous 2-level HGF is structured with following nodes:

# - input node: continuous 
# - state nodes: 
#   - 1st level: continuous (value coupling to input node)
#   - 2nd level: continous (volatility coupling to 1st level)


# ## JGET HGF

# - input node: continuous 
# - state nodes:
#   - 1st level: continuous (value coupling to input node)
#   - 2nd level: continous (volatility coupling to 1st level)
#   - 3rd level: continous (volatility coupling to input node)
#   - 4th level: continous (volatility coupling to 3rd level)

# ## Binary 2-level HGF

# - input node: binary
# - state nodes:
#   - 1st level: binary (value coupling to input node)
#   - 2nd level: continous (volatility coupliong to 1st level)

# ## Binary 3-level HGF

# - input node: Binary
# - state nodes:
#   - 1st level: binary (value coupling to input node)
#   - 2nd level: continous (value coupling to 1st level)
#   - 3rd level: continous (volatility coupling to 2nd level)

# ## Categorical 3-level HGF

# The categorical 3-level HGF model takes an input from one of m categories and learns the probability of a category appearing.

# - input node: categorical
# - state nodes:
#   - 1st level: categorical (value coupling to input node)
#   - 2nd level: m binary (all value couplings to 1st level)
#   - 3rd level: continuous (shared volatility coupling to all m nodes in 2nd level)

# ## Categorical 3-level state transition HGF

# The categorical 3-level HGF model learns state transition probabilities between a set of n categorical startes.

# - input node: categorical
# - state nodes:
#   - 1st level: n categorical state nodes (value coupling to input node)
#   - 2nd level: n binary state nodes pr. n categorical state nodes (value coupling from each categorical state node to n binary state nodes)
#   - 3rd level: continous (volatility coupling to all nodes in 2nd level (n x n nodes))
