import 'dart:async';
import 'package:flutter/material.dart';
import 'package:selena/app/components/sejenak_text.dart';
import 'package:selena/app/components/sejenak_text_field.dart';
import 'package:selena/app/components/sejenak_primary_button.dart';
import 'package:selena/app/partial/chat/sejenak_chat_node.dart';
import 'package:selena/root/sejenak_color.dart';
import 'package:selena/session/user_session.dart';
import 'package:selena/services/counseling/counseling_service.dart';
import 'package:selena/services/api.dart';

class ChatKonselorScreen extends StatefulWidget {
  final Map<String, dynamic>? sessionData;
  const ChatKonselorScreen({super.key, this.sessionData});

  @override
  State<ChatKonselorScreen> createState() => _ChatKonselorScreenState();
}

class _ChatKonselorScreenState extends State<ChatKonselorScreen> {
  final CounselingService _counselingService = CounselingService();
  bool _isLoading = true;
  List<dynamic> _sessions = [];

  // For chat room
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _messages = [];
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    if (widget.sessionData == null) {
      _fetchSessions();
    } else {
      _fetchMessages();
      // Polling for real-time feel since websocket requires deeper setup
      _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        _fetchMessages(silent: true);
      });
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchSessions() async {
    setState(() => _isLoading = true);
    final sessions = await _counselingService.getMySessions();
    if (mounted) {
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    }
  }

  int get partnerId {
    final myId = UserSession().user?.user?.id;
    if (widget.sessionData!['user_id'] == myId) {
      return widget.sessionData!['konselor_id'];
    }
    return widget.sessionData!['user_id'];
  }

  String get partnerName {
    final myId = UserSession().user?.user?.id;
    if (widget.sessionData!['user_id'] == myId) {
      return widget.sessionData!['counselor']?['name'] ?? 'Konselor';
    }
    return widget.sessionData!['user']?['name'] ?? 'Klien';
  }

  String? get partnerAvatar {
    final myId = UserSession().user?.user?.id;
    if (widget.sessionData!['user_id'] == myId) {
      return widget.sessionData!['counselor']?['avatar'];
    }
    return widget.sessionData!['user']?['avatar'];
  }

  Future<void> _fetchMessages({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    try {
      final response = await DioHttpClient.getInstance().get(API.chatMessages(partnerId));
      if (mounted) {
        setState(() {
          _messages = response.data ?? [];
          _isLoading = false;
        });
        if (!silent) _scrollToBottom();
      }
    } catch (e) {
      if (mounted && !silent) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    // Optimistic UI
    setState(() {
      _messages.add({
        'body': text,
        'sender_id': UserSession().user?.user?.id,
        'created_at': DateTime.now().toIso8601String(),
      });
    });
    _scrollToBottom();

    try {
      await DioHttpClient.getInstance().post(
        API.chatSend,
        data: {'receiver_id': partnerId, 'message': text},
      );
      _fetchMessages(silent: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mengirim pesan')));
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sessionData == null) {
      return _buildSessionsList();
    }
    return _buildChatRoom();
  }

  Widget _buildSessionsList() {
    return Scaffold(
      backgroundColor: SejenakColor.white,
      appBar: AppBar(
        backgroundColor: SejenakColor.primary,
        elevation: 0,
        title: const SejenakText(
          text: "Pesan Konseling",
          type: SejenakTextType.h5,
          fontWeight: FontWeight.bold,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: SejenakColor.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: SejenakColor.secondary))
        : _sessions.isEmpty
          ? const Center(child: SejenakText(text: "Belum ada sesi aktif.", type: SejenakTextType.regular))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _sessions.length,
              itemBuilder: (context, index) {
                final session = _sessions[index];
                final myId = UserSession().user?.user?.id;
                final isCounselor = session['konselor_id'] == myId;
                final partner = isCounselor ? session['user'] : session['counselor'];
                
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatKonselorScreen(sessionData: session),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: SejenakColor.primary,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: SejenakColor.dark, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: SejenakColor.dark,
                          offset: Offset(2, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: SejenakColor.light,
                          backgroundImage: partner?['avatar'] != null ? NetworkImage(partner!['avatar']) : null,
                          child: partner?['avatar'] == null ? const Icon(Icons.person, color: SejenakColor.stroke) : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SejenakText(
                                text: partner?['name'] ?? 'Pengguna',
                                type: SejenakTextType.h5,
                                fontWeight: FontWeight.bold,
                              ),
                              const SizedBox(height: 4),
                              SejenakText(
                                text: "Sesi: ${session['status']}",
                                type: SejenakTextType.small,
                                color: session['status'] == 'ongoing' ? SejenakColor.orange : SejenakColor.secondary,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chat_bubble_rounded, color: SejenakColor.secondary),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildChatRoom() {
    return Scaffold(
      backgroundColor: SejenakColor.white,
      appBar: AppBar(
        backgroundColor: SejenakColor.primary,
        elevation: 1,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: SejenakColor.light,
              backgroundImage: partnerAvatar != null ? NetworkImage(partnerAvatar!) : null,
              child: partnerAvatar == null ? const Icon(Icons.person, color: SejenakColor.stroke, size: 20) : null,
            ),
            const SizedBox(width: 12),
            SejenakText(
              text: partnerName,
              type: SejenakTextType.h5,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: SejenakColor.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (widget.sessionData?['status'] == 'ongoing')
            IconButton(
              icon: const Icon(Icons.stop_circle_outlined, color: SejenakColor.error),
              tooltip: "Akhiri Sesi",
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Akhiri Sesi?"),
                    content: const Text("Sesi ini akan ditandai selesai dan chat akan ditutup."),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Batal")),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Akhiri", style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (confirm == true) {
                  final success = await _counselingService.endSession(widget.sessionData!['id']);
                  if (success) {
                    setState(() => widget.sessionData!['status'] = 'completed');
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sesi telah diakhiri.")));
                  }
                }
              },
            )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading && _messages.isEmpty
                ? const Center(child: CircularProgressIndicator(color: SejenakColor.secondary))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMe = msg['sender_id'] == UserSession().user?.user?.id;
                      return SejenakChatNode(
                        message: msg['body'] ?? '',
                        isMe: isMe,
                      );
                    },
                  ),
          ),
          _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    final status = widget.sessionData?['status'];
    final myId = UserSession().user?.user?.id;
    final isCounselor = widget.sessionData?['konselor_id'] == myId;

    if (status == 'completed' || status == 'closed') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: SejenakColor.primary,
          border: Border(top: BorderSide(color: SejenakColor.dark, width: 2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SejenakText(
              text: "Sesi konseling ini telah berakhir.",
              type: SejenakTextType.regular,
              fontWeight: FontWeight.bold,
            ),
            if (!isCounselor) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _showFollowUpDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SejenakColor.secondary,
                  side: const BorderSide(color: SejenakColor.dark, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const SejenakText(
                  text: "Ajukan Jadwal Lagi",
                  type: SejenakTextType.small,
                  color: SejenakColor.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ]
          ],
        ),
      );
    }

    if (status == 'pending') {
      if (isCounselor) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: SejenakColor.white,
            border: Border(top: BorderSide(color: SejenakColor.dark, width: 2)),
          ),
          child: ElevatedButton(
            onPressed: () async {
              final success = await _counselingService.acceptSession(widget.sessionData!['id']);
              if (success) {
                setState(() => widget.sessionData!['status'] = 'ongoing');
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sesi dimulai!")));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal memulai sesi.")));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SejenakColor.secondary,
              side: const BorderSide(color: SejenakColor.dark, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const SejenakText(text: "Terima & Mulai Sesi", type: SejenakTextType.h5, color: SejenakColor.white, fontWeight: FontWeight.bold),
          ),
        );
      } else {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: SejenakColor.primary,
            border: Border(top: BorderSide(color: SejenakColor.dark, width: 2)),
          ),
          child: const Center(
            child: SejenakText(
              text: "Menunggu konselor menerima sesi ini...",
              type: SejenakTextType.regular,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }
    }

    return _buildInputField();
  }

  Widget _buildInputField() {
    return Container(
      decoration: const BoxDecoration(
        color: SejenakColor.white,
        border: Border(top: BorderSide(color: SejenakColor.dark, width: 2)),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: SejenakTextField(
              text: 'Ketik pesan...',
              controller: _messageController,
            ),
          ),
          const SizedBox(width: 8),
          SejenakPrimaryButton(
            text: "",
            icon: "assets/svg/send.svg",
            action: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _showFollowUpDialog() async {
    // Tampilkan loading saat mengambil harga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    final sessionPrice = await _counselingService.getSessionPrice();
    if (!mounted) return;
    Navigator.pop(context); // pop loading

    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (builderContext, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: SejenakColor.primary,
              title: const SejenakText(
                text: "Ajukan Jadwal Sesi",
                type: SejenakTextType.h5,
                fontWeight: FontWeight.bold,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SejenakText(
                    text: "Pilih waktu untuk sesi lanjutan dengan $partnerName.",
                    type: SejenakTextType.regular,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() {
                            selectedDate = date;
                            selectedTime = time;
                          });
                        }
                      }
                    },
                    icon: const Icon(Icons.calendar_month, color: SejenakColor.dark),
                    label: SejenakText(
                      text: selectedDate != null && selectedTime != null
                          ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} ${selectedTime!.format(context)}"
                          : "Pilih Tanggal & Waktu",
                      type: SejenakTextType.small,
                      color: SejenakColor.dark,
                      fontWeight: FontWeight.bold,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SejenakColor.white,
                      side: const BorderSide(color: SejenakColor.dark, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SejenakText(
                    text: "Biaya: $sessionPrice Token",
                    type: SejenakTextType.small,
                    color: SejenakColor.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const SejenakText(
                    text: "Batal",
                    type: SejenakTextType.regular,
                    color: SejenakColor.stroke,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedDate == null || selectedTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Silakan pilih tanggal dan waktu sesi!")),
                      );
                      return;
                    }

                    Navigator.pop(dialogContext);
                    // Show loading
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CircularProgressIndicator()),
                    );
                    
                    final scheduledAt = DateTime(
                      selectedDate!.year,
                      selectedDate!.month,
                      selectedDate!.day,
                      selectedTime!.hour,
                      selectedTime!.minute,
                    ).toIso8601String();

                    final result = await _counselingService.requestSession(
                      partnerId, 
                      scheduledAt: scheduledAt
                    );
                    if (!mounted) return;
                    Navigator.pop(context); // pop loading
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result['message']),
                        backgroundColor: result['success'] ? Colors.green : Colors.red,
                      ),
                    );
                    
                    if (result['requires_topup'] == true) {
                      Navigator.pushNamed(context, '/token-purchase');
                    } else if (result['success']) {
                      // Tutup chat saat ini karena session lama sudah selesai
                      Navigator.pop(context); 
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SejenakColor.secondary,
                    side: const BorderSide(color: SejenakColor.dark, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const SejenakText(
                    text: "Ajukan",
                    type: SejenakTextType.regular,
                    color: SejenakColor.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          }
        );
      },
    );
  }
}
