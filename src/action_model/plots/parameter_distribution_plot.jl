@userplot Parameter_Distribution_Plot

@recipe function f(
    pl::Parameter_Distribution_Plot;
    show_distributions = true,
    show_intervals = true,
    label_list = [],
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

    ### Get quantiles that correspond to the specified interval ###

    #Set quantiles that corresponds to specified intervals
    interval_quantiles = [
        0.5 - outer_interval * 0.5,
        0.5 - inner_interval * 0.5,
        0.5,
        0.5 + inner_interval * 0.5,
        0.5 + outer_interval * 0.5,
    ]

    #Initialize empty dictionary for storing quantile values for each parameter
    param_quantiles = Dict()

    #For each parameter
    for (param_name, param_prior) in params_prior_list

        #Get posterior from the chain
        param_posterior = Array(chain[:, String(param_name), :])[:]

        #Get the quantiles for the prior and posterior
        prior_quantiles = Turing.Statistics.quantile(param_prior, interval_quantiles)
        posterior_quantiles = Turing.Statistics.quantile(param_posterior, interval_quantiles)

        #Save them in a dictionary
        param_quantiles[param_name] = (;
            prior_quantiles = prior_quantiles,
            posterior_quantiles = posterior_quantiles,
        )
    end


    #Make empty lists
    names = []
    labels = []
    prior_mean = []
    posterior_mean = []

    prior_error_left = []
    prior_error_right = []
    prior_error_left_2 = []
    prior_error_right_2 = []

    posterior_error_left = []
    posterior_error_right = []
    posterior_error_left_2 = []
    posterior_error_right_2 = []

    #Add parameter names to a list
    for i in keys(param_quantiles)
        push!(names, i)
    end

    #For each parameter name
    for i in names
        #Add param name to list of subplot titles, unless specified by user
        if Symbol(i) in keys(label_list)
            push!(labels, getindex(label_list, Symbol(i)))
        else
            push!(labels, i)
        end
    end

    for i in names
        #[prior_mean is prior_median]
        #Add values to lists
        push!(prior_mean, param_quantiles[i].prior_quantiles[3])
        push!(posterior_mean, param_quantiles[i].posterior_quantiles[3])
        #Add the sizes fo the error bars (which are the quantiles)
        push!(prior_error_left, (param_quantiles[i].prior_quantiles[3] - param_quantiles[i].prior_quantiles[2]))
        push!(prior_error_right, (param_quantiles[i].prior_quantiles[4] - param_quantiles[i].prior_quantiles[3]))
        push!(prior_error_left_2, (param_quantiles[i].prior_quantiles[3] - param_quantiles[i].prior_quantiles[1]))
        push!(prior_error_right_2, (param_quantiles[i].prior_quantiles[5] - param_quantiles[i].prior_quantiles[3]))

        push!(
            posterior_error_left,
            (param_quantiles[i].posterior_quantiles[3] - param_quantiles[i].posterior_quantiles[2]),
        )
        push!(
            posterior_error_right,
            (param_quantiles[i].posterior_quantiles[4] - param_quantiles[i].posterior_quantiles[3]),
        )
        push!(
            posterior_error_left_2,
            (param_quantiles[i].posterior_quantiles[3] - param_quantiles[i].posterior_quantiles[1]),
        )
        push!(
            posterior_error_right_2,
            (param_quantiles[i].posterior_quantiles[5] - param_quantiles[i].posterior_quantiles[3]),
        )
    end

    #number of subplots
    l = length(names)

    #Specify how to arrange subplots, and their size
    layout := (l, 1)
    size := (plot_width, plot_height * l)

    #For each subplot
    for i = 1:l

        #Set the title
        title := labels[i]

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
                params_prior_list[Symbol(names[i])]
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
                Array(chain[:, names[i], :])[:]
            end
        end


        ### Plot prior mean and errorbar ###
        @series begin
            seriestype := :scatter
            color := prior_color
            subplot := i

            #Set size of big errorbar
            xerror := ([prior_error_left_2[i]], [prior_error_right_2[i]])

            markerstrokewidth := 1 #thickness
            markerstrokecolor := prior_color
            if i != 1
                legend := nothing
            end
            label := nothing
            #Need to plot the point in order to make the rrorbar
            [(prior_mean[i], prior_interval_offset)]
        end
        #plot small errorbar
        @series begin
            seriestype := :scatter
            color := prior_color
            subplot := i
            xerror := ([prior_error_left[i]], [prior_error_right[i]])
            markerstrokewidth := 3 #thickness
            markerstrokecolor := prior_color
            if i != 1
                legend := nothing
            end
            label := nothing
            [(prior_mean[i], prior_interval_offset)]
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
            [(prior_mean[i], prior_interval_offset)]
        end



        ### Plot posterior mean and errorbar ###
        @series begin
            seriestype := :scatter
            color := posterior_color
            subplot := i
            xerror := ([posterior_error_left_2[i]], [posterior_error_right_2[i]])
            markerstrokewidth := 1
            markerstrokecolor := posterior_color
            if i != 1
                legend := nothing
            end
            label := nothing
            [(posterior_mean[i], posterior_interval_offset)]
        end
        @series begin
            seriestype := :scatter
            color := posterior_color
            subplot := i
            xerror := ([posterior_error_left[i]], [posterior_error_right[i]])
            markerstrokewidth := 3
            markerstrokecolor := posterior_color
            if i != 1
                legend := nothing
            end
            label := nothing
            [(posterior_mean[i], posterior_interval_offset)]
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
            [(posterior_mean[i], posterior_interval_offset)]
        end
    end
end
