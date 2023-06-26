# # Creating an HGF and HGF agent

# In this section we will cover the types of nodes, their parameters and the rules for structuring your own HGF. 

# ### Overview

# ![states and parameters](../images/states_nodes/all_states.svg)

# ## Building principles

# The following rules apply for connecting nodes, when customizing your own HGF structure:

# ### Binary state node rules:
 
# - Can only have exactly one value parent
# - Can only have excatly one value child
# - Can only have a contionus state node as value parent

# ![states and parameters](../images/states_nodes/binary_nodes.svg)

# ### continuous state node rules:

# - Can’t have binary input node as child
# - Can’t have binary input node as volatility child
# - Contionus state node having a binary input node as volatility child
# - Can’t have contionus input node as value child while also having volatility children
# - Can’t have the same value parent as volatility parent
# - Can’t have the same value child as volatility child

# ![states and parameters](../images/states_nodes/continuous_nodes.svg)

# ### Categorical state node rules:

# - Can only have exactly one value child
# - Can only have categorical input node as child
# - Can only have binary state node as parents

# ![states and parameters](../images/states_nodes/categorical_nodes.svg)