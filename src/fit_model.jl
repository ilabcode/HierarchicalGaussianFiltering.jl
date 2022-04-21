using Turing

function fit_model(model::ActionStruct, input::Vector, response::Vector)
    my_hgf = model.perceptual_struct
    N = length(my_hgf.state_nodes)
    @model function agent_action(y)
        for node in my_hgf.state_nodes
            node.params.evolution_rate ~ Normal(0, 1)
        end
    end
end