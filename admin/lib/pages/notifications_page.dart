import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../models/admin_models.dart';
import '../widgets/section_header.dart';

// ── Notification types ────────────────────────────────────────────────────────

class _NotifTypeInfo {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final String emoji;
  const _NotifTypeInfo(this.id, this.label, this.icon, this.color, this.emoji);
}

const _kNotifTypes = [
  _NotifTypeInfo('general',  'General',       Icons.notifications_rounded,   Color(0xFF2E7D32), '🌱'),
  _NotifTypeInfo('contest',  'Contest Alert',  Icons.emoji_events_rounded,    Color(0xFFF57F17), '🏆'),
  _NotifTypeInfo('lesson',   'New Lesson',     Icons.menu_book_rounded,       Color(0xFF1565C0), '📚'),
  _NotifTypeInfo('promo',    'Promotion',      Icons.local_offer_rounded,     Color(0xFF6A1B9A), '🎁'),
];

_NotifTypeInfo _typeInfo(String id) =>
    _kNotifTypes.firstWhere((t) => t.id == id, orElse: () => _kNotifTypes.first);

// ── Page ──────────────────────────────────────────────────────────────────────

class NotificationsAdminPage extends StatefulWidget {
  const NotificationsAdminPage({super.key});
  @override
  State<NotificationsAdminPage> createState() => _NotificationsAdminPageState();
}

