// lib/widgets/language_transcription.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/sarvam_helper.dart';

class LanguageTranscription extends StatefulWidget {
  final apiKey = '59c52625-49a6-457c-86b7-67ab6a61a6c9';
  final Key? key;
  final List<Map<String, String>> languages;

  const LanguageTranscription({
    this.key,
    required this.languages,
  }) : super(key: key);

  @override
  LanguageTranscriptionState createState() => LanguageTranscriptionState();
}

class LanguageTranscriptionState extends State<LanguageTranscription> {
  bool _isRecording = false;
  bool _isProcessing = false;
  late String _selectedLanguage;
  String _voiceTranscriptionResult = 'Voice transcription will appear here...';
  File? _audioFile;

  late FlutterSoundRecorder _audioRecorder;
  String? _recordingPath;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.languages.first['code'] ?? 'en-IN';
    _audioRecorder = FlutterSoundRecorder();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    await _audioRecorder.openRecorder();
    await _audioRecorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _audioRecorder.closeRecorder();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await Permission.microphone.request().isGranted) {
        final tempDir = await getTemporaryDirectory();
        final path = '${tempDir.path}/recording.wav';
        await _audioRecorder.startRecorder(
          toFile: path,
          codec: Codec.pcm16WAV,
        );
        setState(() {
          _isRecording = true;
          _recordingPath = path;
        });
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _audioRecorder.stopRecorder();
      _audioFile = File(_recordingPath!);
      setState(() => _isRecording = false);
      await _processVoiceRecording();
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }
  }

  Future<void> _processVoiceRecording() async {
    if (_audioFile == null) return;

    setState(() => _isProcessing = true);

    try {
      final response = await SarvamSpeechToText.transcribeAudio(
        audioFile: _audioFile!,
        apiKey: widget.apiKey,
        languageCode: _selectedLanguage,
      );

      final Map<String, dynamic> jsonResponse = json.decode(response);
      final String transcript = jsonResponse['transcript'] as String;

      setState(() {
        _voiceTranscriptionResult = transcript.isNotEmpty 
            ? transcript 
            : 'No transcription available';
      });
    } catch (e) {
      debugPrint('Error in processVoiceRecording: $e');
      setState(() {
        _voiceTranscriptionResult = 'Failed to transcribe audio: ${e.toString()}';
      });
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _refreshTranscription() {
    setState(() {
      _voiceTranscriptionResult = 'Voice transcription will appear here...';
      _audioFile = null;
    });
  }

  void _copyTranscription() {
    Clipboard.setData(ClipboardData(text: _voiceTranscriptionResult));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transcription copied to clipboard'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[50]!, Colors.white],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Language Selection',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedLanguage,
                          items: widget.languages
                              .map((lang) => DropdownMenuItem(
                                    value: lang['code'],
                                    child: Text(
                                      '${lang['name']} (${lang['label']})',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedLanguage = value);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Transcription',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: _refreshTranscription,
                              tooltip: 'Refresh',
                              color: Colors.blue,
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: _copyTranscription,
                              tooltip: 'Copy',
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Text(
                        _voiceTranscriptionResult,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ),
                    if (_isProcessing)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.blue[100],
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: FloatingActionButton.extended(
                onPressed: () => _isRecording ? _stopRecording() : _startRecording(),
                backgroundColor: _isRecording ? Colors.red : Colors.blue,
                icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                label: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

