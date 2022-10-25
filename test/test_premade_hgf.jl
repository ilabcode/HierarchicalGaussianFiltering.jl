using HierarchicalGaussianFiltering
using Test

@testset "Premade_models" begin
    @testset "Errors and utilities" begin

        #Get the error for misspecified input strings
        try
            HGF_test = premade_hgf("Typo")
            #Get out the error text
        catch error
            buffer = IOBuffer()
            showerror(buffer, error)
            message = String(take!(buffer))
            #And check it is right
            @test message ==
                  "ArgumentError: the specified string does not match any model. Type premade_hgf('help') to see a list of valid input strings"
        end

        #Check that the help function returns nothing
        @test typeof(premade_hgf("help")) == Nothing
    end

    @testset "Standard 2 level HGF" begin
        #Set up test inputs
        test_inputs = [1.0, 1.05, 1.1]

        #Initialize HGF
        HGF_test = premade_hgf("continuous_2level", verbose=false)

        #Give inputs
        give_inputs!(HGF_test, test_inputs)
    end

    @testset "JGET" begin
        #Set up test inputs
        test_inputs = [1.0, 1.05, 1.1]

        #Initialize HGF
        HGF_test = premade_hgf("JGET", verbose=false)

        #Give inputs
        give_inputs!(HGF_test, test_inputs)
    end

    @testset "Binary 2 level HGF" begin
        #Set up test inputs
        test_inputs = [1, 0, 1]

        #Initialize HGF
        HGF_test = premade_hgf("binary_2level", verbose=false)

        #Give inputs
        give_inputs!(HGF_test, test_inputs)
    end

    @testset "Binary 3 level HGF" begin
        #Set up test inputs
        test_inputs = [1, 0, 1]

        #Initialize HGF
        HGF_test = premade_hgf("binary_3level", verbose=false)

        #Give inputs
        give_inputs!(HGF_test, test_inputs)
    end
end
