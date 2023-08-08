const AWS = require("aws-sdk");
const { sendResponse, validateInput } = require("../functions");

const cognito = new AWS.CognitoIdentityServiceProvider();



module.exports.handler = async (event, context) => {
  try {
    const { email, password, firstName, lastName } = JSON.parse(event.body);
    const { user_pool_id, client_id } = process.env;

    const params = {
      ClientId: client_id,
      Password: password,
      Username: email,
      UserAttributes: [
        { Name: "email", Value: email },
        { Name: "given_name", Value: firstName },
        { Name: "family_name", Value: lastName },
      ],
    };

    const response = await cognito.signUp(params).promise();
    const userId = response.UserSub;

    console.log('User ID:*****************', userId);
    console.log('Signup response:', response);


    return sendResponse(200, { message: "User registration successful" });
  } catch (error) {
    console.log(error);
    return sendResponse(500, { message: "Error registering user" });
  }
};

