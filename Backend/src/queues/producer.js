const { getChannel }  = require('../config/rabbitmq');

async function publicTransactionJob(transaction) 
{
  const channel = getChannel();
  const queue = 'transactions';

  await channel.assertQueue(queue , {durable : true});
  channel.sendToQueue(queue , Buffer.from(JSON.stringify(transaction)),
  {
    persistent:true,

  }
);
console.log("Job published:" , transaction._id || transaction);
}

module.exports = {publicTransactionJob};