class _NotificationsAdminPageState extends State<NotificationsAdminPage> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl  = TextEditingController();
  String  _segment    = 'All Users';
  String? _contestId;
  String  _notifType  = 'general';
  bool    _sending    = false;

  // Rich image
  Uint8List? _imageBytes;
  String?    _imageWarning;

  // Preview platform toggle
  bool _showIos = true;

  final List<SentNotification> _sent =
      List.from(MockStore.sentNotifications.reversed);

  static const _segments = [
    'All Users', 'High School', 'College',
    'Young Professional', 'Adult', 'Contest Participants',
  ];
  static const _kPrimary = Color(0xFF2E7D32);

  int get _recipientCount {
    if (_segment == 'Contest Participants') {
      if (_contestId == null) return 0;
      return MockStore.contests
          .firstWhere((c) => c.id == _contestId,
              orElse: () => MockStore.contests.first)
          .participants;
    }
    return MockStore.segmentCounts[_segment] ?? 0;
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg'],
      withData: true,
    );
    final bytes = result?.files.firstOrNull?.bytes;
    if (bytes == null) return;

    final warnings = <String>[];
    final mb = bytes.lengthInBytes / (1024 * 1024);
    if (mb > 2) warnings.add('${mb.toStringAsFixed(1)} MB — over 2 MB limit');
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final w = frame.image.width; final h = frame.image.height;
      frame.image.dispose(); codec.dispose();
      if (w != 1200 || h != 628) {
        warnings.add('${w}×${h} px — recommended 1200×628 (2:1)');
      }
    } catch (_) {}

    if (mounted) setState(() {
      _imageBytes   = bytes;
      _imageWarning = warnings.isEmpty ? null : warnings.join('  ·  ');
    });
  }

  Future<void> _send() async {
    if (_titleCtrl.text.trim().isEmpty || _bodyCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and body are required.')));
      return;
    }
    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 800));

    String segmentLabel = _segment;
    if (_segment == 'Contest Participants' && _contestId != null) {
      final c = MockStore.contests
          .firstWhere((c) => c.id == _contestId, orElse: () => MockStore.contests.first);
      segmentLabel = 'Contest: ${c.title}';
    }

    final n = SentNotification(
      id:             'n${DateTime.now().millisecondsSinceEpoch}',
      title:          _titleCtrl.text.trim(),
      body:           _bodyCtrl.text.trim(),
      segment:        segmentLabel,
      sentAt:         DateTime.now(),
      recipientCount: _recipientCount,
      notifType:      _notifType,
      imageBase64:    _imageBytes != null ? base64Encode(_imageBytes!) : null,
    );

    setState(() {
      _sent.insert(0, n);
      _titleCtrl.clear();
      _bodyCtrl.clear();
      _segment    = 'All Users';
      _contestId  = null;
      _notifType  = 'general';
      _imageBytes = null;
      _imageWarning = null;
      _sending = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Sent to ${_fmtCount(n.recipientCount)} recipients!'),
        backgroundColor: _kPrimary,
      ));
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(builder: (_, constraints) {
        final wide = constraints.maxWidth > 800;
        final composer = _buildComposer();
        final history  = _buildHistory();
        if (wide) {
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: (constraints.maxWidth - 24) * 0.46, child: composer),
            const SizedBox(width: 24),
            Expanded(child: history),
          ]);
        }
        return Column(children: [composer, const SizedBox(height: 24), history]);
      }),
    );
  }

  // ── Composer ─────────────────────────────────────────────────────────────────

  Widget _buildComposer() {
    final typeInfo = _typeInfo(_notifType);
    final hasContent = _titleCtrl.text.isNotEmpty || _bodyCtrl.text.isNotEmpty;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionHeader(title: 'Compose Notification'),
      const SizedBox(height: 12),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── Notification Type ──
            _label('Notification Type'),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8,
              children: _kNotifTypes.map((t) {
                final sel = t.id == _notifType;
                return GestureDetector(
                  onTap: () => setState(() => _notifType = t.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: sel ? t.color : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: sel ? t.color : Colors.grey.shade300),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(t.icon, size: 14,
                          color: sel ? Colors.white : Colors.grey.shade600),
                      const SizedBox(width: 5),
                      Text(t.label, style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : Colors.grey.shade700)),
                    ]),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),

            // ── Target Segment ──
            _label('Target Segment'),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8,
              children: _segments.map((s) {
                final selected = s == _segment;
                return ChoiceChip(
                  label: Text(s, style: TextStyle(fontSize: 12,
                      color: selected ? Colors.white : Colors.black87)),
                  selected: selected,
                  selectedColor: _kPrimary,
                  backgroundColor: Colors.grey.shade100,
                  onSelected: (_) => setState(() => _segment = s),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                );
              }).toList(),
            ),
            if (_segment == 'Contest Participants') ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _contestId,
                hint: const Text('Select a contest…', style: TextStyle(fontSize: 13)),
                decoration: InputDecoration(
                  labelText: 'Contest',
                  prefixIcon: const Icon(Icons.emoji_events_rounded, size: 18, color: _kPrimary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: MockStore.contests.map((c) => DropdownMenuItem(
                  value: c.id,
                  child: Row(children: [
                    Container(width: 8, height: 8,
                        decoration: BoxDecoration(color: c.statusColor, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(c.title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13))),
                    Text('  ${c.participants}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ]),
                )).toList(),
                onChanged: (v) => setState(() => _contestId = v),
              ),
            ],
            const SizedBox(height: 6),
            Text(
              _segment == 'Contest Participants' && _contestId == null
                  ? 'Select a contest to see recipient count'
                  : '${_fmtCount(_recipientCount)} recipients',
              style: TextStyle(
                  fontSize: 11,
                  color: _segment == 'Contest Participants' && _contestId == null
                      ? Colors.orange.shade700
                      : Colors.grey.shade500,
                  fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),

            // ── Title ──
            _label('Notification Title'),
            const SizedBox(height: 8),
            TextField(
              controller: _titleCtrl,
              maxLength: 65,
              onChanged: (_) => setState(() {}),
              decoration: _dec(hint: 'e.g. Spring Trading Cup is LIVE! 🏆'),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 14),

            // ── Body ──
            _label('Message Body'),
            const SizedBox(height: 8),
            TextField(
              controller: _bodyCtrl,
              maxLength: 180,
              maxLines: 3,
              onChanged: (_) => setState(() {}),
              decoration: _dec(hint: 'Enter notification body...'),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 14),

            // ── Rich Image ──
            Row(children: [
              Icon(Icons.info_outline, size: 13, color: Colors.grey.shade500),
              const SizedBox(width: 5),
              Text('Rich Image  ·  1200 × 628 px (2:1)',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ]),
            const SizedBox(height: 8),
            if (_imageBytes == null)
              InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade50,
                  ),
                  child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.add_photo_alternate_rounded,
                        color: Colors.grey.shade400, size: 22),
                    const SizedBox(height: 3),
                    Text('Click to upload  PNG / JPG  (optional)',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ])),
                ),
              )
            else ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: double.infinity, height: 90,
                  child: FittedBox(fit: BoxFit.cover,
                      child: Image.memory(_imageBytes!)),
                ),
              ),
              const SizedBox(height: 6),
              Row(children: [
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.swap_horiz_rounded, size: 15),
                  label: const Text('Replace', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _kPrimary, side: const BorderSide(color: _kPrimary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => setState(() { _imageBytes = null; _imageWarning = null; }),
                  icon: const Icon(Icons.clear_rounded, size: 15),
                  label: const Text('Remove', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade400,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ]),
            ],
            if (_imageWarning != null) ...[
              const SizedBox(height: 6),
              Row(children: [
                Icon(Icons.warning_amber_rounded, size: 14, color: Colors.orange.shade700),
                const SizedBox(width: 4),
                Flexible(child: Text(_imageWarning!,
                    style: TextStyle(fontSize: 11, color: Colors.orange.shade700))),
              ]),
            ],

            // ── Preview ──
            if (hasContent) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 14),
              Row(children: [
                const Text('Preview',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const Spacer(),
                _PlatformToggle(
                    isIos: _showIos,
                    onToggle: (v) => setState(() => _showIos = v)),
              ]),
              const SizedBox(height: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _showIos
                    ? _IosPreview(
                        key: const ValueKey('ios'),
                        title: _titleCtrl.text.trim().isEmpty ? 'Beanstalk' : _titleCtrl.text.trim(),
                        body:  _bodyCtrl.text.trim().isEmpty  ? 'Your message preview...' : _bodyCtrl.text.trim(),
                        typeInfo: typeInfo,
                        imageBytes: _imageBytes,
                      )
                    : _AndroidPreview(
                        key: const ValueKey('android'),
                        title: _titleCtrl.text.trim().isEmpty ? 'Beanstalk' : _titleCtrl.text.trim(),
                        body:  _bodyCtrl.text.trim().isEmpty  ? 'Your message preview...' : _bodyCtrl.text.trim(),
                        typeInfo: typeInfo,
                        imageBytes: _imageBytes,
                      ),
              ),
              const SizedBox(height: 8),
            ],

            const SizedBox(height: 12),

            // ── Send ──
            SizedBox(
              width: double.infinity, height: 44,
              child: ElevatedButton.icon(
                onPressed: _sending ? null : _send,
                icon: _sending
                    ? const SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Icon(typeInfo.icon, size: 18),
                label: Text(_sending ? 'Sending…' : 'Send Notification'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: typeInfo.color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ),
          ]),
        ),
      ),
      const SizedBox(height: 20),

      // Segment breakdown
      const SectionHeader(title: 'Segment Breakdown'),
      const SizedBox(height: 12),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: MockStore.segmentCounts.entries.map((e) {
              final pct = e.value / MockStore.segmentCounts['All Users']!;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [
                  SizedBox(width: 130,
                      child: Text(e.key, style: const TextStyle(fontSize: 12))),
                  Expanded(child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: pct, minHeight: 6,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation(_kPrimary),
                    ),
                  )),
                  const SizedBox(width: 8),
                  Text(_fmtCount(e.value),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ]),
              );
            }).toList(),
          ),
        ),
      ),
    ]);
  }

  // ── History ───────────────────────────────────────────────────────────────────

  Widget _buildHistory() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader(
        title: 'Sent History',
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
          child: Text('${_sent.length} sent',
              style: const TextStyle(fontSize: 11, color: _kPrimary, fontWeight: FontWeight.w600)),
        ),
      ),
      const SizedBox(height: 12),
      if (_sent.isEmpty)
        const Card(child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('No notifications sent yet.',
              style: TextStyle(color: Colors.grey))),
        ))
      else
        Card(child: Column(
          children: _sent.asMap().entries.map((e) {
            final n = e.value;
            final info = _typeInfo(n.notifType);
            final last = e.key == _sent.length - 1;
            return Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(width: 40, height: 40,
                    decoration: BoxDecoration(
                        color: info.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(info.icon, color: info.color, size: 19),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text(n.title,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                      Text(_timeAgo(n.sentAt),
                          style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ]),
                    const SizedBox(height: 3),
                    Text(n.body,
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    if (n.imageBase64 != null) ...[
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          width: double.infinity, height: 48,
                          child: FittedBox(fit: BoxFit.cover,
                              child: Image.memory(base64Decode(n.imageBase64!))),
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(children: [
                      _Chip(label: info.label, color: info.color),
                      const SizedBox(width: 6),
                      _Chip(label: n.segment, color: _kPrimary),
                      const SizedBox(width: 6),
                      _Chip(label: '${_fmtCount(n.recipientCount)} recipients',
                          color: const Color(0xFF1565C0)),
                    ]),
                  ])),
                ]),
              ),
              if (!last) const Divider(height: 1, indent: 68),
            ]);
          }).toList(),
        )),
    ]);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  Widget _label(String text) => Text(text,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600));

  InputDecoration _dec({required String hint}) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        filled: true, fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _kPrimary, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        counterStyle: TextStyle(fontSize: 10, color: Colors.grey.shade400),
      );

  String _fmtCount(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    return 'just now';
  }
}

