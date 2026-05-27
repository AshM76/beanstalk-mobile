// lib/services/ai_advisor_service.dart
//
// AI Advisor service — typed wrapper around the /api/ai/* endpoints.
//
// Error semantics are intentionally different per method, matching how
// each is used in the UI:
//   - getStatus() never throws. The advisor entry point should render
//     even if the status endpoint is unreachable, so on any failure we
//     return a permissive default (5 remaining, free tier).
//   - sendMessage() throws. 429 maps to AiLimitException so the chat
//     view can show the upgrade prompt; anything else surfaces as
//     AiAdvisorException with the backend's error message.
//
// Auth + base URL flow through ApiService — same JWT/Bearer pattern as
// every other service in this layer.

import 'api/api_service.dart';

class AiAdvisorService {
  static ApiService get _api => ApiService();

  /// GET /api/ai/status — current daily-usage snapshot for the user.
  /// Returns a safe default (remaining=5, free, usedToday=0) on any
  /// failure rather than surfacing the error to the UI.
  static Future<AiAdvisorStatus> getStatus() async {
    try {
      final r = await _api.getAiStatus();
      if (!r.isOk || r.data == null) {
        return const AiAdvisorStatus(
          remaining: 5,
          isPremium: false,
          usedToday: 0,
        );
      }
      return AiAdvisorStatus.fromJson(r.data!);
    } catch (_) {
      return const AiAdvisorStatus(
        remaining: 5,
        isPremium: false,
        usedToday: 0,
      );
    }
  }

  /// POST /api/ai/chat — send the running conversation, get the next
  /// assistant reply. Throws [AiLimitException] on 429 so the caller
  /// can branch on rate-limit vs. other errors; any other failure
  /// throws [AiAdvisorException].
  static Future<AiChatResult> sendMessage(List<AiMessage> messages) async {
    final r = await _api.sendAiChat(
      messages.map((m) => m.toJson()).toList(),
    );
    if (r.isOk && r.data != null) {
      return AiChatResult.fromJson(r.data!);
    }
    if (r.statusCode == 429) {
      throw AiLimitException();
    }
    throw AiAdvisorException(r.error ?? 'AI request failed');
  }
}

// ── Data classes ────────────────────────────────────────────────────────────

class AiMessage {
  final String role;
  final String content;

  const AiMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

class AiAdvisorStatus {
  final int? remaining;
  final bool isPremium;
  final int usedToday;

  const AiAdvisorStatus({
    required this.remaining,
    required this.isPremium,
    required this.usedToday,
  });

  /// True only when the user is on the free tier and has hit zero
  /// remaining messages for the day. Premium users (no remaining cap)
  /// always read as not-limited.
  bool get isLimited =>
      !isPremium && remaining != null && remaining! <= 0;

  factory AiAdvisorStatus.fromJson(Map<String, dynamic> json) {
    return AiAdvisorStatus(
      remaining: _asInt(json['remaining']),
      isPremium: json['isPremium'] == true || json['is_premium'] == true,
      usedToday:
          _asInt(json['usedToday']) ?? _asInt(json['used_today']) ?? 0,
    );
  }
}

class AiChatResult {
  final String reply;
  final int? remaining;
  final bool isPremium;

  const AiChatResult({
    required this.reply,
    required this.remaining,
    required this.isPremium,
  });

  factory AiChatResult.fromJson(Map<String, dynamic> json) {
    return AiChatResult(
      reply: (json['reply'] as String?) ?? '',
      remaining: _asInt(json['remaining']),
      isPremium: json['isPremium'] == true || json['is_premium'] == true,
    );
  }
}

// ── Exceptions ──────────────────────────────────────────────────────────────

class AiLimitException implements Exception {
  AiLimitException();

  @override
  String toString() =>
      'AiLimitException: daily AI message limit reached';
}

class AiAdvisorException implements Exception {
  final String message;

  AiAdvisorException(this.message);

  @override
  String toString() => 'AiAdvisorException: $message';
}

// ── Helpers ─────────────────────────────────────────────────────────────────

int? _asInt(Object? v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}
