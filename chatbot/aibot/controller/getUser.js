const AWS = require('aws-sdk');
const { sendResponse } = require('../functions');
const cognito = new AWS.CognitoIdentityServiceProvider();

module.exports.getUserAttribute = async (event, context) => {
  try {
    const { Authorization } = event.headers;
    const accessToken = Authorization;

    const params = {
      AccessToken: accessToken,
    };

    const response = await cognito.getUser(params).promise();
    const userAttributes = response.UserAttributes;

    console.log('User attributes :', userAttributes);
    console.log(response);
    return sendResponse(200, { message: "successfully getted the user attributes", userAttributes : userAttributes });
  } catch (error) {
    console.log(error);
    return sendResponse(500, { message : "An internal Server Error Found"+error});
  }
};
