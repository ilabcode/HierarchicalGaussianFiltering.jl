"""
    function premade_hgf(
        model_name,
        params,
        starting_state,
    )

Function for initializing the structure of an HGF model.
"""
function premade_hgf(model_name::String, config::Dict = Dict(); verbose = true)

    #A list of all the included premade models
    premade_models = Dict(
        "continuous_2level" => premade_continuous_2level,   #The standard continuous input 2 level HGF
        "binary_2level" => premade_binary_2level,           #The standard binary input 2 level HGF
        "binary_3level" => premade_binary_3level,           #The standard binary input 3 level HGF
        "JGET" => premade_JGET,                             #The JGET model
    )

    #Check that the specified model is in the list of keys
    if model_name in keys(premade_models)
        #Create the specified model
        return premade_models[model_name](config, verbose = verbose)
        #If the user asked for help
    elseif model_name == "help"
        #Return the list of keys
        print(keys(premade_models))
        return nothing
        #If an invalid name is given
    else
        #Raise an error
        throw(
            ArgumentError(
                "the specified string does not match any model. Type premade_hgf('help') to see a list of valid input strings",
            ),
        )
    end
end
