import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/todo_node.dart';
import '../providers/canvas_provider.dart';
import '../theme/app_theme.dart';
import 'icon_selector_widget.dart';

class InfoPanelWidget extends StatefulWidget {
  final TodoNode node;

  const InfoPanelWidget({
    super.key,
    required this.node,
  });

  @override
  State<InfoPanelWidget> createState() => _InfoPanelWidgetState();
}

class _InfoPanelWidgetState extends State<InfoPanelWidget> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late Color _selectedColor;
  late String _selectedIcon;

  // Predefined color options
  final List<Color> _colorOptions = [
    const Color(0xFF6366F1), // Indigo (default)
    const Color(0xFFEF4444), // Red
    const Color(0xFF10B981), // Green
    const Color(0xFFF59E0B), // Yellow
    const Color(0xFF3B82F6), // Blue
    const Color(0xFF8B5CF6), // Purple
    const Color(0xFFEC4899), // Pink
    const Color(0xFFF97316), // Orange
    const Color(0xFF06B6D4), // Cyan
    const Color(0xFF84CC16), // Lime
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.node.text);
    _descriptionController = TextEditingController(text: widget.node.description);
    _selectedColor = widget.node.color;
    _selectedIcon = widget.node.icon;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
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
      case 'broom': return PhosphorIcons.broom();
      case 'toilet-paper': return PhosphorIcons.toiletPaper();
      case 'bathtub': return PhosphorIcons.bathtub();
      case 'garage': return PhosphorIcons.garage();
      case 'garden': return PhosphorIcons.flower();
      
      default: return PhosphorIcons.target(); // Default fallback
    }
  }

  void _saveChanges() {
    final provider = context.read<CanvasProvider>();
    
    // Update title if changed
    if (_titleController.text != widget.node.text) {
      provider.updateNodeText(widget.node.id, _titleController.text.trim().isEmpty ? 'New Task' : _titleController.text);
    }
    
    // Update description if changed
    if (_descriptionController.text != widget.node.description) {
      provider.updateNodeDescription(widget.node.id, _descriptionController.text);
    }
    
    // Update icon if changed
    if (_selectedIcon != widget.node.icon) {
      provider.updateNodeIcon(widget.node.id, _selectedIcon);
    }
    
    // Update color if changed
    if (_selectedColor != widget.node.color) {
      provider.updateNodeColor(widget.node.id, _selectedColor);
    }
    
    // Close the panel
    provider.hideNodeInfo();
  }

  void _showIconSelector() {
    final provider = context.read<CanvasProvider>();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.getIconSelectorBackground(provider.isDarkMode),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconSelectorWidget(
          currentIcon: _selectedIcon,
          onIconSelected: (icon) {
            setState(() {
              _selectedIcon = icon;
            });
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CanvasProvider>();
    final screenSize = MediaQuery.of(context).size;
    
    // Calculate responsive panel dimensions
    final panelWidth = (screenSize.width * 0.85).clamp(280.0, 400.0);
    final panelHeight = (screenSize.height * 0.7).clamp(300.0, 500.0);
    
    // Calculate ideal positions to center both node and panel in view
    final screenCenter = Offset(screenSize.width / 2, screenSize.height / 2);
    
    // For mobile screens (narrow), position panel below the centered node
    // For larger screens, position panel to the side
    final isMobile = screenSize.width < 600;
    
    late double panelLeft;
    late double panelTop;
    late double targetScale;
    late Offset nodeTargetPosition;
    
    if (isMobile) {
      // Mobile layout: node at top center, panel below
      targetScale = 1.2;
      nodeTargetPosition = Offset(screenCenter.dx, screenSize.height * 0.25);
      panelLeft = (screenSize.width - panelWidth) / 2;
      panelTop = screenSize.height * 0.45;
    } else {
      // Desktop layout: node on left, panel on right, both centered vertically
      targetScale = 1.5;
      nodeTargetPosition = Offset(screenSize.width * 0.3, screenCenter.dy);
      panelLeft = screenSize.width * 0.55;
      panelTop = (screenSize.height - panelHeight) / 2;
      
      // Ensure panel doesn't go off screen
      if (panelLeft + panelWidth > screenSize.width - 20) {
        panelLeft = screenSize.width - panelWidth - 20;
      }
    }
    
    // Ensure panel fits on screen
    panelLeft = panelLeft.clamp(20.0, screenSize.width - panelWidth - 20);
    panelTop = panelTop.clamp(20.0, screenSize.height - panelHeight - 20);
    
    // Auto-adjust view to center node and panel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetPanOffset = nodeTargetPosition - (widget.node.position * targetScale);
      if ((provider.panOffset - targetPanOffset).distance > 10 || 
          (provider.scale - targetScale).abs() > 0.1) {
        provider.updatePanOffset(targetPanOffset - provider.panOffset);
        provider.updateScale(targetScale);
      }
    });

    return Positioned(
      left: panelLeft,
      top: panelTop,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: panelWidth,
          height: panelHeight,
          decoration: BoxDecoration(
            color: AppTheme.getSurfaceColor(provider.isDarkMode),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.getBorderColor(provider.isDarkMode)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.getInfoPanelHeaderBackground(provider.isDarkMode),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.getTextColor(provider.isDarkMode),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.node.text.isEmpty ? 'New Task' : widget.node.text,
                        style: TextStyle(
                          color: AppTheme.getTextColor(provider.isDarkMode),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => provider.hideNodeInfo(),
                      icon: const Icon(Icons.close),
                      iconSize: 18,
                      color: AppTheme.getTextSecondaryColor(provider.isDarkMode),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title field
                      Text(
                        'Title:',
                        style: TextStyle(
                          color: AppTheme.getTextSecondaryColor(provider.isDarkMode),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _titleController,
                        style: TextStyle(
                          color: AppTheme.getTextColor(provider.isDarkMode),
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter task title...',
                          hintStyle: TextStyle(
                            color: AppTheme.getTextHintColor(provider.isDarkMode),
                            fontSize: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppTheme.getBorderColor(provider.isDarkMode)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          filled: true,
                          fillColor: AppTheme.getInfoPanelFieldBackground(provider.isDarkMode),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Icon selector
                      Row(
                        children: [
                          Text(
                            'Icon:',
                            style: TextStyle(
                              color: AppTheme.getTextSecondaryColor(provider.isDarkMode),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _showIconSelector(),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.getNodeBackgroundColor(_selectedColor, provider.isDarkMode),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: _selectedColor.withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getPhosphorIcon(_selectedIcon),
                                    size: 24,
                                    color: AppTheme.getNodeIconColor(provider.isDarkMode),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.edit,
                                    size: 14,
                                    color: AppTheme.getTextSecondaryColor(provider.isDarkMode),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Description field
                      Text(
                        'Description:',
                        style: TextStyle(
                          color: AppTheme.getTextSecondaryColor(provider.isDarkMode),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 4,
                        style: TextStyle(
                          color: AppTheme.getTextColor(provider.isDarkMode),
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Add a description...',
                          hintStyle: TextStyle(
                            color: AppTheme.getTextHintColor(provider.isDarkMode),
                            fontSize: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppTheme.getBorderColor(provider.isDarkMode)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
                          ),
                          contentPadding: const EdgeInsets.all(10),
                          filled: true,
                          fillColor: AppTheme.getInfoPanelFieldBackground(provider.isDarkMode),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Color picker
                      Text(
                        'Color:',
                        style: TextStyle(
                          color: AppTheme.getTextSecondaryColor(provider.isDarkMode),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _colorOptions.map((color) {
                          final isSelected = _selectedColor == color;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColor = color;
                              });
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? Colors.white : Colors.transparent,
                                  width: isSelected ? 2 : 0,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Colors.white.withValues(alpha: 0.3),
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Action buttons
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.getInfoPanelHeaderBackground(provider.isDarkMode).withValues(alpha: 0.3),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => provider.hideNodeInfo(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppTheme.getTextSecondaryColor(provider.isDarkMode),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}