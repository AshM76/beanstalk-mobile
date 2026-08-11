// lib/widgets/cash_advisor_sheet.dart
//
// Cash AI Advisor — modal bottom sheet built on top of AiAdvisorService.
//
// Entry point: showCashAdvisor(context, seedMessage: ...). The optional
// seedMessage is auto-sent after the first frame, so callers that already
// have a question (e.g. tapping a "Help me pick" chip on a stock detail
// page) don't force the user to retype it.
//
// Error model mirrors the service:
//   - AiLimitException → flip remaining to 0, render the paywall card,
//     disable the input.
//   - AiAdvisorException / any other failure → roll back the failed user
//     message, render the error card.
//   - status fetch failures fall back to the service's permissive default
//     so the sheet stays usable when /api/ai/status is unreachable.
//
// Visual language: dark surface (matches the modal convention rather than
// the app's light-on-white pages), Beanstalk green (#2E7D32) for accent,
// gradient bubbles for user messages, flat surface bubbles for assistant.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/ai_advisor_service.dart';

// ── Palette ─────────────────────────────────────────────────────────────────

const _kGreen      = Color(0xFF2E7D32); // Beanstalk green — see main.dart
const _kGreenDark  = Color(0xFF1B5E20); // gradient companion
const _kGreenLight = Color(0xFF4CAF50); // small accents (status dot, dots anim)
const _kBg         = Color(0xFF121212);
const _kSurface    = Color(0xFF1E1E1E);
const _kSurfaceHi  = Color(0xFF262626);
const _kBorder     = Color(0xFF2A2A2A);
const _kTextMuted  = Color(0xFFB0B0B0);

// ── Entry point ─────────────────────────────────────────────────────────────

/// Open the Cash AI Advisor as a modal bottom sheet. When [seedMessage] is
/// non-null and non-empty, it is auto-sent on the first frame so callers can
/// jump straight into a specific conversation (e.g. from a "Help me pick"
/// chip on a stock detail page).
void showCashAdvisor(BuildContext context, {String? seedMessage}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => CashAdvisorSheet(seedMessage: seedMessage),
  );
}

// ── Sheet ───────────────────────────────────────────────────────────────────

class CashAdvisorSheet extends StatefulWidget {
  final String? seedMessage;
  const CashAdvisorSheet({super.key, this.seedMessage});

  @override
  State<CashAdvisorSheet> createState() => _CashAdvisorSheetState();
}

