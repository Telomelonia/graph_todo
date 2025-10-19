import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
  
  // Comprehensive Phosphor Icons collection organized by category
  static const List<Map<String, dynamic>> _availableIcons = [
    // Tasks & Goals
    {'icon': 'target', 'name': 'target', 'category': 'tasks'},
    {'icon': 'check-circle', 'name': 'check circle', 'category': 'tasks'},
    {'icon': 'flag', 'name': 'flag', 'category': 'tasks'},
    {'icon': 'trophy', 'name': 'trophy', 'category': 'tasks'},
    {'icon': 'medal', 'name': 'medal', 'category': 'tasks'},
    {'icon': 'star', 'name': 'star', 'category': 'tasks'},
    {'icon': 'check', 'name': 'check', 'category': 'tasks'},
    {'icon': 'x', 'name': 'x', 'category': 'tasks'},
    {'icon': 'clock', 'name': 'clock', 'category': 'tasks'},
    {'icon': 'calendar', 'name': 'calendar', 'category': 'tasks'},
    {'icon': 'bookmark', 'name': 'bookmark', 'category': 'tasks'},
    {'icon': 'list', 'name': 'list', 'category': 'tasks'},
    {'icon': 'note', 'name': 'note', 'category': 'tasks'},
    {'icon': 'plus', 'name': 'plus', 'category': 'tasks'},
    {'icon': 'minus', 'name': 'minus', 'category': 'tasks'},
    
    // Work & Business
    {'icon': 'briefcase', 'name': 'briefcase', 'category': 'business'},
    {'icon': 'bank', 'name': 'bank', 'category': 'business'},
    {'icon': 'chart-line', 'name': 'chart line', 'category': 'business'},
    {'icon': 'chart-bar', 'name': 'chart bar', 'category': 'business'},
    {'icon': 'money', 'name': 'money', 'category': 'business'},
    {'icon': 'diamond', 'name': 'diamond', 'category': 'business'},
    {'icon': 'currency-dollar', 'name': 'dollar', 'category': 'business'},
    {'icon': 'currency-euro', 'name': 'euro', 'category': 'business'},
    {'icon': 'credit-card', 'name': 'credit card', 'category': 'business'},
    {'icon': 'calculator', 'name': 'calculator', 'category': 'business'},
    {'icon': 'presentation-chart', 'name': 'presentation', 'category': 'business'},
    {'icon': 'handshake', 'name': 'handshake', 'category': 'business'},
    {'icon': 'building', 'name': 'building', 'category': 'business'},
    {'icon': 'office-chair', 'name': 'office chair', 'category': 'business'},
    {'icon': 'receipt', 'name': 'receipt', 'category': 'business'},
    {'icon': 'vault', 'name': 'vault', 'category': 'business'},
    {'icon': 'coin', 'name': 'coin', 'category': 'business'},
    {'icon': 'piggy-bank', 'name': 'piggy bank', 'category': 'business'},
    
    // Technology & Programming
    {'icon': 'laptop', 'name': 'laptop', 'category': 'tech'},
    {'icon': 'monitor', 'name': 'monitor', 'category': 'tech'},
    {'icon': 'device-mobile', 'name': 'mobile', 'category': 'tech'},
    {'icon': 'code', 'name': 'code', 'category': 'tech'},
    {'icon': 'terminal', 'name': 'terminal', 'category': 'tech'},
    {'icon': 'gear', 'name': 'gear', 'category': 'tech'},
    {'icon': 'database', 'name': 'database', 'category': 'tech'},
    {'icon': 'cloud', 'name': 'cloud', 'category': 'tech'},
    {'icon': 'wifi', 'name': 'wifi', 'category': 'tech'},
    {'icon': 'bluetooth', 'name': 'bluetooth', 'category': 'tech'},
    {'icon': 'usb', 'name': 'usb', 'category': 'tech'},
    {'icon': 'hard-drive', 'name': 'hard drive', 'category': 'tech'},
    {'icon': 'cpu', 'name': 'cpu', 'category': 'tech'},
    {'icon': 'memory', 'name': 'memory', 'category': 'tech'},
    {'icon': 'circuit-board', 'name': 'motherboard', 'category': 'tech'},
    {'icon': 'network', 'name': 'router', 'category': 'tech'},
    {'icon': 'browser', 'name': 'browser', 'category': 'tech'},
    {'icon': 'bug', 'name': 'bug', 'category': 'tech'},
    {'icon': 'git-branch', 'name': 'git branch', 'category': 'tech'},
    {'icon': 'github-logo', 'name': 'github', 'category': 'tech'},
    
    // Health & Fitness
    {'icon': 'heart', 'name': 'heart', 'category': 'health'},
    {'icon': 'pulse', 'name': 'pulse', 'category': 'health'},
    {'icon': 'bicycle', 'name': 'bicycle', 'category': 'health'},
    {'icon': 'barbell', 'name': 'barbell', 'category': 'health'},
    {'icon': 'person-simple-run', 'name': 'running', 'category': 'health'},
    {'icon': 'apple-logo', 'name': 'apple', 'category': 'health'},
    {'icon': 'person-simple-walk', 'name': 'walking', 'category': 'health'},
    {'icon': 'person-simple-swim', 'name': 'swimming', 'category': 'health'},
    {'icon': 'person-simple-bike', 'name': 'biking', 'category': 'health'},
    {'icon': 'person', 'name': 'yoga', 'category': 'health'},
    {'icon': 'basketball', 'name': 'basketball', 'category': 'health'},
    {'icon': 'soccer-ball', 'name': 'soccer', 'category': 'health'},
    {'icon': 'tennis-ball', 'name': 'tennis', 'category': 'health'},
    {'icon': 'barbell', 'name': 'dumbbell', 'category': 'health'},
    {'icon': 'pill', 'name': 'pill', 'category': 'health'},
    {'icon': 'first-aid', 'name': 'first aid', 'category': 'health'},
    {'icon': 'thermometer', 'name': 'thermometer', 'category': 'health'},
    {'icon': 'tooth', 'name': 'tooth', 'category': 'health'},
    
    // Knowledge & Learning
    {'icon': 'book', 'name': 'book', 'category': 'knowledge'},
    {'icon': 'books', 'name': 'books', 'category': 'knowledge'},
    {'icon': 'brain', 'name': 'brain', 'category': 'knowledge'},
    {'icon': 'lightbulb', 'name': 'lightbulb', 'category': 'knowledge'},
    {'icon': 'graduation-cap', 'name': 'graduation cap', 'category': 'knowledge'},
    {'icon': 'microscope', 'name': 'microscope', 'category': 'knowledge'},
    {'icon': 'student', 'name': 'student', 'category': 'knowledge'},
    {'icon': 'teacher', 'name': 'teacher', 'category': 'knowledge'},
    {'icon': 'chalkboard', 'name': 'chalkboard', 'category': 'knowledge'},
    {'icon': 'test-tube', 'name': 'test tube', 'category': 'knowledge'},
    {'icon': 'atom', 'name': 'atom', 'category': 'knowledge'},
    {'icon': 'dna', 'name': 'dna', 'category': 'knowledge'},
    {'icon': 'flask', 'name': 'flask', 'category': 'knowledge'},
    {'icon': 'math-operations', 'name': 'math', 'category': 'knowledge'},
    {'icon': 'translate', 'name': 'translate', 'category': 'knowledge'},
    {'icon': 'certificate', 'name': 'certificate', 'category': 'knowledge'},
    {'icon': 'exam', 'name': 'exam', 'category': 'knowledge'},
    {'icon': 'pencil', 'name': 'pencil', 'category': 'knowledge'},
    
    // Creative & Arts
    {'icon': 'palette', 'name': 'palette', 'category': 'creative'},
    {'icon': 'paint-brush', 'name': 'paintbrush', 'category': 'creative'},
    {'icon': 'camera', 'name': 'camera', 'category': 'creative'},
    {'icon': 'music-note', 'name': 'music note', 'category': 'creative'},
    {'icon': 'film-strip', 'name': 'film strip', 'category': 'creative'},
    {'icon': 'pen', 'name': 'pen', 'category': 'creative'},
    {'icon': 'microphone', 'name': 'microphone', 'category': 'creative'},
    {'icon': 'guitar', 'name': 'guitar', 'category': 'creative'},
    {'icon': 'piano-keys', 'name': 'piano', 'category': 'creative'},
    {'icon': 'headphones', 'name': 'headphones', 'category': 'creative'},
    {'icon': 'speaker-high', 'name': 'speaker', 'category': 'creative'},
    {'icon': 'vinyl-record', 'name': 'vinyl', 'category': 'creative'},
    {'icon': 'video-camera', 'name': 'video camera', 'category': 'creative'},
    {'icon': 'image', 'name': 'image', 'category': 'creative'},
    {'icon': 'sketch-logo', 'name': 'sketch', 'category': 'creative'},
    {'icon': 'design-system', 'name': 'design', 'category': 'creative'},
    {'icon': 'color-palette', 'name': 'colors', 'category': 'creative'},
    {'icon': 'scissors', 'name': 'scissors', 'category': 'creative'},
    
    // Communication & Social
    {'icon': 'chat-circle', 'name': 'chat circle', 'category': 'social'},
    {'icon': 'envelope', 'name': 'envelope', 'category': 'social'},
    {'icon': 'phone', 'name': 'phone', 'category': 'social'},
    {'icon': 'users', 'name': 'users', 'category': 'social'},
    {'icon': 'share', 'name': 'share', 'category': 'social'},
    {'icon': 'megaphone', 'name': 'megaphone', 'category': 'social'},
    {'icon': 'video', 'name': 'video', 'category': 'social'},
    {'icon': 'chat-text', 'name': 'chat text', 'category': 'social'},
    {'icon': 'at', 'name': 'at symbol', 'category': 'social'},
    {'icon': 'hash', 'name': 'hashtag', 'category': 'social'},
    {'icon': 'thumbs-up', 'name': 'thumbs up', 'category': 'social'},
    {'icon': 'thumbs-down', 'name': 'thumbs down', 'category': 'social'},
    {'icon': 'handshake', 'name': 'handshake', 'category': 'social'},
    {'icon': 'user-circle', 'name': 'user circle', 'category': 'social'},
    {'icon': 'crown', 'name': 'crown', 'category': 'social'},
    {'icon': 'smiley', 'name': 'smiley', 'category': 'social'},
    
    // Travel & Adventure
    {'icon': 'airplane', 'name': 'airplane', 'category': 'travel'},
    {'icon': 'map-pin', 'name': 'map pin', 'category': 'travel'},
    {'icon': 'compass', 'name': 'compass', 'category': 'travel'},
    {'icon': 'globe', 'name': 'globe', 'category': 'travel'},
    {'icon': 'suitcase', 'name': 'suitcase', 'category': 'travel'},
    {'icon': 'train', 'name': 'train', 'category': 'travel'},
    {'icon': 'bus', 'name': 'bus', 'category': 'travel'},
    {'icon': 'taxi', 'name': 'taxi', 'category': 'travel'},
    {'icon': 'ship', 'name': 'ship', 'category': 'travel'},
    {'icon': 'anchor', 'name': 'anchor', 'category': 'travel'},
    {'icon': 'passport', 'name': 'passport', 'category': 'travel'},
    {'icon': 'ticket', 'name': 'ticket', 'category': 'travel'},
    {'icon': 'mountains', 'name': 'mountains', 'category': 'travel'},
    {'icon': 'tent', 'name': 'tent', 'category': 'travel'},
    {'icon': 'campfire', 'name': 'campfire', 'category': 'travel'},
    {'icon': 'binoculars', 'name': 'binoculars', 'category': 'travel'},
    {'icon': 'backpack', 'name': 'backpack', 'category': 'travel'},
    {'icon': 'road-horizon', 'name': 'road', 'category': 'travel'},
    
    // Tools & Crafting
    {'icon': 'hammer', 'name': 'hammer', 'category': 'tools'},
    {'icon': 'wrench', 'name': 'wrench', 'category': 'tools'},
    {'icon': 'screwdriver', 'name': 'screwdriver', 'category': 'tools'},
    {'icon': 'toolbox', 'name': 'toolbox', 'category': 'tools'},
    {'icon': 'ruler', 'name': 'ruler', 'category': 'tools'},
    {'icon': 'scissors', 'name': 'scissors', 'category': 'tools'},
    {'icon': 'knife', 'name': 'knife', 'category': 'tools'},
    {'icon': 'gear', 'name': 'saw', 'category': 'tools'},
    {'icon': 'gear', 'name': 'drill', 'category': 'tools'},
    {'icon': 'magnet', 'name': 'magnet', 'category': 'tools'},
    {'icon': 'nut', 'name': 'nut', 'category': 'tools'},
    {'icon': 'gear', 'name': 'screw', 'category': 'tools'},
    {'icon': 'gear', 'name': 'pliers', 'category': 'tools'},
    {'icon': 'ruler', 'name': 'level', 'category': 'tools'},
    {'icon': 'tape-measure', 'name': 'tape measure', 'category': 'tools'},
    {'icon': 'hard-hat', 'name': 'hard hat', 'category': 'tools'},
    
    // Nature & Environment
    {'icon': 'tree', 'name': 'tree', 'category': 'nature'},
    {'icon': 'leaf', 'name': 'leaf', 'category': 'nature'},
    {'icon': 'sun', 'name': 'sun', 'category': 'nature'},
    {'icon': 'moon', 'name': 'moon', 'category': 'nature'},
    {'icon': 'lightning', 'name': 'lightning', 'category': 'nature'},
    {'icon': 'fire', 'name': 'fire', 'category': 'nature'},
    {'icon': 'flower', 'name': 'flower', 'category': 'nature'},
    {'icon': 'plant', 'name': 'plant', 'category': 'nature'},
    {'icon': 'cloud-rain', 'name': 'rain', 'category': 'nature'},
    {'icon': 'cloud-snow', 'name': 'snow', 'category': 'nature'},
    {'icon': 'wind', 'name': 'wind', 'category': 'nature'},
    {'icon': 'waves', 'name': 'wave', 'category': 'nature'},
    {'icon': 'drop', 'name': 'drop', 'category': 'nature'},
    {'icon': 'butterfly', 'name': 'butterfly', 'category': 'nature'},
    {'icon': 'bird', 'name': 'bird', 'category': 'nature'},
    {'icon': 'fish', 'name': 'fish', 'category': 'nature'},
    {'icon': 'paw-print', 'name': 'paw print', 'category': 'nature'},
    {'icon': 'mountains', 'name': 'mountains', 'category': 'nature'},
    
    // Food & Cooking
    {'icon': 'fork-knife', 'name': 'fork knife', 'category': 'food'},
    {'icon': 'chef-hat', 'name': 'chef hat', 'category': 'food'},
    {'icon': 'coffee', 'name': 'coffee', 'category': 'food'},
    {'icon': 'wine', 'name': 'wine', 'category': 'food'},
    {'icon': 'pizza', 'name': 'pizza', 'category': 'food'},
    {'icon': 'cooking-pot', 'name': 'cooking pot', 'category': 'food'},
    {'icon': 'hamburger', 'name': 'hamburger', 'category': 'food'},
    {'icon': 'ice-cream', 'name': 'ice cream', 'category': 'food'},
    {'icon': 'cake', 'name': 'cake', 'category': 'food'},
    {'icon': 'cookie', 'name': 'cookie', 'category': 'food'},
    {'icon': 'bread', 'name': 'bread', 'category': 'food'},
    {'icon': 'carrot', 'name': 'carrot', 'category': 'food'},
    {'icon': 'martini', 'name': 'martini', 'category': 'food'},
    {'icon': 'wine', 'name': 'beer', 'category': 'food'},
    {'icon': 'cooking-pot', 'name': 'bowl', 'category': 'food'},
    {'icon': 'egg', 'name': 'egg', 'category': 'food'},
    {'icon': 'fish', 'name': 'fish', 'category': 'food'},
    {'icon': 'pepper', 'name': 'pepper', 'category': 'food'},
    
    // Home & Life
    {'icon': 'house', 'name': 'house', 'category': 'home'},
    {'icon': 'bed', 'name': 'bed', 'category': 'home'},
    {'icon': 'shower', 'name': 'shower', 'category': 'home'},
    {'icon': 'car', 'name': 'car', 'category': 'home'},
    {'icon': 'key', 'name': 'key', 'category': 'home'},
    {'icon': 'lock', 'name': 'lock', 'category': 'home'},
    {'icon': 'door', 'name': 'door', 'category': 'home'},
    {'icon': 'armchair', 'name': 'armchair', 'category': 'home'},
    {'icon': 'television', 'name': 'television', 'category': 'home'},
    {'icon': 'washing-machine', 'name': 'washing machine', 'category': 'home'},
    {'icon': 'oven', 'name': 'oven', 'category': 'home'},
    {'icon': 'house', 'name': 'refrigerator', 'category': 'home'},
    {'icon': 'broom', 'name': 'vacuum', 'category': 'home'},
    {'icon': 'broom', 'name': 'broom', 'category': 'home'},
    {'icon': 'toilet-paper', 'name': 'toilet paper', 'category': 'home'},
    {'icon': 'bathtub', 'name': 'bathtub', 'category': 'home'},
    {'icon': 'garage', 'name': 'garage', 'category': 'home'},
    {'icon': 'garden', 'name': 'garden', 'category': 'home'},
    
    // Entertainment & Games
    {'icon': 'game-controller', 'name': 'game controller', 'category': 'entertainment'},
    {'icon': 'dice-one', 'name': 'dice', 'category': 'entertainment'},
    {'icon': 'cards', 'name': 'cards', 'category': 'entertainment'},
    {'icon': 'squares-four', 'name': 'chess', 'category': 'entertainment'},
    {'icon': 'puzzle-piece', 'name': 'puzzle', 'category': 'entertainment'},
    {'icon': 'joystick', 'name': 'joystick', 'category': 'entertainment'},
    {'icon': 'magic-wand', 'name': 'magic wand', 'category': 'entertainment'},
    {'icon': 'balloon', 'name': 'balloon', 'category': 'entertainment'},
    {'icon': 'confetti', 'name': 'confetti', 'category': 'entertainment'},
    {'icon': 'party-popper', 'name': 'party', 'category': 'entertainment'},
    {'icon': 'gift', 'name': 'gift', 'category': 'entertainment'},
    {'icon': 'ticket', 'name': 'ticket', 'category': 'entertainment'},
    {'icon': 'popcorn', 'name': 'popcorn', 'category': 'entertainment'},
    {'icon': 'mask-happy', 'name': 'mask happy', 'category': 'entertainment'},
    {'icon': 'sparkle', 'name': 'fireworks', 'category': 'entertainment'},
    
    // Shopping & Fashion
    {'icon': 'shopping-cart', 'name': 'shopping cart', 'category': 'shopping'},
    {'icon': 'shopping-bag', 'name': 'shopping bag', 'category': 'shopping'},
    {'icon': 'handbag', 'name': 'handbag', 'category': 'shopping'},
    {'icon': 'dress', 'name': 'dress', 'category': 'shopping'},
    {'icon': 't-shirt', 'name': 't-shirt', 'category': 'shopping'},
    {'icon': 'pants', 'name': 'pants', 'category': 'shopping'},
    {'icon': 'sneaker', 'name': 'sneaker', 'category': 'shopping'},
    {'icon': 'high-heel', 'name': 'high heel', 'category': 'shopping'},
    {'icon': 'eyeglasses', 'name': 'eyeglasses', 'category': 'shopping'},
    {'icon': 'sunglasses', 'name': 'sunglasses', 'category': 'shopping'},
    {'icon': 'watch', 'name': 'watch', 'category': 'shopping'},
    {'icon': 'diamond', 'name': 'ring', 'category': 'shopping'},
    {'icon': 'diamond', 'name': 'necklace', 'category': 'shopping'},
    {'icon': 'baseball-cap', 'name': 'hat', 'category': 'shopping'},
    {'icon': 'baseball-cap', 'name': 'baseball cap', 'category': 'shopping'},
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

  // Helper function to get PhosphorIcon from string name
  IconData _getPhosphorIcon(String iconName) {
    switch (iconName) {
      // Tasks & Goals
      case 'target': return PhosphorIcons.target();
      case 'check-circle': return PhosphorIcons.checkCircle();
      case 'flag': return PhosphorIcons.flag();
      case 'trophy': return PhosphorIcons.trophy();
      case 'medal': return PhosphorIcons.medal();
      case 'star': return PhosphorIcons.star();
      case 'check': return PhosphorIcons.check();
      case 'x': return PhosphorIcons.x();
      case 'clock': return PhosphorIcons.clock();
      case 'calendar': return PhosphorIcons.calendar();
      case 'bookmark': return PhosphorIcons.bookmark();
      case 'list': return PhosphorIcons.list();
      case 'note': return PhosphorIcons.note();
      case 'plus': return PhosphorIcons.plus();
      case 'minus': return PhosphorIcons.minus();
      
      // Business
      case 'briefcase': return PhosphorIcons.briefcase();
      case 'bank': return PhosphorIcons.bank();
      case 'chart-line': return PhosphorIcons.chartLine();
      case 'chart-bar': return PhosphorIcons.chartBar();
      case 'money': return PhosphorIcons.money();
      case 'diamond': return PhosphorIcons.diamond();
      case 'currency-dollar': return PhosphorIcons.currencyDollar();
      case 'currency-euro': return PhosphorIcons.currencyEur();
      case 'credit-card': return PhosphorIcons.creditCard();
      case 'calculator': return PhosphorIcons.calculator();
      case 'presentation-chart': return PhosphorIcons.presentationChart();
      case 'handshake': return PhosphorIcons.handshake();
      case 'building': return PhosphorIcons.building();
      case 'office-chair': return PhosphorIcons.officeChair();
      case 'receipt': return PhosphorIcons.receipt();
      case 'vault': return PhosphorIcons.vault();
      case 'coin': return PhosphorIcons.coin();
      case 'piggy-bank': return PhosphorIcons.piggyBank();
      
      // Technology
      case 'laptop': return PhosphorIcons.laptop();
      case 'monitor': return PhosphorIcons.monitor();
      case 'device-mobile': return PhosphorIcons.deviceMobile();
      case 'code': return PhosphorIcons.code();
      case 'terminal': return PhosphorIcons.terminal();
      case 'gear': return PhosphorIcons.gear();
      case 'database': return PhosphorIcons.database();
      case 'cloud': return PhosphorIcons.cloud();
      case 'wifi': return PhosphorIcons.wifiHigh();
      case 'bluetooth': return PhosphorIcons.bluetoothConnected();
      case 'usb': return PhosphorIcons.usb();
      case 'hard-drive': return PhosphorIcons.hardDrive();
      case 'cpu': return PhosphorIcons.cpu();
      case 'memory': return PhosphorIcons.memory();
      case 'circuit-board': return PhosphorIcons.gear();
      case 'network': return PhosphorIcons.network();
      case 'browser': return PhosphorIcons.browser();
      case 'bug': return PhosphorIcons.bug();
      case 'git-branch': return PhosphorIcons.gitBranch();
      case 'github-logo': return PhosphorIcons.githubLogo();
      
      // Health & Fitness
      case 'heart': return PhosphorIcons.heart();
      case 'pulse': return PhosphorIcons.pulse();
      case 'bicycle': return PhosphorIcons.bicycle();
      case 'barbell': return PhosphorIcons.barbell();
      case 'person-simple-run': return PhosphorIcons.personSimpleRun();
      case 'apple-logo': return PhosphorIcons.appleLogo();
      case 'person-simple-walk': return PhosphorIcons.personSimpleWalk();
      case 'person-simple-swim': return PhosphorIcons.personSimpleSwim();
      case 'person-simple-bike': return PhosphorIcons.personSimpleBike();
      case 'person': return PhosphorIcons.person();
      case 'basketball': return PhosphorIcons.basketball();
      case 'soccer-ball': return PhosphorIcons.soccerBall();
      case 'tennis-ball': return PhosphorIcons.basketball();
      case 'barbell': return PhosphorIcons.barbell();
      case 'pill': return PhosphorIcons.pill();
      case 'first-aid': return PhosphorIcons.firstAid();
      case 'thermometer': return PhosphorIcons.thermometer();
      case 'tooth': return PhosphorIcons.tooth();
      
      // Knowledge & Learning
      case 'book': return PhosphorIcons.book();
      case 'books': return PhosphorIcons.books();
      case 'brain': return PhosphorIcons.brain();
      case 'lightbulb': return PhosphorIcons.lightbulb();
      case 'graduation-cap': return PhosphorIcons.graduationCap();
      case 'microscope': return PhosphorIcons.microscope();
      case 'student': return PhosphorIcons.student();
      case 'teacher': return PhosphorIcons.chalkboardTeacher();
      case 'chalkboard': return PhosphorIcons.chalkboard();
      case 'test-tube': return PhosphorIcons.testTube();
      case 'atom': return PhosphorIcons.atom();
      case 'dna': return PhosphorIcons.dna();
      case 'flask': return PhosphorIcons.flask();
      case 'math-operations': return PhosphorIcons.mathOperations();
      case 'translate': return PhosphorIcons.translate();
      case 'certificate': return PhosphorIcons.certificate();
      case 'exam': return PhosphorIcons.exam();
      case 'pencil': return PhosphorIcons.pencil();
      
      // Creative & Arts
      case 'palette': return PhosphorIcons.palette();
      case 'paint-brush': return PhosphorIcons.paintBrush();
      case 'camera': return PhosphorIcons.camera();
      case 'music-note': return PhosphorIcons.musicNote();
      case 'film-strip': return PhosphorIcons.filmStrip();
      case 'pen': return PhosphorIcons.pen();
      case 'microphone': return PhosphorIcons.microphone();
      case 'guitar': return PhosphorIcons.guitar();
      case 'piano-keys': return PhosphorIcons.pianoKeys();
      case 'headphones': return PhosphorIcons.headphones();
      case 'speaker-high': return PhosphorIcons.speakerHigh();
      case 'vinyl-record': return PhosphorIcons.vinylRecord();
      case 'video-camera': return PhosphorIcons.videoCamera();
      case 'image': return PhosphorIcons.image();
      case 'sketch-logo': return PhosphorIcons.sketchLogo();
      case 'design-system': return PhosphorIcons.selection();
      case 'color-palette': return PhosphorIcons.palette();
      case 'scissors': return PhosphorIcons.scissors();
      
      // Communication & Social
      case 'chat-circle': return PhosphorIcons.chatCircle();
      case 'envelope': return PhosphorIcons.envelope();
      case 'phone': return PhosphorIcons.phone();
      case 'users': return PhosphorIcons.users();
      case 'share': return PhosphorIcons.share();
      case 'megaphone': return PhosphorIcons.megaphone();
      case 'video': return PhosphorIcons.videoCamera();
      case 'chat-text': return PhosphorIcons.chatText();
      case 'at': return PhosphorIcons.at();
      case 'hash': return PhosphorIcons.hash();
      case 'thumbs-up': return PhosphorIcons.thumbsUp();
      case 'thumbs-down': return PhosphorIcons.thumbsDown();
      case 'user-circle': return PhosphorIcons.userCircle();
      case 'crown': return PhosphorIcons.crown();
      case 'smiley': return PhosphorIcons.smiley();
      
      // Travel & Adventure
      case 'airplane': return PhosphorIcons.airplane();
      case 'map-pin': return PhosphorIcons.mapPin();
      case 'compass': return PhosphorIcons.compass();
      case 'globe': return PhosphorIcons.globe();
      case 'suitcase': return PhosphorIcons.suitcase();
      case 'train': return PhosphorIcons.train();
      case 'bus': return PhosphorIcons.bus();
      case 'taxi': return PhosphorIcons.taxi();
      case 'ship': return PhosphorIcons.boat();
      case 'anchor': return PhosphorIcons.anchor();
      case 'passport': return PhosphorIcons.identificationCard();
      case 'ticket': return PhosphorIcons.ticket();
      case 'mountains': return PhosphorIcons.mountains();
      case 'tent': return PhosphorIcons.tent();
      case 'campfire': return PhosphorIcons.campfire();
      case 'binoculars': return PhosphorIcons.binoculars();
      case 'backpack': return PhosphorIcons.backpack();
      case 'road-horizon': return PhosphorIcons.roadHorizon();
      
      // Tools & Crafting
      case 'hammer': return PhosphorIcons.hammer();
      case 'wrench': return PhosphorIcons.wrench();
      case 'screwdriver': return PhosphorIcons.screwdriver();
      case 'toolbox': return PhosphorIcons.toolbox();
      case 'ruler': return PhosphorIcons.ruler();
      case 'knife': return PhosphorIcons.knife();
      case 'gear': return PhosphorIcons.gear();
      case 'gear': return PhosphorIcons.gear();
      case 'magnet': return PhosphorIcons.magnet();
      case 'nut': return PhosphorIcons.nut();
      case 'gear': return PhosphorIcons.gear();
      case 'gear': return PhosphorIcons.gear();
      case 'ruler': return PhosphorIcons.ruler();
      case 'tape-measure': return PhosphorIcons.ruler();
      case 'hard-hat': return PhosphorIcons.hardHat();
      
      // Nature & Environment
      case 'tree': return PhosphorIcons.tree();
      case 'leaf': return PhosphorIcons.leaf();
      case 'sun': return PhosphorIcons.sun();
      case 'moon': return PhosphorIcons.moon();
      case 'lightning': return PhosphorIcons.lightning();
      case 'fire': return PhosphorIcons.fire();
      case 'flower': return PhosphorIcons.flower();
      case 'plant': return PhosphorIcons.plant();
      case 'cloud-rain': return PhosphorIcons.cloudRain();
      case 'cloud-snow': return PhosphorIcons.cloudSnow();
      case 'wind': return PhosphorIcons.wind();
      case 'waves': return PhosphorIcons.waves();
      case 'drop': return PhosphorIcons.drop();
      case 'butterfly': return PhosphorIcons.butterfly();
      case 'bird': return PhosphorIcons.bird();
      case 'fish': return PhosphorIcons.fish();
      case 'paw-print': return PhosphorIcons.pawPrint();
      
      // Food & Cooking
      case 'fork-knife': return PhosphorIcons.forkKnife();
      case 'chef-hat': return PhosphorIcons.chefHat();
      case 'coffee': return PhosphorIcons.coffee();
      case 'wine': return PhosphorIcons.wine();
      case 'pizza': return PhosphorIcons.pizza();
      case 'cooking-pot': return PhosphorIcons.cookingPot();
      case 'hamburger': return PhosphorIcons.hamburger();
      case 'ice-cream': return PhosphorIcons.iceCream();
      case 'cake': return PhosphorIcons.cake();
      case 'cookie': return PhosphorIcons.cookie();
      case 'bread': return PhosphorIcons.bread();
      case 'carrot': return PhosphorIcons.carrot();
      case 'martini': return PhosphorIcons.martini();
      case 'wine': return PhosphorIcons.wine();
      case 'cooking-pot': return PhosphorIcons.cookingPot();
      case 'egg': return PhosphorIcons.egg();
      case 'pepper': return PhosphorIcons.pepper();
      
      // Home & Life
      case 'house': return PhosphorIcons.house();
      case 'bed': return PhosphorIcons.bed();
      case 'shower': return PhosphorIcons.shower();
      case 'car': return PhosphorIcons.car();
      case 'key': return PhosphorIcons.key();
      case 'lock': return PhosphorIcons.lock();
      case 'door': return PhosphorIcons.door();
      case 'armchair': return PhosphorIcons.armchair();
      case 'television': return PhosphorIcons.television();
      case 'washing-machine': return PhosphorIcons.washingMachine();
      case 'oven': return PhosphorIcons.oven();
      case 'house': return PhosphorIcons.house();
      case 'broom': return PhosphorIcons.broom();
      case 'broom': return PhosphorIcons.broom();
      case 'toilet-paper': return PhosphorIcons.toiletPaper();
      case 'bathtub': return PhosphorIcons.bathtub();
      case 'garage': return PhosphorIcons.garage();
      case 'garden': return PhosphorIcons.flower();
      
      // Entertainment & Games
      case 'game-controller': return PhosphorIcons.gameController();
      case 'dice-one': return PhosphorIcons.diceOne();
      case 'cards': return PhosphorIcons.cards();
      case 'squares-four': return PhosphorIcons.squaresFour();
      case 'puzzle-piece': return PhosphorIcons.puzzlePiece();
      case 'joystick': return PhosphorIcons.joystick();
      case 'magic-wand': return PhosphorIcons.magicWand();
      case 'balloon': return PhosphorIcons.balloon();
      case 'confetti': return PhosphorIcons.confetti();
      case 'party-popper': return PhosphorIcons.confetti();
      case 'gift': return PhosphorIcons.gift();
      case 'popcorn': return PhosphorIcons.popcorn();
      case 'mask-happy': return PhosphorIcons.maskHappy();
      case 'sparkle': return PhosphorIcons.sparkle();
      
      // Shopping & Fashion
      case 'shopping-cart': return PhosphorIcons.shoppingCart();
      case 'shopping-bag': return PhosphorIcons.shoppingBag();
      case 'handbag': return PhosphorIcons.handbag();
      case 'dress': return PhosphorIcons.dress();
      case 't-shirt': return PhosphorIcons.tShirt();
      case 'pants': return PhosphorIcons.pants();
      case 'sneaker': return PhosphorIcons.sneaker();
      case 'high-heel': return PhosphorIcons.highHeel();
      case 'eyeglasses': return PhosphorIcons.eyeglasses();
      case 'sunglasses': return PhosphorIcons.sunglasses();
      case 'watch': return PhosphorIcons.watch();
      case 'diamond': return PhosphorIcons.diamond();
      case 'diamond': return PhosphorIcons.diamond();
      case 'baseball-cap': return PhosphorIcons.baseballCap();
      case 'baseball-cap': return PhosphorIcons.baseballCap();
      
      default: return PhosphorIcons.target(); // Default fallback
    }
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
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          // Search bar
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search icons (e.g., target, code, heart)...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: const Icon(Icons.search, color: Colors.white),
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[600]!),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      child: Icon(
                        _getPhosphorIcon(icon),
                        size: 24,
                        color: isSelected 
                          ? Theme.of(context).primaryColor
                          : Colors.white,
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
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
        ],
      ),
    );
  }
}