import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mime/mime.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;


import 'package:learnscribe/services/sarvam_helper.dart';

class AiTutorPage extends StatefulWidget {
  const AiTutorPage({super.key});

  @override
  State<AiTutorPage> createState() => _AiTutorPageState();
}

class _AiTutorPageState extends State<AiTutorPage> with TickerProviderStateMixin {
  late final GenerativeModel model;
  final apiKey = 'AIzaSyC0VnLwadAiNZ9QBu3MnvbdnhA2MTb_z4g';
  final openRouterApiKey =
      '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';
  final sarvamApiKey = '59c52625-49a6-457c-86b7-67ab6a61a6c9';

  bool isLoading = false;
  int userScore = 0;
  List<ChatMessage> messages = [];

  final FlutterTts flutterTts = FlutterTts();
  bool isSpeaking = false;

  final translator = GoogleTranslator();
  final TextRecognizer _textRecognizer = GoogleMlKit.vision.textRecognizer();

  String selectedLanguage = 'en-IN';
  final Map<String, String> indianLanguages = {
    'en-IN': 'English (India)',
    'hi-IN': 'Hindi', 
    'bn-IN': 'Bengali',
    'kn-IN': 'Kannada',
    'ml-IN': 'Malayalam',
    'mr-IN': 'Marathi',
    'od-IN': 'Odia',
    'pa-IN': 'Punjabi',
    'ta-IN': 'Tamil',
    'te-IN': 'Telugu',
    'gu-IN': 'Gujarati'
  };

  late FlutterSoundRecorder _audioRecorder;
  bool isRecording = false;
  File? _audioFile;
  String? _recordingPath;

  late AnimationController _bounceController;

  ChatUser currentUser = ChatUser(id: "0", firstName: "Student");
  ChatUser aiUser = ChatUser(
    id: "1",
    firstName: "Vidyasagar",
    profileImage:
        "https://cdn2.vectorstock.com/i/1000x1000/64/71/female-teacher-avatar-educacion-and-school-vector-38156471.jpg",
  );

