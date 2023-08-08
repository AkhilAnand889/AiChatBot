const AWS = require('aws-sdk');
const { sendResponse } = require('../functions');

const docClient = new AWS.DynamoDB.DocumentClient();
const tableName = "brainwave-chat";

module.exports.getMessages = async (event, context) => {
  try {
    const params = {
      TableName: tableName,
    };

    const result = await docClient.scan(params).promise();
    const messages = result.Items;

    return {
      statusCode: 200,
      body: JSON.stringify({ messages }),
    };
  } catch (err) {
    console.log(err.message);
    return {
      statusCode: 500,
      body: JSON.stringify({ message: err.message }),
    };
  }
};

//get messages by user

module.exports.retrieveMessages = async (event,context) => {
  try {
    const { userId } = event.pathParameters;
    const params = {
      TableName: tableName
    };

    const result = await docClient.scan(params).promise();
     const filteredItems = result.Items.filter(item => item.userId === userId);
     const responseItems = filteredItems.map((item) => ({
      messageId: item.id,
    }));
     console.log(filteredItems);
    return sendResponse(200,{message : 'successfully retrieved messages by user', filteredItems : filteredItems, responseItems : responseItems});
  } catch (err) {
    console.log(err.message);
    throw err;
  }
}