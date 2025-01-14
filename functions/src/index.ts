import * as functions from "firebase-functions";
import * as admin from 'firebase-admin';

admin.initializeApp();

// const db = admin.firestore();
const fcm = admin.messaging();

export const emergencyNotif = functions.firestore
    .document("emergencies/{docId}")
    .onCreate((snap, context) => {
        const doc = snap.data();
        const fCMTokens = doc.caretakers;

        const payload: admin.messaging.MessagingPayload = {
            notification: {
                title: "Emergency!",
                body: `${doc.name} has clicked the Emergency button!`,
                icon: 'static/ic_launcher.png',
                clickAction: 'FLUTTER_NOTIFICATION_CLICK'
            }
        };

        return fcm.sendToDevice(fCMTokens, payload);
    })