  @override
  void initState() {
    super.initState();

    model = GenerativeModel(
      model: 'gemini-2.0-flash-exp', 
      apiKey: apiKey,
    );

    _initTts();
    _audioRecorder = FlutterSoundRecorder();
    _initRecorder();

    messages.add(
      ChatMessage(
        user: aiUser,
        createdAt: DateTime.now(),
        text: "Namaste! I am learnscribe, your AI education guide. I can help you learn new topics through text, images, and suggest relevant educational YouTube videos. How may I assist you today?",
      ),
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _audioRecorder.closeRecorder();
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _initRecorder() async {
    await _audioRecorder.openRecorder();
    await _audioRecorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage(selectedLanguage);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    flutterTts.setStartHandler(() {
      setState(() {
        isSpeaking = true;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        isSpeaking = false;
      });
    });
  }

  Future<void> _startRecording() async {
    try {
      if (await Permission.microphone.request().isGranted) {
        final tempDir = await getTemporaryDirectory();
        final path = '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';

        await _audioRecorder.startRecorder(
          toFile: path,
          codec: Codec.pcm16WAV,
        );
        setState(() {
          isRecording = true;
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
      setState(() {
        isRecording = false;
      });

      if (_recordingPath != null) {
        _audioFile = File(_recordingPath!);
        final transcription = await _processVoiceRecording();
        if (transcription != null) {
          final chatMessage = ChatMessage(
            user: currentUser,
            createdAt: DateTime.now(),
            text: transcription,
          );
          _sendMessage(chatMessage);
        }
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }
  }

  Future<String?> _processVoiceRecording() async {
    if (_audioFile == null) return null;

    setState(() => isLoading = true);

    try {
      final response = await SarvamSpeechToText.transcribeAudio(
        audioFile: _audioFile!,
        apiKey: sarvamApiKey,
        languageCode: selectedLanguage,
      );
      final Map<String, dynamic> jsonResponse = json.decode(response);
      final String transcript = jsonResponse['transcript'] ?? '';

      return transcript.isNotEmpty ? transcript : null;
    } catch (e) {
      debugPrint('Error in processVoiceRecording: $e');
      return null;
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _sendMessage(ChatMessage chatMessage) async {
    // Avoid multiple simultaneous calls
    if (isLoading) return;
  
    setState(() {
      // Add the user message to the top
      messages = [chatMessage, ...messages];
      isLoading = true;
    });
  
    try {
      // Translate user message to English if needed
      String userMessage = chatMessage.text;
      if (selectedLanguage != 'en-IN') {
        final translation = await translator.translate(
          userMessage,
          from: selectedLanguage.split('-')[0],
          to: 'en',
        );
        userMessage = translation.text;
      }
  
      // We'll assemble the server's raw English response here
      String englishResponse = '';
  
      // Check if user provided an image
      if ((chatMessage.medias?.isNotEmpty ?? false)) {
        // --------------- IMAGE LOGIC ---------------
        final filePath = chatMessage.medias![0].url;
        final inputImage = InputImage.fromFilePath(filePath);
        final recognizedText = await _textRecognizer.processImage(inputImage);
        // e.g., call your Gemini model with recognizedText, etc.
        final geminiResult = await model.generateContent([
          Content.text(
            "Analyze this image. User request: $userMessage\n"
            "Extracted text: ${recognizedText.text}",
          ),
        ]);
        englishResponse = geminiResult.text ?? '';
      } else {
        // --------------- STREAMING LOGIC ---------------
        // 1) Insert a placeholder "partial AI message" in the conversation
        ChatMessage partialAiMsg = ChatMessage(
          user: aiUser,
          createdAt: DateTime.now(),
          text: '', // We'll update this with streaming tokens
        );
        setState(() {
          messages = [partialAiMsg, ...messages];
        });
  
        // 2) Prepare a streaming request
        final request = http.Request(
          'POST',
          Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        );
        request.headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openRouterApiKey',
        });
        request.body = jsonEncode({
          'model': 'openai/gpt-4o-2024-11-20', 
          'messages': [
            {
              'role': 'user',
              'content': 'You are an education assistant. Give responses in plain text form, avoid using markdown syntax. Here is the student question: $userMessage',
            }
          ],
          'stream': true,
        });
  
        final client = http.Client();
        final response = await client.send(request);
        final stream = response.stream.transform(utf8.decoder);
  
        // 3) Read the stream line-by-line and parse partial tokens
        await for (final chunk in stream) {
          for (final line in chunk.split('\n')) {
            if (line.startsWith('data: ')) {
              final jsonStr = line.substring(6).trim(); // remove "data: "
  
              // 4) If the chunk says [DONE], streaming is complete
              if (jsonStr == '[DONE]') {
                // Now we have the *complete* englishResponse
                // Translate it if the user selected a different language
                if (selectedLanguage != 'en-IN') {
                  final translation = await translator.translate(
                    englishResponse,
                    from: 'en',
                    to: selectedLanguage.split('-')[0],
                  );
                  englishResponse = translation.text;
                }
  
                // Update the partialAiMsg to final text in user’s language
                setState(() {
                  // Create new ChatMessage instead of using copyWith
                  partialAiMsg = ChatMessage(
                    user: partialAiMsg.user,
                    createdAt: partialAiMsg.createdAt, 
                    text: englishResponse
                  );
                  messages[0] = partialAiMsg;
                  userScore += 10; // scoring
                });

                // Optionally do TTS after final text is set
                flutterTts.speak(englishResponse);

                break;
              }

              // Else parse the streamed JSON chunk
              try {
                final Map<String, dynamic> jsonData = jsonDecode(jsonStr);
                final content = jsonData['choices']?[0]?['delta']?['content'];

                if (content != null) {
                  // Append partial tokens to englishResponse
                  englishResponse += content;

                  // Optionally show partial English text in the UI
                  // (If you truly want to hide partial English, you could skip this setState)
                  setState(() {
                    // Create new ChatMessage instead of using copyWith
                    partialAiMsg = ChatMessage(
                      user: partialAiMsg.user,
                      createdAt: partialAiMsg.createdAt,
                      text: englishResponse
                    );
                    messages[0] = partialAiMsg;
                  });
                }
              } catch (e) {
                debugPrint('Error parsing streamed line: $e');
              }
            }
          }
        }
        client.close();
      }
      
  
      // If you used the streaming block above, you've already updated partialAiMsg,
      // so you can skip rewriting messages. The final text is already set.
      //
      // If you used the image block, you'd need to do final translation at the end:
      if ((chatMessage.medias?.isNotEmpty ?? false)) {
        // If the user’s language is not English, translate once
        if (selectedLanguage != 'en-IN') {
          final translation = await translator.translate(
            englishResponse,
            from: 'en',
            to: selectedLanguage.split('-')[0],
          );
          englishResponse = translation.text;
        }
  
        // Insert or update the final message
        setState(() {
          userScore += 10;
          messages = [
            ChatMessage(
              user: aiUser,
              createdAt: DateTime.now(),
              text: englishResponse,
            ),
            // Keep rest of the conversation
            ...messages.where((m) => m.user.id != aiUser.id),
          ];
        });
  
        // TTS
        flutterTts.speak(englishResponse);
      }
    } catch (e) {
      debugPrint("Error: $e");
      final errorMessage = ChatMessage(
        user: aiUser,
        createdAt: DateTime.now(),
        text: "Sorry, I'm having trouble processing your request. Please try again.",
      );
      setState(() {
        messages = [errorMessage, ...messages];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  
  

  void _sendMediaMessage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (file != null) {
      final chatMessage = ChatMessage(
        user: currentUser,
        createdAt: DateTime.now(),
        text: "Please analyze this image, explain the topic, and suggest educational YouTube videos that can help me learn more about it:",
        medias: [
          ChatMedia(
            url: file.path,
            fileName: "",
            type: MediaType.image,
          )
        ],
      );
      _sendMessage(chatMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "AI Learning Assistant",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.blue[900],
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[400]!, Colors.blue[700]!],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.blue[200]!,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$userScore',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: PopupMenuButton<String>(
              icon: Icon(Icons.language, color: Colors.blue[900]),
              onSelected: (String value) {
                setState(() {
                  selectedLanguage = value;
                  flutterTts.setLanguage(value);
                });
              },
              itemBuilder: (BuildContext context) => indianLanguages.entries
                  .map(
                    (entry) => PopupMenuItem<String>(
                      value: entry.key,
                      child: Text(
                        entry.value,
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: Column(
          children: [
            if (isLoading) LinearProgressIndicator(
              backgroundColor: Colors.blue[100],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[900]!),
            ),
            Expanded(
              child: DashChat(
                messageOptions: MessageOptions(
                  containerColor: Colors.blue[600]!,
                  currentUserContainerColor: Colors.blue[900]!,
                  textColor: Colors.white,
                  showTime: true,
                  messagePadding: const EdgeInsets.all(12),
                  borderRadius: 16,
                ),
                inputOptions: InputOptions(
                  inputTextStyle: GoogleFonts.poppins(),
                  inputDecoration: InputDecoration(
                    hintText: "Ask me anything...",
                    hintStyle: GoogleFonts.poppins(color: Colors.grey),
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: Colors.blue[100]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: Colors.blue[100]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: Colors.blue[400]!),
                    ),
                  ),
                  trailing: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: _sendMediaMessage,
                        icon: Icon(Icons.image, color: Colors.blue[900]),
                        tooltip: "Upload image",
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isRecording ? Colors.red[50] : Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: isRecording ? _stopRecording : _startRecording,
                        icon: Icon(
                          isRecording ? Icons.stop : Icons.mic,
                          color: isRecording ? Colors.red : Colors.blue[900],
                        ),
                        tooltip: isRecording ? "Stop recording" : "Start recording",
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: () {
                          if (isSpeaking) {
                            flutterTts.stop();
                          } else if (messages.isNotEmpty) {
                            final latestAiMsg = messages
                                .firstWhere(
                                  (m) => m.user.id == aiUser.id,
                                  orElse: () => messages.first,
                                )
                                .text;
                            flutterTts.speak(latestAiMsg);
                          }
                        },
                        icon: Icon(
                          isSpeaking ? Icons.stop : Icons.volume_up,
                          color: Colors.blue[900],
                        ),
                        tooltip: isSpeaking ? "Stop speaking" : "Speak last reply",
                      ),
                    ),
                  ],
                ),
                currentUser: currentUser,
                onSend: _sendMessage,
                messages: messages,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
