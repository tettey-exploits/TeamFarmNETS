import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:test_1/Chat_gpt_API/consts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_1/Components/services/weather_service.dart';
import 'package:test_1/Components/weather_model.dart';
import 'package:permission_handler/permission_handler.dart';
import '../Components/services/Text_translator.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

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

  void _fetchTranslator() async {
    try {
      final weather = await _textTranslate.translateText(weatherText);
      if (kDebugMode) {
        print(weather);
      }
    }
    // any errors
    catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
  String weatherText = 'I am a boy.' ;

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

  final OpenAI _openAI = OpenAI.instance.build(
    token: OPENAI_API_KEY,
    baseOption: HttpSetup(
      receiveTimeout: const Duration(seconds: 5),
    ),
    enableLog: true,
  );

  final ChatUser _currentUser =
      ChatUser(id: '1', firstName: 'User', lastName: 'Account');
  final ChatUser _gptChatUser =
      ChatUser(id: '2', firstName: 'Farm', lastName: 'NETS');

  final List<ChatMessage> _messages = <ChatMessage>[];

  File? imageFile;
  bool isLoading = false;
  String imageUrl = "";

  void _capturePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (kDebugMode) {
      print("Picked file: ${pickedFile?.path}");
    }
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
      _sendImageMessage();
    } else {
      if (kDebugMode) {
        print("Picked file is null\n");
      }
    }
  }

  Future<String> createFolder(String cow) async {
    final dir = Directory(
        '${(Platform.isAndroid ? await getExternalStorageDirectory() //FOR ANDROID
                : await getApplicationSupportDirectory() //FOR IOS
            )!.path}/$cow');
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

      final media = ChatMedia(
        url: imageFile!.path,
        type: MediaType.image,
        fileName: 'test_file',
      );
      final message = ChatMessage(
        user: _currentUser,
        createdAt: DateTime.now(),
        medias: [media],
      );
      setState(() {
        _messages.insert(0, message);
        imageFile = null; // Reset imageFile after sending
      });
      createFolder('images');
    }
  }

  late Record audioRecord;
  late AudioPlayer audioPlayer;
  bool isRecording = false;
  String audioPath = '';

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    audioRecord = Record();
    // fetch weather on startup
    _fetchWeather();
    _fetchTranslator();
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.dispose();
    audioRecord.dispose();
  }

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
      createFolder('audio_recorded');
    } catch (e) {
      if (kDebugMode) {
        print('Error Stopping Record: $e');
      }
    }
  }

  Future<void> playRecording() async {
    try {
      Source urlSource = UrlSource(audioPath);
      await audioPlayer.play(urlSource);
    } catch (e) {
      if (kDebugMode) {
        print('Error playing Recording: $e');
      }
    }
  }

  late Interpreter interpreter;
  late Tensor inputTensor;
  late Tensor outputTensor;

  Future<void> loadModel() async {
    final options = InterpreterOptions();

    interpreter = await Interpreter.fromAsset('assets/afiricoco.tflite');

    inputTensor = interpreter.getInputTensors().first;

    outputTensor = interpreter.getOutputTensors().first;
  }

  Future<void> loadLabels() async {
    final labelTxt = await rootBundle.loadString('assets/labels.txt');
    final labels = labelTxt.split('\n');
  }

  Future<void> runInference(List<List<List<num>>> imageMatrix,) async {
    final input = [imageMatrix];

    final output = [List<int>.filled(1001, 0)];

    interpreter.run(input, output);

    final result = output.first;
  }

  @override
  Widget build(BuildContext context) {
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
                DashChat(
                  currentUser: _currentUser,
                  messageOptions: const MessageOptions(
                      currentUserContainerColor: Colors.green),
                  onSend: (ChatMessage m) {
                    getChatMessage(m);
                  },
                  messages: _messages,
                  inputOptions: InputOptions(
                    leading: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            IconButton(
                                icon: isRecording
                                    ? const Icon(Icons.stop)
                                    : const Icon(Icons.mic),
                                onPressed: isRecording
                                    ? stopRecording
                                    : startRecording),
                            IconButton(
                                onPressed: playRecording,
                                icon: const Icon(Icons.play_arrow))
                          ],
                        ),
                      )
                    ],
                    textCapitalization: TextCapitalization.sentences,
                    inputDecoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: const BorderSide(width: 0.5),
                          borderRadius: BorderRadius.circular(20)),
                      filled: true,
                      fillColor: Colors.grey[100],
                      hintText: "Type a message...",
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: IconButton(
                          icon: const Icon(Icons.camera_alt_outlined),
                          onPressed: _capturePhoto),
                    ),
                  ),
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
                        Text(
                            'At ${_weather?.cityName ?? "Loading... city"},'
                                ' \nThe Temperature for today is ${_weather?.temperature.round()}°C, '
                                '\n It is going to be ${_weather?.mainConditions ?? ""}.'),
                      ],
                    ),
                  ),
                )
              ],
            )),
          ],
        ),
      ),
    );
  }

  Future<void> getChatMessage(ChatMessage m) async {
    setState(() {
      _messages.insert(0, m);
    });

    // Dummy response in wait of ChatGPT API
    String dummyResponse = "Welcome to FarmNETS";

    setState(() {
      _messages.insert(
        0,
        ChatMessage(
          user: _gptChatUser,
          createdAt: DateTime.now(),
          text: dummyResponse,
        ),
      );
    });

    /*Message History
    List<Messages> _messagesHistory = _messages.reversed.map((m) {
      if (m.user == _currentUser) {
        return Messages(role: Role.user, content: m.text);
      } else {
        return Messages(role: Role.assistant, content: m.text);
      }
    }).toList();
    final request = ChatCompleteText(
      model: GptTurbo0301ChatModel(),
      messages: _messagesHistory,
      maxToken: 200,
    );
    final response = await _OpenAI.onChatCompletion(request: request);
    for (var element in response!.choices) {
      if (element.message != null) {
        setState(() {
          _messages.insert(
            0,
            ChatMessage(
              user: _gptChatUser,
              createdAt: DateTime.now(),
              text: element.message!.content,
            ),
          );
        });
      }
    }*/
  }
}
