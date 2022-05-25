using RecipesBase
@userplot Posterior_Parameter_Plot

@recipe function f(pl::Posterior_Parameter_Plot)
    
    chain = pl.args[1]
    params_prior_list = pl.args[2]

    D = Dict()

    for i in keys(params_prior_list)
        prior = getindex(params_prior_list,i)
        posterior = Array(chain[:,String(i),:])[:]
        D[String(i)] = (;prior_quantiles=Turing.Statistics.quantile(prior,[0.1,0.25,0.5,0.75,0.9]),
        posterior_quantiles=Turing.Statistics.quantile(posterior,[0.1,0.25,0.5,0.75,0.9]))
    end

    names = []
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

    for i in 1:l

        # set up the subplots
        #legend := false
        title := names[i]
        ylims:=(0,2)
        yaxis:= nothing

        @series begin
            seriestype := :scatter
            color := :red
            subplot := i
            markerstrokewidth := 1
            markersize := 5
            if i !=1 legend := nothing end
            label := "prior"
            [(prior_mean[i],1)]
        end

        @series begin
            seriestype := :scatter
            color := :red
            subplot := i
            xerror := ([prior_error_left[i]],[prior_error_right[i]])
            markerstrokewidth := 3
            markerstrokecolor := "red"
            if i !=1 legend := nothing end
            label := nothing
            [(prior_mean[i],1)]
        end

        @series begin
            seriestype := :scatter
            color := :red
            subplot := i
            xerror := ([prior_error_left_2[i]],[prior_error_right_2[i]])
            markerstrokewidth := 1
            markerstrokecolor := "red"
            if i !=1 legend := nothing end
            label := nothing
            [(prior_mean[i],1)]
        end

        @series begin
            seriestype := :scatter
            color := :blue
            markersize := 5
            subplot := i
            markerstrokewidth := 1
            if i !=1 legend := nothing end
            label := "posterior"
            [(posterior_mean[i],1)]
        end
        @series begin
            seriestype := :scatter
            color := :blue
            subplot := i
            xerror := ([posterior_error_left[i]],[posterior_error_right[i]])
            markerstrokewidth := 3
            markerstrokecolor := "blue"
            if i !=1 legend := nothing end
            label := nothing
            [(posterior_mean[i],1)]
        end
        @series begin
            seriestype := :scatter
            color := :blue
            subplot := i
            xerror := ([posterior_error_left_2[i]],[posterior_error_right_2[i]])
            markerstrokewidth := 1
            markerstrokecolor := "blue"
            if i !=1 legend := nothing end
            label := nothing
            [(posterior_mean[i],1)]
        end
    end
end