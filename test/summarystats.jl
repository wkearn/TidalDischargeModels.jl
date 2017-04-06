println("Calculating summary statistics")
for m in [boon,lti,volterra,kmm]
    err = msd(TDM.validate(quantity(Q2),1:N2,m.M),TDM.evalmodel(m,p2,Q2,1:N2))
    ns = nash_sutcliffe(m,Q2)
    sf = flatness(m,Q2)
    println(typeof(m),":: ",err,"\t",ns,"\t",sf)
end
