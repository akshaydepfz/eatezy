const admin = require("firebase-admin");
const functions = require("firebase-functions");
const {logger} = require("firebase-functions");

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();
const ADMIN_DOC_ID = "vcEyyBUUm5NAwliB3dTX";

exports.onCartOrderCreated = functions.firestore
    .document("cart/{orderId}")
    .onCreate(async (snapshot, context) => {
    if (!snapshot) {
      logger.warn("Missing cart snapshot in create event");
      return;
    }

    const order = snapshot.data() || {};
    const vendorId = (order.vendor_id || "").toString().trim();
    const customerName = (order.customer_name || "Customer").toString().trim();
    const orderId = context.params.orderId;

    if (!vendorId) {
      logger.warn("Order missing vendor_id", {orderId});
      return;
    }

    const [vendorSnap, adminSnap] = await Promise.all([
      db.collection("vendors").doc(vendorId).get(),
      db.collection("admin").doc(ADMIN_DOC_ID).get(),
    ]);

    const vendorToken = vendorSnap.exists ?
      (vendorSnap.get("fcm_token") || "").toString().trim() :
      "";
    const adminToken = adminSnap.exists ?
      (adminSnap.get("fcm_token") || "").toString().trim() :
      "";

    const messages = [];
    if (vendorToken) {
      messages.push({
        token: vendorToken,
        notification: {
          title: "New order received",
          body: `${customerName} placed an order`,
        },
        data: {
          type: "new_order",
          orderId,
          vendorId,
        },
      });
    }

    if (adminToken) {
      messages.push({
        token: adminToken,
        notification: {
          title: "New order received",
          body: `${customerName} placed an order`,
        },
        data: {
          type: "new_order",
          orderId,
          vendorId,
        },
      });
    }

    if (messages.length === 0) {
      logger.info("No FCM tokens found for vendor/admin", {orderId, vendorId});
      return;
    }

    const results = await Promise.allSettled(
      messages.map((msg) => messaging.send(msg)),
    );

    results.forEach((result, index) => {
      const target = index === 0 ? "vendor" : "admin";
      if (result.status === "fulfilled") {
        logger.info(`Sent ${target} notification`, {
          orderId,
          messageId: result.value,
        });
      } else {
        logger.error(`Failed ${target} notification`, {
          orderId,
          error: result.reason?.message || result.reason,
        });
      }
    });
    });
