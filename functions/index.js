/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 *
 * NOTE: before enabling this function we had to:
 * 1. Install npm
 * 2. Install the Firebase CLI (npm install -g firebase-tools)
 * 3. Run firebase init and select Function (as we had our project configured already)
 * 4. Run firebase deploy --only functions (when function was complete
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require('firebase-admin');

admin.initializeApp();

// Cloud Firestore triggers ref: https://firebase.google.com/docs/functions/firestore-events
exports.myFunction = onDocumentCreated("chat/{messageId}", (event) => {
  const snapshot = event.data;
  if (!snapshot) {
    console.log("No data associated with the event");
    return null;
  }

  return admin.messaging().send({
    notification: {
      title: snapshot.data()['username'],
      body: snapshot.data()['text'],
    },
    data: {
      click_action: 'FLUTTER_NOTIFICATION_CLICK',
    },
    topic: 'chat',
  });
});