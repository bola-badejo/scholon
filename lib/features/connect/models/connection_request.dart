import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/connect/models/connection_status.dart';
import 'package:isapp/features/connect/models/connection_type.dart';
import 'package:isapp/features/connect/models/nigerian_system_on_connect_controller.dart';

// ========== CONNECTION REQUEST MODEL ==========
class ConnectionRequest {
  final String id;
  final String senderId;
  final String senderName;
  final String senderType;
  final String receiverId;
  final String receiverName;
  final String receiverType;
  final ConnectionType type;
  final String? message;
  final DateTime sentAt;
  final ConnectionStatus status;
  final DateTime? respondedAt;
  final String? rejectionReason;

  ConnectionRequest({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderType,
    required this.receiverId,
    required this.receiverName,
    required this.receiverType,
    required this.type,
    this.message,
    required this.sentAt,
    this.status = ConnectionStatus.pending,
    this.respondedAt,
    this.rejectionReason,
  });

  factory ConnectionRequest.fromFirestore(Map<String, dynamic> data) {
    return ConnectionRequest(
      id: data['id']?.toString() ?? '',
      senderId: data['senderId']?.toString() ?? '',
      senderName: data['senderName']?.toString() ?? '',
      senderType: data['senderType']?.toString() ?? '',
      receiverId: data['receiverId']?.toString() ?? '',
      receiverName: data['receiverName']?.toString() ?? '',
      receiverType: data['receiverType']?.toString() ?? '',
      type: ConnectionType.values.firstWhere(
        (e) => e.name == (data['type']?.toString() ?? 'student'),
        orElse: () => ConnectionType.student,
      ),
      message: data['message']?.toString(),
      sentAt: (data['sentAt'] as Timestamp).toDate(),
      status: ConnectionStatus.values.firstWhere(
        (e) => e.name == (data['status']?.toString() ?? 'pending'),
        orElse: () => ConnectionStatus.pending,
      ),
      respondedAt: data['respondedAt'] != null
          ? (data['respondedAt'] as Timestamp).toDate()
          : null,
      rejectionReason: data['rejectionReason']?.toString(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'senderType': senderType,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverType': receiverType,
      'type': type.name,
      'message': message,
      'sentAt': Timestamp.fromDate(sentAt),
      'status': status.name,
      'respondedAt': respondedAt != null
          ? Timestamp.fromDate(respondedAt!)
          : null,
      'rejectionReason': rejectionReason,
      'createdAt': Timestamp.now(),
    };
  }

  bool get isPending => status == ConnectionStatus.pending;
  bool get isAccepted => status == ConnectionStatus.accepted;
  bool get isRejected => status == ConnectionStatus.rejected;
}
