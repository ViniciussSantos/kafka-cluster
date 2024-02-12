#!/bin/bash

node_ip=$(kubectl get node worker01 -o=jsonpath='{range .status.addresses[?(@.type=="InternalIP")]}{.address}{"\n"}')

service_port=$(kubectl get service kafka-connect-port -o=jsonpath='{.spec.ports[0].nodePort}{"\n"}' -n kafka)

curl "$node_ip:$service_port/connectors" -X POST -H 'Content-Type: application/json' -d '{
 "name":"mqtt-source-connector",
 "config":{
 "connector.class":"io.lenses.streamreactor.connect.mqtt.source.MqttSourceConnector",
 "connect.mqtt.hosts":"tcp://192.168.60.1:1883",
 "connect.mqtt.clean":"true",
 "connect.mqtt.timeout":"1000",
 "connect.mqtt.keep.alive":"1000",
 "connect.mqtt.service.quality":"1",
 "connect.mqtt.kcql":"INSERT INTO test-topic SELECT * FROM test/topic",
 "connect.progress.enabled":"true",
 "connect.mqtt.process.duplicates":"true",
 "connect.mqtt.log.message":"true"
 }
}' | jq