class _CashAdvisorSheetState extends State<CashAdvisorSheet>
    with TickerProviderStateMixin {
  // Hardcoded opening line — kept in code (rather than fetched from the
  // server) so the sheet renders something useful even before getStatus()
  // returns, and so the persona stays consistent across builds.
  static const _opening =
      "Hey! I'm Cash, your Beanstalk AI advisor 🌱\n\n"
      "Ask me about stocks, ETFs, crypto, or strategy — I'll point you "
      "toward interesting virtual trades with suggested amounts.\n\n"
      "All trades here are virtual, so it's a safe space to learn!";

  late final List<AiMessage> _messages;
  final TextEditingController _input  = TextEditingController();
  final FocusNode _inputFocus         = FocusNode();
  final ScrollController _scroll      = ScrollController();
  late final AnimationController _dotsAnim;

  // Permissive default — matches AiAdvisorService.getStatus()'s fallback so
  // the input is interactive while the real status is in flight.
  AiAdvisorStatus _status = const AiAdvisorStatus(
    remaining: 5,
    isPremium: false,
    usedToday: 0,
  );
  bool _sending = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _messages = [
      const AiMessage(role: 'assistant', content: _opening),
    ];
    _dotsAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    _loadStatus();

    final seed = widget.seedMessage?.trim();
    if (seed != null && seed.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _send(seed);
      });
    }
  }

  @override
  void dispose() {
    _input.dispose();
    _inputFocus.dispose();
    _scroll.dispose();
    _dotsAnim.dispose();
    super.dispose();
  }

  // ── State helpers ─────────────────────────────────────────────────────────

  Future<void> _loadStatus() async {
    final s = await AiAdvisorService.getStatus();
    if (!mounted) return;
    setState(() => _status = s);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send(String text) async {
    final t = text.trim();
    if (t.isEmpty || _sending || _status.isLimited) return;

    setState(() {
      _messages.add(AiMessage(role: 'user', content: t));
      _sending = true;
      _errorText = null;
      _input.clear();
    });
    _scrollToBottom();

    try {
      final res = await AiAdvisorService.sendMessage(_messages);
      if (!mounted) return;
      setState(() {
        _messages.add(AiMessage(role: 'assistant', content: res.reply));
        _status = AiAdvisorStatus(
          remaining: res.remaining,
          isPremium: res.isPremium,
          usedToday: _status.usedToday + 1,
        );
        _sending = false;
      });
      _scrollToBottom();
    } on AiLimitException {
      if (!mounted) return;
      // Force-limit the local status so the paywall card and disabled
      // input render immediately — the backend already rejected this
      // request, so any optimistic "remaining" we had is stale.
      setState(() {
        _status = AiAdvisorStatus(
          remaining: 0,
          isPremium: _status.isPremium,
          usedToday: _status.usedToday,
        );
        _sending = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        // Roll back the failed user message so the conversation doesn't
        // show an unanswered question hanging in the air.
        if (_messages.isNotEmpty && _messages.last.role == 'user') {
          _messages.removeLast();
        }
        _errorText = e is AiAdvisorException
            ? e.message
            : "Network error — couldn't reach Cash. Please try again.";
        _sending = false;
      });
      _scrollToBottom();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final insets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.only(bottom: insets.bottom),
      child: Container(
        height: size.height * 0.88,
        decoration: const BoxDecoration(
          color: _kBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              _dragHandle(),
              _header(),
              const Divider(height: 1, color: _kBorder),
              Expanded(child: _messageList()),
              _inputBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dragHandle() => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF3A3A3A),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      );

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: 'Close',
            icon: const Icon(Icons.close, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 4),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_kGreen, _kGreenDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Text('🌱', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Cash AI Advisor',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: _kGreenLight,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Flexible(
                      child: Text(
                        'Virtual trading only · Educational',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: _kTextMuted, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _usageChip(),
        ],
      ),
    );
  }

  Widget _usageChip() {
    if (_status.isPremium) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          '⭐ Premium · Unlimited',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    final remaining = _status.remaining ?? 5;
    final Color color;
    if (remaining <= 0) {
      color = const Color(0xFFEF5350); // red
    } else if (remaining == 1) {
      color = const Color(0xFFFFB300); // amber
    } else {
      color = _kGreenLight;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        '$remaining of 5 left today',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _messageList() {
    final children = <Widget>[];
    for (final m in _messages) {
      children.add(_bubble(m));
    }
    if (_sending) children.add(_typingIndicator());
    if (_status.isLimited) children.add(_paywallCard());
    if (_errorText != null) children.add(_errorCard(_errorText!));

    return ListView(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      children: children,
    );
  }

  Widget _bubble(AiMessage m) {
    final isUser = m.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
                  colors: [_kGreen, _kGreenDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isUser ? null : _kSurface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Text(
          m.content,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _typingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: const BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: AnimatedBuilder(
          animation: _dotsAnim,
          builder: (_, __) => Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _dot(0),
              const SizedBox(width: 4),
              _dot(1),
              const SizedBox(width: 4),
              _dot(2),
            ],
          ),
        ),
      ),
    );
  }

  /// One bouncing dot in the typing indicator. Each dot's vertical offset
  /// follows a sin wave clamped to the upper half so dots only rise, never
  /// dip below the baseline. Phases are spaced by 0.22 of the period so the
  /// three dots feel like a wave, not a single pulse.
  Widget _dot(int i) {
    final phase = (_dotsAnim.value + i * 0.22) * 2 * math.pi;
    final lift = math.max(0.0, math.sin(phase)) * 5.0;
    return Transform.translate(
      offset: Offset(0, -lift),
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: _kGreenLight,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _paywallCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kSurfaceHi,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kGreen.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "🔒 You've used your 5 free questions today",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upgrade to Premium for unlimited AI advice, deeper insights, '
            'and personalized virtual-trade suggestions.',
            style: TextStyle(color: _kTextMuted, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/premium'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Go Premium',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorCard(String msg) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1414),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              msg,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _errorText = null),
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 32),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Dismiss',
              style: TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputBar() {
    final limited = _status.isLimited;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: const BoxDecoration(
        color: _kBg,
        border: Border(top: BorderSide(color: _kBorder)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _input,
              focusNode: _inputFocus,
              enabled: !limited,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: limited ? null : _send,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              cursorColor: _kGreenLight,
              decoration: InputDecoration(
                hintText: limited
                    ? 'Upgrade to keep chatting…'
                    : 'Ask Cash anything…',
                hintStyle: const TextStyle(color: _kTextMuted, fontSize: 13),
                filled: true,
                fillColor: _kSurface,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: _kBorder),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: _kBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: _kGreen, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: limited ? _kSurface : _kGreen,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: (limited || _sending) ? null : () => _send(_input.text),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  Icons.send,
                  color: limited ? _kTextMuted : Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
