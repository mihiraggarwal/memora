import * as functions from "firebase-functions";
import * as admin from 'firebase-admin';

admin.initializeApp();

// const db = admin.firestore();
const fcm = admin.messaging();

export const emergencyNotif = functions.firestore
    .document("emergencies/{docId}")
    .onCreate(async (snap, context) => {
        const doc = await snap.data();
        const fCMTokens = doc.caretakers;

        fCMTokens.forEach((token: string) => {
            const payload = {
                notification: {
                    title: "Emergency!",
                    body: `${doc.name} has clicked the Emergency button!`,
    //                 icon: 'static/ic_launcher.png',
                },
                token: token
            };
            fcm.send(payload);
        });
    })