"""
    function premade_agent(
        model_name::String,
        perception_model = (;),
        params = Dict(),
        states = Dict(),
        settings = (;),
    )

Function for initializing the structure of an agent model.
"""
function premade_agent(
    model_name::String,
    perception_model = (;),
    params = Dict(),
    states = Dict(),
    settings = Dict(),
)

    #A list of all the included premade models
    premade_models = Dict(
        "hgf_gaussian_action" => gaussian_action,                           #A gaussian action based on an hgf
        "hgf_binary_softmax_action" => binary_softmax_action,               #A binary softmax action based on an hgf
        "hgf_unit_square_sigmoid_action" => unit_square_sigmoid_action,   #A binary unit square sigmoid action based on an hgf
    )

    #If the user asked for help
    if model_name == "help"
        #Return the list of keys
        print(keys(premade_models))
        return nothing

        #If the specified model is not in the list of keys
    elseif model_name ∉ keys(premade_models)
        #Raise an error
        throw(
            ArgumentError(
                "the specified string does not match any model. Type premade_agent('help') to see a list of valid input strings",
            ),
        )

        #Otherwise
    else
        #Create an agent with the corresponding model
        agent = HGF.init_agent(
            premade_models[model_name],
            perception_model,
            params,
            states,
            settings,
        )

        #Return the agent
        return agent
    end
end




#Create the function
function gaussian_action(action_struct, input)

    #Get out settings
    target_node = action_struct.settings["target_node"]
    target_state = action_struct.settings["target_state"]
    #Get out parameters
    action_precision = action_struct.params["action_precision"]

    #Get out the HGF
    hgf = action_struct.perception_struct

    #Update the HGF
    hgf.perception_model(hgf, input)

    #Extract the specified state from the specified node
    target_state = getproperty(hgf.state_nodes[target_node].state, Symbol(target_state))

    #Create normal distribution with mean of the target value and a standard deviation from parameters
    distribution = Distributions.Normal(target_state, 1 / action_precision)

    #Return the action distribution
    return distribution
end



function binary_softmax_action(action_struct, input)

    #Get out settings
    target_node = action_struct.settings["target_node"]
    target_state = action_struct.settings["target_state"]
    #Get out parameters
    action_precision = action_struct.params["action_precision"]

    #Get out the HGF
    hgf = action_struct.perception_struct

    #Update the HGF
    hgf.perception_model(hgf, input)

    #Extract the specified state from the specified node
    target_state = getproperty(hgf.state_nodes[target_node].state, Symbol(target_state))

    #Use sotmax to get the action probability 
    action_probability = 1 / (1 + exp(-action_precision * target_state))

    #Create Bernoulli normal distribution with mean of the target value and a standard deviation from parameters
    distribution = Distributions.Bernoulli(action_probability)

    #Return the action distribution
    return distribution
end


function unit_square_sigmoid_action(action_struct, input)

    #Get out settings
    target_node = action_struct.settings["target_node"]
    target_state = action_struct.settings["target_state"]
    #Get out parameters
    action_precision = action_struct.params["action_precision"]

    #Get out the HGF
    hgf = action_struct.perception_struct

    #Update the HGF
    hgf.perception_model(hgf, input)

    #Extract the specified state from the specified node
    target_state = getproperty(hgf.state_nodes[target_node].state, Symbol(target_state))

    #Use sotmax to get the action probability 
    action_probability =
        target_state^action_precision /
        (target_state^action_precision + (1 - target_state)^action_precision)

    #Create Bernoulli normal distribution with mean of the target value and a standard deviation from parameters
    distribution = Distributions.Bernoulli(action_probability)

    #Return the action distribution
    return distribution
end







# """
#     create_gaussian_action(state::String)

# Function for creating a customized gaussian action action model. Takes a node name and a state as arguments. Outputs a function which reports the chosen state from the chosen node with some noise.
# """
# function create_gaussian_action(; state::String = "x1__posterior_mean")

#     #Separate into node and state
#     node, state = split(state, "__")

#     #Change the state to a symbol
#     state = Symbol(state)

#     #Evaluate the function definition
#     eval(quote

#         #Create the function
#         function gaussian_action(action_struct, input)

#             #Get out parameters
#             action_precision = action_struct.params["action_precision"]

#             #Get out the HGF
#             hgf = action_struct.perception_struct

#             #Update the HGF
#             hgf.perception_model(hgf, input)

#             #Extract the specified state from the specified node
#             target_state = hgf.state_nodes[$node].state.$state

#             #Create normal distribution with mean of the target value and a standard deviation from parameters
#             distribution = Distributions.Normal(target_state, 1 / action_precision)

