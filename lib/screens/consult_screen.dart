import 'package:flutter/material.dart';

/// Mock doctor-chat screen. Pre-seeded with a short conversation; tapping
/// the send button appends a new user-side bubble to the bottom of the list.
class ConsultScreen extends StatefulWidget {
  const ConsultScreen({super.key});

  @override
  State<ConsultScreen> createState() => _ConsultScreenState();
}

class _ConsultScreenState extends State<ConsultScreen> {
  // Palette aligned with the rest of the app.
  static const Color _userBubble = Color(0xFF315660);
  static const Color _accent = Color(0xFF1a434e);
  static const Color _doctorTextColor = Color(0xFF1a434e);

  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();

  final List<_ChatMessage> _messages = <_ChatMessage>[
    _ChatMessage(
      text: 'Halo! Saya Dr. Sari, dokter umum di TBXpert.',
      fromUser: false,
    ),
    _ChatMessage(
      text: 'Ada keluhan apa yang bisa saya bantu hari ini?',
      fromUser: false,
    ),
    _ChatMessage(
      text: 'Halo dok, saya sudah batuk lebih dari 2 minggu.',
      fromUser: true,
    ),
    _ChatMessage(
      text: 'Apakah batuknya berdahak? Ada darah dalam dahak?',
      fromUser: false,
    ),
    _ChatMessage(
      text: 'Berdahak dok, tidak ada darah. Tapi kadang berkeringat di malam hari.',
      fromUser: true,
    ),
    _ChatMessage(
      text:
          'Gejala tersebut perlu dievaluasi. Coba rekam suara batuk Anda di tab Home untuk skrining awal, ya.',
      fromUser: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Scroll to the latest message after the first layout.
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom(jump: true));
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text: text, fromUser: true));
      _input.clear();
    });
    // Wait one frame so the new bubble's height is known before scrolling.
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom({bool jump = false}) {
    if (!_scroll.hasClients) return;
    final target = _scroll.position.maxScrollExtent;
    if (jump) {
      _scroll.jumpTo(target);
    } else {
      _scroll.animateTo(
        target,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            itemCount: _messages.length,
            itemBuilder: (context, i) => _ChatBubble(
              message: _messages[i],
              userColor: _userBubble,
              doctorTextColor: _doctorTextColor,
              accentColor: _accent,
            ),
          ),
        ),
        _ChatInput(
          controller: _input,
          accentColor: _accent,
          onSend: _handleSend,
        ),
      ],
    );
  }
}

class _ChatMessage {
  final String text;
  final bool fromUser;

  const _ChatMessage({required this.text, required this.fromUser});
}

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;
  final Color userColor;
  final Color doctorTextColor;
  final Color accentColor;

  const _ChatBubble({
    required this.message,
    required this.userColor,
    required this.doctorTextColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.fromUser;
    final double maxWidth = MediaQuery.of(context).size.width * 0.72;

    final bubble = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? userColor : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: isUser ? null : Border.all(color: Colors.black12),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isUser ? Colors.white : doctorTextColor,
            fontSize: 14,
            height: 1.35,
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFFD7E5E9),
              child: Icon(
                Icons.medical_services_rounded,
                size: 14,
                color: accentColor,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(child: bubble),
        ],
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final Color accentColor;
  final VoidCallback onSend;

  const _ChatInput({
    required this.controller,
    required this.accentColor,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    // Push the input above the keyboard while leaving the bottom nav
    // to be covered by it (MainShell sets resizeToAvoidBottomInset: false).
    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      padding: EdgeInsets.fromLTRB(16, 8, 16, 12 + bottomInset),
      child: Material(
        color: Colors.white,
        elevation: 4,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(28),
        clipBehavior: Clip.antiAlias,
        child: TextField(
          controller: controller,
          minLines: 1,
          maxLines: 4,
          textInputAction: TextInputAction.send,
          onSubmitted: (_) => onSend(),
          decoration: InputDecoration(
            hintText: 'Tulis pesan...',
            hintStyle: TextStyle(color: Colors.grey.shade500),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.fromLTRB(20, 14, 4, 14),
            suffixIcon: IconButton(
              tooltip: 'Kirim',
              icon: Icon(Icons.send_rounded, color: accentColor),
              onPressed: onSend,
            ),
          ),
        ),
      ),
    );
  }
}
