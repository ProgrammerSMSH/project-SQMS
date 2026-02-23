const admin = require('firebase-admin');

// Note: In production, place your firebase service account JSON securely and reference it via env
// e.g. admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
// For this structure, we'll initialize a mock block or require a local path if exists.
try {
  // admin.initializeApp({ credential: admin.credential.cert(require('../firebase-service-account.json')) });
  console.log('FCM initialized (Mocked missing credentials for safety)');
} catch (error) {
  console.warn('FCM initiation skipped: Missing credentials.');
}

const sendPushNotification = async (fcmTokens, title, body, data = {}) => {
  if (!fcmTokens || fcmTokens.length === 0) return;

  const message = {
    notification: {
      title,
      body,
    },
    data,
    tokens: fcmTokens,
  };

  try {
    // const response = await admin.messaging().sendMulticast(message);
    // console.log(response.successCount + ' messages were sent successfully');
    console.log(`[FCM Mock] Sent to ${fcmTokens.length} devices: ${title} - ${body}`);
  } catch (error) {
    console.error('Error sending message:', error);
  }
};

module.exports = { sendPushNotification };
