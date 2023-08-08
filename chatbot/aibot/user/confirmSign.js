const AWS = require('aws-sdk');
const { sendResponse, validateInput } = require("../functions");

const cognito = new AWS.CognitoIdentityServiceProvider();

module.exports.handler = async (event) => {

  const { email, confirmationcode} = JSON.parse(event.body);
  const { user_pool_id,client_id } = process.env;

  const params = {
    ClientId: client_id,
    ConfirmationCode: confirmationcode,
    Username: email,
    //MessageAction: 'SUPPRESS'
  };

  try {
    const response = await cognito.confirmSignUp(params).promise();

    return sendResponse(200, { message: 'User verification completed' });
  } catch (error) {
    return sendResponse(500, { message: 'Error registering user' });
  }
};
