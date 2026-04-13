import 'dart:convert';
import 'package:flutter/material.dart';

// ── Notification type ─────────────────────────────────────────────────────────

enum AppNotifType { general, contest, lesson, promo, badge }

extension AppNotifTypeX on AppNotifType {
  String get id {
    switch (this) {
      case AppNotifType.general: return 'general';
      case AppNotifType.contest: return 'contest';
      case AppNotifType.lesson:  return 'lesson';
      case AppNotifType.promo:   return 'promo';
      case AppNotifType.badge:   return 'badge';
    }
  }

  IconData get icon {
    switch (this) {
      case AppNotifType.general: return Icons.notifications_rounded;
      case AppNotifType.contest: return Icons.emoji_events_rounded;
      case AppNotifType.lesson:  return Icons.menu_book_rounded;
      case AppNotifType.promo:   return Icons.local_offer_rounded;
      case AppNotifType.badge:   return Icons.military_tech_rounded;
    }
  }

  Color get color {
    switch (this) {
      case AppNotifType.general: return const Color(0xFF2E7D32);
      case AppNotifType.contest: return const Color(0xFFF57F17);
      case AppNotifType.lesson:  return const Color(0xFF1565C0);
      case AppNotifType.promo:   return const Color(0xFF6A1B9A);
      case AppNotifType.badge:   return const Color(0xFFAD6C00);
    }
  }

  Color get bgColor {
    switch (this) {
      case AppNotifType.general: return const Color(0xFFE8F5E9);
      case AppNotifType.contest: return const Color(0xFFFFF8E1);
      case AppNotifType.lesson:  return const Color(0xFFE3F2FD);
      case AppNotifType.promo:   return const Color(0xFFF3E5F5);
      case AppNotifType.badge:   return const Color(0xFFFFF3E0);
    }
  }

  static AppNotifType fromId(String id) {
    switch (id) {
      case 'contest': return AppNotifType.contest;
      case 'lesson':  return AppNotifType.lesson;
      case 'promo':   return AppNotifType.promo;
      case 'badge':   return AppNotifType.badge;
      default:        return AppNotifType.general;
    }
  }
}

// ── Model ─────────────────────────────────────────────────────────────────────

class AppNotification {
  final String id;
  final AppNotifType type;
  final String title;
  final String body;
  final String? imageBase64; // optional rich image (base64 or data: URI)
  final DateTime createdAt;
  bool isRead;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.imageBase64,
    required this.createdAt,
    this.isRead = false,
  });

  // ── JSON serialisation ────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
    'id':          id,
    'type':        type.id,
    'title':       title,
    'body':        body,
    'imageBase64': imageBase64,
    'createdAt':   createdAt.toIso8601String(),
    'isRead':      isRead,
  };

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
    id:          j['id'] as String,
    type:        AppNotifTypeX.fromId(j['type'] as String? ?? 'general'),
    title:       j['title'] as String,
    body:        j['body'] as String,
    imageBase64: j['imageBase64'] as String?,
    createdAt:   DateTime.parse(j['createdAt'] as String),
    isRead:      j['isRead'] as bool? ?? false,
  );

  static String encodeList(List<AppNotification> list) =>
      jsonEncode(list.map((n) => n.toJson()).toList());

  static List<AppNotification> decodeList(String raw) {
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
  }
}
