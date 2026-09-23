import 'package:flutter/material.dart';

import '../services/ketok_order_repository.dart';
import '../widgets/ketok_colors.dart';
import 'app.dart';

class ChatScreen extends StatefulWidget {
  final String? initialMitraName;
  final String? initialServiceName;
  final String? initialMitraPhotoUrl;

  const ChatScreen({
    super.key,
    this.initialMitraName,
    this.initialServiceName,
    this.initialMitraPhotoUrl,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _searchController = TextEditingController();
  late Future<List<_Conversation>> _chatsFuture;
  int _selectedConversation = 0;
  bool _showThreadOnMobile = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _messageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialMitraName != null) {
      _showThreadOnMobile = true;
      _selectedConversation = 0;
    }
    _loadChats();
  }

  void _loadChats() {
    _chatsFuture = KetokOrderRepository().getChats().then((chats) {
      final list = chats.map((c) {
        return _Conversation(
          name: c.order.mitraName,
          order: c.order.title,
          orderId: c.order.invoice,
          lastMessage: 'Halo, saya siap membantu koordinasi layanan Anda.',
          time: 'Baru saja',
          unread: c.unread,
          messages: [
            _ChatMessage(
              'Halo, saya siap membantu koordinasi layanan Anda.',
              true,
              'Baru saja',
            ),
          ],
        );
      }).toList();

      if (widget.initialMitraName != null) {
        list.insert(
          0,
          _Conversation(
            name: widget.initialMitraName!,
            photoUrl: widget.initialMitraPhotoUrl,
            order: widget.initialServiceName ?? 'Konsultasi Jasa',
            orderId: '',
            lastMessage: 'Halo, ada yang bisa dibantu?',
            time: 'Baru saja',
            unread: 0,
            messages: [
              _ChatMessage('Halo, ada yang bisa dibantu?', true, 'Baru saja'),
            ],
          ),
        );
      }
      return list;
    });
  }

