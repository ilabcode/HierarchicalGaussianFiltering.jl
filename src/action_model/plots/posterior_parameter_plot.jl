@userplot Posterior_Parameter_Plot

@recipe function f(pl::Posterior_Parameter_Plot; label_list = [], prior_offset = 0, posterior_offset = 0.01, prior_color = :green,posterior_color = :orange, distributions=true, interval_1 = 0.5, interval_2 = 0.8, plot_width = 900, plot_height = 300)
    
    #Get out arguments
    chain = pl.args[1]
    params_prior_list = pl.args[2]
    
    #initialize empty dictionary for...?
    D = Dict()

    ### Get quantiles ###
    #Interval_1 is the smaller width, amount fo probability mass around the median [change] 

    #Quantiles that correspond to the specified intervals around the median
    quantiles = [0.5-interval_2*.5, 0.5-interval_1*.5, 0.5,0.5+interval_1*.5, 0.5+interval_2*.5,]

    #For each parameter
    for i in keys(params_prior_list) #Do double thing here
        #Get prior and posterior
        prior = getindex(params_prior_list,i)
        posterior = Array(chain[:,String(i),:])[:]

        #Get the values that correspond to the quantiles, save them in dictionary
        D[String(i)] = (;prior_quantiles=Turing.Statistics.quantile(prior,quantiles),
        posterior_quantiles=Turing.Statistics.quantile(posterior,quantiles))
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
    for i in keys(D)
        push!(names,i)
    end

    #For each parameter name
    for i in names
        #Add param name to list of subplot titles, unless specified by user
        if Symbol(i) in keys(label_list)
            push!(labels,getindex(label_list,Symbol(i)))
        else
            push!(labels,i)
        end
    end

    for i in names
        #[prior_mean is prior_median]
        #Add values to lists
        push!(prior_mean,D[i].prior_quantiles[3])
        push!(posterior_mean,D[i].posterior_quantiles[3])
        #Add the sizes fo the error bars (which are the quantiles)
        push!(prior_error_left,(D[i].prior_quantiles[3]-D[i].prior_quantiles[2]))
        push!(prior_error_right,(D[i].prior_quantiles[4]-D[i].prior_quantiles[3]))
        push!(prior_error_left_2,(D[i].prior_quantiles[3]-D[i].prior_quantiles[1]))
        push!(prior_error_right_2,(D[i].prior_quantiles[5]-D[i].prior_quantiles[3]))

        push!(posterior_error_left,(D[i].posterior_quantiles[3]-D[i].posterior_quantiles[2]))
        push!(posterior_error_right,(D[i].posterior_quantiles[4]-D[i].posterior_quantiles[3]))
        push!(posterior_error_left_2,(D[i].posterior_quantiles[3]-D[i].posterior_quantiles[1]))
        push!(posterior_error_right_2,(D[i].posterior_quantiles[5]-D[i].posterior_quantiles[3]))
    end

    #number of subplots
    l = length(names)
    
    #Specify how to arrange subplots, and their size
    layout := (l,1)
    size := (plot_width,plot_height*l)

    #For each subplot
    for i in 1:l

        #Set the title
        title := labels[i]

        #Aesthetic settings
        yshowaxis:= false
        yticks:=false
        
        #The font size
        legendfontsize --> 15
        
        ### Plot prior and posterior distribution ###
        #if show distributions
        if distributions

            #Plot the prior
            @series begin
                #color
                color := prior_color
                #transparency
                fill := (0,0.5)
                #subplot nr
                subplot := i
                #Only put legend on first plot
                if i !=1 legend := nothing end
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
                fill := (0,0.5)
                subplot := i
                if i !=1 legend := nothing end
                label := nothing

                #Make an array of samples for the specified parameter to plot it
                Array(chain[:,names[i],:])[:]
            end
        end


        ### Plot prior mean and errorbar ###
        @series begin
            seriestype := :scatter
            color := prior_color
            subplot := i

            #Set size of big errorbar
            xerror := ([prior_error_left_2[i]],[prior_error_right_2[i]])

            markerstrokewidth := 1 #thickness
            markerstrokecolor := prior_color
            if i !=1 legend := nothing end
            label := nothing
            #Need to plot the point in order to make the rrorbar
            [(prior_mean[i],prior_offset)]
        end
        #plot small errorbar
        @series begin
            seriestype := :scatter
            color := prior_color
            subplot := i
            xerror := ([prior_error_left[i]],[prior_error_right[i]])
            markerstrokewidth := 3 #thickness
            markerstrokecolor := prior_color
            if i !=1 legend := nothing end
            label := nothing
            [(prior_mean[i],prior_offset)]
        end

        #Plot point
        @series begin
            seriestype := :scatter
            color := prior_color
            subplot := i
            markerstrokewidth := 1
            markersize := 5
            if i !=1 legend := nothing end
            label := "Prior"
            [(prior_mean[i],prior_offset)]
        end


        
        ### Plot posterior mean and errorbar ###
        @series begin
            seriestype := :scatter
            color := posterior_color
            subplot := i
            xerror := ([posterior_error_left_2[i]],[posterior_error_right_2[i]])
            markerstrokewidth := 1
            markerstrokecolor := posterior_color
            if i !=1 legend := nothing end
            label := nothing
            [(posterior_mean[i],posterior_offset)]
        end 
        @series begin
            seriestype := :scatter
            color := posterior_color
            subplot := i
            xerror := ([posterior_error_left[i]],[posterior_error_right[i]])
            markerstrokewidth := 3
            markerstrokecolor := posterior_color
            if i !=1 legend := nothing end
            label := nothing
            [(posterior_mean[i],posterior_offset)]
        end
        @series begin
            seriestype := :scatter
            color := posterior_color
            markersize := 5
            subplot := i
            markerstrokewidth := 1
            if i !=1 legend := nothing end
            label := "Posterior"
            [(posterior_mean[i],posterior_offset)]
        end
    end
end