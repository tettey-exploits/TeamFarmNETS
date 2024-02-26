import 'dart:developer';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:chat_package/models/chat_message.dart';
import 'package:chat_package/models/media/chat_media.dart';
import 'package:chat_package/models/media/media_type.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:test_1/components/crop_diseases.dart';
import 'package:test_1/components/services/weather_service.dart';
import 'package:test_1/components/weather_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:test_1/components/try_chat.dart';
import 'package:tflite/tflite.dart';
import '../components/digits_to_num.dart';
import '../components/services/speect_to_text.dart';
import '../components/services/text_translator.dart';
import '../components/services/text_to_speech.dart';
import 'package:chat_package/chat_package.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  Future<void> _playWelcomeNote() async {
    String translatedWelcome = await _textTranslate.translateText("Welcome. My name is Abena. How may I help you?");
    _textSpeech.textToSpeech(translatedWelcome, textContentType: 0);

    const welcomeNotePath = '/storage/emulated/0/Android/data/com.example.test_1/files/audio_recorded/welcome_note_3.wav';
    playRecording(pathToAudio: welcomeNotePath);
  }

  /// api key
  final _weatherService = WeatherService('51b6adfd3b1af06d26e10abacb4a3813');
  Weather? _weather;

  //final _textTranslate = TextTranslator('1eb2c5650b6e467db32b87ff60e64f25');
  //final _textTranslate = TextTranslator('b751d61514ce47cd958348531dad1cb2');
  final _textTranslate = TextTranslator('63a22bc0561f4844972dc905bb0f5145');

  //final _textSpeech = TextToSpeech('1eb2c5650b6e467db32b87ff60e64f25');
  //final _textSpeech = TextToSpeech('b751d61514ce47cd958348531dad1cb2');
  final _textSpeech = TextToSpeech('63a22bc0561f4844972dc905bb0f5145');

  //final _speechText = SpeechToText('b751d61514ce47cd958348531dad1cb2');
  final _speechText = SpeechToText('63a22bc0561f4844972dc905bb0f5145');

  _fetchWeather() async {
    String cityName = await _weatherService.getCurrentCity();
    try {
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
      });
    }
    // any errors
    catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  String weatherText = '';

  void _translateForWeather() async {
    try {
      final weather = await _textTranslate.translateText(weatherText);
      _textSpeech.textToSpeech(weather, textContentType: 1);
      if (kDebugMode) {
        print(weatherText);
        print('\n');
        print("The Twi weather: $weather");
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  String getWeatherAnimation(String? mainConditions) {
    if (mainConditions == null) return 'assets/sunny_animation.json';
    switch (mainConditions.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'haze':
      case 'dust':
        return 'assets/cloudy.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rainy.json';
      case 'thunderstorm':
        return 'assets/thunderstorm.json';
      case 'clear':
        return 'assets/sunny_animation.json';
      default:
        return 'assets/sunny_animation.json';
    }
  }

  final scrollController = ScrollController();
  TryChat tryChat = TryChat();

  late bool _loading;
  late List _outputs;

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/afiricoco.tflite",
      labels: "assets/labels.txt",
    );
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: imageFilePath!.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 255,
      imageStd: 255,
    );
    setState(() {
      _loading = false;
      _outputs = output!;
    });
    if (kDebugMode) {
      print(_outputs[0]["label"].toString());
    }

    String diseaseFeature = getDiseaseFeature(_outputs[0]["label"].toString());
    String translatedText = await _textTranslate.translateText(diseaseFeature);
    if (kDebugMode) {
      print(translatedText);
    }
    _textSpeech.textToSpeech(translatedText, textContentType: 3);

    const diseaseAudioPath =
        '/storage/emulated/0/Android/data/com.example.test_1/files/audio_recorded/crop_disease_voice.wav';
    ChatMessage detectedDiseaseAudio = ChatMessage(
        isSender: false,
        chatMedia: ChatMedia(
            url: diseaseAudioPath, mediaType: const MediaType.audioMediaType()));
    setState(() {
      tryChat.messages.add(detectedDiseaseAudio);
    });
  }

  File? imageFilePath;
  String imageUrl = "";

  Future<String> createFolder(String dirName) async {
    final dir = Directory(
        '${(Platform.isAndroid ? await getExternalStorageDirectory() //FOR ANDROID
                : await getApplicationSupportDirectory() //FOR IOS
            )!.path}/$dirName');
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    if ((await dir.exists())) {
      return dir.path;
    } else {
      dir.create();
      return dir.path;
    }
  }

  late AudioPlayer audioPlayer;
  bool isRecording = false;
  String audioPath = '';

  Future<void> playRecording({String? pathToAudio}) async {
    try {
      if (pathToAudio == null) {
        Source urlSource = UrlSource(audioPath);
        await audioPlayer.play(urlSource);
      } else {
        Source urlSource = UrlSource(pathToAudio);
        await audioPlayer.play(urlSource);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error playing Recording: $e');
      }
    }
  }

  Future<String?> _translateForGemini() async {
    if (geminiResponseText != null) {
      try {
        final geminiTwi =
            await _textTranslate.translateText(geminiResponseText!);
        _textSpeech.textToSpeech(geminiTwi, textContentType: 2);
        if (kDebugMode) {
          print("Gemini response: $geminiResponseText\n $geminiTwi");
        }
        return geminiTwi;
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    }
  }

  String? geminiResponseText;

  Future<String?> _callGenerativeModel({String? prompt}) async {
    const String apiKey = "AIzaSyBJnAGPttq6Ha4K6bX4uAQDa-TFOioEtEs";

    // For text-only input, use the gemini-pro model
    final model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: apiKey,
        generationConfig: GenerationConfig(maxOutputTokens: 300));
    final content = [
      Content.text(prompt ?? 'Respond with this string only: "Welcome User"')
    ];
    final response = await model.generateContent(content);

    setState(() {
      geminiResponseText = response.text;
    });
    String? geminiVoice = await _translateForGemini();
    _textSpeech.textToSpeech(geminiVoice!, textContentType: 2);

    // Return the response from the generative model
    return geminiResponseText;
  }

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    // fetch weather on startup
    _fetchWeather();
    _translateForWeather();
    _playWelcomeNote();

    // AI Model
    _loading = true;
    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const textSpeechPath =
        "/storage/emulated/0/Android/data/com.example.test_1/files/audio_recorded/Weather_voice.wav";
    final tempInWords = _weather?.temperature != null
        ? getNumberInWords(_weather!.temperature.round().toString())
        : "";
    final weatherInSentence =
        getConditionToSentence(_weather?.mainConditions ?? "");
    final weatherResponse =
        'The weather condition for today is $weatherInSentence and the temperature is $tempInWords degree celsius';
    setState(() {
      weatherText = weatherResponse;
    });

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          title: Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('assets/AgridisScan_logo.png'),
                backgroundColor: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                "FarmNETS",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.background,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/chat_background.jpg"),
              fit: BoxFit.cover,
              opacity: 0.3,
            ),
          ),
          child: Column(
            children: [
              Container(
                color: Theme.of(context).colorScheme.secondary,
                child: TabBar(
                  indicator: const UnderlineTabIndicator(
                    borderSide: BorderSide(
                      width: 3,
                      color: Colors.amber,
                    ),
                    insets: EdgeInsets.symmetric(horizontal: 100),
                  ),
                  tabs: [
                    Tab(
                      icon: Icon(
                        Icons.chat,
                        color: Theme.of(context).colorScheme.background,
                      ),
                    ),
                    Tab(
                      icon: Icon(
                        Icons.cloudy_snowing,
                        color: Theme.of(context).colorScheme.background,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: TabBarView(
                children: [
                  ChatScreen(
                    sendMessageHintText: 'Type your message here',
                    scrollController: scrollController,
                    messages: tryChat.messages,
                    chatInputFieldPadding:
                        const EdgeInsets.symmetric(horizontal: 12),
                    onSlideToCancelRecord: () {
                      log('not sent');
                    },
                    onTextSubmit: (textMessage) async {
                      setState(() {
                        tryChat.messages.add(textMessage);
                      });

                      // Call _callGenerativeModel and wait for the response
                      String? geminiResponse = await _callGenerativeModel(prompt: textMessage.text);

                      // Once you have the response, create the audio ChatMessage and add it to the chat messages list
                      if (geminiResponse != null) {
                        const geminiVoicePath = "/storage/emulated/0/Android/data/com.example.test_1/files/audio_recorded/Gemini_voice.wav";
                        ChatMessage geminiVoiceMessage = ChatMessage(
                            isSender: false,
                            chatMedia: ChatMedia(url: geminiVoicePath, mediaType: const MediaType.audioMediaType())
                        );

                        setState(() {
                          tryChat.messages.add(geminiVoiceMessage);
                        });
                      }
                      // Scroll to the bottom of the chat after adding the messages
                      scrollController.jumpTo(scrollController.position.maxScrollExtent);
                    },
                    handleRecord: (audioMessage, canceled) async {
                      if (!canceled) {
                        var transcribedText = await _speechText.speechToText(audioMessage!.chatMedia!.url);
                        var translatedText = await _textTranslate.translateText(transcribedText!);
                        if (kDebugMode) {
                          print("In English: $translatedText");
                        }
                        setState(() {
                          tryChat.messages.add(audioMessage!);
                          scrollController.jumpTo(
                              scrollController.position.maxScrollExtent + 90);
                        });
                      }
                    },
                    handleImageSelect: (imageMessage) async {
                      if (imageMessage != null) {
                        setState(() async {
                          /// Get the path to the image file
                          imageFilePath = File(imageMessage.chatMedia!.url);
                          tryChat.messages.add(
                            imageMessage,
                          );

                          /// Call the model to do the classification
                          await classifyImage(imageFilePath!);
                          scrollController.jumpTo(
                              scrollController.position.maxScrollExtent + 300);
                        });
                      }
                    },
                  ),
                  Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(
                              getWeatherAnimation(_weather?.mainConditions)),
                          Text(
                            _weather?.cityName ?? "Loading... city",
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          const Text(
                            'Weather',
                            style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Forecasts',
                            style: TextStyle(
                              fontSize: 40,
                              color: Colors.amber,
                            ),
                          ),
                          const SizedBox(height: 40),
                          ElevatedButton(
                              onPressed: () {
                                _translateForWeather();
                                playRecording(pathToAudio: textSpeechPath);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.secondary,
                                shape: const CircleBorder(),
                                minimumSize: const Size(80, 80),
                                elevation: 6,
                              ),
                              child: const Icon(
                                Icons.multitrack_audio,
                                color: Colors.white,
                                size: 40,
                              )),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }
}
