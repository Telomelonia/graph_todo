import 'package:flutter/material.dart';

class IconSelectorWidget extends StatefulWidget {
  final String? currentIcon;
  final Function(String) onIconSelected;

  const IconSelectorWidget({
    super.key,
    this.currentIcon,
    required this.onIconSelected,
  });

  @override
  State<IconSelectorWidget> createState() => _IconSelectorWidgetState();
}

class _IconSelectorWidgetState extends State<IconSelectorWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredIcons = [];
  
  // Predefined skill tree / game-like icons
  static const List<Map<String, dynamic>> _availableIcons = [
    // Combat & Weapons
    {'icon': '⚔️', 'name': 'sword', 'category': 'combat'},
    {'icon': '🛡️', 'name': 'shield', 'category': 'combat'},
    {'icon': '🏹', 'name': 'bow', 'category': 'combat'},
    {'icon': '🔥', 'name': 'fire', 'category': 'combat'},
    {'icon': '⚡', 'name': 'lightning', 'category': 'combat'},
    {'icon': '❄️', 'name': 'ice', 'category': 'combat'},
    
    // Magic & Mystical
    {'icon': '🔮', 'name': 'crystal ball', 'category': 'magic'},
    {'icon': '✨', 'name': 'sparkles', 'category': 'magic'},
    {'icon': '🌟', 'name': 'star', 'category': 'magic'},
    {'icon': '💫', 'name': 'dizzy', 'category': 'magic'},
    {'icon': '🪄', 'name': 'magic wand', 'category': 'magic'},
    {'icon': '🧙', 'name': 'mage', 'category': 'magic'},
    
    // Skills & Crafting
    {'icon': '🔨', 'name': 'hammer', 'category': 'crafting'},
    {'icon': '⚒️', 'name': 'tools', 'category': 'crafting'},
    {'icon': '🔧', 'name': 'wrench', 'category': 'crafting'},
    {'icon': '⚙️', 'name': 'gear', 'category': 'crafting'},
    {'icon': '🧰', 'name': 'toolbox', 'category': 'crafting'},
    {'icon': '🏗️', 'name': 'construction', 'category': 'crafting'},
    
    // Knowledge & Learning
    {'icon': '📚', 'name': 'books', 'category': 'knowledge'},
    {'icon': '🧠', 'name': 'brain', 'category': 'knowledge'},
    {'icon': '💡', 'name': 'idea', 'category': 'knowledge'},
    {'icon': '🔬', 'name': 'microscope', 'category': 'knowledge'},
    {'icon': '📊', 'name': 'chart', 'category': 'knowledge'},
    {'icon': '🎯', 'name': 'target', 'category': 'knowledge'},
    
    // Health & Fitness
    {'icon': '💪', 'name': 'muscle', 'category': 'health'},
    {'icon': '❤️', 'name': 'heart', 'category': 'health'},
    {'icon': '🏃', 'name': 'running', 'category': 'health'},
    {'icon': '🧘', 'name': 'meditation', 'category': 'health'},
    {'icon': '🥇', 'name': 'gold medal', 'category': 'health'},
    {'icon': '🏆', 'name': 'trophy', 'category': 'health'},
    
    // Technology & Programming
    {'icon': '💻', 'name': 'laptop', 'category': 'tech'},
    {'icon': '🖥️', 'name': 'desktop', 'category': 'tech'},
    {'icon': '⌨️', 'name': 'keyboard', 'category': 'tech'},
    {'icon': '🖱️', 'name': 'mouse', 'category': 'tech'},
    {'icon': '📱', 'name': 'phone', 'category': 'tech'},
    {'icon': '🔌', 'name': 'plug', 'category': 'tech'},
    
    // Creative & Arts
    {'icon': '🎨', 'name': 'art', 'category': 'creative'},
    {'icon': '🖌️', 'name': 'paintbrush', 'category': 'creative'},
    {'icon': '🎭', 'name': 'theater', 'category': 'creative'},
    {'icon': '🎵', 'name': 'music', 'category': 'creative'},
    {'icon': '📸', 'name': 'camera', 'category': 'creative'},
    {'icon': '🎬', 'name': 'movie', 'category': 'creative'},
    
    // Adventure & Exploration
    {'icon': '🗺️', 'name': 'map', 'category': 'adventure'},
    {'icon': '🧭', 'name': 'compass', 'category': 'adventure'},
    {'icon': '⛰️', 'name': 'mountain', 'category': 'adventure'},
    {'icon': '🌍', 'name': 'earth', 'category': 'adventure'},
    {'icon': '🚀', 'name': 'rocket', 'category': 'adventure'},
    {'icon': '🔭', 'name': 'telescope', 'category': 'adventure'},
    
    // Business & Finance
    {'icon': '💰', 'name': 'money', 'category': 'business'},
    {'icon': '💎', 'name': 'diamond', 'category': 'business'},
    {'icon': '📈', 'name': 'trending up', 'category': 'business'},
    {'icon': '🏦', 'name': 'bank', 'category': 'business'},
    {'icon': '💼', 'name': 'briefcase', 'category': 'business'},
    {'icon': '📊', 'name': 'bar chart', 'category': 'business'},
    
    // Nature & Elements
    {'icon': '🌱', 'name': 'seedling', 'category': 'nature'},
    {'icon': '🌳', 'name': 'tree', 'category': 'nature'},
    {'icon': '🌊', 'name': 'wave', 'category': 'nature'},
    {'icon': '🌙', 'name': 'moon', 'category': 'nature'},
    {'icon': '☀️', 'name': 'sun', 'category': 'nature'},
    {'icon': '🌈', 'name': 'rainbow', 'category': 'nature'},
    
    // Animals & Creatures
    {'icon': '🦅', 'name': 'eagle', 'category': 'animals'},
    {'icon': '🐺', 'name': 'wolf', 'category': 'animals'},
    {'icon': '🦁', 'name': 'lion', 'category': 'animals'},
    {'icon': '🐉', 'name': 'dragon', 'category': 'animals'},
    {'icon': '🦋', 'name': 'butterfly', 'category': 'animals'},
    {'icon': '🐝', 'name': 'bee', 'category': 'animals'},
  ];

  @override
  void initState() {
    super.initState();
    _filteredIcons = List.from(_availableIcons);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterIcons(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredIcons = List.from(_availableIcons);
      } else {
        _filteredIcons = _availableIcons.where((iconData) {
          final name = iconData['name'].toString().toLowerCase();
          final category = iconData['category'].toString().toLowerCase();
          final searchQuery = query.toLowerCase();
          return name.contains(searchQuery) || category.contains(searchQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Icon',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Search bar
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search icons (e.g., sword, magic, tech)...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: _filterIcons,
          ),
          const SizedBox(height: 16),
          
          // Icon grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: _filteredIcons.length,
              itemBuilder: (context, index) {
                final iconData = _filteredIcons[index];
                final icon = iconData['icon'] as String;
                final isSelected = widget.currentIcon == icon;
                
                return GestureDetector(
                  onTap: () => widget.onIconSelected(icon),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected 
                        ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.1),
                      border: Border.all(
                        color: isSelected 
                          ? Theme.of(context).primaryColor
                          : Colors.grey.withValues(alpha: 0.3),
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Footer info
          if (_filteredIcons.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No icons found. Try a different search term.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }
}