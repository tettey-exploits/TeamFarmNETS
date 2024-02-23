import 'dart:developer';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:test_1/Chat_gpt_API/consts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_1/Components/services/weather_service.dart';
import 'package:test_1/Components/weather_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:test_1/components/try_chat.dart';
import 'package:tflite/tflite.dart';
import '../Components/services/Text_translator.dart';
import '../components/services/Text_to_speech.dart';
import 'package:chat_package/chat_package.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  // api key
  final _weatherService = WeatherService('51b6adfd3b1af06d26e10abacb4a3813');
  Weather? _weather;

  final _textTranslate = TextTranslator('2c524c9c68ab4e2da999a3f9d641ba5d#');

  final _textSpeech = SpeechToText('2c524c9c68ab4e2da999a3f9d641ba5d#');

  _fetchWeather() async {
    // get the current city
    String cityName = await _weatherService.getCurrentCity();
    // get weather for city
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

  void _fetchTranslator() async {
    try {
      final weather = await _textTranslate
          .translateText("It is rainy, the temperature is 40 degrees Celsius");
      _textSpeech.speechText(weather);
      const textSpeechPath =
          "/storage/emulated/0/Android/data/com.example.test_1/files/audio_recorded/Weather_voice.wav";
      playRecording(pathToAudio: textSpeechPath);
      if (kDebugMode) {
        print(weather);
        print(textSpeechPath);
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
      path: imageFile!.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    setState(() {
      _loading = false;
      _outputs = output!;
    });
    if (kDebugMode) {
      print(_outputs);
    }
  }

  final picker = ImagePicker();
  File? imageFile;
  bool isLoading = false;
  String imageUrl = "";
  File? controlImage;

  void _capturePhoto() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (kDebugMode) {
      print("Picked file: ${pickedFile?.path}");
    }
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
        _loading = true;
      });
      classifyImage(imageFile!);
      _sendImageMessage();
    } else {
      if (kDebugMode) {
        print("Picked file is null\n");
      }
    }
  }

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

  void _sendImageMessage() async {
    if (imageFile != null) {
      /*final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/image_${DateTime.now()}.png';
      await imageFile!.copy(imagePath);*/

      controlImage = File(imageFile!.path);

      setState(() {
        imageFile = null; // Reset imageFile after sending
      });
      createFolder('images');
    }
  }

  late Record audioRecord;
  late AudioPlayer audioPlayer;
  bool isRecording = false;
  String audioPath = '';

  Future<void> startRecording() async {
    try {
      if (await audioRecord.hasPermission()) {
        await audioRecord.start();
        setState(() {
          isRecording = true;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error Start Recording : $e');
      }
    }
  }

  Future<void> stopRecording() async {
    try {
      String? path = await audioRecord.stop();
      setState(() {
        isRecording = false;
        audioPath = path!;
      });
      createFolder('audio');
    } catch (e) {
      if (kDebugMode) {
        print('Error Stopping Record: $e');
      }
    }
  }

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

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    audioRecord = Record();
    // fetch weather on startup
    _fetchWeather();
    _fetchTranslator();

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
    audioRecord.dispose();
  }

  @override
  Widget build(BuildContext context) {
    weatherText = 'At ${_weather?.cityName ?? "Loading... city"},'
        ' \nThe Temperature for today is ${_weather?.temperature.round()}°C, '
        '\n It is going to be ${_weather?.mainConditions ?? ""}.';
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "FarmNETS",
            style: TextStyle(
              color: Theme.of(context).colorScheme.background,
              fontSize: 24,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
        body: Column(
          children: [
            Container(
              color: Theme.of(context).colorScheme.secondary,
              child: TabBar(
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
                      sendMessageHintText: '',
                      scrollController: scrollController,
                      messages: tryChat.messages,
                      onSlideToCancelRecord: () {
                        log('not sent');
                      },
                      onTextSubmit: (textMessage) {
                        setState(() {
                          tryChat.messages.add(textMessage);

                          scrollController
                              .jumpTo(scrollController.position.maxScrollExtent + 50);
                        });
                      },
                      handleRecord: (audioMessage, canceled) {
                        if (!canceled) {
                          setState(() {
                            tryChat.messages.add(audioMessage!);
                            scrollController
                                .jumpTo(scrollController.position.maxScrollExtent + 90);
                          });
                        }
                      },
                      handleImageSelect: (imageMessage) async {
                        if (imageMessage != null) {
                          setState(() {
                            tryChat.messages.add(
                              imageMessage,
                            );
                            scrollController
                                .jumpTo(scrollController.position.maxScrollExtent + 300);
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
                                fontSize: 35,
                                color: Colors.amber,
                              ),
                            ),
                            const SizedBox(height: 40),
                            ElevatedButton(
                                onPressed: _fetchTranslator,
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
                            Text(weatherText),
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}