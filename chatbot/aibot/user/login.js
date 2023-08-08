const AWS = require('aws-sdk');

const cognito = new AWS.CognitoIdentityServiceProvider();

module.exports.handler = async (event) => {
    const {
        email,
        password
    } = JSON.parse(event.body);
    const {
        user_pool_id,
        client_id
    } = process.env;

    const params = {
        AuthFlow: "ADMIN_NO_SRP_AUTH",
        UserPoolId: user_pool_id,
        ClientId: client_id,
        AuthParameters: {
            USERNAME: email,
            PASSWORD: password
        }
    };

    try {
        const response = await cognito.adminInitiateAuth(params).promise();
        console.log('token -  '+response.AuthenticationResult.AccessToken);
        console.log('Id token -  '+response.AuthenticationResult.IdToken);
        
        return {
            statusCode: 200,
            body: JSON.stringify({
                message: 'Success',
                idToken: response.AuthenticationResult.IdToken,
                accessToken: response.AuthenticationResult.AccessToken
            })
        };
    } catch (error) {
        return {
            statusCode: 500,
            body: JSON.stringify({ message: 'Error logging in BRAIN WAVES' + error })
        };
    }
};
