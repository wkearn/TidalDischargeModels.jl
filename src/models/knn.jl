using NearestNeighbors

export KNNModel

struct KNNModel <: DischargeModel
    M::Int
    k::Int
    t
    Q::Vector{Float64}
    idx::Vector{Int}
    dist::Vector{Float64}    
end

function StatsBase.fit!(m::KNNModel, H::Matrix{Float64}, Q::Vector{Float64})
    m.t = KDTree(H)
    m.Q = Q
end

function StatsBase.fit(m::KNNModel, H::Matrix{Float64}, Q::Vector{Float64})
    KNNModel(m.M, m.k, KDTree(H), Q, zeros(Int, m.k), zeros(Float64, m.k))
end

function StatsBase.fit(::Type{KNNModel},
                       h::AbstractVector{S},
                       q::AbstractVector{T};
                       M=1, k=1) where {S, T}
    H,Q = preparedata(h, q, M)
    KNNModel(M, k, KDTree(H), Q, zeros(Int, k), zeros(Float64, k))
end

StatsBase.predict(m::KNNModel) = predict(m, reduce(hcat, m.t.data))

function StatsBase.predict(m::KNNModel, H::Matrix{T}) where T
    Qp = Array{Union{Missing, Float64}}(missing, size(H, 2))
    for i in axes(H, 2)
        h = H[:, i]
        if !any(ismissing, h)
            h = convert(Vector{nonmissingtype(T)}, h)
            knn!(m.idx, m.dist, m.t, h, m.k)
            Qp[i] = mean(m.Q[m.idx])
        end
    end
    Qp
end

function StatsBase.predict(m::KNNModel, h::AbstractVector{T}) where T
    H = lagmatrix(h, m.M)
    predict(m, H)
end

StatsBase.residuals(m::KNNModel) = m.Q - predict(m)
StatsBase.residuals(m::KNNModel, H, Q) = Q - predict(m, H)

