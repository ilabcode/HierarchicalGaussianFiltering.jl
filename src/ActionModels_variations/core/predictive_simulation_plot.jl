"""
"""
function ActionModels.predictive_simulation_plot(
    hgf::HGFStruct,
    parameter_distributions::Union{Chains,Dict},
    target_state::Union{String,Tuple},
    inputs::Vector;
    n_simulations::Int = 1000,
    median_color::Union{String,Symbol} = :red,
    title::String = "",
    alpha::Real = 0.1,
    linewidth::Real = 2,
)
    #Set an empty action model
    empty_action_model = function ()
        return nothing
    end

    #Create an agent containing the HGF
    agent = init_agent(empty_action_model, hgf)

    #Run the plotting function on the agent
    predictive_simulation_plot(
        agent,
        parameter_distributions,
        target_state,
        inputs;
        n_simulations,
        median_color,
        title,
        alpha,
        linewidth,
    )
end