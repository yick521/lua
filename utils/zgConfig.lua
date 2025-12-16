local broker_list = {
    { host = "alikafka-pre-cn-2r42sho6i013-1-vpc.alikafka.aliyuncs.com", port = 9092 },
    { host = "alikafka-pre-cn-2r42sho6i013-2-vpc.alikafka.aliyuncs.com", port = 9092 },
    { host = "alikafka-pre-cn-2r42sho6i013-3-vpc.alikafka.aliyuncs.com", port = 9092 }
};

-- config
local zgConfig = {
    broker_list=broker_list
}
return zgConfig;