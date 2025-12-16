local broker_list = {
    { host = "realtime-1", port = 9092 }
};

-- config
local zgConfig = {
    broker_list=broker_list
}
return zgConfig;