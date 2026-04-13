import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/app_notification.dart';
import '../../services/notification/notification_service.dart';

// ── NotificationsPage ─────────────────────────────────────────────────────────

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<AppNotification> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await NotificationService.load();
    if (!mounted) return;
    setState(() {
      _notifications = list;
      _loading = false;
    });
  }

  Future<void> _markAllRead() async {
    await NotificationService.markAllRead();
    if (!mounted) return;
    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });
  }

  Future<void> _markRead(AppNotification notif) async {
    if (notif.isRead) return;
    await NotificationService.markRead(notif.id);
    if (!mounted) return;
    setState(() => notif.isRead = true);
  }

  Future<void> _delete(String id) async {
    await NotificationService.delete(id);
    if (!mounted) return;
    setState(() => _notifications.removeWhere((n) => n.id == id));
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notifications',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            if (_unreadCount > 0)
              Text('$_unreadCount unread',
                  style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Mark all read',
                  style: TextStyle(color: Colors.white, fontSize: 13)),
            ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : _notifications.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: _load,
                  color: const Color(0xFF2E7D32),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: _notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 2),
                    itemBuilder: (ctx, i) {
                      final notif = _notifications[i];
                      return _NotifTile(
                        key: ValueKey(notif.id),
                        notif: notif,
                        onTap: () => _markRead(notif),
                        onDismiss: () => _delete(notif.id),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmpty() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cash character placeholder
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🌱', style: TextStyle(fontSize: 48)),
                ),
              ),
              const SizedBox(height: 20),
              const Text("You're all caught up! 🌱",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20))),
              const SizedBox(height: 10),
              const Text(
                  'No new notifications.\nCash will let you know when something exciting happens!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5)),
            ],
          ),
        ),
      );
}

// ── Individual notification tile ──────────────────────────────────────────────

class _NotifTile extends StatefulWidget {
  const _NotifTile({
    super.key,
    required this.notif,
    required this.onTap,
    required this.onDismiss,
  });

  final AppNotification notif;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  State<_NotifTile> createState() => _NotifTileState();
}

class _NotifTileState extends State<_NotifTile> {
  bool _expanded = false;

  void _handleTap() {
    setState(() => _expanded = !_expanded);
    widget.onTap(); // mark read
  }

  @override
  Widget build(BuildContext context) {
    final n       = widget.notif;
    final isUnread = !n.isRead;
    final color   = n.type.color;

    return Dismissible(
      key: ValueKey('dismiss_${n.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 26),
            SizedBox(height: 2),
            Text('Delete', style: TextStyle(color: Colors.white, fontSize: 11)),
          ],
        ),
      ),
      onDismissed: (_) => widget.onDismiss(),
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          decoration: BoxDecoration(
            color: isUnread
                ? Colors.white
                : const Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(16),
            border: Border(
              left: BorderSide(
                color: isUnread ? color : Colors.transparent,
                width: 4,
              ),
              right:  const BorderSide(color: Colors.transparent),
              top:    BorderSide(color: isUnread ? color.withValues(alpha: 0.15) : Colors.transparent),
              bottom: BorderSide(color: isUnread ? color.withValues(alpha: 0.15) : Colors.transparent),
            ),
            boxShadow: isUnread
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 13, 12, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type icon bubble
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: n.type.bgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(n.type.icon, size: 20, color: color),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  n.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isUnread
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: const Color(0xFF1A1A1A),
                                  ),
                                ),
                              ),
                              if (isUnread)
                                Padding(
                                  padding: const EdgeInsets.only(left: 6, top: 3),
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Body — always shows 2-line preview; expands to full on tap
                          AnimatedSize(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            alignment: Alignment.topCenter,
                            child: Text(
                              n.body,
                              maxLines: _expanded ? null : 2,
                              overflow: _expanded
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: isUnread
                                    ? const Color(0xFF444444)
                                    : Colors.grey.shade600,
                                height: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Footer row: timestamp + type chip
                          Row(
                            children: [
                              Text(
                                _formatTime(n.createdAt),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: n.type.bgColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _typeLabel(n.type),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                _expanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                size: 18,
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Optional rich image
              if (n.imageBase64 != null && n.imageBase64!.isNotEmpty && _expanded)
                _buildImage(n.imageBase64!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String src) {
    try {
      final b64 = src.contains(',') ? src.split(',').last : src;
      return ClipRRect(
        borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(16)),
        child: SizedBox(
          width: double.infinity,
          height: 160,
          child: FittedBox(
            fit: BoxFit.cover,
            child: Image.memory(base64Decode(b64)),
          ),
        ),
      );
    } catch (_) {
      return const SizedBox.shrink();
    }
  }

  static String _typeLabel(AppNotifType t) {
    switch (t) {
      case AppNotifType.contest: return 'Contest';
      case AppNotifType.lesson:  return 'Lesson';
      case AppNotifType.promo:   return 'Promo';
      case AppNotifType.badge:   return 'Badge';
      case AppNotifType.general: return 'General';
    }
  }

  static String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1)  return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    if (diff.inDays == 1)    return 'Yesterday';
    if (diff.inDays < 7)     return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dt);
  }
}
