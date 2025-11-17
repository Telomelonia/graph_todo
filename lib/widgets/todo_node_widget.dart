import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/todo_node.dart';
import '../providers/canvas_provider.dart';
import '../theme/app_theme.dart';

class TodoNodeWidget extends StatefulWidget {
  final TodoNode node;

  const TodoNodeWidget({
    super.key,
    required this.node,
  });

  @override
  State<TodoNodeWidget> createState() => _TodoNodeWidgetState();
}

class _TodoNodeWidgetState extends State<TodoNodeWidget>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Setup glow animation for completion
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Setup pulsing animation for continuous glow effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start animations if node is completed
    if (widget.node.isCompleted) {
      _glowController.forward();
      _pulseController.repeat(reverse: true);
    }

    // Check if this is a newly created node that should open info panel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CanvasProvider>();
      if (provider.newlyCreatedNodeId == widget.node.id) {
        provider.showNodeInfo(widget.node.id);
        provider.clearNewlyCreatedFlag();
      }
    });
  }

  @override
  void didUpdateWidget(TodoNodeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle completion animation
    if (widget.node.isCompleted != oldWidget.node.isCompleted) {
      if (widget.node.isCompleted) {
        _glowController.forward();
        _pulseController.repeat(reverse: true);
      } else {
        _glowController.reverse();
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();
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

  void _handleTap() {
    final provider = context.read<CanvasProvider>();
    
    // Prevent interactions when info panel is open
    if (provider.isInfoPanelOpen) return;

    // Handle special modes
    if (provider.isEraserMode) {
      provider.removeNode(widget.node.id);
      return;
    } else if (provider.isConnectMode) {
      provider.selectNodeForConnection(widget.node.id);
      return;
    }

    // In normal mode, toggle action buttons
    provider.toggleNodeActionButtons(widget.node.id);
  }

  void _handleCompletionTap() {
    final provider = context.read<CanvasProvider>();
    provider.toggleNodeCompletion(widget.node.id);
    provider.hideNodeActionButtons();
  }

  void _handleConnectorTap() {
    final provider = context.read<CanvasProvider>();
    provider.startConnectionFromNode(widget.node.id);
    provider.hideNodeActionButtons();
  }

  void _handleDeleteTap() {
    final provider = context.read<CanvasProvider>();
    provider.removeNode(widget.node.id);
  }

  void _handleInfoTap() {
    final provider = context.read<CanvasProvider>();
    provider.showNodeInfo(widget.node.id);
    provider.hideNodeActionButtons();
  }

  void _handleDoubleTap() {
    final provider = context.read<CanvasProvider>();
    if (!provider.isConnectMode && !provider.isEraserMode && !provider.isInfoPanelOpen) {
      // Open info panel for editing
      provider.showNodeInfo(widget.node.id);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<CanvasProvider>(
      builder: (context, provider, child) {
        // Convert canvas position to screen position
        final screenPosition = provider.canvasToScreen(widget.node.position);
        // Scale the node size based on canvas scale
        final scaledSize = widget.node.size * provider.scale;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Main node
            Positioned(
              left: screenPosition.dx - scaledSize / 2,
              top: screenPosition.dy - scaledSize / 2,
              child: GestureDetector(
                onTap: _handleTap,
                onDoubleTap: _handleDoubleTap,
                onPanStart: (details) {
                  context.read<CanvasProvider>().startDrag(widget.node);
                },
                onPanUpdate: (details) {
                  final provider = context.read<CanvasProvider>();
                  // Convert screen delta to canvas coordinates and update position
                  // Increased sensitivity for web platform mouse dragging
                  const sensitivity = kIsWeb ? 2.0 : 1.6;
                  final canvasDelta = (details.delta * sensitivity) / provider.scale;
                  final newPosition = widget.node.position + canvasDelta;
                  provider.updateNodePosition(widget.node.id, newPosition);
                },
                onPanEnd: (details) {
                  context.read<CanvasProvider>().endDrag();
                },
                child: AnimatedBuilder(
                  animation: Listenable.merge([_glowAnimation, _pulseAnimation]),
                  builder: (context, child) {
                    return Container(
                      width: scaledSize,
                      height: scaledSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.node.isCompleted 
                          ? widget.node.color.withValues(alpha: 0.95)
                          : widget.node.color.withValues(alpha: 0.9),
                        border: Border.all(
                          color: _getSelectionColor(),
                          width: _getSelectionWidth() * provider.scale,
                        ),
                        boxShadow: _buildShadows(provider.scale),
                        gradient: widget.node.isCompleted ? RadialGradient(
                          colors: [
                            widget.node.color.withValues(alpha: 1.0),
                            widget.node.color.withValues(alpha: 0.7),
                            widget.node.color.withValues(alpha: 0.9),
                          ],
                          stops: const [0.0, 0.7, 1.0],
                        ) : null,
                      ),
                      child: _buildContent(provider.scale),
                    );
                  },
                ),
              ),
            ),
            // Action buttons (separate from node gesture detector)
            if (provider.nodeWithActiveButtons == widget.node.id)
              ..._buildActionButtons(screenPosition.dx, screenPosition.dy, scaledSize, provider.scale),
          ],
        );
      },
    );
  }

  Color _getSelectionColor() {
    final provider = context.watch<CanvasProvider>();

    if (provider.selectedNodeForConnection == widget.node.id) {
      return AppTheme.getSelectionColor(provider.isDarkMode);
    } else if (provider.isEraserMode) {
      return AppTheme.getEraserColor(provider.isDarkMode);
    } else if (provider.isConnectMode) {
      return AppTheme.getConnectModeColor(provider.isDarkMode);
    } else {
      return Colors.transparent;
    }
  }

  double _getSelectionWidth() {
    final provider = context.watch<CanvasProvider>();

    if (provider.selectedNodeForConnection == widget.node.id) {
      return 3.0;
    } else if (provider.isEraserMode) {
      return 2.5;
    } else if (provider.isConnectMode) {
      return 2.0;
    } else {
      return 0.0;
    }
  }

  List<BoxShadow> _buildShadows(double scale) {
    final provider = context.watch<CanvasProvider>();
    List<BoxShadow> shadows = AppTheme.getNodeShadow(provider.isDarkMode, scale);

    // Add dramatic glow effects when completed
    if (widget.node.isCompleted) {
      final pulseValue = _pulseAnimation.value;
      final glowValue = _glowAnimation.value;
      
      // Inner bright glow
      shadows.add(
        BoxShadow(
          color: Colors.greenAccent.withValues(alpha: 0.8 * glowValue * pulseValue),
          blurRadius: 15.0 * scale * glowValue,
          spreadRadius: 3.0 * scale * glowValue,
        ),
      );
      
      // Middle glow layer
      shadows.add(
        BoxShadow(
          color: Colors.green.withValues(alpha: 0.6 * glowValue * pulseValue),
          blurRadius: 30.0 * scale * glowValue * pulseValue,
          spreadRadius: 8.0 * scale * glowValue,
        ),
      );
      
      // Outer dramatic glow
      shadows.add(
        BoxShadow(
          color: Colors.lightGreen.withValues(alpha: 0.4 * glowValue * pulseValue),
          blurRadius: 50.0 * scale * glowValue * pulseValue,
          spreadRadius: 15.0 * scale * glowValue * pulseValue,
        ),
      );
      
      // Subtle white highlight for sparkle effect
      shadows.add(
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.3 * glowValue * pulseValue),
          blurRadius: 8.0 * scale * glowValue,
          spreadRadius: 1.0 * scale * glowValue,
        ),
      );
    }

    return shadows;
  }

  Widget _buildContent(double scale) {
    return Stack(
      children: [
        // Main icon display
        Center(
          child: widget.node.isCompleted
            ? AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (0.1 * _pulseAnimation.value * _glowAnimation.value),
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.9),
                            Colors.greenAccent.withValues(alpha: 0.7),
                          ],
                        ).createShader(bounds);
                      },
                      child: Icon(
                        _getPhosphorIcon(widget.node.icon),
                        size: 48 * scale.clamp(0.5, 1.2),
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.white.withValues(alpha: 0.5 * _pulseAnimation.value),
                            blurRadius: 8.0 * _pulseAnimation.value,
                          ),
                          Shadow(
                            color: Colors.greenAccent.withValues(alpha: 0.3 * _pulseAnimation.value),
                            blurRadius: 12.0 * _pulseAnimation.value,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            : Icon(
                _getPhosphorIcon(widget.node.icon),
                size: 48 * scale.clamp(0.5, 1.2),
                color: Colors.white,
              ),
        ),
        // Checkmark overlay for completed tasks
        if (widget.node.isCompleted)
          Positioned(
            right: 4,
            top: 4,
            child: FadeTransition(
              opacity: _glowAnimation,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildActionButtons(double centerX, double centerY, double scaledSize, double scale) {
    final buttonSize = 32.0 * scale.clamp(0.8, 1.5);
    final radius = scaledSize / 2 + buttonSize + 8;
    
    // Define button positions around the node (top, right, bottom, left)
    final buttonPositions = [
      {'offset': Offset(0, -radius), 'icon': widget.node.isCompleted ? Icons.refresh : Icons.check, 'color': widget.node.isCompleted ? Colors.orange : Colors.green, 'onTap': _handleCompletionTap},
      {'offset': Offset(radius, 0), 'icon': Icons.link, 'color': Colors.purple, 'onTap': _handleConnectorTap},
      {'offset': Offset(0, radius), 'icon': Icons.delete, 'color': Colors.red, 'onTap': _handleDeleteTap},
      {'offset': Offset(-radius, 0), 'icon': Icons.info, 'color': Colors.blue, 'onTap': _handleInfoTap},
    ];

    return buttonPositions.asMap().entries.map((entry) {
      final index = entry.key;
      final buttonData = entry.value;
      final offset = buttonData['offset'] as Offset;
      final icon = buttonData['icon'] as IconData;
      final color = buttonData['color'] as Color;
      final onTap = buttonData['onTap'] as VoidCallback;
      
      return Positioned(
        left: centerX + offset.dx - buttonSize / 2,
        top: centerY + offset.dy - buttonSize / 2,
        child: AnimatedScale(
          scale: 1.0,
          duration: Duration(milliseconds: 300 + (index * 75)),
          curve: Curves.elasticOut,
          child: AnimatedOpacity(
            opacity: 1.0,
            duration: Duration(milliseconds: 200 + (index * 50)),
            curve: Curves.easeOut,
            child: GestureDetector(
              onTap: onTap,
              child: Consumer<CanvasProvider>(
                builder: (context, provider, child) => Container(
                  width: buttonSize,
                  height: buttonSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.9),
                    border: Border.all(
                      color: AppTheme.getActionButtonBorder(provider.isDarkMode),
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8.0,
                        offset: const Offset(0, 2),
                      ),
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 12.0,
                        spreadRadius: 2.0,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: buttonSize * 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}