# # Creating an HGF and HGF agent

# In this section we will cover the types of nodes, their parameters and the rules for structuring your own HGF. 


# ### Overview

#   - [The Node Types In an HGF and their states](#The-Node-Types-In-an-HGF)
#   - [Building principles ](#Building-principles )

# ### The Node Types In an HGF

# We have six types of nodes in the HGF: binary (state node and input node), categorical (state node and input node), and continuous (state node and input node).

# If a node's parameters are configured with a default value, they are stated below as well. 

# We provide an overview of the states in each of the nodes. 

# 1. [Binary Nodes](#Binary-Nodes)
#     1. [State Node: States and parameters](#The-states-of-binary-state-nodes-and-parameters)
#     2. [Input Node: States and parameters](#The-states-of-binary-input-nodes-and-parameters)

# 3. [Categorical Nodes](#Categorical-Nodes)
#    1. [State Node: States and parameters](#The-states-of-Categorical-state-nodes-and-parameters)
#    2. [Input Node: States and parameters](#The-states-of-Categorical-Input-nodes-and-parameters)

# 4. [Continuous Nodes](#Continuous-Nodes)
#    1. [State Node: States and parameters](#The-states-of-Continuous-state-nodes-and-parameters)
#    2. [Input Node: States and parameters](#The-states-of-Continuous-Input-nodes-and-parameters)


# ## Binary Nodes

# ### The states of binary state nodes

# - posterior_mean
# - posterior_precision
# - value\_prediction\_error
# - prediction_mean
# - prediction_precision

# ### Parameters

# - Value coupling


# ### The states of binary input nodes and parameters

# - input value
# - value prediction error

# ### Parameters

# - Category means (default is [0,1])
# - Input precision (default is  infinite input precision)


# ## Categorical Nodes

# ### The states of Categorical state nodes and parameters

# - posterior
# - value prediction error
# - prediction

# ### Parameters

# - no parameters in the categorical state node

# ### The states of Categorical input nodes and parameters

# - input value

# ### Parameters

# - no parameters in the categorical state node

# ## Continuous Nodes

# ### The states of Continuous state nodes and parameters

# #### States

# - posterior mean
# - posterior precision
# - value prediction error
# - volatility prediction error
# - prediction mean
# - prediciton volatility
# - prediction precision
# - auxiliary prediction precision

# ### Parameters

# - evolution rate (default is 0)
# - value coupling
# - volatility coupling
# - initial mean (default is 0)
# - initital precision (default is 0)


# ### The states of Continuous input nodes and parameters

# - input value
# - value prediction error
# - volatility prediction error
# - prediction volatility
# - prediction precision

# ### Parameters

# - evolution rate (default is 0)
# - value coupling 
# - volatility coupling
 


# ## Building principles 

# ### Binary state node rules:
 
# - Can only have exactly one value parent
# - Can only have excatly one value child
# - Can only have a contionus state node as value parent

# ### continuous state node rules:

# - Can’t have binary input node as child
# - Can’t have binary input node as volatility child
# - Contionus state node having a binary input node as volatility child
# - Can’t have contionus input node as value child while also having volatility children
# - Can’t have the same value parent as volatility parent
# - Can’t have the same value child as volatility child

# ### Categorical state node rules:

# - Can only have exactly one value child
# - Can only have categorical input node as child
# - Can only have binary state node as parents