// ── Platform toggle ───────────────────────────────────────────────────────────

class _PlatformToggle extends StatelessWidget {
  final bool isIos;
  final ValueChanged<bool> onToggle;
  const _PlatformToggle({required this.isIos, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.all(2),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _tab('iOS',     Icons.phone_iphone_rounded,   isIos,  () => onToggle(true)),
        _tab('Android', Icons.phone_android_rounded, !isIos, () => onToggle(false)),
      ]),
    );
  }

  Widget _tab(String label, IconData icon, bool active, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
              color: active ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              boxShadow: active ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4, offset: const Offset(0, 1))] : null),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 13, color: active ? Colors.black87 : Colors.grey),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600,
                color: active ? Colors.black87 : Colors.grey)),
          ]),
        ),
      );
}

// ── iOS Notification Preview ──────────────────────────────────────────────────

class _IosPreview extends StatelessWidget {
  final String title;
  final String body;
  final _NotifTypeInfo typeInfo;
  final Uint8List? imageBytes;
  const _IosPreview({super.key, required this.title, required this.body,
      required this.typeInfo, this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('iOS Lock Screen',
          style: TextStyle(fontSize: 10, color: Colors.grey.shade500,
              fontWeight: FontWeight.w600, letterSpacing: 0.4)),
      const SizedBox(height: 6),
      // Simulated lock screen background
      Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF1A237E), Color(0xFF283593)],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
        child: Column(children: [
          // Time
          const Text('9:41', style: TextStyle(
              color: Colors.white, fontSize: 28, fontWeight: FontWeight.w200)),
          const Text('Sunday, April 13', style: TextStyle(
              color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 12),
          // Notification bubble
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                  child: Row(children: [
                    Container(width: 22, height: 22,
                      decoration: BoxDecoration(
                          color: typeInfo.color, borderRadius: BorderRadius.circular(6)),
                      child: Center(child: Text(typeInfo.emoji,
                          style: const TextStyle(fontSize: 12))),
                    ),
                    const SizedBox(width: 6),
                    const Text('BEANSTALK', style: TextStyle(
                        color: Colors.white70, fontSize: 10,
                        fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                    const Spacer(),
                    const Text('now', style: TextStyle(
                        color: Colors.white54, fontSize: 10)),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white,
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text(body, maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ])),
                    if (imageBytes != null) ...[
                      const SizedBox(width: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(width: 48, height: 48,
                            child: FittedBox(fit: BoxFit.cover,
                                child: Image.memory(imageBytes!))),
                      ),
                    ],
                  ]),
                ),
                if (imageBytes != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(14),
                        bottomRight: Radius.circular(14)),
                    child: SizedBox(
                      width: double.infinity, height: 100,
                      child: FittedBox(fit: BoxFit.cover,
                          child: Image.memory(imageBytes!)),
                    ),
                  ),
                ] else const SizedBox(height: 10),
              ]),
            ),
          ),
        ]),
      ),
    ]);
  }
}

