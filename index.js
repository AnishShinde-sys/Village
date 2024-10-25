// index.js

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendAlertNotification = functions.firestore
    .document('alerts/{alertId}')
    .onCreate(async (snap, context) => {
        const alertData = snap.data();
        const kidID = alertData.kidID;
        const status = alertData.status;

        // Get the kid's data
        const kidDoc = await admin.firestore().collection('users').doc(kidID).get();
        const kidData = kidDoc.data();
        const kidName = kidData.name || 'A kid';
        const villageID = kidData.villageID;

        // Get all parents in the village
        const villageMembersSnapshot = await admin.firestore()
            .collection('villages')
            .doc(villageID)
            .collection('members')
            .where('isParent', '==', true)
            .get();

        const tokens = [];
        villageMembersSnapshot.forEach(memberDoc => {
            const memberData = memberDoc.data();
            const fcmToken = memberData.fcmToken;
            if (fcmToken) {
                tokens.push(fcmToken);
            }
        });

        const payload = {
            notification: {
                title: 'Alert',
                body: `${kidName} is ${status}! Can you go to their location?`,
            },
            data: {
                kidID: kidID,
                status: status
            }
        };

        if (tokens.length > 0) {
            return admin.messaging().sendToDevice(tokens, payload);
        } else {
            return null;
        }
    });
