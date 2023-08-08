const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB();

exports.handler = async (event) => {
  const { id } = event.pathParameters;

  try {
    const params = {
      TableName: 'brainwave-chat',
      Key: {
        id: { S: id },
      },
    };

    await dynamodb.deleteItem(params).promise();

    return {
      statusCode: 200,
      body: JSON.stringify({ message: 'Message deleted successfully' }),
    };
  } catch (error) {
    console.error('Error deleting message', error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Failed to delete messages' }),
    };
  }
};


exports.deleteAll = async (event) => {
  try {
    const params = {
      TableName: 'updated-chat',
    };

    await dynamodb.scan(params).promise()
      .then(data => {
        const deletePromises = data.Items.map(item => {
          const deleteParams = {
            TableName: 'updated-chat',
            Key: {
              id: item.id,
            },
          };
          return dynamodb.deleteItem(deleteParams).promise();
        });
        return Promise.all(deletePromises);
      });

    return {
      statusCode: 200,
      body: JSON.stringify({ message: 'All messages deleted successfully' }),
    };
  } catch (error) {
    console.error('Error deleting messages', error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Failed to delete messagess' }),
    };
  }
};