#!/bin/bash

node_ip=$(kubectl get node worker01 -o=jsonpath='{range .status.addresses[?(@.type=="InternalIP")]}{.address}{"\n"}')

service_port=$(kubectl get service kafka-connect-port -o=jsonpath='{.spec.ports[0].nodePort}{"\n"}' -n kafka)

curl -X POST \
	"$node_ip:$service_port/connectors" \
	-H 'Content-Type: application/json' \
	-d '{
    "name": "mqtt-source-connector",
    "config": {
      "connector.class": "be.jovacon.kafka.connect.MQTTSourceConnector",
      "mqtt.topic": "my-topic",
      "kafka.topic": "my-topic",
      "mqtt.clientID": "my_client_id",
      "mqtt.broker": "tcp://192.168.15.4:1883",
      "key.converter": "org.apache.kafka.connect.storage.StringConverter",
      "key.converter.schemas.enable": "false",
      "value.converter": "org.apache.kafka.connect.storage.StringConverter",
      "value.converter.schemas.enable": "false"
    }
  }'
