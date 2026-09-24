import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../widgets/ketok_colors.dart';
import '../widgets/ketok_app_bar.dart';

class ChatScreen extends StatefulWidget {
  final VoidCallback? onNotificationTap;

  const ChatScreen({
    super.key,
    this.onNotificationTap,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _searchController = TextEditingController();
  int _selectedConversation = 0;
  bool _showThreadOnMobile = false;
  String _searchQuery = '';

  final List<_Conversation> _conversations = [
    _Conversation(
      name: 'Sari Wijaya',
      order: 'Servis AC Mobil',
      orderId: '#KTK-2048',
      lastMessage: 'Baik, saya tunggu di lokasi ya.',
      time: '10:42',
      unread: 2,
      messages: [
        _ChatMessage(
          'Halo Pak, apakah bisa datang sekitar jam 11?',
          false,
          '10:35',
        ),
        _ChatMessage(
          'Halo Kak Sari, bisa. Saya berangkat sekarang.',
          true,
          '10:38',
        ),
        _ChatMessage(
          'Lokasinya tetap di Jalan Melati No. 12 ya?',
          false,
          '10:40',
        ),
        _ChatMessage(
          'Betul Kak. Saya akan kabari saat sudah dekat.',
          true,
          '10:41',
        ),
        _ChatMessage('Baik, saya tunggu di lokasi ya.', false, '10:42'),
      ],
    ),
    _Conversation(
      name: 'Andi Pratama',
      order: 'Ganti Ban',
      orderId: '#KTK-2041',
      lastMessage: 'Terima kasih, Pak.',
      time: 'Kemarin',
      messages: [
        _ChatMessage('Pak, saya sudah sampai di bengkel.', false, 'Kemarin'),
        _ChatMessage('Siap, Kak. Saya segera ke sana.', true, 'Kemarin'),
        _ChatMessage('Terima kasih, Pak.', false, 'Kemarin'),
      ],
    ),
    _Conversation(
      name: 'Rina Lestari',
      order: 'Bodi dan Cat',
      orderId: '#KTK-2033',
      lastMessage: 'Kapan mobil bisa diambil?',
      time: 'Sen',
      messages: [
        _ChatMessage('Kapan mobil bisa diambil?', false, 'Sen'),
        _ChatMessage('Sore ini sudah selesai, Kak.', true, 'Sen'),
      ],
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  List<_Conversation> get _filteredConversations {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _conversations;
    return _conversations
        .where(
          (conversation) =>
              conversation.name.toLowerCase().contains(query) ||
              conversation.order.toLowerCase().contains(query),
        )
        .toList();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    final l10n = context.l10n;
    setState(() {
      _conversations[_selectedConversation].messages.add(
        _ChatMessage(text, true, l10n.isIndonesian ? 'Baru' : 'Just now'),
      );
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;
        return Container(
          color: KetokColors.bgColor,
          padding: const EdgeInsets.only(bottom: 0),
          child: isWide ? _buildWideLayout() : _buildCompactLayout(),
        );
      },
    );
  }

  Widget _buildWideLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageHeading(),
        const SizedBox(height: 18),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: 320, child: _buildConversationList()),
                const SizedBox(width: 16),
                Expanded(child: _buildThread()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_showThreadOnMobile) ...[
          _buildPageHeading(),
          const SizedBox(height: 18),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildConversationList(),
            ),
          ),
        ] else ...[
          Expanded(child: _buildThread(showBackButton: true, compact: true)),
        ],
      ],
    );
  }

  Widget _buildPageHeading() {
    return KetokAppBar(
      onNotificationTap: widget.onNotificationTap,
    );
  }

  Widget _buildConversationList() {
    final conversations = _filteredConversations;
    final l10n = context.l10n;
    return Column(
      children: [
        TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: l10n.isIndonesian ? 'Cari pelanggan atau pesanan' : 'Search customer or order',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _searchQuery.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: conversations.isEmpty
              ? Center(
                  child: Text(
                    l10n.isIndonesian
                        ? 'Percakapan tidak ditemukan.'
                        : 'No conversations found.',
                    style: const TextStyle(color: KetokColors.onSurfaceVariant),
                  ),
                )
              : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: conversations.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    final actualIndex = _conversations.indexOf(conversation);
                    return _buildConversationTile(conversation, actualIndex);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildConversationTile(_Conversation conversation, int index) {
    final selected = index == _selectedConversation;
    return Material(
      color: selected ? KetokColors.surfaceLow : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => setState(() {
          _selectedConversation = index;
          _showThreadOnMobile = true;
          conversation.unread = 0; // Tandai sudah dibaca
        }),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            children: [
              _Avatar(name: conversation.name),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Text(
                          conversation.time,
                          style: const TextStyle(
                            fontSize: 11,
                            color: KetokColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      conversation.order,
                      style: const TextStyle(
                        color: KetokColors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      conversation.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: KetokColors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (conversation.unread > 0) ...[
                const SizedBox(width: 8),
                Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: KetokColors.darkPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${conversation.unread}',
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThread({bool showBackButton = false, bool compact = false}) {
    final l10n = context.l10n;
    final conversation = _conversations[_selectedConversation];
    return Column(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(compact ? 0 : 4, 0, compact ? 0 : 4, 14),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: KetokColors.borderColor)),
          ),
          child: Row(
            children: [
              if (showBackButton)
                IconButton(
                  onPressed: () => setState(() => _showThreadOnMobile = false),
                  icon: const Icon(Icons.arrow_back_rounded),
                  tooltip: l10n.isIndonesian ? 'Kembali ke daftar chat' : 'Back to chat list',
                ),
              _Avatar(name: conversation.name),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${conversation.order}  ${conversation.orderId}',
                      style: const TextStyle(
                        color: KetokColors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_horiz_rounded),
                tooltip: l10n.isIndonesian ? 'Opsi percakapan' : 'Conversation options',
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(4, 18, 4, 18),
            physics: const BouncingScrollPhysics(),
            itemCount: conversation.messages.length,
            itemBuilder: (context, index) =>
                _buildMessageBubble(conversation.messages[index]),
          ),
        ),
        _buildComposer(),
      ],
    );
  }

  Widget _buildMessageBubble(_ChatMessage message) {
    return Align(
      alignment: message.fromMitra
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(14, 10, 12, 8),
        decoration: BoxDecoration(
          color: message.fromMitra ? KetokColors.darkPrimary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.fromMitra ? 16 : 4),
            bottomRight: Radius.circular(message.fromMitra ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.fromMitra
                      ? Colors.white
                      : KetokColors.onSurface,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.time,
                  style: TextStyle(
                    color: message.fromMitra
                        ? Colors.white70
                        : KetokColors.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
                if (message.fromMitra) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.done_all_rounded,
                    size: 14,
                    color: Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComposer() {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: l10n.typeMessageHint,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: _sendMessage,
            style: IconButton.styleFrom(
              backgroundColor: KetokColors.darkPrimary,
              foregroundColor: Colors.white,
              fixedSize: const Size(46, 46),
            ),
            icon: const Icon(Icons.send_rounded, size: 20),
            tooltip: l10n.isIndonesian ? 'Kirim pesan' : 'Send message',
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;

  const _Avatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 23,
      backgroundColor: KetokColors.surfaceLow,
      child: Text(
        name.substring(0, 1),
        style: const TextStyle(
          color: KetokColors.darkPrimary,
          fontWeight: FontWeight.w800,
          fontSize: 17,
        ),
      ),
    );
  }
}

class _Conversation {
  final String name;
  final String order;
  final String orderId;
  final String lastMessage;
  final String time;
  int unread;
  final List<_ChatMessage> messages;

  _Conversation({
    required this.name,
    required this.order,
    required this.orderId,
    required this.lastMessage,
    required this.time,
    this.unread = 0,
    required this.messages,
  });
}

class _ChatMessage {
  final String text;
  final bool fromMitra;
  final String time;

  _ChatMessage(this.text, this.fromMitra, this.time);
}
