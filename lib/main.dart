import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// 🔹 MAIN APP
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

/// 🔹 HOME PAGE
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Conversations',
        onSearchTextChanged: (text) {
          // Handle search text changes here
          print("Search: $text");
        },
        onMenuPressed: () {
          // Handle menu action here
          print("Menu pressed");
        },
      ),
      body: const Center(
        child: Text('Content Here', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}

/// 🔹 CUSTOM APPBAR
class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final ValueChanged<String>? onSearchTextChanged;
  final VoidCallback? onMenuPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onSearchTextChanged,
    this.onMenuPressed,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar>
    with TickerProviderStateMixin {
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
        widget.onSearchTextChanged?.call('');
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
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      leadingWidth: isSearchVisible ? 0 : 200,
      leading: isSearchVisible
          ? const SizedBox.shrink()
          : Padding(
        padding: const EdgeInsets.only(left: 12, top: 12),
        child: Text(
          widget.title,
          key: const ValueKey('title'),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ),
      title: Row(
        children: [
          const SizedBox(width: 12),
          // Search bar
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
                onTextChanged: widget.onSearchTextChanged,
              )
                  : const SizedBox.shrink(),
            ),
          ),
          // Search / Close icon
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
                isSearchVisible ? CupertinoIcons.clear : CupertinoIcons.search,
                size: isSearchVisible ? 24 : 30,
              ),
              onPressed: _toggleSearch,
            ),
          ),
          if (!isSearchVisible)
            IconButton(
              onPressed: widget.onMenuPressed,
              icon: const Icon(CupertinoIcons.bars, size: 28),
            ),
        ],
      ),
    );
  }
}

/// 🔹 CUSTOM SEARCH BAR
class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String>? onTextChanged;

  const SearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    this.onTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          const Icon(CupertinoIcons.search, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              onChanged: onTextChanged,
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
