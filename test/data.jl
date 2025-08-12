using CSV, DataFrames


# Load data from USGS RDB format
stage_data = CSV.read(joinpath(@__DIR__, "data", "mallard_stage.rdb"), DataFrame,
                      comment="#", delim='\t',
                      dateformat="yyyy-mm-dd HH:MM",
                      header=["Agency", "Site", "DateTime", "TZ", "Stage", "Quality"],
                      skipto=29)

discharge_data = CSV.read(joinpath(@__DIR__, "data", "mallard_discharge.rdb"), DataFrame,
                          comment="#", delim='\t',
                          header=["Agency", "Site", "DateTime", "TZ", "Discharge", "Quality"],
                          dateformat="yyyy-mm-dd HH:MM",
                          skipto=29)

stage_test_data = CSV.read(joinpath(@__DIR__, "data", "mallard_test_stage.rdb"), DataFrame,
                      comment="#", delim='\t',
                      dateformat="yyyy-mm-dd HH:MM",
                      header=["Agency", "Site", "DateTime", "TZ", "Stage", "Quality"],
                      skipto=29)

discharge_test_data = CSV.read(joinpath(@__DIR__, "data", "mallard_test_discharge.rdb"), DataFrame,
                          comment="#", delim='\t',
                          header=["Agency", "Site", "DateTime", "TZ", "Discharge", "Quality"],
                          dateformat="yyyy-mm-dd HH:MM",
                          skipto=29)

# Join stage and discharge tables together so they are easier to
# manage
data = innerjoin(stage_data, discharge_data, on=[:Agency, :Site, :DateTime, :TZ], makeunique=true)
test_data = innerjoin(stage_test_data, discharge_test_data, on=[:Agency, :Site, :DateTime, :TZ], makeunique=true)
