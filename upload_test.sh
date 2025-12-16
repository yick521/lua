#!/bin/sh
#####and
curl --insecure -X POST "http://172.16.0.33/open/v2/event_statis_srv/upload_event" -u "ae45076ffa0e4812af4996ffe5fb33b8:ae45076ffa0e4812af4996ffe5fb33b8" -d 'data={ "ak": "ae45076ffa0e4812af4996ffe5fb33b8", "dt": "usr", "pr": { "$ct": 1491812561821, "$cuid": "123", "_信息网": "我没有", "_小游戏": "我默默", "_我妈妈": " 小游戏" }, "debug": 0, "pl": "and", "usr": { "did": "7df321978522f95327c2c413c0405c0e" } }'

curl --insecure -X POST "http://172.16.0.33/open/v2/event_statis_srv/upload_event" -u "ae45076ffa0e4812af4996ffe5fb33b8:ae45076ffa0e4812af4996ffe5fb33b8" -d 'data={ "ak": "ae45076ffa0e4812af4996ffe5fb33b8", "dt": "evt", "pr": { "$ct": 1491812561821, "$eid": "观察and", "$sid": 1491812519004 ,"$cuid": "123", "_信息网": "我没有", "_小游戏": "我默默", "_我妈妈": " 小游戏" }, "debug": 0, "pl": "and", "usr": { "did": "" } }'


#####ios
curl --insecure -X POST "http://172.16.0.33/open/v2/event_statis_srv/upload_event" -u "ae45076ffa0e4812af4996ffe5fb33b8:ae45076ffa0e4812af4996ffe5fb33b8" -d 'data={ "ak": "ae45076ffa0e4812af4996ffe5fb33b8", "dt": "usr", "pr": { "$ct": 1491812561821, "$cuid": "123", "_信息网": "我没有", "_小游戏": "我默默", "_我妈妈": " 小游戏" }, "debug": 0, "pl": "ios", "usr": { "did": "7df321978522f95327c2c413c0405c0e" }}'

curl --insecure -X POST "http://172.16.0.33/open/v2/event_statis_srv/upload_event" -u "ae45076ffa0e4812af4996ffe5fb33b8:ae45076ffa0e4812af4996ffe5fb33b8" -d 'data={ "ak": "ae45076ffa0e4812af4996ffe5fb33b8", "dt": "evt", "pr": { "$ct": 1491812556091, "$eid": "观察ios", "$sid": 1491812519004, "$cuid": "1234523", "_信息网": "我没有", "_小游戏": "我默默", "_我妈妈": " 小游戏" }, "debug": 0, "pl": "ios", "usr": { "did": "7df321978522f95327c2c413c0405c0e" }}'

#####js
curl --insecure -X POST "http://172.16.0.33/open/v2/event_statis_srv/upload_event" -u "ae45076ffa0e4812af4996ffe5fb33b8:ae45076ffa0e4812af4996ffe5fb33b8" -d 'data={ "pl": "js", "debug": 0, "ak": "ae45076ffa0e4812af4996ffe5fb33b8", "usr": { "did": "15b57433eba4bf-0fa1b52580b7b-396d7807-fa000-15b57433ebbab6" }, "dt": "usr", "pr": { "$ct": 1491818163955, "$cuid": "zhuge@37degree.com", "$sid": 1491817676477, "name": "sdk测试", "属性1": "这是属性1", "属性2": "这是属性2" } }'

curl --insecure -X POST "http://172.16.0.33/open/v2/event_statis_srv/upload_event" -u "ae45076ffa0e4812af4996ffe5fb33b8:ae45076ffa0e4812af4996ffe5fb33b8" -d 'data={ "pl": "js", "debug": 0, "ak": "ae45076ffa0e4812af4996ffe5fb33b8", "usr": { "did": "15b57433eba4bf-0fa1b52580b7b-396d7807-fa000-15b57433ebbab6" }, "dt": "evt", "pr": { "$ct": 1491817766926, "$sid": 1491817676477, "$eid": "无属性事件", "$cuid":"zhuge" } }'