#             #Return the action distribution
#             return distribution
#         end
#     end)

#     #Return the action model
#     return gaussian_action
# end


# """
#     create_binary_softmax_action(; state::String = "x1__prediction_mean") 

# Function for creating a customized binary softmax action model. Takes a state as argument. Outputs a function which inputs the state into a softmax, to get the action probability for a Bernoulli distribution.
# """
# function create_binary_softmax_action(; state::String = "x1__prediction_mean")

#     #Separate into node and state
#     node, state = split(state, "__")

#     #Change the state to a symbol
#     state = Symbol(state)

#     #Evaluate the function definition
#     eval(quote

#         #Create the function
#         function binary_softmax_action(action_struct, input)

#             #Get out parameters
#             action_precision = action_struct.params["action_precision"]

#             #Get out the HGF
#             hgf = action_struct.perception_struct

#             #Update the HGF
#             hgf.perception_model(hgf, input)

#             #Extract the specified state from the specified node
#             target_state = hgf.state_nodes[$node].state.$state

#             #Use sotmax to get the action probability 
#             action_probability = 1 / (1 + exp(-action_precision * target_state))

#             #Create Bernoulli normal distribution with mean of the target value and a standard deviation from parameters
#             distribution = Distributions.Bernoulli(action_probability)

#             #Return the action distribution
#             return distribution
#         end
#     end)

#     return binary_softmax_action
# end


# """
#     create_unit_square_sigmoid_action(; state::String = "x1__prediction_mean") 

# Function for creating a customized binary unit square sigmoid action model. Takes a state as argument. Outputs a function which inputs the state into a unit square sigmoid, to get the action probability for a Bernoulli distribution.
# """
# function create_unit_square_sigmoid_action(; state::String = "x1__prediction_mean")

#     #Separate into node and state
#     node, state = split(state, "__")

#     #Change the state to a symbol
#     state = Symbol(state)

#     #Evaluate the function definition
#     eval(
#         quote

#             #Create the function
#             function unit_square_sigmoid_action(action_struct, input)

#                 #Get out parameters
#                 action_precision = action_struct.params["action_precision"]

#                 #Get out the HGF
#                 hgf = action_struct.perception_struct

#                 #Update the HGF
#                 hgf.perception_model(hgf, input)

#                 #Extract the specified state from the specified node
#                 target_state = hgf.state_nodes[$node].state.$state

#                 #Use sotmax to get the action probability 
#                 action_probability =
#                     target_state^action_precision /
#                     (target_state^action_precision + (1 - target_state)^action_precision)

#                 #Create Bernoulli normal distribution with mean of the target value and a standard deviation from parameters
#                 distribution = Distributions.Bernoulli(action_probability)

#                 #Return the action distribution
#                 return distribution
#             end
#         end,
#     )

#     return unit_square_sigmoid_action
# end











# """
#     create_gaussian_action(state::Vector{String})

# Function for creating a customized gaussian action action model. Takes a node name and a string of states as arguments. Outputs a function which reports a linear combination of the chosen states from the chosen node with some noise.
# """
# function create_gaussian_action(;
#     state::Vector{String} = ["x1__posterior_mean", "x2__posterior_mean"],
# )

#     node, state = split(state, "__")

#     #Change the state to a symbol
#     state = Symbol(state)

#     #Evaluate the function definition
#     eval(
#         quote

#             #Create the function
#             function gaussian_action(action_struct, input)

#                 #Get out the HGF
#                 hgf = action_struct.perception_struct

#                 #Update the HGF
#                 hgf.perception_model(hgf, input)

#                 #Extract the specified state from the specified node
#                 target_state = hgf.state_nodes[$node].state.$state

#                 #Create normal distribution with mean of the target value and a standard deviation from parameters
#                 distribution = Distributions.Normal(
#                     target_state,
#                     1 / action_struct.params["action_precision"],
#                 )

#                 #Return the action distribution
#                 return distribution
#             end
#         end,
#     )

#     #Return the action model
#     return gaussian_action
# end


# """
#     gaussian_action(agent::AgentStruct, input)

# Gaussian action action model. Updates the hgf, extracts the posterior mean for x1, and reports it with some noise
# """
# function gaussian_action(agent::AgentStruct, input)

#     #Get out the HGF
#     hgf = agent.perception_struct

#     #Update the HGF
#     hgf.perception_model(hgf, input)

#     #Extract the posterior belief about x1
#     μ1 = hgf.state_nodes["x1"].state.posterior_mean

#     #Create normal distribution with mean μ1 and a standard deviation from parameters
#     distribution = Distributions.Normal(μ1, 1 / agent.params["action_precision"])

#     #Return the action dsitribution
#     return distribution
# end