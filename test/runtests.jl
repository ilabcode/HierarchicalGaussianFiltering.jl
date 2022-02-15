using HGF
using Test

@testset "Dummy tests" begin
    @test dummy_function(2) == 4
    @test dummy_function([1,0,0,1]) == 1
    @test dummy_function([1,2,3,4]) == 10
end


