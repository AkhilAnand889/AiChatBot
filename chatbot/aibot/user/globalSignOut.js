const AWS = require('aws-sdk');
const { sendResponse } = require('../functions');
const cognito = new AWS.CognitoIdentityServiceProvider();


module.exports.globalSignout = async (event, context) => {
    try {
        const { Authorization } = event.headers;
        const accessToken = Authorization;
        const params = {
            AccessToken: accessToken,
        };

        await cognito.globalSignOut(params).promise();
        return sendResponse(200,{success : true, message : 'Logout Completed successfully'});
    } catch (error) {
        console.error('Error during global signout:', error);
        return { success: false, message: 'Global signout failed.' };
    }
}