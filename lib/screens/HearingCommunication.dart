import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:camera/camera.dart';
import 'dart:io';
import '../widgets/language_transcription.dart';
import '../screens/hear/hear_dashboard.dart';

class HearingCommunicationScreen extends StatefulWidget {
  @override
  _HearingCommunicationScreenState createState() =>
      _HearingCommunicationScreenState();
}

class _HearingCommunicationScreenState extends State<HearingCommunicationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<CameraDescription>? _cameras;
  CameraController? _cameraController;
  int _selectedCameraIndex = 0;
  bool _isRecordingVideo = false;

  String _selectedLanguage = 'en-IN';
  String _lipReadingResult = 'Lip reading transcription will appear here...';

  final List<Map<String, String>> languages = [
    {'code': 'hi-IN', 'name': 'हिंदी', 'label': 'Hindi'},
    {'code': 'bn-IN', 'name': 'বাংলা', 'label': 'Bengali'},
    {'code': 'kn-IN', 'name': 'ಕನ್ನಡ', 'label': 'Kannada'},
    {'code': 'ml-IN', 'name': 'മലയാളം', 'label': 'Malayalam'},
    {'code': 'mr-IN', 'name': 'मराठी', 'label': 'Marathi'},
    {'code': 'od-IN', 'name': 'ଓଡ଼ିଆ', 'label': 'Odia'},
    {'code': 'pa-IN', 'name': 'ਪੰਜਾਬੀ', 'label': 'Punjabi'},
    {'code': 'ta-IN', 'name': 'தமிழ்', 'label': 'Tamil'},
    {'code': 'te-IN', 'name': 'తెలుగు', 'label': 'Telugu'},
    {'code': 'gu-IN', 'name': 'ગુજરાતી', 'label': 'Gujarati'},
    {'code': 'en-IN', 'name': 'English', 'label': 'English'},
  ];

  final String _apiKey = 'YOUR_API_KEY';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeCameras();
  }

  Future<void> _initializeCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _initCameraController(_selectedCameraIndex);
      } else {
        debugPrint('No cameras found');
      }
    } catch (e) {
      debugPrint('Error in _initializeCameras: $e');
    }
  }

  Future<void> _initCameraController(int cameraIndex) async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
    }

    final camera = _cameras![cameraIndex];
    final controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: true,
    );

    try {
      await controller.initialize();
      setState(() => _cameraController = controller);
    } catch (e) {
      debugPrint('Error initializing camera controller: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.isEmpty) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
    await _initCameraController(_selectedCameraIndex);
  }

  Future<void> _toggleLipReading() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      debugPrint('CameraController not ready');
      return;
    }

    if (!_isRecordingVideo) {
      try {
        setState(() => _isRecordingVideo = true);
        await controller.startVideoRecording();
      } catch (e) {
        debugPrint('Error starting video recording: $e');
        setState(() => _isRecordingVideo = false);
      }
    } else {
      try {
        final file = await controller.stopVideoRecording();
        setState(() => _isRecordingVideo = false);
        await _processLipReadingVideo(file.path);
      } catch (e) {
        debugPrint('Error stopping video recording: $e');
        setState(() => _isRecordingVideo = false);
      }
    }
  }

  Future<void> _processLipReadingVideo(String filePath) async {
    try {
      final fileUri = await _uploadFile(filePath, 'video/mp4');
      final transcription = await _transcribeAudio(fileUri, 'video/mp4');

      setState(() {
        _lipReadingResult = transcription;
      });
    } catch (e) {
      debugPrint('Error in processLipReadingVideo: $e');
      setState(() {
        _lipReadingResult = 'Failed to process video for lip reading.';
      });
    }
  }

  Future<String> _uploadFile(String filePath, String mimeType) async {
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/upload/v1beta/files?key=$_apiKey');

    final fileBytes = await File(filePath).readAsBytes();
    final fileSize = fileBytes.length;

    final headers = {
      'X-Goog-Upload-Command': 'start, upload, finalize',
      'X-Goog-Upload-Header-Content-Length': fileSize.toString(),
      'X-Goog-Upload-Header-Content-Type': mimeType,
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'file': {'display_name': filePath.split('/').last}
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['file']['uri'];
    } else {
      throw Exception('Failed to upload file. Code: ${response.statusCode}');
    }
  }

  Future<String> _transcribeAudio(String fileUri, String mimeType) async {
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-exp-1206:generateContent?key=$_apiKey');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'role': 'user',
            'parts': [
              {
                'fileData': {
                  'fileUri': fileUri,
                  'mimeType': mimeType,
                }
              }
            ]
          },
          {
            'role': 'user',
            'parts': [
              {'text': "Transcribe (or read lips from) this file content."}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 1,
          'topK': 64,
          'topP': 0.95,
          'maxOutputTokens': 8192,
          'responseMimeType': 'text/plain'
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['candidates'][0]['content']['parts'][0]['text'];
      return text;
    } else {
      throw Exception('Failed to transcribe. Code: ${response.statusCode}');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _cameraController;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Hearing & Communication',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: [
            Tab(
              icon: Icon(Icons.camera_alt),
              text: 'Lip Reading',
            ),
            Tab(
              icon: Icon(Icons.mic),
              text: 'Voice Transcription',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Container(
            color: Colors.grey[100],
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (controller != null && controller.value.isInitialized)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: AspectRatio(
                          aspectRatio: controller.value.aspectRatio,
                          child: CameraPreview(controller),
                        ),
                      ),
                    )
                  else
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_outlined, size: 48, color: Colors.grey[600]),
                            SizedBox(height: 16),
                            Text(
                              'Initializing camera...',
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(Icons.cameraswitch),
                          color: Theme.of(context).primaryColor,
                          onPressed: _switchCamera,
                          tooltip: 'Switch Camera',
                          iconSize: 28,
                        ),
                      ),
                      SizedBox(width: 32),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: (controller != null && controller.value.isInitialized)
                              ? _toggleLipReading
                              : null,
                          style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(24),
                            backgroundColor: _isRecordingVideo ? Colors.red : Theme.of(context).primaryColor,
                            elevation: 0,
                          ),
                          child: Icon(
                            _isRecordingVideo ? Icons.stop : Icons.videocam,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Transcription',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        Divider(height: 1),
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            _lipReadingResult,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField(
                      value: _selectedLanguage,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: languages
                          .map((lang) => DropdownMenuItem(
                                value: lang['code'],
                                child: Text(
                                  '${lang['name']} (${lang['label']})',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedLanguage = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          LanguageTranscription(
            languages: languages,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HearingImpairedDashboard(),
            ),
          );
        },
        child: Icon(Icons.arrow_forward),
      ),
      
    );
  }
}
