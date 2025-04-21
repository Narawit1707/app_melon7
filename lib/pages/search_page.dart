import 'package:flutter/material.dart';
import 'package:pj_app/widgets/user_search_result.dart';
import 'package:pj_app/widgets/post_search_result.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearchingUsers = true;

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 252, 252, 252), // เปลี่ยนพื้นหลัง
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: Colors.lime,
        actions: [
          IconButton(
            icon: Icon(_isSearchingUsers ? Icons.person : Icons.post_add),
            onPressed: () {
              setState(() {
                _isSearchingUsers = !_isSearchingUsers;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                labelText: 'Search...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: _searchQuery.isEmpty
                ? const Center(child: Text('Start typing to search...'))
                : _isSearchingUsers
                    ? UserSearchResult(searchQuery: _searchQuery)
                    : PostSearchResult(searchQuery: _searchQuery),
          ),
        ],
      ),
    );
  }
}