@testset "kMeansModel" begin
    m = fit(kMeansModel, data[!,:Stage], data[!,:Discharge], M=3, k=27)
    Qpp = predict(m, test_data[!, :Stage])
    
    @test length(Qpp) == length(test_data[!, :Stage])
    @test count(ismissing, Qpp) == 2
end

@testset "kMeansModel with missing data" begin
    h = Array{Union{Missing, Float64}}(randn(200))
    h[10] = missing

    q = Array{Union{Missing, Float64}}(randn(200))
    q[24] = missing

    m = fit(kMeansModel, h, q, M=3, k=27)

    ht = Array{Union{Missing, Float64}}(randn(100))
    ht[73] = missing

    Qpp = predict(m, ht)

    @test length(Qpp) == 100

    # M-1 points at the beginning + M points around the single missing
    # value
    @test count(ismissing, Qpp) == 5
end
