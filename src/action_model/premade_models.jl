"""
    function premade_agent(
        model_name::String,
        perception_model = (;),
        params = Dict(),
        states = Dict(),
        specifications = (;),
    )

Function for initializing the structure of an agent model.
"""
function premade_agent(
    model_name::String,
    perception_model = (;),
    params = Dict(),
    states = Dict(),
    specifications = (;),
)

    #A list of all the included premade models
    premade_models = Dict(
        "hgf_gaussian_response" => create_gaussian_response(; specifications...),    #A gaussian response based on an hgf
        "unit_square_sigmoid" => create_unit_square_sigmoid(; specifications...),
        "linear_regression_gaussian" => create_linear_regression_gaussian(; specifications...),
    )

    #If the user asked for help
    if model_name == "help"
        #Return the list of keys
        print(keys(premade_models))
        return nothing
    end

    #If the specified model is not in the list of keys
    if model_name ∉ keys(premade_models)
        #Raise an error
        throw(
            ArgumentError(
                "the specified string does not match any model. Type premade_agent('help') to see a list of valid input strings",
            ),
        )

        #Otherwise
    else
        #Create an agent with the corresponding model
        agent = HGF.init_agent(premade_models[model_name], perception_model, params, states)

        #Return the agent
        return agent
    end
end


"""
    gaussian_response(agent::AgentStruct, input)

Gaussian response action model. Updates the hgf, extracts the posterior mean for x1, and reports it with some noise
"""
function gaussian_response(agent::AgentStruct, input)

    #Get out the HGF
    hgf = agent.perception_struct

    #Update the HGF
    hgf.perception_model(hgf, input)

    #Extract the posterior belief about x1
    μ1 = hgf.state_nodes["x1"].state.posterior_mean

    #Create normal distribution with mean μ1 and a standard deviation from parameters
    distribution = Distributions.Normal(μ1, agent.params["action_noise"])

    #Return the action dsitribution
    return distribution
end



"""
    create_gaussian_response(node::String, state::String)

Function for creating a customized gaussian response action model. Takes a node name and a state as arguments. Outputs a function which reports the chosen state from the chosen node with some noise.
"""
function create_gaussian_response(; node::String = "x1", state::String = "posterior_mean")

    #Change the state to a symbol
    state = Symbol(state)

    #Evaluate the function definition
    eval(
        quote

            #Create the function
            function gaussian_response(action_struct, input)

                #Get out the HGF
                hgf = action_struct.perception_struct

                #Update the HGF
                hgf.perception_model(hgf, input)

                #Extract the specified state from the specified node
                target_state = hgf.state_nodes[$node].state.$state

                #Create normal distribution with mean of the target value and a standard deviation from parameters
                distribution = Distributions.Normal(
                    target_state,
                    action_struct.params["action_noise"],
                )

                #Return the action distribution
                return distribution
            end
        end,
    )

    #Return the action model
    return gaussian_response
end

function unit_square_sigmoid(agent::AgentStruct, input)

    #Get out the HGF
    hgf = agent.perception_struct

    #Update the HGF
    hgf.perception_model(hgf, input)

    #Extract the posterior belief about x1
    μhat1 = hgf.state_nodes["x1"].state.prediction_mean
    ζ = agent.params["inverse_noise"]
    p1  = (μhat1^ζ)/(μhat1^ζ+(1-μhat1)^ζ)
    if p1>1|| p1 === NaN
        p1=1 
    elseif p1<0
        p1 = 0
    end 
    #Create normal distribution with mean μ1 and a standard deviation from parameters
    distribution = Distributions.Bernoulli(p1)

    #Return the action dsitribution
    return distribution
end

function create_unit_square_sigmoid(; node::String = "x1", state::String = "posterior_mean")

    #Change the state to a symbol
    state = Symbol(state)

    #Evaluate the function definition
    eval(
        quote

            #Create the function
            function unit_square_sigmoid(action_struct, input)

                #Get out the HGF
                hgf = action_struct.perception_struct

                #Update the HGF
                hgf.perception_model(hgf, input)

                #Extract the specified state from the specified node
                target_state = hgf.state_nodes[$node].state.$state
                ζ = agent.params["inverse_noise"]
                p1  = (target_state^ζ)/(target_state^ζ+(target_state-1)^ζ)

                #Create normal distribution with mean of the target value and a standard deviation from parameters
                distribution = Distributions.Bernoulli(p1)

                #Return the action distribution
                return distribution
            end
        end,
    )

    #Return the action model
    return unit_square_sigmoid
end

function linear_regression_gaussian(agent::AgentStruct, input)

    #Get out the HGF
    hgf = agent.perception_struct

    #Update the HGF
    hgf.perception_model(hgf, input)

    #Extract the posterior belief about x1
    mean = agent.params["alpha1"]*hgf.state_nodes["x1"].state.prediction_mean + agent.params["alpha2"]*hgf.state_nodes["x2"].state.prediction_mean
    #Create normal distribution with mean μ1 and a standard deviation from parameters
    distribution = Distributions.Normal(mean, agent.params["action_noise"])

    #Return the action dsitribution
    return distribution
end



"""
    create_gaussian_response(node::String, state::String)

Function for creating a customized gaussian response action model. Takes a node name and a state as arguments. Outputs a function which reports the chosen state from the chosen node with some noise.
"""
function create_linear_regression_gaussian(; node::String = "x1", state::String = "posterior_mean")

    #Change the state to a symbol
    #Evaluate the function definition
    eval(
        quote

            #Create the function
            function linear_regression_gaussian(action_struct, input)

                #Get out the HGF
                hgf = action_struct.perception_struct

                #Update the HGF
                hgf.perception_model(hgf, input)

                #Extract the specified state from the specified node
                mean = action_struct.params["alpha1"]*hgf.state_nodes["x1"].state.prediction_mean + action_struct.params["alpha2"]*hgf.state_nodes["x2"].state.prediction_mean
                #Create normal distribution with mean of the target value and a standard deviation from parameters
                distribution = Distributions.Normal(
                    mean,
                    action_struct.params["action_noise"],
                )

                #Return the action distribution
                return distribution
            end
        end,
    )

    #Return the action model
    return linear_regression_gaussian
end