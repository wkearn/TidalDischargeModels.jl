# Probably not a good way to load data directory paths
module Databases

export adcp_data_directory,
setADCPdatadir!,
met_data_directory,
setmetdatadir!

adcp_data_directory = Dict(:_ADCPDATA_DIR=>"")

function setADCPdatadir!(path,datavars=adcp_data_directory)
    datavars[:_ADCPDATA_DIR] = path
end

met_data_directory = Dict(:_METDATA_DIR=>"")

function setmetdatadir!(path,datavars=met_data_directory)
    datavars[:_METDATA_DIR] = path
end

end # module end
