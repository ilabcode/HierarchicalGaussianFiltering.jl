"""

    plot_predictive_simulation(hgf::HGF, parameter_distributions::Union{Chains,Dict}, target_state::Union{String,Tuple}, 
    inputs::Vector, n_simulations::Int, median_color::Union{String,Symbol}, title::String, alpha::Real, linewidth::Real )

Function for plotting predictive simulation. Default simulations set to 1000.
"""
function ActionModels.plot_predictive_simulation(
    hgf::HGF,
    parameter_distributions::Union{Chains,Dict},
    target_state::Union{String,Tuple},
    inputs::Vector;
    n_simulations::Int = 1000,
    median_color::Union{String,Symbol} = :red,
    title::String = "",
    alpha::Real = 0.1,
    linewidth::Real = 2,
    verbose::Bool = true,
)
    #Set an empty action model
    empty_action_model = function ()
        return nothing
    end

    #Create an agent containing the HGF
    agent = init_agent(empty_action_model, hgf)

    #Run the plotting function on the agent
    plot_predictive_simulation(
        agent,
        parameter_distributions,
        target_state,
        inputs;
        n_simulations = n_simulations,
        median_color = median_color,
        title = title,
        alpha = alpha,
        linewidth = linewidth,
        verbose = verbose,
    )
end
