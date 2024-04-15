#Transformation (of varioius derivations) for a linear transformation
function transform_parent_value(
    transform_type::LinearTransform,
    parent_value::Real;
    derivation_level::Integer,
)
    if derivation_level == 0
        return parent_value
    elseif derivation_level == 0
        return 1
    elseif derivation_level == 0
        return 0
    else
        @error "derivation level is misspecified"
    end
end

#Transformation (of varioius derivations) for a nonlinear transformation
function transform_parent_value(
    transform_type::NonlinearTransform,
    parent_value::Real,
    derivation_level::Integer,
)

    #Get the transformation function that fits the derivation level
    if derivation_level == 0
        transform_function = node.parameters.coupling_transforms[parent.name].base_function
    elseif derivation_level == 1
        transform_function =
            node.parameters.coupling_transforms[parent.name].first_derivation
    elseif derivation_level == 2
        transform_function =
            node.parameters.coupling_transforms[parent.name].second_derivation
    else
        @error "derivation level is misspecified"
    end

    #Get the transformation parameters
    transform_parameters = node.parameters.coupling_transforms[parent.name].parameters

    #Transform the value
    return transform_function(parent_value, transform_parameters)
end
