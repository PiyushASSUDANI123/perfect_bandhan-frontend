import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/profile.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_feedback.dart';
import '../widgets/profile_details_sheet.dart';

class ChatScreen extends StatefulWidget {
  final Profile profile;

  const ChatScreen({super.key, required this.profile});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  Timer? _timer;
  bool _isSending = false;
  List<String> _icebreakers = [];
  bool _isLoadingIcebreakers = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadChatHistory();
    _startTimer();
  }

  Future<void> _fetchIcebreakers(AuthProvider provider) async {
    if (!mounted) return;
    setState(() => _isLoadingIcebreakers = true);
    
    final fetched = await provider.fetchIcebreakers(widget.profile.phone);
    
    if (!mounted) return;
    setState(() {
      _icebreakers = fetched;
      _isLoadingIcebreakers = false;
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _loadChatHistory(silent: true));
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _stopTimer();
    } else if (state == AppLifecycleState.resumed) {
      _loadChatHistory(silent: true);
      _startTimer();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTimer();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadChatHistory({bool silent = false}) async {
    if (!mounted) return;
    if (!silent) {
      setState(() {
        _isLoading = true;
      });
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final history = await authProvider.fetchChatHistory(widget.profile.id);

    if (!mounted) return;
    setState(() {
      _messages = history;
      _isLoading = false;
    });

    if (_messages.isEmpty && _icebreakers.isEmpty && !_isLoadingIcebreakers) {
      _fetchIcebreakers(authProvider);
    }

    if (!silent) {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    _messageController.clear(); // Clear immediately for snappy UI

    setState(() {
      _isSending = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.sendChatMessage(widget.profile.id, text);

    if (!mounted) return;
    setState(() {
      _isSending = false;
    });

    if (result['success'] == true) {
      _loadChatHistory(silent: true);
      _scrollToBottom();
      
      // Notify user with a subtle feedback Toast
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Message sent successfully", style: GoogleFonts.montserrat(fontSize: 12, color: Colors.black)),
          backgroundColor: AppTheme.accentGold,
          duration: const Duration(seconds: 1),
        ),
      );
    } else if (result['limit_reached'] == true) {
      _messageController.text = text; // restore text
      _showLimitReachedDialog(result['message']);
    } else {
      _messageController.text = text; // restore text
      PremiumFeedback.showError(
        context: context,
        title: "Failed to Send",
        message: result['message'] ?? "Unable to send your message. Please try again.",
      );
    }
  }

  void _showLimitReachedDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: AppTheme.cardGray,
              borderRadius: BorderRadius.circular(28.0),
              border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.3), width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 20.0,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: AppTheme.accentGold,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20.0),
                Text(
                  "LIMIT REACHED",
                  style: GoogleFonts.cinzel(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentGold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12.0),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: AppTheme.textCarbon,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGold,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                  ),
                  child: Text(
                    "ACKNOWLEDGE",
                    style: GoogleFonts.cinzel(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selfUserId = Provider.of<AuthProvider>(context).myProfile?['id'] ?? '';

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.cardGray,
        elevation: 0.5,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.accentGold, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => ProfileDetailsSheet(profile: widget.profile),
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.accentGold.withValues(alpha: 0.1),
                child: Text(
                  widget.profile.initials,
                  style: GoogleFonts.cinzel(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentGold,
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.profile.name,
                      style: GoogleFonts.cinzel(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textCarbon,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Active Connection",
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        color: AppTheme.accentGold,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.textMuted),
            onPressed: () => _loadChatHistory(),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
          children: [
            Expanded(
              child: _isLoading && _messages.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.accentGold))
                  : _messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.forum_outlined, size: 48, color: AppTheme.textMuted.withValues(alpha: 0.5)),
                              const SizedBox(height: 12.0),
                              Text(
                                "No messages yet",
                                style: GoogleFonts.cinzel(
                                  fontSize: 14,
                                  color: AppTheme.textMuted,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6.0),
                              Text(
                                "Start the conversation below",
                                style: GoogleFonts.montserrat(
                                  fontSize: 11,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final msg = _messages[index];
                            final isMe = msg['sender'] == selfUserId;
                            final text = msg['text'] ?? '';
                            final timestamp = msg['createdAt'] != null
                                ? DateTime.parse(msg['createdAt'].toString()).toLocal()
                                : DateTime.now();

                            return _buildMessageBubble(text, isMe, timestamp);
                          },
                        ),
            ),
            if (_messages.isEmpty && _icebreakers.isNotEmpty)
              _buildIcebreakerChips(),
            _buildInputArea(),
          ],
        ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe, DateTime time) {
    final timeStr = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.accentGold : AppTheme.cardGray,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16.0),
            topRight: const Radius.circular(16.0),
            bottomLeft: Radius.circular(isMe ? 16.0 : 4.0),
            bottomRight: Radius.circular(isMe ? 4.0 : 16.0),
          ),
          border: isMe
              ? null
              : Border.all(color: AppTheme.glassBorderColor, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              text,
              style: GoogleFonts.montserrat(
                color: isMe ? Colors.black : AppTheme.textCarbon,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              timeStr,
              style: GoogleFonts.montserrat(
                color: isMe ? Colors.black54 : AppTheme.textMuted,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppTheme.cardGray,
        border: const Border(
          top: BorderSide(color: AppTheme.glassBorderColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              style: GoogleFonts.montserrat(color: AppTheme.textCarbon, fontSize: 13),
              decoration: InputDecoration(
                hintText: "Type a message...",
                hintStyle: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 13),
                filled: true,
                fillColor: AppTheme.backgroundLight,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          Container(
            decoration: const BoxDecoration(
              color: AppTheme.accentGold,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.black, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcebreakerChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: AppTheme.backgroundLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: AppTheme.accentGold, size: 14),
              const SizedBox(width: 4),
              Text(
                "AI CONVERSATION STARTERS",
                style: GoogleFonts.cinzel(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _icebreakers.map((text) {
              return GestureDetector(
                onTap: () {
                  _messageController.text = text;
                  _sendMessage();
                  setState(() {
                    _icebreakers.clear();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: AppTheme.cardWhite,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: AppTheme.glassBorderGold.withValues(alpha: 0.5), width: 0.5),
                    boxShadow: [
                      BoxShadow(color: AppTheme.accentGold.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))
                    ],
                  ),
                  child: Text(
                    text,
                    style: GoogleFonts.montserrat(fontSize: 12, color: AppTheme.textCarbon),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
