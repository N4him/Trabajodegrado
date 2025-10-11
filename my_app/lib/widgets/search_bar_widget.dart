import 'dart:async';
import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final Function(String) onSearch;
  final VoidCallback? onClear;
  final String? initialValue;

  const SearchBarWidget({
    super.key,
    required this.onSearch,
    this.onClear,
    this.initialValue,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      _searchController.text = widget.initialValue!;
      _isSearching = true;
    }
  }

  @override
  void didUpdateWidget(SearchBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Actualizar el controlador si cambia el valor inicial
    if (widget.initialValue != oldWidget.initialValue) {
      if (widget.initialValue == null || widget.initialValue!.isEmpty) {
        _searchController.clear();
        _isSearching = false;
      } else {
        _searchController.text = widget.initialValue!;
        _isSearching = true;
      }
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    setState(() {
      _isSearching = value.trim().isNotEmpty;
    });
    
    // Set up new timer for debounced search (300ms delay)
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        final query = value.trim();
        widget.onSearch(query);
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _debounceTimer?.cancel();
    setState(() {
      _isSearching = false;
    });
    widget.onSearch(''); // Trigger search with empty query
    widget.onClear?.call();
  }

  void _handleSubmitted(String value) {
    _debounceTimer?.cancel();
    final query = value.trim();
    if (query.isNotEmpty) {
      widget.onSearch(query);
    }
    // Quitar el foco del campo de texto
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            _isSearching ? Icons.search : Icons.search_rounded,
            color: _isSearching ? const Color(0xFF4CAF50) : const Color(0xFF5E35B1),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'Buscar por título del libro...',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              textInputAction: TextInputAction.search,
              onChanged: _onSearchChanged,
              onSubmitted: _handleSubmitted,
            ),
          ),
          if (_isSearching)
            GestureDetector(
              onTap: _clearSearch,
              child: Container(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.clear,
                  color: Colors.grey[600],
                  size: 18,
                ),
              ),
            )
          
        ],
      ),
    );
  }


  Widget _buildQuickSearchChip(String label, IconData icon) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: const Color(0xFF5E35B1)),
      label: Text(label),
      onPressed: () {
        Navigator.pop(context);
        _searchController.text = label;
        setState(() {
          _isSearching = true;
        });
        widget.onSearch(label);
      },
      backgroundColor: const Color(0xFF5E35B1).withOpacity(0.1),
      labelStyle: const TextStyle(
        color: Color(0xFF5E35B1),
        fontWeight: FontWeight.w500,
      ),
      elevation: 0,
      pressElevation: 2,
    );
  }
}