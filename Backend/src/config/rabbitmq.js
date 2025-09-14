// config/rabbit.js
const amqp = require('amqplib');

let channel;

async function connectRabbit() {
  if (channel) return channel; // reuse if already created
  const connection = await amqp.connect(process.env.RABBITMQ_URI || 'amqp://localhost');
  channel = await connection.createChannel();
  console.log('✅ Connected to RabbitMQ');

  // declare queues (manual, voice, email)
  await channel.assertQueue('manual-transactions', { durable: true });
  await channel.assertQueue('voice-transactions', { durable: true });
  await channel.assertQueue('email-transactions', { durable: true });

  return channel;
}

async function publishToQueue(queue, msg) {
  const ch = await connectRabbit();
  ch.sendToQueue(queue, Buffer.from(JSON.stringify(msg)), { persistent: true });
  console.log(`📩 Job sent to queue "${queue}":`, msg);
}

module.exports = { connectRabbit, publishToQueue };
