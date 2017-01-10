# Statistical computations for DischargeModels


nash_sutcliffe(M::DischargeModel) = 1-sumabs2(residuals(M))/sumabs2(model_response(M)-mean(model_response(M)))
nash_sutcliffe(M::DischargeModel,H,Q) = 1-sumabs2(residuals(M,H,Q))/sumabs2(Q-mean(Q))
function nash_sutcliffe(M::DischargeModel,dd::DischargeData)
    Hm,Qm = preparedata(dd,1:length(dd.Q),M.M)
    nash_sutcliffe(M,Hm,Qm)
end

function simpsonweights(N)
    w = zeros(Int,N)
    w[1] = 1
    w[end] = 1
    for j in 1:div(N-1,2)-1
        w[2j+1] = 2
        w[2j] = 4
    end
    w[N-1] = 4
    w
end

"""
Calculate the water balance for `Q` sampled at an interval of `dt` over the period `range`
"""
waterbalance(Q,dt,range) = dot(dt/3.*Q[r],simpsonweights(length(r)))

"""
Calculate the value of a Ljung-Box statistic for a model
"""
function ljung_box(M::DischargeModel,H,Q,p)
    rs = residuals(M,H,Q)
    n = length(rs)
    ρ = autocor(rs,1:p)
    n*(n+2)*sum((ρ.^2)./[n-k for k in 1:p])
end

ljung_box(M::DischargeModel,p) = ljung_box(M,M.H,M.Q,p)

function χ2test(Q,df)
    pdf(Chisq(df),Q)
end

"""
Calculate the p-value of a Ljung-Box test for a discharge model
"""
ljung_box_test(M::DischargeModel,H,Q,p) = χ2test(ljung_box(M,H,Q,p),p-M.M)

ljung_box_test(M::DischargeModel,p) = ljung_box_test(M,M.H,M.Q,p)


"""
Calculate the spectral flatness of a signal
"""
function flatness(x)
    psd = abs2(fft(x))
    geomean(psd)/mean(psd)
end

flatness(M::DischargeModel,H,Q) = flatness(residuals(M,H,Q))
function flatness(M::DischargeModel,dd::DischargeData)
    Hm,Qm = preparedata(dd,1:length(dd.Q),M.M)
    flatness(M,Hm,Qm)
end
    

"""
Calculate the prediction error of a model
"""
pe(M::DischargeModel,H,Q) = var(residuals(M,H,Q))
pe(M::DischargeModel) = var(residuals(M))

"""
Calculate the coefficient of determination
"""
function r2(M::DischargeModel,H,Q)
    SStot = sumabs2(Q-mean(Q))
    SSres = sumabs2(residuals(M,H,Q))
    1-SSres/SStot
end

r2(M::DischargeModel) = r2(M,M.H,M.Q)


