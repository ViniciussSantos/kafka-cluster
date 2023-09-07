import { Kafka } from "kafkajs";

const kafka = new Kafka({
  clientId: "my-app",
  brokers: ["localhost:9092"],
});

const producer = kafka.producer();

const runProducer = async () => {
  await producer.connect();
  await producer.send({
    topic: "test",
    messages: [{ value: "Hello KafkaJS user!" }],
  });

  await producer.disconnect();
};

runProducer().catch(console.error);

const consumer = kafka.consumer({ groupId: "test-group" });

const runConsumer = async () => {
  await consumer.connect();
  await consumer.subscribe({ topic: "test", fromBeginning: true });

  await consumer.run({
    eachMessage: async ({ topic, partition, message }) => {
      console.log({
        partition,
        offset: message.offset,
        value: message.value?.toString(),
      });
    },
  });
};

runConsumer().catch(console.error);
