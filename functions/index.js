const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();
const db = getFirestore();

// 🔔 Send push notification when a join request is made
// exports.sendJoinRequestNotification = onDocumentUpdated("study_groups/{groupId}", async (event) => {
//   const before = event.data.before.data();
//   const after = event.data.after.data();

//   const beforeRequests = before.pendingRequests || [];
//   const afterRequests = after.pendingRequests || [];

//   const newRequests = afterRequests.filter(uid => !beforeRequests.includes(uid));
//   if (newRequests.length === 0) return;

//   const groupId = event.params.groupId;
//   const groupName = after.groupName || "Your Group";
//   const creatorId = after.createdBy;

//   const creatorSnap = await db.collection("users").doc(creatorId).get();
//   const creatorToken = creatorSnap.data()?.fcmToken;
//   if (!creatorToken) return;

//   const requesterSnapshots = await Promise.all(
//     newRequests.map(uid => db.collection("users").doc(uid).get())
//   );
//   const requesterNames = requesterSnapshots.map(doc => doc.data()?.name || "Someone");

//   const payload = {
//     notification: {
//       title: `Join Request for ${groupName}`,
//       body: `${requesterNames.join(", ")} requested to join your group.`,
//     },
//   };

//   await getMessaging().sendToDevice(creatorToken, payload);
// });

// const { onSchedule } = require("firebase-functions/v2/scheduler");

// // 🔔 Scheduled Function: Remind users 10 mins before group starts
// exports.sendUpcomingGroupReminders = onSchedule("every 1 minutes", async (event) => {
//   const now = new Date();
//   const tenMinutesLater = new Date(now.getTime() + 10 * 60 * 1000);
//   const bufferEnd = new Date(now.getTime() + 11 * 60 * 1000);

//   const snapshot = await db.collection("study_groups")
//     .where("reminderSent", "!=", true)
//     .get();

//   const groupsToNotify = snapshot.docs.filter(doc => {
//     const data = doc.data();
//     const startTime = data.startTime.toDate();
//     return startTime >= tenMinutesLater && startTime < bufferEnd;
//   });

//   for (const doc of groupsToNotify) {
//     const data = doc.data();
//     const members = new Set(data.members || []);
// members.add(data.createdBy); //  leader
//     const groupName = data.groupName || "Group";

//     const tokens = [];

//     for (const uid of members) {
//   const userSnap = await db.collection("users").doc(uid).get();
//   const token = userSnap.data()?.fcmToken;
//   if (token) tokens.push(token);
// }

//     const payload = {
//       notification: {
//         title: `⏰ Reminder: "${groupName}" starts soon!`,
//         body: `Your study group is starting in 10 minutes. Get ready!`,
//       },
//     };

//     if (tokens.length > 0) {
//       await getMessaging().sendToDevice(tokens, payload);
//     }

//     await doc.ref.update({ reminderSent: true });
//   }

//   console.log(`⏰ Reminder sent for ${groupsToNotify.length} groups`);
// });