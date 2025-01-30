import 'package:flutter/material.dart';

class HearingImpairedDashboard extends StatefulWidget {
  const HearingImpairedDashboard({super.key});

  @override
  State<HearingImpairedDashboard> createState() => _HearingImpairedDashboardState();
}

class _HearingImpairedDashboardState extends State<HearingImpairedDashboard> {
  String? selectedActivity;

  final List<Map<String, dynamic>> activities = [
    {
      'id': 'sign-language',
      'title': 'Sign Language Learning',
      'icon': Icons.accessibility,
      'color': Colors.green[100],
      'iconColor': Colors.green,
      'description': 'Learn and practice sign language through interactive lessons',
      'features': [
        'Video demonstrations',
        'Interactive practice sessions',
        'Progress tracking',
        'Family sign language basics'
      ],
      'adaptations': 'Clear visual demonstrations with slow-motion replay options'
    },
    {
      'id': 'visual-communication',
      'title': 'Visual Communication', 
      'icon': Icons.remove_red_eye,
      'color': Colors.orange[100],
      'iconColor': Colors.orange,
      'description': 'Develop visual communication skills and expression recognition',
      'features': [
        'Facial expression practice',
        'Body language recognition',
        'Visual storytelling',
        'Emotion cards'
      ],
      'adaptations': 'Enhanced visual cues and feedback systems'
    },
    {
      'id': 'speech-reading',
      'title': 'Speech Reading',
      'icon': Icons.message,
      'color': Colors.purple[100],
      'iconColor': Colors.purple,
      'description': 'Learn lip reading and speech pattern recognition',
      'features': [
        'Lip reading exercises',
        'Visual phonics',
        'Common phrases practice',
        'Interactive conversations'
      ],
      'adaptations': 'Close-up video demonstrations with visual feedback'
    },
    {
      'id': 'rhythm-vibration',
      'title': 'Rhythm & Vibration',
      'icon': Icons.music_note,
      'color': Colors.blue[100],
      'iconColor': Colors.blue,
      'description': 'Experience music and rhythm through vibration and visual patterns',
      'features': [
        'Visual rhythm patterns',
        'Vibration-based activities',
        'Dance visualization',
        'Musical story time'
      ],
      'adaptations': 'Visual and tactile feedback for musical experiences'
    },
    {
      'id': 'social-skills',
      'title': 'Social Skills',
      'icon': Icons.people,
      'color': Colors.pink[100],
      'iconColor': Colors.pink,
      'description': 'Practice social interactions and group communication',
      'features': [
        'Group activity simulations',
        'Social scenario practice',
        'Friend communication tips',
        'School situation guides'
      ],
      'adaptations': 'Visual social stories with sign language integration'
    },
    {
      'id': 'academic-support',
      'title': 'Academic Learning',
      'icon': Icons.menu_book,
      'color': Colors.yellow[100],
      'iconColor': Colors.amber,
      'description': 'Visual-based academic subjects and homework support',
      'features': [
        'Visual vocabulary building',
        'Math visualization tools',
        'Science concept videos',
        'Interactive assignments'
      ],
      'adaptations': 'Captions and sign language for all educational content'
    }
  ];

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    final isSelected = selectedActivity == activity['id'];

    return Card(
      elevation: isSelected ? 4 : 2,
      margin: const EdgeInsets.only(bottom: 16),
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
        child: SingleChildScrollView(
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
                const SizedBox(height: 8),
                Text(
                  activity['description'],
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                ...activity['features'].map<Widget>((feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Adaptations: ${activity['adaptations']}',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 14,
                    ),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visual Learning Journey'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Visual Learning Journey',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Interactive learning experiences designed for children with hearing impairments',
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
              childAspectRatio: isWideScreen ? 0.85 : 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: activities.map((activity) => _buildActivityCard(activity)).toList(),
            ),
            const SizedBox(height: 32),
            Center(
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.settings),
                label: const Text('Customize your learning experience'),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
