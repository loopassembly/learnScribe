import 'package:flutter/material.dart';
import '../storage/user_data.dart';
import './HearingCommunication.dart';
import './visual/visual_screen.dart';
import '../screens/learningsupport/learnsupport_dahboard.dart';
import '../screens/motor/motor_dash.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String selectedLanguage = 'en-IN';
  String? selectedCategory;
  late UserDataStorage _storage;

  final List<Map<String, String>> languages = [
    {'code': 'en-IN', 'name': 'English'},
    {'code': 'hi-IN', 'name': 'हिंदी'},
    {'code': 'ta-IN', 'name': 'தமிழ்'},
    {'code': 'te-IN', 'name': 'తెలుగు'}
  ];

  final List<Map<String, dynamic>> accessibilityOptions = [
    {
      'category': 'Visual Support',
      'icon': Icons.remove_red_eye_outlined,
      'description':
          'Reading assistance, color adjustments, and screen preferences',
    },
    {
      'category': 'Hearing & Communication',
      'icon': Icons.hearing_outlined,
      'description': 'Lip reading, voice transcription, and communication aids',
    },
    {
      'category': 'Learning Support',
      'icon': Icons.psychology_outlined,
      'description': 'Personalized learning pace and style adaptations',
    },
    {
      'category': 'Motor Support',
      'icon': Icons.accessibility_new_outlined,
      'description': 'Voice commands, eye tracking, and adaptive controls',
    }
  ];

  @override
  void initState() {
    super.initState();
    _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    _storage = await UserDataStorage.getInstance();
    setState(() {
      selectedLanguage = _storage.getLanguage();
      selectedCategory = _storage.getCategory();
    });
  }

  Future<void> selectCategory(String category) async {
    setState(() {
      selectedCategory = category;
    });
    await _storage.saveCategory(category);
  }

  Future<void> selectLanguage(String language) async {
    setState(() {
      selectedLanguage = language;
    });
    await _storage.saveLanguage(language);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0F7FF),
              Colors.white,
            ],
            stops: [0.0, 0.6],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Language Selector
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: languages.length,
                    separatorBuilder: (context, index) => SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final lang = languages[index];
                      final isSelected = selectedLanguage == lang['code'];
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        child: TextButton(
                          onPressed: () async {
                            await selectLanguage(lang['code']!);
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(
                                isSelected ? Color(0xFF2563EB) : Colors.white),
                            padding: MaterialStatePropertyAll(
                                EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8)),
                            shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected
                                      ? Colors.transparent
                                      : Colors.grey.shade300,
                                ),
                              ),
                            ),
                          ),
                          child: Text(
                            lang['name']!,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 40),

                // Welcome Header
                Text(
                  'Welcome to',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  'LearnScribe',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E40AF),
                    height: 1.1,
                  ),
                ),

                SizedBox(height: 24),

                // Alert Banner
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Color(0xFFBFDBFE)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personalized Learning for Everyone',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E40AF),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Select your preferences to customize your learning experience',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32),

                // Main Options Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio:
                        0.8, // Changed from 0.95 to 0.8 to fix overflow
                  ),
                  itemCount: accessibilityOptions.length,
                  itemBuilder: (context, index) {
                    final category = accessibilityOptions[index];
                    final isSelected = selectedCategory == category['category'];
                    return InkWell(
                      onTap: () => selectCategory(category['category']),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isSelected
                                ? Color(0xFF2563EB)
                                : Colors.grey.shade200,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        color: isSelected ? Color(0xFFEFF6FF) : Colors.white,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Color(0xFF2563EB).withAlpha(25)
                                          : Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      category['icon'],
                                      size: 24,
                                      color: isSelected
                                          ? Color(0xFF2563EB)
                                          : Color(0xFF64748B),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      category['category'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? Color(0xFF2563EB)
                                            : Colors.grey[900],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                category['description'],
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isSelected
                                      ? Color(0xFF2563EB)
                                      : Colors.grey[600],
                                  height: 1.4,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 32),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedCategory != null
                        ? () {
                            switch (selectedCategory) {
                              case 'Hearing & Communication':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        HearingCommunicationScreen(),
                                  ),
                                );
                                break;
                              case 'Visual Support':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VisualSupportScreen(),
                                  ),
                                );
                                break;
                              case 'Learning Support':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PDFTranslationDashboard(),
                                  ),
                                );
                                break;
                              case 'Motor Support':
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MotorImpairedDashboard(),
                                ),
                              );
                                break;
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF90CAF9),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Color(0xFFEFF6FF)),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Continue to Learning',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Skip Option
                Center(
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: Color(0xFF2563EB),
                    ),
                    child: Text(
                      'Skip for now (I\'ll set these later)',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
