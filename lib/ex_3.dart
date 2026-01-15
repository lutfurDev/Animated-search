import 'package:flutter/cupertino.dart';
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

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool isSearchVisible = false;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late final AnimationController _iconController;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _toggleSearch() {
    setState(() {
      isSearchVisible = !isSearchVisible;
      if (isSearchVisible) {
        _focusNode.requestFocus();
        _iconController.forward();
      } else {
        _focusNode.unfocus();
        _controller.clear();
        _iconController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,

        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leadingWidth: isSearchVisible ? 0 : 200,
        leading: isSearchVisible
            ? const SizedBox.shrink()
            : const Padding(
          padding: EdgeInsets.only(left: 12, top: 12),
          child: Text(
            'Conversations',
            key: ValueKey('title'),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
        ),
        title: Row(
          children: [
            const SizedBox(width: 12),
            // Search Bar AnimatedSwitcher
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final isSearch = child.key == const ValueKey('search');
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(isSearch ? 1 : -0.3, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: SizeTransition(
                        sizeFactor: animation,
                        axis: Axis.horizontal,
                        axisAlignment: -1,
                        child: child,
                      ),
                    ),
                  );
                },
                child: isSearchVisible
                    ? SearchBar(
                  key: const ValueKey('search'),
                  controller: _controller,
                  focusNode: _focusNode,
                )
                    : const SizedBox.shrink(),
              ),
            ),
            // Search / Close Icon
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return RotationTransition(
                  turns: Tween<double>(begin: 0.75, end: 1).animate(animation),
                  child: ScaleTransition(scale: animation, child: child),
                );
              },
              child: IconButton(
                key: ValueKey(isSearchVisible),
                icon: Icon(
                  isSearchVisible
                      ? CupertinoIcons.clear
                      : CupertinoIcons.search,
                  size: isSearchVisible ? 24 : 30,
                ),
                onPressed: _toggleSearch,
              ),
            ),
            if (!isSearchVisible)
              IconButton(
                onPressed: () {},
                icon: Icon(CupertinoIcons.bars, size: 28),
              ),
          ],
        ),
      ),
      body: const Center(
        child: Text('Content Here', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}

/// 🔎 SEARCH BAR
class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const SearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          Icon(CupertinoIcons.search, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search',
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
