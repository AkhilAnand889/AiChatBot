const AWS = require('aws-sdk');
const { sendResponse, validateInput } = require("../functions");

const cognito = new AWS.CognitoIdentityServiceProvider();

module.exports.handler = async (event) => {

  const { email,confirmationcode,newPassword} = JSON.parse(event.body);
  const { user_pool_id,client_id } = process.env;

  const params = {
    ClientId: client_id,
    ConfirmationCode: confirmationcode,
    Password: newPassword,
    Username: email,
  };

  try {
    const response = await cognito.confirmForgotPassword(params).promise();

    return sendResponse(200, { response, work : "Password successfully changed" });
  } catch (error) {
    return sendResponse(500, { message: error.message });
  }
};
