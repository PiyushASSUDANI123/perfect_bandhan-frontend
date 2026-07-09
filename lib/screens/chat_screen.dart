import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_windowmanager_plus/flutter_windowmanager_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/profile.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_feedback.dart';
import '../widgets/profile_details_sheet.dart';
import '../services/socket_service.dart';

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
  bool _isSending = false;
  List<String> _icebreakers = [];
  bool _isLoadingIcebreakers = false;
  late final SocketService _socketService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (!kIsWeb && Platform.isAndroid) {
      FlutterWindowManagerPlus.addFlags(FlutterWindowManagerPlus.FLAG_SECURE);
    }
    
    _socketService = SocketService();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final myId = authProvider.myProfile?['id'] ?? '';
    
    if (myId.isNotEmpty) {
      _socketService.connect(myId);
    }

    _socketService.onConnectionError((data) {
      if (mounted) {
        setState(() {
          _messages.add({
            'text': 'SOCKET_CONN_ERROR: $data',
            'sender': 'system',
            'createdAt': DateTime.now().toIso8601String()
          });
        });
        _scrollToBottom();
      }
    });

    _socketService.onReceiveMessage((data) {
      if (mounted) {
        setState(() {
          try {
            dynamic msgData = data is List && data.isNotEmpty ? data.first : data;
            _messages.add(Map<String, dynamic>.from(msgData));
          } catch (e) {
            _messages.add({'text': 'RECEIVE_PARSE_ERROR: $e', 'sender': 'system', 'createdAt': DateTime.now().toIso8601String()});
          }
        });
        _scrollToBottom();
      }
    });

    _socketService.onMessageSent((data) {
      if (mounted) {
        setState(() {
          _isSending = false;
          try {
            dynamic msgData = data is List && data.isNotEmpty ? data.first : data;
            _messages.add(Map<String, dynamic>.from(msgData));
          } catch (e) {
            _messages.add({'text': 'SENT_PARSE_ERROR: $e | Data: $data', 'sender': 'system', 'createdAt': DateTime.now().toIso8601String()});
          }
        });
        _scrollToBottom();
      }
    });

    _socketService.onMessageError((data) {
      if (mounted) {
        setState(() {
          _isSending = false;
          dynamic errData = data is List && data.isNotEmpty ? data.first : data;
          _messages.add({'text': 'SERVER_ERROR: ${errData['error']}', 'sender': 'system', 'createdAt': DateTime.now().toIso8601String()});
        });
        
        dynamic errData = data is List && data.isNotEmpty ? data.first : data;
        PremiumFeedback.showError(
          context: context,
          title: 'Error',
          message: errData['error'] ?? "Unable to send your message. Please try again.",
        );
      }
    });

    _loadChatHistory();
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadChatHistory(silent: true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (!kIsWeb && Platform.isAndroid) {
      FlutterWindowManagerPlus.clearFlags(FlutterWindowManagerPlus.FLAG_SECURE);
    }
    // We do NOT disconnect the socket here if we want it global, 
    // but we should remove the listeners tied to this specific chat screen.
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
    final myId = authProvider.myProfile?['id'] ?? '';
    
    // Connect socket just in case it's needed for receiving
    if (myId.isNotEmpty) {
      _socketService.connect(myId);
    }
    
    // Use reliable HTTP API for sending
    final response = await authProvider.sendChatMessage(widget.profile.id, text);
    
    if (mounted) {
      setState(() {
        _isSending = false;
        if (response.isNotEmpty && response['status'] == 'success') {
           // Successfully sent via HTTP
           _messages.add({
             'text': text,
             'sender': myId,
             'createdAt': DateTime.now().toIso8601String(),
             'isSent': true,
             'status': 'sent',
           });
        } else {
           // Failed to send
           PremiumFeedback.showError(
             context: context,
             title: 'Error',
             message: response['message'] ?? response['error'] ?? "Unable to send your message. Please try again.",
           );
        }
      });
      _scrollToBottom();
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppTheme.textMuted),
            color: AppTheme.cardGray,
            onSelected: (value) async {
              if (value == 'report') {
                _reportUser();
              } else if (value == 'block') {
                _blockUser();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'report',
                child: Text('Report User', style: GoogleFonts.montserrat(color: AppTheme.textCarbon)),
              ),
              PopupMenuItem(
                value: 'block',
                child: Text('Block', style: GoogleFonts.montserrat(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
          children: [
                        if (widget.profile.whatsappNumber.contains('*'))
              Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: AppTheme.cardGray,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline, color: AppTheme.accentGold, size: 20),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        "Satisfied with the conversation?",
                        style: GoogleFonts.montserrat(color: AppTheme.textCarbon, fontSize: 12),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final auth = Provider.of<AuthProvider>(context, listen: false);
                        try {
                          await auth.requestWhatsappUnlock(widget.profile.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Request sent!'), backgroundColor: AppTheme.accentGold)
                          );
                        } catch (e) {}
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: AppTheme.accentGold.withValues(alpha: 0.1),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: Text("Request Unlock", style: GoogleFonts.cinzel(color: AppTheme.accentGold, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
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
                            final isMe = (msg['sender'] ?? msg['senderId']) == selfUserId;
                            final text = msg['text'] ?? '';
                            final timestamp = msg['createdAt'] != null
                                ? DateTime.parse(msg['createdAt'].toString()).toLocal()
                                : DateTime.now();

                            return _buildMessageBubble(
                              text, 
                              isMe, 
                              timestamp, 
                              status: msg['status'] ?? 'sent',
                              isSent: msg['isSent'] ?? true
                            );
                          },
                        ),
            ),
            if (!_hasBothMessaged() && _icebreakers.isNotEmpty)
              _buildIcebreakerSheet(),
            _buildInputArea(),
          ],
        ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe, DateTime time, {String status = 'sent', bool isSent = true}) {
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeStr,
                  style: GoogleFonts.montserrat(
                    color: isMe ? Colors.black54 : AppTheme.textMuted,
                    fontSize: 9,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    isSent == false 
                        ? Icons.access_time 
                        : (status == 'read' ? Icons.done_all : (status == 'delivered' ? Icons.done_all : Icons.check)),
                    size: 12,
                    color: status == 'read' ? Colors.blueAccent : Colors.black54,
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    final lang = Provider.of<LanguageProvider>(context);
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
                hintText: lang.translate("type_message"),
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

  Widget _buildIcebreakerSheet() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.cardGray.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        border: Border(top: BorderSide(color: AppTheme.glassBorderGold.withValues(alpha: 0.5), width: 1)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: AppTheme.accentGold, size: 16),
              const SizedBox(width: 8),
              Text(
                "AI ICEBREAKERS",
                style: GoogleFonts.cinzel(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accentGold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: AppTheme.textMuted, size: 16),
                onPressed: () => setState(() => _icebreakers.clear()),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              )
            ],
          ),
          const SizedBox(height: 12.0),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
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
                    margin: const EdgeInsets.only(right: 8.0),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    decoration: BoxDecoration(
                      color: AppTheme.cardWhite.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.3), width: 1),
                    ),
                    child: Text(
                      text,
                      style: GoogleFonts.montserrat(fontSize: 13, color: AppTheme.textCarbon),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasBothMessaged() {
    bool hasMe = false;
    bool hasThem = false;
    final selfUserId = Provider.of<AuthProvider>(context, listen: false).myProfile?["id"] ?? "";
    for (var m in _messages) {
      if (m["sender"] == selfUserId) {
        hasMe = true;
      } else {
        hasThem = true;
      }
      if (hasMe && hasThem) return true;
    }
    return false;
  }

  Future<void> _reportUser() async {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardGray,
        title: Text('Report User', style: GoogleFonts.cinzel(color: AppTheme.accentGold)),
        content: Text('Are you sure you want to report this user? Your recent messages will be securely submitted to admin for review.', style: GoogleFonts.montserrat(color: AppTheme.textCarbon)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Report', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    ) ?? false;

    if (confirm && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        final dump = _messages.reversed.take(20).toList();
        await authProvider.reportUserWithDump(widget.profile.phone, 'Inappropriate behavior in chat', dump);
        PremiumFeedback.showSuccess(context: context, title: 'Reported', message: 'User has been reported to the administration.');
      } catch (e) {
        PremiumFeedback.showError(context: context, title: 'Error', message: 'Failed to report user.');
      }
    }
  }

  Future<void> _blockUser() async {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardGray,
        title: Text('Block User', style: GoogleFonts.cinzel(color: Colors.redAccent)),
        content: Text('Are you sure you want to block this user? The conversation will be deleted.', style: GoogleFonts.montserrat(color: AppTheme.textCarbon)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Block', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    ) ?? false;

    if (confirm && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        await authProvider.blockUser(widget.profile.phone, 'Blocked from chat', '');
        if (mounted) {
          Navigator.pop(context); // Pop chat screen
        }
      } catch (e) {
        PremiumFeedback.showError(context: context, title: 'Error', message: 'Failed to block user.');
      }
    }
  }
}
