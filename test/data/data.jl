using CSV, DataFrames, TidalDischargeModels

stage_data = CSV.read(joinpath(@__DIR__, "mallard_stage.rdb"), DataFrame,
                      comment="#", delim='\t',
                      dateformat="yyyy-mm-dd HH:MM",
                      header=["Agency", "Site", "DateTime", "TZ", "Stage", "Quality"],
                      skipto=29)

discharge_data = CSV.read(joinpath(@__DIR__, "mallard_discharge.rdb"), DataFrame,
                          comment="#", delim='\t',
                          header=["Agency", "Site", "DateTime", "TZ", "Discharge", "Quality"],
                          dateformat="yyyy-mm-dd HH:MM",
                          skipto=29)

stage_test_data = CSV.read(joinpath(@__DIR__, "mallard_test_stage.rdb"), DataFrame,
                      comment="#", delim='\t',
                      dateformat="yyyy-mm-dd HH:MM",
                      header=["Agency", "Site", "DateTime", "TZ", "Stage", "Quality"],
                      skipto=29)

discharge_test_data = CSV.read(joinpath(@__DIR__, "mallard_test_discharge.rdb"), DataFrame,
                          comment="#", delim='\t',
                          header=["Agency", "Site", "DateTime", "TZ", "Discharge", "Quality"],
                          dateformat="yyyy-mm-dd HH:MM",
                          skipto=29)

data = innerjoin(stage_data, discharge_data, on=[:Agency, :Site, :DateTime, :TZ], makeunique=true)

test_data = innerjoin(stage_test_data, discharge_test_data, on=[:Agency, :Site, :DateTime, :TZ], makeunique=true)

m = kMeansModel(3, 0, 27, 0.0)
m = estfun(m, data[!,:Stage], data[!,:Discharge])

Qpp = evalmodel(m, test_data[!,:Stage], test_data[!,:Discharge])

evalfun(m, test_data[!,:Stage], test_data[!,:Discharge])




