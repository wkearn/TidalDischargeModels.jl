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

KNNModel(M, k) = KNNModel(M, k, nothing, Float64[], zeros(Int, k), zeros(Float64, k))

function StatsBase.fit!(m::KNNModel, H::Matrix{Float64}, Q::Vector{Float64})
    m.t = KDTree(H)
    m.Q = Q
end

function StatsBase.fit(m::KNNModel, H::Matrix{Float64}, Q::Vector{Float64})
    KNNModel(m.M, m.k, KDTree(H), Q, zeros(Int, m.k), zeros(Float64, m.k))
end

function StatsBase.fit(m::KNNModel, h::Vector{Float64}, Q::Vector{Float64})
    H = zeros(m.M, length(h) - m.M + 1)
    for i in 1:m.M
        H[i, :] = h[i:end - m.M + i]
    end
    KNNModel(m.M, m.k, KDTree(H), Q[m.M:end], zeros(Int, m.k), zeros(Float64, m.k))
end

StatsBase.predict(m::KNNModel) = predict(m, m.t.data)

function StatsBase.predict(m::KNNModel, H::Matrix{Float64})
    Qp = zeros(size(H, 2))
    for i in axes(H, 2)
        knn!(m.idx, m.dist, m.t, H[:, i], m.k)
        Qp[i] = mean(m.Q[m.idx])
    end
    Qp
end

function StatsBase.predict(m::KNNModel, h::Vector{Float64})
    Qp = Array{Union{Missing,Float64}}(missing, length(h))
    for i in m.M:length(h)
        knn!(m.idx, m.dist, m.t, h[i-m.M+1:i], m.k)
        Qp[i] = mean(m.Q[m.idx])
    end
    Qp
end

StatsBase.residuals(m::KNNModel) = m.Q - predict(m)
StatsBase.residuals(m::KNNModel, H, Q) = Q - predict(m, H)

