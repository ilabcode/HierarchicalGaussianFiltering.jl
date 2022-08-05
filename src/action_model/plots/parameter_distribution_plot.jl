@userplot Parameter_Distribution_Plot

@recipe function f(
    pl::Parameter_Distribution_Plot;
    show_distributions = true,
    show_intervals = true,
    subplot_title_list = [],
    prior_color = :green,
    posterior_color = :orange,
    prior_interval_offset = 0,
    posterior_interval_offset = 0.01,
    inner_interval = 0.5,
    outer_interval = 0.8,
    plot_width = 900,
    plot_height = 300,
)

    #Get arguments
    chain = pl.args[1]
    params_prior_list = pl.args[2]


    #Make empty lists for populating with names, titles, medians and interval bounds
    param_names = []
    subplot_titles = []
    prior_median = []
    posterior_median = []

    prior_inner_interval_lower = []
    prior_inner_interval_upper = []
    prior_outer_interval_lower = []
    prior_outer_interval_upper = []

    posterior_inner_interval_lower = []
    posterior_inner_interval_upper = []
    posterior_outer_interval_lower = []
    posterior_outer_interval_upper = []

    #Initialize empty dictionary for storing quantile values for each parameter
    param_quantiles = Dict()


    ### Get uncertainty interval bar sizes ###
    #Set quantiles that corresponds to specified uncertainty intervals
    interval_quantiles = [
        0.5 - outer_interval * 0.5,
        0.5 - inner_interval * 0.5,
        0.5,
        0.5 + inner_interval * 0.5,
        0.5 + outer_interval * 0.5,
    ]


    #For each parameter
    for (param_name, param_prior) in params_prior_list

        #Add the name to a list
        push!(param_names, param_name)



        #Get posterior from the chain
        param_posterior = Array(chain[:, String(param_name), :])[:]

        #Get the quantiles for the prior and posterior
        prior_quantiles = Turing.Statistics.quantile(param_prior, interval_quantiles)
        posterior_quantiles = Turing.Statistics.quantile(param_posterior, interval_quantiles)

        #Save them in the dictionary
        param_quantiles[param_name] = (;
            prior_quantiles = prior_quantiles,
            posterior_quantiles = posterior_quantiles,
        )




        #If the user has specified a subplot title
        if param_name in keys(subplot_title_list)
            #Add the user-specified title to the list
            push!(subplot_titles, getindex(subplot_title_list, Symbol(param_name)))
            
            #Otherwise
        else
            #Use the parameter name as the subplot title
            push!(subplot_titles, param_name)
        end



        #[prior_median is prior_median]
        #Add values to lists
        push!(prior_median, param_quantiles[param_name].prior_quantiles[3])
        push!(posterior_median, param_quantiles[param_name].posterior_quantiles[3])
        #Add the sizes fo the error bars (which are the quantiles)
        push!(prior_inner_interval_lower, (param_quantiles[param_name].prior_quantiles[3] - param_quantiles[param_name].prior_quantiles[2]))
        push!(prior_inner_interval_upper, (param_quantiles[param_name].prior_quantiles[4] - param_quantiles[param_name].prior_quantiles[3]))
        push!(prior_outer_interval_lower, (param_quantiles[param_name].prior_quantiles[3] - param_quantiles[param_name].prior_quantiles[1]))
        push!(prior_outer_interval_upper, (param_quantiles[param_name].prior_quantiles[5] - param_quantiles[param_name].prior_quantiles[3]))

        push!(
            posterior_inner_interval_lower,
            (param_quantiles[param_name].posterior_quantiles[3] - param_quantiles[param_name].posterior_quantiles[2]),
        )
        push!(
            posterior_inner_interval_upper,
            (param_quantiles[param_name].posterior_quantiles[4] - param_quantiles[param_name].posterior_quantiles[3]),
        )
        push!(
            posterior_outer_interval_lower,
            (param_quantiles[param_name].posterior_quantiles[3] - param_quantiles[param_name].posterior_quantiles[1]),
        )
        push!(
            posterior_outer_interval_upper,
            (param_quantiles[param_name].posterior_quantiles[5] - param_quantiles[param_name].posterior_quantiles[3]),
        )





    end



    ### Create plots ###

    #number of subplots
    l = length(param_names)

    #Specify how to arrange subplots, and their size
    layout := (l, 1)
    size := (plot_width, plot_height * l)

    #For each subplot
    for i = 1:l

        #Set the title
        title := subplot_titles[i]

        #Aesthetic settings
        yshowaxis := false
        yticks := false

        #The font size
        legendfontsize --> 15

        ### Plot prior and posterior distribution ###
        #if show distributions
        if show_distributions

            #Plot the prior
            @series begin
                #color
                color := prior_color
                #transparency
                fill := (0, 0.5)
                #subplot nr
                subplot := i
                #Only put legend on first plot
                if i != 1
                    legend := nothing
                end
                #Empty labels
                label := nothing
                #Get the distribution to plot it
                params_prior_list[Symbol(param_names[i])]
            end

            #Plot the posterior
            @series begin
                #This is a density (not a functional form)
                seriestype := :density

                color := posterior_color
                fill := (0, 0.5)
                subplot := i
                if i != 1
                    legend := nothing
                end
                label := nothing

                #Make an array of samples for the specified parameter to plot it
                Array(chain[:, param_names[i], :])[:]
            end
        end


        ### Plot prior median and errorbar ###
        @series begin
            seriestype := :scatter
            color := prior_color
            subplot := i

            #Set size of big errorbar
            xerror := ([prior_outer_interval_lower[i]], [prior_outer_interval_upper[i]])

            markerstrokewidth := 1 #thickness
            markerstrokecolor := prior_color
            if i != 1
                legend := nothing
            end
            label := nothing
            #Need to plot the point in order to make the rrorbar
            [(prior_median[i], prior_interval_offset)]
        end
        #plot small errorbar
        @series begin
            seriestype := :scatter
            color := prior_color
            subplot := i
            xerror := ([prior_inner_interval_lower[i]], [prior_inner_interval_upper[i]])
            markerstrokewidth := 3 #thickness
            markerstrokecolor := prior_color
            if i != 1
                legend := nothing
            end
            label := nothing
            [(prior_median[i], prior_interval_offset)]
        end

        #Plot point
        @series begin
            seriestype := :scatter
            color := prior_color
            subplot := i
            markerstrokewidth := 1
            markersize := 5
            if i != 1
                legend := nothing
            end
            label := "Prior"
            [(prior_median[i], prior_interval_offset)]
        end



        ### Plot posterior median and errorbar ###
        @series begin
            seriestype := :scatter
            color := posterior_color
            subplot := i
            xerror := ([posterior_outer_interval_lower[i]], [posterior_outer_interval_upper[i]])
            markerstrokewidth := 1
            markerstrokecolor := posterior_color
            if i != 1
                legend := nothing
            end
            label := nothing
            [(posterior_median[i], posterior_interval_offset)]
        end
        @series begin
            seriestype := :scatter
            color := posterior_color
            subplot := i
            xerror := ([posterior_inner_interval_lower[i]], [posterior_inner_interval_upper[i]])
            markerstrokewidth := 3
            markerstrokecolor := posterior_color
            if i != 1
                legend := nothing
            end
            label := nothing
            [(posterior_median[i], posterior_interval_offset)]
        end
        @series begin
            seriestype := :scatter
            color := posterior_color
            markersize := 5
            subplot := i
            markerstrokewidth := 1
            if i != 1
                legend := nothing
            end
            label := "Posterior"
            [(posterior_median[i], posterior_interval_offset)]
        end
    end
end
