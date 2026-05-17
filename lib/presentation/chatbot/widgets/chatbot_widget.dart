import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

/// Widget chatbot Gemini AI - floating overlay
class ChatbotWidget extends StatefulWidget {
  const ChatbotWidget({super.key});
  @override
  State<ChatbotWidget> createState() => _ChatbotWidgetState();
}

class _ChatbotWidgetState extends State<ChatbotWidget> with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;
  late final GenerativeModel _model;
  late final ChatSession _chat;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: AppConstants.geminiModel,
      apiKey: AppConstants.geminiApiKey,
      systemInstruction: Content.system('''
Kamu adalah asisten AI kesehatan untuk ${AppConstants.clinicName},
berlokasi di ${AppConstants.clinicAddress}.
Telepon: ${AppConstants.clinicPhone}. Buka ${AppConstants.clinicHours}.

Tugasmu:
1. Menjawab pertanyaan umum tentang kesehatan dengan bahasa yang mudah dipahami (Bahasa Indonesia)
2. Memberikan informasi layanan dan jadwal klinik
3. Membantu pre-screening gejala pasien sebelum bertemu dokter
4. Memberikan edukasi kesehatan dasar
5. Memberikan saran pertolongan pertama ringan

Batasan:
- JANGAN memberikan diagnosis pasti atau resep obat
- Selalu anjurkan pasien untuk berkonsultasi langsung dengan dokter
- Jika gejala darurat (sesak napas, nyeri dada hebat, dll), segera arahkan ke IGD atau hubungi 119
- Tetap profesional dan empati

Selalu akhiri dengan: "Untuk pemeriksaan lebih lanjut, silakan kunjungi ${AppConstants.clinicName} atau hubungi ${AppConstants.clinicPhone}."
'''),
    );
    _chat = _model.startChat();
    _messages.add(_ChatMessage(
      text: 'Halo! 👋 Saya asisten AI ${AppConstants.clinicName}. Ada yang bisa saya bantu? Anda bisa bertanya tentang kesehatan, jadwal klinik, atau informasi layanan kami.',
      isBot: true,
    ));
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text: text, isBot: false));
      _isTyping = true;
    });
    _msgController.clear();
    _scrollToBottom();

    try {
      final response = await _chat.sendMessage(Content.text(text));
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(text: response.text ?? 'Maaf, tidak ada respons.', isBot: true));
          _isTyping = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(text: 'Maaf, terjadi kesalahan. Pastikan API key sudah dikonfigurasi. Error: $e', isBot: true));
          _isTyping = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Chat panel
        if (_isOpen)
          Positioned(right: 16, bottom: 80, child: Material(
            elevation: 16, borderRadius: BorderRadius.circular(20),
            shadowColor: Colors.black26,
            child: Container(
              width: 400, height: 560,
              decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.grey200)),
              child: Column(children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryMedium]),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(children: [
                    Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20)),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Asisten AI Medina', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                      Text('Online • Siap membantu', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.white70)),
                    ]),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20), onPressed: () => setState(() => _isOpen = false)),
                  ]),
                ),
                // Messages
                Expanded(child: ListView.builder(
                  controller: _scrollController, padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i == _messages.length && _isTyping) {
                      return _buildTypingIndicator();
                    }
                    final msg = _messages[i];
                    return _buildBubble(msg);
                  },
                )),
                // Quick replies
                if (_messages.length <= 1) Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(spacing: 8, runSpacing: 8, children: [
                    _quickReply('📋 Jadwal Dokter'), _quickReply('🏥 Info Klinik'),
                    _quickReply('🩺 Cek Gejala'), _quickReply('🆘 Pertolongan Pertama'),
                  ]),
                ),
                // Input
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: AppColors.grey200))),
                  child: Row(children: [
                    Expanded(child: TextField(controller: _msgController,
                      decoration: InputDecoration(hintText: 'Ketik pesan...', filled: true, fillColor: AppColors.grey50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                      onSubmitted: _sendMessage)),
                    const SizedBox(width: 8),
                    Container(decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.teal]), borderRadius: BorderRadius.circular(12)),
                      child: IconButton(icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                        onPressed: () => _sendMessage(_msgController.text))),
                  ]),
                ),
              ]),
            ),
          )),

        // FAB
        Positioned(right: 16, bottom: 16, child: FloatingActionButton(
          onPressed: () => setState(() => _isOpen = !_isOpen),
          backgroundColor: AppColors.primary,
          child: AnimatedSwitcher(duration: const Duration(milliseconds: 200),
            child: Icon(_isOpen ? Icons.close_rounded : Icons.smart_toy_rounded, key: ValueKey(_isOpen), color: Colors.white)),
        )),
      ],
    );
  }

  Widget _buildBubble(_ChatMessage msg) {
    return Align(
      alignment: msg.isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: msg.isBot ? AppColors.surface : AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isBot ? 4 : 16), bottomRight: Radius.circular(msg.isBot ? 16 : 4)),
        ),
        child: Text(msg.text, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: msg.isBot ? AppColors.black : Colors.white, height: 1.4)),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(alignment: Alignment.centerLeft, child: Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        for (int i = 0; i < 3; i++) ...[
          TweenAnimationBuilder<double>(tween: Tween(begin: 0, end: 1), duration: Duration(milliseconds: 600 + i * 200),
            builder: (_, v, __) => Container(width: 8, height: 8,
              decoration: BoxDecoration(color: AppColors.grey400.withValues(alpha: 0.4 + v * 0.6), shape: BoxShape.circle))),
          if (i < 2) const SizedBox(width: 4),
        ],
      ]),
    ));
  }

  Widget _quickReply(String text) {
    return InkWell(
      onTap: () => _sendMessage(text),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(border: Border.all(color: AppColors.primaryLight), borderRadius: BorderRadius.circular(20)),
        child: Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500)),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isBot;
  _ChatMessage({required this.text, required this.isBot});
}
