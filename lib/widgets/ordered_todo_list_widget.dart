import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import '../providers/canvas_provider.dart';

class OrderedTodoListWidget extends StatelessWidget {
  const OrderedTodoListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CanvasProvider>(
      builder: (context, provider, child) {
        // Get all nodes with due dates and sort them
        final nodesWithDueDates = provider.nodes
            .where((node) => node.dueDate != null)
            .toList()
          ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

        return Dialog(
          backgroundColor: provider.isDarkMode
              ? const Color(0xFF2D2D2D)
              : const Color(0xFFF0F0F0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: provider.isDarkMode
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.5),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        PhosphorIcons.calendarCheck(),
                        color: provider.isDarkMode
                            ? Colors.white.withValues(alpha: 0.9)
                            : const Color(0xFF333333),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tasks by Due Date',
                          style: TextStyle(
                            color: provider.isDarkMode
                                ? Colors.white.withValues(alpha: 0.9)
                                : const Color(0xFF333333),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        iconSize: 20,
                        color: provider.isDarkMode
                            ? Colors.white.withValues(alpha: 0.7)
                            : const Color(0xFF666666),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: nodesWithDueDates.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                PhosphorIcons.calendar(),
                                size: 64,
                                color: provider.isDarkMode
                                    ? Colors.white.withValues(alpha: 0.3)
                                    : Colors.grey.withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No tasks with due dates',
                                style: TextStyle(
                                  color: provider.isDarkMode
                                      ? Colors.white.withValues(alpha: 0.5)
                                      : Colors.grey.withValues(alpha: 0.6),
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add due dates to your tasks to see them here',
                                style: TextStyle(
                                  color: provider.isDarkMode
                                      ? Colors.white.withValues(alpha: 0.4)
                                      : Colors.grey.withValues(alpha: 0.5),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: nodesWithDueDates.length,
                          itemBuilder: (context, index) {
                            final node = nodesWithDueDates[index];
                            final dueDate = node.dueDate!;
                            final now = DateTime.now();
                            final today = DateTime(now.year, now.month, now.day);
                            final dueDateNormalized = DateTime(dueDate.year, dueDate.month, dueDate.day);

                            final isOverdue = dueDateNormalized.isBefore(today) &&
                                !node.isCompleted;
                            final isDueToday = dueDateNormalized.isAtSameMomentAs(today);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: provider.isDarkMode
                                    ? Colors.black.withValues(alpha: 0.2)
                                    : Colors.white.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isOverdue
                                      ? (provider.isDarkMode
                                          ? Colors.red.withValues(alpha: 0.5)
                                          : const Color(0xFFFCA5A5))
                                      : isDueToday
                                          ? (provider.isDarkMode
                                              ? Colors.orange.withValues(alpha: 0.5)
                                              : const Color(0xFFFDBA74))
                                          : (provider.isDarkMode
                                              ? Colors.white.withValues(alpha: 0.2)
                                              : Colors.grey.withValues(alpha: 0.3)),
                                  width: isOverdue || isDueToday ? 2 : 1,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                leading: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: node.color.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    _getPhosphorIcon(node.icon),
                                    color: node.color,
                                    size: 24,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        node.text,
                                        style: TextStyle(
                                          color: provider.isDarkMode
                                              ? Colors.white.withValues(alpha: 0.9)
                                              : const Color(0xFF333333),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          decoration: node.isCompleted
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      ),
                                    ),
                                    if (node.isCompleted)
                                      Icon(
                                        PhosphorIcons.checkCircle(
                                            PhosphorIconsStyle.fill),
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (node.description.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        node.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: provider.isDarkMode
                                              ? Colors.white.withValues(alpha: 0.6)
                                              : const Color(0xFF666666),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          PhosphorIcons.calendar(),
                                          size: 14,
                                          color: isOverdue
                                              ? Colors.red
                                              : isDueToday
                                                  ? Colors.orange
                                                  : (provider.isDarkMode
                                                      ? Colors.white
                                                          .withValues(alpha: 0.5)
                                                      : const Color(0xFF999999)),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          DateFormat('MMM d, y').format(dueDate),
                                          style: TextStyle(
                                            color: isOverdue
                                                ? Colors.red
                                                : isDueToday
                                                    ? Colors.orange
                                                    : (provider.isDarkMode
                                                        ? Colors.white.withValues(
                                                            alpha: 0.5)
                                                        : const Color(0xFF999999)),
                                            fontSize: 13,
                                            fontWeight: isOverdue || isDueToday
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                        if (isOverdue) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red
                                                  .withValues(alpha: 0.2),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'OVERDUE',
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ] else if (isDueToday) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.orange
                                                  .withValues(alpha: 0.2),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'TODAY',
                                              style: TextStyle(
                                                color: Colors.orange,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    PhosphorIcons.eye(),
                                    color: provider.isDarkMode
                                        ? Colors.white.withValues(alpha: 0.6)
                                        : const Color(0xFF666666),
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    // Close the dialog
                                    Navigator.of(context).pop();
                                    // Show the node's info panel
                                    provider.showNodeInfo(node.id);
                                  },
                                  tooltip: 'View details',
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper function to get PhosphorIcon from string name
  IconData _getPhosphorIcon(String iconName) {
    switch (iconName) {
      // Tasks & Goals
      case 'target':
        return PhosphorIcons.target();
      case 'check-circle':
        return PhosphorIcons.checkCircle();
      case 'flag':
        return PhosphorIcons.flag();
      case 'trophy':
        return PhosphorIcons.trophy();
      case 'medal':
        return PhosphorIcons.medal();
      case 'star':
        return PhosphorIcons.star();
      case 'check':
        return PhosphorIcons.check();
      case 'x':
        return PhosphorIcons.x();
      case 'clock':
        return PhosphorIcons.clock();
      case 'calendar':
        return PhosphorIcons.calendar();
      case 'bookmark':
        return PhosphorIcons.bookmark();
      case 'list':
        return PhosphorIcons.list();
      case 'note':
        return PhosphorIcons.note();
      case 'plus':
        return PhosphorIcons.plus();
      case 'minus':
        return PhosphorIcons.minus();

      // Business
      case 'briefcase':
        return PhosphorIcons.briefcase();
      case 'bank':
        return PhosphorIcons.bank();
      case 'chart-line':
        return PhosphorIcons.chartLine();
      case 'chart-bar':
        return PhosphorIcons.chartBar();
      case 'money':
        return PhosphorIcons.money();
      case 'diamond':
        return PhosphorIcons.diamond();
      case 'currency-dollar':
        return PhosphorIcons.currencyDollar();
      case 'currency-euro':
        return PhosphorIcons.currencyEur();
      case 'credit-card':
        return PhosphorIcons.creditCard();
      case 'calculator':
        return PhosphorIcons.calculator();
      case 'presentation-chart':
        return PhosphorIcons.presentationChart();
      case 'handshake':
        return PhosphorIcons.handshake();
      case 'building':
        return PhosphorIcons.building();
      case 'office-chair':
        return PhosphorIcons.officeChair();
      case 'receipt':
        return PhosphorIcons.receipt();
      case 'vault':
        return PhosphorIcons.vault();
      case 'coin':
        return PhosphorIcons.coin();
      case 'piggy-bank':
        return PhosphorIcons.piggyBank();

      // Technology
      case 'laptop':
        return PhosphorIcons.laptop();
      case 'monitor':
        return PhosphorIcons.monitor();
      case 'device-mobile':
        return PhosphorIcons.deviceMobile();
      case 'code':
        return PhosphorIcons.code();
      case 'terminal':
        return PhosphorIcons.terminal();
      case 'gear':
        return PhosphorIcons.gear();
      case 'database':
        return PhosphorIcons.database();
      case 'cloud':
        return PhosphorIcons.cloud();
      case 'wifi':
        return PhosphorIcons.wifiHigh();
      case 'bluetooth':
        return PhosphorIcons.bluetoothConnected();
      case 'usb':
        return PhosphorIcons.usb();
      case 'hard-drive':
        return PhosphorIcons.hardDrive();
      case 'cpu':
        return PhosphorIcons.cpu();
      case 'memory':
        return PhosphorIcons.memory();
      case 'circuit-board':
        return PhosphorIcons.gear();
      case 'network':
        return PhosphorIcons.network();
      case 'browser':
        return PhosphorIcons.browser();
      case 'bug':
        return PhosphorIcons.bug();
      case 'git-branch':
        return PhosphorIcons.gitBranch();
      case 'github-logo':
        return PhosphorIcons.githubLogo();

      // Health & Fitness
      case 'heart':
        return PhosphorIcons.heart();
      case 'pulse':
        return PhosphorIcons.pulse();
      case 'bicycle':
        return PhosphorIcons.bicycle();
      case 'barbell':
        return PhosphorIcons.barbell();
      case 'person-simple-run':
        return PhosphorIcons.personSimpleRun();
      case 'apple-logo':
        return PhosphorIcons.appleLogo();
      case 'person-simple-walk':
        return PhosphorIcons.personSimpleWalk();
      case 'person-simple-swim':
        return PhosphorIcons.personSimpleSwim();
      case 'person-simple-bike':
        return PhosphorIcons.personSimpleBike();
      case 'person':
        return PhosphorIcons.person();
      case 'basketball':
        return PhosphorIcons.basketball();
      case 'soccer-ball':
        return PhosphorIcons.soccerBall();
      case 'tennis-ball':
        return PhosphorIcons.basketball();
      case 'pill':
        return PhosphorIcons.pill();
      case 'first-aid':
        return PhosphorIcons.firstAid();
      case 'thermometer':
        return PhosphorIcons.thermometer();
      case 'tooth':
        return PhosphorIcons.tooth();

      // Knowledge & Learning
      case 'book':
        return PhosphorIcons.book();
      case 'books':
        return PhosphorIcons.books();
      case 'brain':
        return PhosphorIcons.brain();
      case 'lightbulb':
        return PhosphorIcons.lightbulb();
      case 'graduation-cap':
        return PhosphorIcons.graduationCap();
      case 'microscope':
        return PhosphorIcons.microscope();
      case 'student':
        return PhosphorIcons.student();
      case 'teacher':
        return PhosphorIcons.chalkboardTeacher();
      case 'chalkboard':
        return PhosphorIcons.chalkboard();
      case 'test-tube':
        return PhosphorIcons.testTube();
      case 'atom':
        return PhosphorIcons.atom();
      case 'dna':
        return PhosphorIcons.dna();
      case 'flask':
        return PhosphorIcons.flask();
      case 'math-operations':
        return PhosphorIcons.mathOperations();
      case 'translate':
        return PhosphorIcons.translate();
      case 'certificate':
        return PhosphorIcons.certificate();
      case 'exam':
        return PhosphorIcons.exam();
      case 'pencil':
        return PhosphorIcons.pencil();

      // Creative & Arts
      case 'palette':
        return PhosphorIcons.palette();
      case 'paint-brush':
        return PhosphorIcons.paintBrush();
      case 'camera':
        return PhosphorIcons.camera();
      case 'music-note':
        return PhosphorIcons.musicNote();
      case 'film-strip':
        return PhosphorIcons.filmStrip();
      case 'pen':
        return PhosphorIcons.pen();
      case 'microphone':
        return PhosphorIcons.microphone();
      case 'guitar':
        return PhosphorIcons.guitar();
      case 'piano-keys':
        return PhosphorIcons.pianoKeys();
      case 'headphones':
        return PhosphorIcons.headphones();
      case 'speaker-high':
        return PhosphorIcons.speakerHigh();
      case 'vinyl-record':
        return PhosphorIcons.vinylRecord();
      case 'video-camera':
        return PhosphorIcons.videoCamera();
      case 'image':
        return PhosphorIcons.image();
      case 'sketch-logo':
        return PhosphorIcons.sketchLogo();
      case 'design-system':
        return PhosphorIcons.selection();
      case 'color-palette':
        return PhosphorIcons.palette();
      case 'scissors':
        return PhosphorIcons.scissors();

      // Communication & Social
      case 'chat-circle':
        return PhosphorIcons.chatCircle();
      case 'envelope':
        return PhosphorIcons.envelope();
      case 'phone':
        return PhosphorIcons.phone();
      case 'users':
        return PhosphorIcons.users();
      case 'share':
        return PhosphorIcons.share();
      case 'megaphone':
        return PhosphorIcons.megaphone();
      case 'video':
        return PhosphorIcons.videoCamera();
      case 'chat-text':
        return PhosphorIcons.chatText();
      case 'at':
        return PhosphorIcons.at();
      case 'hash':
        return PhosphorIcons.hash();
      case 'thumbs-up':
        return PhosphorIcons.thumbsUp();
      case 'thumbs-down':
        return PhosphorIcons.thumbsDown();
      case 'user-circle':
        return PhosphorIcons.userCircle();
      case 'crown':
        return PhosphorIcons.crown();
      case 'smiley':
        return PhosphorIcons.smiley();

      // Travel & Adventure
      case 'airplane':
        return PhosphorIcons.airplane();
      case 'map-pin':
        return PhosphorIcons.mapPin();
      case 'compass':
        return PhosphorIcons.compass();
      case 'globe':
        return PhosphorIcons.globe();
      case 'suitcase':
        return PhosphorIcons.suitcase();
      case 'train':
        return PhosphorIcons.train();
      case 'bus':
        return PhosphorIcons.bus();
      case 'taxi':
        return PhosphorIcons.taxi();
      case 'ship':
        return PhosphorIcons.boat();
      case 'anchor':
        return PhosphorIcons.anchor();
      case 'passport':
        return PhosphorIcons.identificationCard();
      case 'ticket':
        return PhosphorIcons.ticket();
      case 'mountains':
        return PhosphorIcons.mountains();
      case 'tent':
        return PhosphorIcons.tent();
      case 'campfire':
        return PhosphorIcons.campfire();
      case 'binoculars':
        return PhosphorIcons.binoculars();
      case 'backpack':
        return PhosphorIcons.backpack();
      case 'road-horizon':
        return PhosphorIcons.roadHorizon();

      // Home & Life
      case 'house':
        return PhosphorIcons.house();
      case 'bed':
        return PhosphorIcons.bed();
      case 'shower':
        return PhosphorIcons.shower();
      case 'car':
        return PhosphorIcons.car();
      case 'key':
        return PhosphorIcons.key();
      case 'lock':
        return PhosphorIcons.lock();
      case 'door':
        return PhosphorIcons.door();
      case 'armchair':
        return PhosphorIcons.armchair();
      case 'television':
        return PhosphorIcons.television();
      case 'washing-machine':
        return PhosphorIcons.washingMachine();
      case 'oven':
        return PhosphorIcons.oven();
      case 'broom':
        return PhosphorIcons.broom();
      case 'toilet-paper':
        return PhosphorIcons.toiletPaper();
      case 'bathtub':
        return PhosphorIcons.bathtub();
      case 'garage':
        return PhosphorIcons.garage();
      case 'garden':
        return PhosphorIcons.flower();

      default:
        return PhosphorIcons.target(); // Default fallback
    }
  }
}
