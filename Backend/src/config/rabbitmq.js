// config/rabbit.js
const amqp = require('amqplib');

let connection;
let channel;

async function connectRabbit() {
  if (channel) return channel;
  try {
    const uri = process.env.RABBITMQ_URI || 'amqp://localhost';

    connection = await amqp.connect(uri, {
      heartbeat: 30,        // keep-alive
      connection_timeout: 10000, // 10s timeout
    });

    connection.on('error', (err) => {
      console.error('🐇 RabbitMQ connection error:', err.message);
    });

    connection.on('close', () => {
      console.error('🐇 RabbitMQ connection closed. Retrying...');
      channel = null; // reset channel
      setTimeout(connectRabbit, 5000); // retry after 5s
    });

    channel = await connection.createChannel();
    console.log('✅ Connected to RabbitMQ');

    // declare queues (idempotent)
    await channel.assertQueue('manual-transactions', { durable: true });
    await channel.assertQueue('voice-transactions', { durable: true });
    await channel.assertQueue('email-transactions', { durable: true });

    return channel;
  } catch (err) {
    console.error('❌ RabbitMQ connect failed:', err.message);
    setTimeout(connectRabbit, 5000); // retry after 5s
  }
}

async function publishToQueue(queue, msg) {
  const ch = await connectRabbit();
  if (!ch) {
    console.error('⚠️ No RabbitMQ channel available right now, dropping message.');
    return;
  }

  await ch.assertQueue(queue, { durable: true });
  ch.sendToQueue(queue, Buffer.from(JSON.stringify(msg)), { persistent: true });

  console.log(`📩 Job sent to queue "${queue}":`, msg);
}

module.exports = { connectRabbit, publishToQueue };
