import 'package:flutter/material.dart';
import 'dart:io';

class PDFTranslationDashboard extends StatefulWidget {
  const PDFTranslationDashboard({super.key});

  @override
  State<PDFTranslationDashboard> createState() => _PDFTranslationDashboardState();
}

class _PDFTranslationDashboardState extends State<PDFTranslationDashboard> {
  File? selectedFile;
  String selectedLanguage = '';

  final List<Map<String, dynamic>> languages = [
    {'code': 'es', 'name': 'Spanish'},
    {'code': 'fr', 'name': 'French'},
    {'code': 'de', 'name': 'German'},
    {'code': 'it', 'name': 'Italian'},
    {'code': 'pt', 'name': 'Portuguese'},
    {'code': 'ru', 'name': 'Russian'},
    {'code': 'zh', 'name': 'Chinese'},
    {'code': 'ja', 'name': 'Japanese'},
    {'code': 'ko', 'name': 'Korean'},
    {'code': 'hi', 'name': 'Hindi'},
  ];

  final List<Map<String, dynamic>> features = [
    {
      'id': 'upload',
      'title': 'Upload PDF',
      'icon': Icons.upload,
      'color': Colors.blue[100],
      'iconColor': Colors.blue,
      'description': 'Upload your English PDF document',
      'features': [
        'Supports all PDF formats',
        'Multiple file upload',
        'OCR capability',
        'File size up to 50MB'
      ],
    },
    {
      'id': 'language',
      'title': 'Select Language',
      'icon': Icons.language,
      'color': Colors.green[100],
      'iconColor': Colors.green,
      'description': 'Choose your target translation language',
      'features': [
        'Multiple language support',
        'Regional variants',
        'Language detection',
        'Dialect options'
      ],
    },
  ];

  void _handleTranslate() {
    setState(() {
      selectedFile = null;
      selectedLanguage = '';
    });
  }

  Widget _buildFeatureCard(Map<String, dynamic> feature) {
    Widget? content;

    switch (feature['id']) {
      case 'upload':
        content = Column(
          children: [
            GestureDetector(
              onTap: () async {
                // Implement file picking logic here
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.cloud_upload, size: 40, color: Colors.blue),
                    const SizedBox(height: 8),
                    Text(
                      'Drop your PDF here or tap to browse',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (selectedFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Selected: ${selectedFile!.path.split('/').last}',
                  style: const TextStyle(color: Colors.green),
                ),
              ),
          ],
        );
        break;
      case 'language':
        content = DropdownButtonFormField<String>(
          value: selectedLanguage.isEmpty ? null : selectedLanguage,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          hint: const Text('Select a language'),
          items: languages
              .map<DropdownMenuItem<String>>(
                (lang) => DropdownMenuItem<String>(
              value: lang['code'] as String,
              child: Text(lang['name'] as String),
            ),
          )
              .toList(),
          onChanged: (value) => setState(() => selectedLanguage = value ?? ''),
        );
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: feature['color'],
                shape: BoxShape.circle,
              ),
              child: Icon(feature['icon'], color: feature['iconColor']),
            ),
            const SizedBox(height: 16),
            Text(
              feature['title'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              feature['description'],
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            content!,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Translation Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'PDF Translation Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload your English PDF and translate it to your preferred language',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
              childAspectRatio: 0.9,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: features.map((feature) => _buildFeatureCard(feature)).toList(),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed:
              selectedFile != null && selectedLanguage.isNotEmpty ? _handleTranslate : null,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Translate Document'),
            ),
          ],
        ),
      ),
    );
  }
}