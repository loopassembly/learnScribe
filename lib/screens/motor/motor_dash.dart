import 'package:flutter/material.dart';

class MotorImpairedDashboard extends StatefulWidget {
  const MotorImpairedDashboard({super.key});

  @override
  State<MotorImpairedDashboard> createState() => _MotorImpairedDashboardState();
}

class _MotorImpairedDashboardState extends State<MotorImpairedDashboard> {
  String? selectedActivity;

  final List<Map<String, dynamic>> activities = [
    {
      'id': 'adaptive-controls',
      'title': 'Adaptive Control Training',
      'icon': Icons.mouse,
      'color': Colors.blue[100],
      'iconColor': Colors.blue,
      'description': 'Learn to use various adaptive input devices and controls',
      'features': [
        'Switch control practice',
        'Eye tracking exercises',
        'Voice command training',
        'Adaptive mouse techniques'
      ],
      'adaptations': 'Multiple input methods supported, adjustable sensitivity'
    },
    {
      'id': 'fine-motor',
      'title': 'Fine Motor Skills',
      'icon': Icons.accessibility,
      'color': Colors.green[100],
      'iconColor': Colors.green,
      'description': 'Develop precision and control through adaptive exercises',
      'features': [
        'Virtual object manipulation',
        'Precision clicking tasks',
        'Drawing exercises',
        'Typing practice'
      ],
      'adaptations': 'Adjustable difficulty and timing settings'
    },
    {
      'id': 'adaptive-gaming',
      'title': 'Adaptive Gaming',
      'icon': Icons.sports_esports,
      'color': Colors.purple[100],
      'iconColor': Colors.purple,
      'description': 'Engaging games designed for various motor abilities',
      'features': [
        'Single-switch games',
        'Eye-tracking games',
        'Voice-controlled games',
        'Adaptive sports games'
      ],
      'adaptations': 'Customizable control schemes and game speed'
    },
    {
      'id': 'keyboard-skills',
      'title': 'Keyboard Accessibility',
      'icon': Icons.keyboard,
      'color': Colors.orange[100],
      'iconColor': Colors.orange,
      'description': 'Master keyboard navigation and shortcuts',
      'features': [
        'Keyboard navigation training',
        'Custom shortcut setup',
        'On-screen keyboard practice',
        'Word prediction tools'
      ],
      'adaptations': 'Adjustable key timing and sticky keys support'
    },
    {
      'id': 'physical-therapy',
      'title': 'Virtual Physical Therapy',
      'icon': Icons.fitness_center,
      'color': Colors.red[100],
      'iconColor': Colors.red,
      'description': 'Guided exercise routines with virtual assistance',
      'features': [
        'Range of motion exercises',
        'Strength training',
        'Coordination activities',
        'Progress tracking'
      ],
      'adaptations': 'Customizable to individual mobility ranges'
    },
    {
      'id': 'daily-skills',
      'title': 'Daily Living Skills',
      'icon': Icons.people,
      'color': Colors.yellow[100],
      'iconColor': Colors.amber,
      'description': 'Practice everyday tasks with adaptive techniques',
      'features': [
        'Virtual home navigation',
        'Adaptive tool usage',
        'Communication practice',
        'Life skills simulation'
      ],
      'adaptations': 'Multiple control methods for each activity'
    }
  ];

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    final isSelected = selectedActivity == activity['id'];

    return Card(
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.transparent,
          width: isSelected ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: () => setState(() => selectedActivity = activity['id']),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: activity['color'],
                  shape: BoxShape.circle,
                ),
                child: Icon(activity['icon'], color: activity['iconColor'], size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                activity['title'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.play_arrow, size: 20),
                  label: const Text('Start Activity'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adaptive Learning & Development'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Adaptive Learning & Development',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Personalized activities designed for various motor abilities',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isWideScreen ? 3 : 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: activities.map((activity) => _buildActivityCard(activity)).toList(),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.settings),
                  label: const Text('Adjust Control Settings'),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.sports_esports),
                  label: const Text('Configure Input Devices'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}