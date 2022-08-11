"""
"""
function predictive_simulation_plot(
    hgf::HGFStruct,
    distributions::Union{Chains,NamedTuple},
    target_state::String,
    input;
    n_simulations::Int = 1000,
    median_color = "red",
    title = "",
    alpha = 0.1,
    linewidth = 2,
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
        distributions,
        target_state,
        input;
        n_simulations = n_simulations,
        median_color = median_color,
        title = title,
        alpha = alpha,
        linewidth = linewidth,
    )

end
