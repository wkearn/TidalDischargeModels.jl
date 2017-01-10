module MetData

using DataFrames, Base.Dates, TidalDischargeModels.Databases

export parsemet

# This is the directory which contains the meteorological data
# Change the _DATA_DIR to 
_DATA_DIR = Databases._METDATA_DIR

doy(t::DateTime) = dayofyear(t) + (hour(t)+minute(t)/60)/24

function doy2date(y,d)
    md = Base.Dates.MONTHDAYS[:]
    ms = 1:12
    if isleapyear(y)
        md[ms.>2]+=1
    end
    m = findfirst(x->x>=d,md)-1
    if m <= 0
        error("$d is not a valid day of the year")
    end
    dd = d-md[m]
    Date(y,m,dd)    
end

function timepad(ds)
    map(x->lpad(string(x),4,'0'),ds)
end

function parsemet(year::Int)
    M = readtable(joinpath(_DATA_DIR,string(year),"met.csv"))
    n = size(M,1)
    M[:Date] = map(x->doy2date(M[x,:Year],M[x,:Day]),1:n)
    mstring = String[string(x) for x in M[:Date]]
    tstring = String[timepad(x) for x in M[:Time]]
    # The PIE met data uses 2400 on day i instead of 0000 on
    # day i+1
    q = tstring .== "2400"
    tstring[q] = "0000"
    M[:DateTime] = DateTime(mstring.*tstring,
                            DateFormat("yyyy-mm-ddHHMM"))+Day.(q)
    M
end

end # module end
