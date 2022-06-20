using RecipesBase
@userplot Posterior_Parameter_Plot

@recipe function f(pl::Posterior_Parameter_Plot; prior_offset = 0, posterior_offset = 0.01, prior_color = :green,posterior_color = :orange, distributions=true, interval_1 = 0.5, interval_2 = 0.8, plot_width = 900, plot_height = 300)
    
    chain = pl.args[1]
    params_prior_list = pl.args[2]
    if length(pl.args) >2
        label_list = pl.args[3]
    end
    D = Dict()

    quantiles = [0.5-interval_2*.5,0.5-interval_1*.5,0.5,0.5+interval_1*.5,0.5+interval_2*.5,]

    for i in keys(params_prior_list)
        prior = getindex(params_prior_list,i)
        posterior = Array(chain[:,String(i),:])[:]
        D[String(i)] = (;prior_quantiles=Turing.Statistics.quantile(prior,quantiles),
        posterior_quantiles=Turing.Statistics.quantile(posterior,quantiles))
    end

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


    for i in keys(D)
        push!(names,i)
    end

    for i in names
        if Symbol(i) in keys(label_list)
            push!(labels,getindex(label_list,Symbol(i)))
        else
            push!(labels,i)
        end
    end

    for i in names
        push!(prior_mean,D[i].prior_quantiles[3])
        push!(posterior_mean,D[i].posterior_quantiles[3])

        push!(prior_error_left,(D[i].prior_quantiles[3]-D[i].prior_quantiles[2]))
        push!(prior_error_right,(D[i].prior_quantiles[4]-D[i].prior_quantiles[3]))
        push!(prior_error_left_2,(D[i].prior_quantiles[3]-D[i].prior_quantiles[1]))
        push!(prior_error_right_2,(D[i].prior_quantiles[5]-D[i].prior_quantiles[3]))

        push!(posterior_error_left,(D[i].posterior_quantiles[3]-D[i].posterior_quantiles[2]))
        push!(posterior_error_right,(D[i].posterior_quantiles[4]-D[i].posterior_quantiles[3]))
        push!(posterior_error_left_2,(D[i].posterior_quantiles[3]-D[i].posterior_quantiles[1]))
        push!(posterior_error_right_2,(D[i].posterior_quantiles[5]-D[i].posterior_quantiles[3]))
    end

    l = length(names)
    
    layout := (l,1)
    size := (plot_width,plot_height*l)
    # annots = [
    #     (x=0, y=0,
    #         text="I'm a text",
    #         xref="paper",
    #         yref="paper",
    #     ),
    # ];
    # annotations := annots


    for i in 1:l
        # set up the subplots
        #legend := false
        title := labels[i]
        #ylims:=(0,2)
        yshowaxis:= false
        yticks:=false
        legendfontsize --> 15
        
        if distributions
            @series begin
                color := prior_color
                fill := (0,0.5)
                subplot := i
                if i !=1 legend := nothing end
                label := nothing
                params_prior_list[Symbol(names[i])]
            end
            @series begin
                seriestype := :density
                color := posterior_color
                fill := (0,0.5)
                subplot := i
                if i !=1 legend := nothing end
                label := nothing
                Array(chain[:,names[i],:])[:]
            end
        end

        
        

        @series begin
            seriestype := :scatter
            color := prior_color
            subplot := i
            xerror := ([prior_error_left_2[i]],[prior_error_right_2[i]])
            markerstrokewidth := 1
            markerstrokecolor := prior_color
            if i !=1 legend := nothing end
            label := nothing
            [(prior_mean[i],prior_offset)]
        end
        @series begin
            seriestype := :scatter
            color := prior_color
            subplot := i
            xerror := ([prior_error_left[i]],[prior_error_right[i]])
            markerstrokewidth := 3
            markerstrokecolor := prior_color
            if i !=1 legend := nothing end
            label := nothing
            [(prior_mean[i],prior_offset)]
        end
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