// ── Android Notification Preview ──────────────────────────────────────────────

class _AndroidPreview extends StatelessWidget {
  final String title;
  final String body;
  final _NotifTypeInfo typeInfo;
  final Uint8List? imageBytes;
  const _AndroidPreview({super.key, required this.title, required this.body,
      required this.typeInfo, this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Android Notification Shade',
          style: TextStyle(fontSize: 10, color: Colors.grey.shade500,
              fontWeight: FontWeight.w600, letterSpacing: 0.4)),
      const SizedBox(height: 6),
      // Notification shade container
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(children: [
            // Header row
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              child: Row(children: [
                Container(width: 20, height: 20,
                  decoration: BoxDecoration(
                      color: typeInfo.color, borderRadius: BorderRadius.circular(6)),
                  child: Icon(typeInfo.icon, size: 12, color: Colors.white),
                ),
                const SizedBox(width: 6),
                Text('Beanstalk', style: TextStyle(
                    color: Colors.grey.shade400, fontSize: 11, fontWeight: FontWeight.w500)),
                const Spacer(),
                Text('now', style: TextStyle(
                    color: Colors.grey.shade500, fontSize: 10)),
              ]),
            ),
            // Title + body + optional thumbnail
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white,
                          fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(body, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                ])),
                if (imageBytes != null && true) ...[
                  const SizedBox(width: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(width: 44, height: 44,
                        child: FittedBox(fit: BoxFit.cover,
                            child: Image.memory(imageBytes!))),
                  ),
                ],
              ]),
            ),
            // Big image below (Android BigPicture style)
            if (imageBytes != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: double.infinity, height: 96,
                    child: FittedBox(fit: BoxFit.cover,
                        child: Image.memory(imageBytes!)),
                  ),
                ),
              ),
            ],
          ]),
        ),
      ),
    ]);
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
    child: Text(label, style: TextStyle(
        fontSize: 10, color: color, fontWeight: FontWeight.w600)),
  );
}
