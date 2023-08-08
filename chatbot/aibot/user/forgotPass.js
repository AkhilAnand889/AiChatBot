const AWS = require('aws-sdk');
const { sendResponse, validateInput } = require("../functions");

const cognito = new AWS.CognitoIdentityServiceProvider();

module.exports.handler = async (event) => {
    try {
        const { email } = JSON.parse(event.body);
        const { user_pool_id, client_id } = process.env;

        const params = {
            ClientId: client_id,
            Username: email,
        };

        const response = await cognito.forgotPassword(params).promise();

        return sendResponse(200, { response });
    } catch (error) {
        return sendResponse(500, { message: error.message });
    }
};
