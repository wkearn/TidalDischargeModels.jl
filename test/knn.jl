@testset "KNNModel" begin
    m = fit(KNNModel, data[!,:Stage], data[!,:Discharge], M=4, k=10)
    Qpp = predict(m, test_data[!, :Stage])

    @test length(Qpp) == length(test_data[!, :Stage])
    @test count(ismissing, Qpp) == 3
end

@testset "KNNModel with missing data" begin
    h = Array{Union{Missing, Float64}}(randn(200))
    h[10] = missing

    q = Array{Union{Missing, Float64}}(randn(200))
    q[24] = missing

    m = fit(KNNModel, h, q, M=3, k=27)

    ht = Array{Union{Missing, Float64}}(randn(100))
    ht[73] = missing

    Qpp = predict(m, ht)

    @test length(Qpp) == 100

    # M-1 points at the beginning + M points around the single missing
    # value
    @test count(ismissing, Qpp) == 5
end

@testset "KNNModel with multiple data sets" begin
    h1 = randn(200)
    q1 = randn(200)
    h2 = randn(200)
    q2 = randn(200)

    m0 = fit(KNNModel, [h1, h2], [q1, q2], M=10, k=10)

    @assert length(m0.Q) == 400 - 18
end
