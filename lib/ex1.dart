import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isSearching = false;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  void _openSearch() {
    setState(() => isSearching = true);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _closeSearch() {
    _focusNode.unfocus();
    setState(() {
      isSearching = false;
      _searchController.clear();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 12),

            /// TITLE ↔ SEARCH BAR
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final isSearch =
                      child.key == const ValueKey('search');

                  final slideAnimation = Tween<Offset>(
                    begin: Offset(isSearch ? 1 : -0.3, 0),
                    end: Offset.zero,
                  ).animate(animation);

                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: slideAnimation,
                      child: SizeTransition(
                        sizeFactor: animation,
                        axis: Axis.horizontal,
                        axisAlignment: -1,
                        child: child,
                      ),
                    ),
                  );
                },
                child: isSearching
                    ? SearchBarWidget(
                  key: const ValueKey('search'),
                  controller: _searchController,
                  focusNode: _focusNode,
                )
                    : const Text(
                  'Conversations',
                  key: ValueKey('title'),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            /// SEARCH ↔ CLOSE ICON
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return RotationTransition(
                  turns:
                  Tween<double>(begin: 0.8, end: 1).animate(animation),
                  child: ScaleTransition(
                    scale: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  ),
                );
              },
              child: IconButton(
                key: ValueKey(isSearching),
                icon:
                Icon(isSearching ? Icons.close : Icons.search),
                onPressed:
                isSearching ? _closeSearch : _openSearch,
              ),
            ),

            /// MENU ICON (HIDES DURING SEARCH)
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: isSearching
                  ? const SizedBox(width: 0)
                  : IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text(
          'Content Here',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

/// 🔎 SEARCH BAR WIDGET
class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(21),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'Search',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
