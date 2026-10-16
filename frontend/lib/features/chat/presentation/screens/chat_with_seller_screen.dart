import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../product_detail/presentation/screens/product_detail.dart';

const _bg = Color(0xFFFBF9FF);
const _teal = Color(0xFF0E3436);
const _ink = Color(0xFF111827);
const _muted = Color(0xFF5B6270);
const _line = Color(0xFFE5E3EF);

class ChatWithSellerScreen extends StatefulWidget {
  const ChatWithSellerScreen({super.key, required this.product});

  final ProductDetailsData product;

  @override
  State<ChatWithSellerScreen> createState() => _ChatWithSellerScreenState();
}

class _ChatWithSellerScreenState extends State<ChatWithSellerScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      'Hi! Thanks for checking out this item. Feel free to ask me anything.',
      false,
      DateTime.now(),
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: _ink),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 19,
              backgroundColor: _teal,
              child: Text(
                'DP',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 9),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dinda Putri',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
                Text(
                  'Seller · replies in a few hours',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    color: _muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _productPreview(product),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              itemCount: _messages.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return _safetyNotice();
                final message = _messages[index - 1];
                return Align(
                  alignment: message.fromBuyer
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 280),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: message.fromBuyer ? _teal : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: message.fromBuyer
                          ? null
                          : Border.all(color: _line),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            message.text,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              height: 1.4,
                              color: message.fromBuyer ? Colors.white : _ink,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(message.sentAt),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            color: message.fromBuyer ? Colors.white70 : _muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          _composer(),
        ],
      ),
    );
  }

  Widget _productPreview(ProductDetailsData product) => Container(
    margin: const EdgeInsets.fromLTRB(16, 5, 16, 0),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _line),
    ),
    child: Row(
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: product.placeholderColor,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(product.icon, color: product.iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
              Text(
                product.price,
                style: GoogleFonts.plusJakartaSans(fontSize: 10, color: _muted),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded, color: _muted, size: 20),
      ],
    ),
  );

  Widget _safetyNotice() => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF8E8),
      borderRadius: BorderRadius.circular(13),
    ),
    child: Text(
      'For your safety, keep chats and payments on Thrifty. Meet in a public place.',
      textAlign: TextAlign.center,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 10,
        height: 1.4,
        color: const Color(0xFF775719),
      ),
    ),
  );

  Widget _composer() => SafeArea(
    top: false,
    child: Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              minLines: 1,
              maxLines: 4,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Message the seller...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: _muted,
                ),
                filled: true,
                fillColor: _bg,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: _sendMessage,
            style: IconButton.styleFrom(backgroundColor: _teal),
            icon: const Icon(Icons.send_rounded, size: 18),
          ),
        ],
      ),
    ),
  );

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text, true, DateTime.now()));
      _messageController.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}

class _ChatMessage {
  const _ChatMessage(this.text, this.fromBuyer, this.sentAt);

  final String text;
  final bool fromBuyer;
  final DateTime sentAt;
}
