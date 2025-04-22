import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;

class ChatProvider with ChangeNotifier {
  String userToken = FirebaseAuth.instance.currentUser!.uid;

  Future<int> getUnreadCount(String chatId) async {
    if (userToken == null) return 0;

    final messages = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .where('senderToken', isNotEqualTo: userToken)
        .get();

    return messages.docs.length;
  }

  Future<void> sendDummyMessage() async {
    final dummyMessage = "Hello from the other side!";
    final timestamp = FieldValue.serverTimestamp();

    await FirebaseFirestore.instance
        .collection('chats')
        .doc('FfKvM00wNorG7OJjdK98_dummy_user')
        .collection('messages')
        .add({
      'text': dummyMessage,
      'senderToken': "other_person_token",
      'timestamp': timestamp,
      'isRead': false,
    });

    await FirebaseFirestore.instance
        .collection('chats')
        .doc('FfKvM00wNorG7OJjdK98_dummy_user')
        .update({
      'lastMessage': dummyMessage,
      'lastMessageTime': timestamp,
    });
  }

  Stream<QuerySnapshot> getChatStream() {
    if (userToken == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: userToken)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  Future<void> markMessagesAsRead(String chatId) async {
    if (chatId != '') {
      final unreadMessages = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('isRead', isEqualTo: false)
          .where('senderToken', isNotEqualTo: userToken)
          .get();

      if (unreadMessages.docs.isNotEmpty) {
        final batch = FirebaseFirestore.instance.batch();
        for (var doc in unreadMessages.docs) {
          batch.update(doc.reference, {'isRead': true});
        }
        await batch.commit();
      }
    }
  }

  Future<void> sendMessage(
      String chatId, String text, String vedorToken) async {
    if (text.trim().isEmpty) return;

    final messageData = {
      'text': text.trim(),
      'senderToken': userToken,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    };

    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);

    await chatRef.collection('messages').add(messageData);
    await chatRef.update({
      'lastMessage': text.trim(),
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
    sendFCMMessage(vedorToken, text);
  }

  Stream<QuerySnapshot> getMessagesStream(String chatId, vendorId) {
    if (chatId == '') {
      return FirebaseFirestore.instance
          .collection('chats')
          .doc("${FirebaseAuth.instance.currentUser!.uid}$vendorId")
          .collection('messages')
          .orderBy('timestamp')
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp')
          .snapshots();
    }
  }

  Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "eatezy-63f35",
      "private_key_id": "af3cd0df401e419c44d03a104fb0c8589e3dd76d",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCuo2sgQ68HULgN\nZfpIDdGZarPOB2NQsNNK/IiKzft60p8Qog37VhpOmtAYhstAYRO8RKBs77XprA2c\nabI8u5OVuHuVpfJ0muhWbDNjpTKTAK/JR+7kjLbAvBiv9o5fDn8cb7t7jhqEe3Xt\nnI621Lm8jpbnZr2YF/L+3W6gLzelAtsMJ945B45J65IrkTS8gC52R/YWMtIp4Lef\naz1WEpvSyBTpXARq2EhdoAjdGVARdGHQyN3AfOZEdfKnBalXOrVvtFpRX10045XM\nDZB/5d5B1+uNCmyF8zuwcCMt9nZdoN/wYwV8egnn4cNKwHEdJKIyn7rNwknWdHHz\nuiHh16Y3AgMBAAECggEATdHFVUHD11MpSNMl5YC+4wnQqKDTKSw6Y0JHx+6EvtTn\nC57i8xoJq/hBfYRnQr9fb3f3MsPYgJFqGUZiJb0CRWfJLkSd10cF/CjH94GwGSBn\ntJ4ovlBTyWun5pVMGOCZVL8XQLXwbBOl16V5VNBTGcpCRUgbeRBG+DoM5zVTKuRv\npxtiZ6sawrshbLjewX11J1tWglRcK3F3B3P+2KoYXDBujOjcvyy2jucJt9dzvkGr\nHUbJWdQ0zg9wfyxrlFncMR4JMCeCRx/8KkdxTFM5E6rJylRuWN9PQO7SWAtibtcv\nQWodNLs+0KYoffLkSpgusfegHsBLFcRNQBuf9mqfoQKBgQDfNI8ZQDncKIWPRb3a\nZb9rMzlBo0BlrGCjxsqttjiBDNosu4hErpurjG5FnMhgA5a9B/3dOarl+xVAwgVq\n39Y2tyan9m8U8xXTRpbX33LSdJFezGGLD+uLCEZIWpgsUaxixfEEvvicIvOd6nHg\nIlnUOFhcs1fALoqPc/nAzUzWIQKBgQDITBs2ffgE3/cP6YtRYHWj/9baX7ueSaJ4\nsRrqTbx+GVp9fRB/GSzOJ+8Pg0Lb0NvtOkeIIeRCehaw84FRXRhJaiSz6NeRINPu\n2VvHKtW2p1C25hj/ShI5zMq383V65wXFONhA8b9WuWPUTEBLBaqwA48qU9SPd6Bv\nBjue7czBVwKBgQC3NEzATRcwvZHipzvNpvYW51R3q6ePzI0F4IU7T/XQ9tudG9Ad\nj7P2eq2INcfCBzASuByHGG5Nlmk7XgVUU6VgA7SW6I8EgwHHCImHZsC4PTWUuezW\nV5rd40zM1o9Q0TjNWesaGiW1Anszgts1PPy+VAEzFYFRHOJeHLNCrUAEAQKBgQDB\nOBHEVm6MnVUjZ4L7BJdXlnS4AkPmZVgzH348arMb3e9aQOxJ/4omcYV/LHuxu2B9\nD4xzuWYN7uK23qBwUeMc5yTy3PoeyVFJBysvDZZOdkc5uOyCUP0V/wXLwDMjVXtO\njxCmTc7rpTm1Ub1v4c6Pr09LYMUbhSYiFBwtq26rTwKBgEektJZyozz9iRbfNTKp\nLCxKR0q/Sx/Cjp+uryqGRAMuXnWiDiPL0Ge37kg75CFi143DRfwF/2gqoFec7/e3\nW1FD4vn2GFPrd3ORpVR4ZAnYqlv3gEvGPyH84ZtWzwabIUPHHoVsoy/Ktu994Qvf\n0CG9SsrPYpHzMNSrJdUJoLvf\n-----END PRIVATE KEY-----\n",
      "client_email":
          "firebase-adminsdk-fbsvc@eatezy-63f35.iam.gserviceaccount.com",
      "client_id": "105045129822052618782",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40eatezy-63f35.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client);

    client.close();

    return credentials.accessToken.data;
  }

  Future<void> sendFCMMessage(String token, String text) async {
    final String serverKey = await getAccessToken(); // Your FCM server key

    final String fcmEndpoint =
        'https://fcm.googleapis.com/v1/projects/eatezy-63f35/messages:send';
    // final currentFCMToken = await FirebaseMessaging.instance.getToken();

    final Map<String, dynamic> message = {
      'message': {
        'token': token,
        'notification': {'body': text, 'title': 'New Message Recived 🔔'},
      }
    };

    final http.Response response = await http.post(
      Uri.parse(fcmEndpoint),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKey',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('FCM message sent successfully');
    } else {
      print('Failed to send FCM message: ${response.statusCode}');
    }
  }
}
