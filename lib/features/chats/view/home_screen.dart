import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/avatar.dart';
import '../../auth/providers/auth_provider.dart';
import '../../conversation/view/chat_screen.dart';
import '../../settings/view/settings_screen.dart';
import '../providers/chats_provider.dart';
import '../widgets/chat_tile.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Purely local UI state, so it stays out of Riverpod.
  int _tab = 0;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).set('');
  }

  void _open(Chat chat) {
    ref.read(chatsProvider.notifier).markAsRead(chat.id);
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ChatScreen(chatId: chat.id)));
  }

  @override
  Widget build(BuildContext context) {
    final chats = ref.watch(filteredChatsProvider);
    final query = ref.watch(searchQueryProvider);
    final unread = ref.watch(totalUnreadProvider);

    return Scaffold(
      body: _tab == 3
          ? const SettingsScreen()
          : SafeArea(
              bottom: false,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _header(context)),
                  SliverToBoxAdapter(child: _searchBar()),
                  if (query.isEmpty) ...[
                    const SliverToBoxAdapter(
                      child: _SectionLabel('ACTIVE NOW'),
                    ),
                    const SliverToBoxAdapter(child: _ActiveRow()),
                  ],
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      height: 24,
                      decoration: BoxDecoration(
                        color: context.surface,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _SectionLabel(
                      query.isEmpty ? 'MESSAGES' : 'SEARCH RESULTS',
                      count: chats.value?.length,
                    ),
                  ),
                  ...chats.when(
                    data: (list) => list.isEmpty
                        ? [
                            SliverToBoxAdapter(
                              child: ColoredBox(
                                color: context.surface,
                                child: _EmptyChats(
                                  isSearching: query.isNotEmpty,
                                  onClearSearch: _clearSearch,
                                ),
                              ),
                            ),
                          ]
                        : [
                            SliverList.builder(
                              itemCount: list.length,
                              itemBuilder: (_, i) => ColoredBox(
                                color: context.surface,
                                child: ChatTile(
                                  chat: list[i],
                                  onTap: () => _open(list[i]),
                                ),
                              ),
                            ),
                          ],
                    loading: () => [
                      SliverToBoxAdapter(
                        child: ColoredBox(
                          color: context.surface,
                          child: const Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ),
                      ),
                    ],
                    error: (e, _) => [
                      SliverToBoxAdapter(
                        child: ColoredBox(
                          color: context.surface,
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Text(
                                  'Chats load karanna bari una',
                                  style: TextStyle(color: context.subtext),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      ref.invalidate(chatsProvider),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: ColoredBox(color: context.surface),
                  ),
                ],
              ),
            ),
      floatingActionButton: _tab == 3
          ? null
          : FloatingActionButton(
              onPressed: () {},
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.edit_rounded),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          NavigationDestination(
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text('$unread'),
              child: const Icon(Icons.chat_bubble_outline_rounded),
            ),
            selectedIcon: Badge(
              isLabelVisible: unread > 0,
              label: Text('$unread'),
              child: const Icon(Icons.chat_bubble_rounded),
            ),
            label: 'Chats',
          ),
          const NavigationDestination(
            icon: Icon(Icons.call_outlined),
            selectedIcon: Icon(Icons.call_rounded),
            label: 'Calls',
          ),
          const NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'Contacts',
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
      child: Row(
        children: [
          const AppLogo(markSize: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Messages',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.camera_alt_outlined),
          ),
          _menu(),
        ],
      ),
    );
  }

  Widget _menu() {
    final me = ref.watch(authProvider).value;
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (v) {
        if (v == 'logout') ref.read(authProvider.notifier).signOut();
      },
      itemBuilder: (_) => [
        if (me != null)
          PopupMenuItem(
            enabled: false,
            child: Row(
              children: [
                Avatar(user: me, size: 36, showOnline: false),
                const SizedBox(width: 12),
                Text(me.name, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout_rounded, color: Colors.redAccent),
              SizedBox(width: 12),
              Text('Logout', style: TextStyle(color: Colors.redAccent)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _searchBar() {
    final query = ref.watch(searchQueryProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: TextField(
        controller: _searchController,
        onChanged: ref.read(searchQueryProvider.notifier).set,
        decoration: InputDecoration(
          hintText: 'Search chats',
          prefixIcon: Icon(Icons.search_rounded),
          suffixIcon: query.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.close_rounded),
                ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final int? count;

  const _SectionLabel(this.label, {this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: context.subtext,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 8),
            Text(
              '$count',
              style: TextStyle(
                color: context.subtext,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyChats extends StatelessWidget {
  final bool isSearching;
  final VoidCallback onClearSearch;

  const _EmptyChats({required this.isSearching, required this.onClearSearch});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 56, 28, 72),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .secondary
                  .withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSearching ? Icons.search_off_rounded : Icons.forum_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 34,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            isSearching ? 'No chats found' : 'No conversations yet',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? 'Try another name or clear your search.'
                : 'Your conversations will show up here.',
            style: TextStyle(color: context.subtext, height: 1.4),
            textAlign: TextAlign.center,
          ),
          if (isSearching) ...[
            const SizedBox(height: 14),
            TextButton(
              onPressed: onClearSearch,
              child: const Text('Clear search'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActiveRow extends ConsumerWidget {
  const _ActiveRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(onlineUsersProvider).value ?? const <User>[];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: online.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (_, i) {
          if (i == 0) return _addStory(context);
          final u = online[i - 1];
          return Column(
            children: [
              Avatar(user: u, size: 56, ring: true),
              const SizedBox(height: 6),
              Text(
                u.name.split(' ').first,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _addStory(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.surface,
            border: Border.all(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Icon(
            Icons.add_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 6),
        Text('Your story', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