  void _sendMessage(List<_Conversation> conversations) {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      conversations[_selectedConversation].messages.add(
        _ChatMessage(text, false, 'Baru'),
      );
      _messageController.clear();
    });
  }

  List<_Conversation> _getFilteredConversations(List<_Conversation> conversations) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return conversations;
    return conversations
        .where(
          (c) =>
              c.name.toLowerCase().contains(query) ||
              c.order.toLowerCase().contains(query),
        )
        .toList();
  }

  void _handleBack() {
    if (widget.initialMitraName != null) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
        return;
      }
    }
    if (_showThreadOnMobile) {
      setState(() => _showThreadOnMobile = false);
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDirectChat = widget.initialMitraName != null;
    final bool canPopDirectly = isDirectChat || !_showThreadOnMobile;

    return PopScope(
      canPop: canPopDirectly,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_showThreadOnMobile) {
          setState(() => _showThreadOnMobile = false);
        }
      },
      child: Scaffold(
        backgroundColor: KetokColors.background,
        body: SafeArea(
          child: KetokResponsiveContent(
            child: FutureBuilder<List<_Conversation>>(
              future: _chatsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading chats:\n${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                final conversations = snapshot.data ?? [];
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 700;
                    return Container(
                      color: KetokColors.background,
                      padding: const EdgeInsets.only(bottom: 0),
                      child: isWide 
                          ? _buildWideLayout(conversations) 
                          : _buildCompactLayout(conversations),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout(List<_Conversation> conversations) {
    final canPop = Navigator.canPop(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (canPop && widget.initialMitraName != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: _handleBack,
                  icon: const Icon(Icons.arrow_back_rounded),
                  tooltip: 'Kembali',
                ),
                const SizedBox(width: 8),
                Text(
                  'Kembali ke ${widget.initialServiceName ?? "Detail Layanan"}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          )
        else
          const KetokScreenHeader(),
        const SizedBox(height: 18),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 320, 
                  child: _buildConversationList(conversations),
                ),
                const SizedBox(width: 16),
                Expanded(child: _buildThread(conversations, showBackButton: canPop)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactLayout(List<_Conversation> conversations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_showThreadOnMobile) ...[
          const KetokScreenHeader(),
          const SizedBox(height: 18),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildConversationList(conversations),
            ),
          ),
        ] else ...[
          Expanded(
            child: _buildThread(
              conversations, 
              showBackButton: true, 
              compact: true,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildConversationList(List<_Conversation> allConversations) {
    final conversations = _getFilteredConversations(allConversations);
    return Column(
      children: [
        TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Cari mitra atau pesanan',
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
              ? const Center(
                  child: Text(
                    'Percakapan tidak ditemukan.',
                    style: TextStyle(color: KetokColors.textMuted),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async => setState(() => _loadChats()),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    itemCount: conversations.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final conversation = conversations[index];
                      final actualIndex = allConversations.indexOf(conversation);
                      return _buildConversationTile(
                        conversation, 
                        actualIndex,
                      );
                    },
                  ),
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
                            color: KetokColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      conversation.order,
                      style: const TextStyle(
                        color: KetokColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      conversation.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: KetokColors.textMuted,
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
                    color: KetokColors.primary,
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

  Widget _buildThread(
    List<_Conversation> conversations, {
    bool showBackButton = false, 
    bool compact = false,
  }) {
    if (conversations.isEmpty) return const SizedBox();
    
    // Ensure index is valid when switching lists or layouts
    final validIndex = _selectedConversation < conversations.length 
        ? _selectedConversation 
        : 0;
    if (_selectedConversation != validIndex) {
      _selectedConversation = validIndex;
    }
    
    final conversation = conversations[validIndex];
    return Column(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(compact ? 0 : 4, 0, compact ? 0 : 4, 14),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: KetokColors.border)),
          ),
          child: Row(
            children: [
              if (showBackButton)
                IconButton(
                  onPressed: _handleBack,
                  icon: const Icon(Icons.arrow_back_rounded),
                  tooltip: widget.initialMitraName != null
                      ? 'Kembali ke detail layanan'
                      : 'Kembali ke daftar chat',
                ),
              _Avatar(name: conversation.name, photoUrl: conversation.photoUrl),
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
                        color: KetokColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_horiz_rounded),
                tooltip: 'Opsi percakapan',
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
        _buildComposer(conversations),
      ],
    );
  }

  Widget _buildMessageBubble(_ChatMessage message) {
    return Align(
      alignment: message.fromMitra
          ? Alignment.centerLeft
          : Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(14, 10, 12, 8),
        decoration: BoxDecoration(
          color: message.fromMitra ? Colors.white : KetokColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.fromMitra ? 4 : 16),
            bottomRight: Radius.circular(message.fromMitra ? 16 : 4),
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
                      ? KetokColors.text
                      : Colors.white,
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
                        ? KetokColors.textMuted
                        : Colors.white70,
                    fontSize: 10,
                  ),
                ),
                if (!message.fromMitra) ...[
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

  Widget _buildComposer(List<_Conversation> conversations) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(conversations),
              decoration: InputDecoration(
                hintText: 'Tulis pesan untuk mitra...',
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
            onPressed: () => _sendMessage(conversations),
            style: IconButton.styleFrom(
              backgroundColor: KetokColors.primary,
              foregroundColor: Colors.white,
              fixedSize: const Size(46, 46),
            ),
            icon: const Icon(Icons.send_rounded, size: 20),
            tooltip: 'Kirim pesan',
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final String? photoUrl;

  const _Avatar({required this.name, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    final validUrl = (photoUrl != null && photoUrl!.startsWith('http')) ? photoUrl : null;
    return CircleAvatar(
      radius: 23,
      backgroundColor: KetokColors.surfaceLow,
      backgroundImage: validUrl != null ? NetworkImage(validUrl) : null,
      child: validUrl == null 
          ? Text(
              name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
              style: const TextStyle(
                color: KetokColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            )
          : null,
    );
  }
}

class _Conversation {
  final String name;
  final String? photoUrl;
  final String order;
  final String orderId;
  final String lastMessage;
  final String time;
  int unread;
  final List<_ChatMessage> messages;

  _Conversation({
    required this.name,
    this.photoUrl,
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
