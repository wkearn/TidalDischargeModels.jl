"""
Takes a time series and produces a matrix containing all the possible lags.

Those points which do not have lags of that magnitude are set to Null.
"""
function lagmatrix(x::AbstractVector{T}) where {T <: Real}
    n = length(x)
    X = zeros(Union{Missing, T}, n,n)
    for j in 1:n, i in 1:n
        X[i,j] = j-i>=0 ? x[j-i+1] : missing
    end
    X
end

function preparedata(p::Vector{Float64},d::Vector{Float64},range,M)
    H = lagmatrix(p)
    Hm = validate(H,range,M)
    Qm = validate(Q,range,M)
    Hm,Qm
end

"""
Given a matrix formed by `lagmatrix`, a range of valid values desired and a number of lags,
return those data points which are valid data
"""
function validate(X::Matrix{Union{Missing, T}},range,n::Int) where {T <: Real}
    X = X[:,range]
    i = 1
    while any(map(ismissing,X[1:n,i]))
        i+=1
    end
    _,m = size(X)
    Y = zeros(T,n,m-i+1)
    for k in 1:n, j in i:m
        Y[k,j-i+1] = X[k,j]
    end
    Y
end

"""
The same idea, but give all the valid response values from a vector of discharges

Try not to pass in a range which is invalid for the vector
"""
function validate(x::AbstractVector,range,n::Int)
    if range.start < n
        return x[n:range.stop]
    else
        return x[range]
    end 
end
