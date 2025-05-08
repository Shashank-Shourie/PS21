const AWS = require('aws-sdk');

AWS.config.update({
  region: process.env.AWS_REGION,
  accessKeyId: process.env.AWS_ACCESS_KEY,
  secretAccessKey: process.env.AWS_SECRET_KEY,
});

const sns = new AWS.SNS();

const sendCredentialsSMS = async (phone, email, password) => {
  const params = {
    Message: `Your Document Analyzer credentials - Email: ${email}, Password: ${password}`,
    PhoneNumber: phone,
  };

  try {
    await sns.publish(params).promise();
    console.log('SMS sent successfully');
  } catch (err) {
    console.error('Error sending SMS:', err);
    throw err;
  }
};

module.exports = { sendCredentialsSMS };