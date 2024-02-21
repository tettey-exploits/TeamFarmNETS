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
import 'package:image/image.dart' as Imagi;
import 'dart:ui' as ui;
import 'dart:typed_data';

import '../components/services/Text_to_speech.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // api key
  final _weatherService = WeatherService('51b6adfd3b1af06d26e10abacb4a3813');
  Weather? _weather;

  final _textTranslate = TextTranslator('2c524c9c68ab4e2da999a3f9d641ba5d');

  final _textSpeech = SpeechToText('2c524c9c68ab4e2da999a3f9d641ba5d');

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
      final weather = await _textTranslate.translateText("It is rainy, the temperature is 40 degrees Celsius");
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
  File? controlImage;

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

  Future<void> runInference(
    List<List<List<num>>> imageMatrix,
  ) async {
    final input = [imageMatrix];

    final output = [List<int>.filled(1001, 0)];

    interpreter.run(input, output);

    final result = output.first;
  }

  List<List<int>> imgArray = [];
  var imageSize = 255;
  ByteBuffer bitmapToByteBuffer(ui.Image bitmap) {
    // Create a ByteData to hold the bytes
    final byteData = ByteData(4 * imageSize * imageSize * 3);
    final byteBuffer = byteData.buffer;
    final intValues = Int32List(imageSize * imageSize);
    // Get the pixels from the bitmap as Uint32List
    bitmap.toByteData(format: ui.ImageByteFormat.rawRgba).then((value) {
      final buffer = value?.buffer;
      final pixels = buffer?.asUint32List();
      int pixelIndex = 0;
      for (int i = 0; i < imageSize; i++) {
        for (int j = 0; j < imageSize; j++) {
          final val = pixels?[pixelIndex++]; // RGBA
          byteData.setFloat32((pixelIndex - 1) * 12, (val! >> 16 & 0xFF) / 255.0, Endian.host);
          byteData.setFloat32((pixelIndex - 1) * 12 + 4, (val >> 8 & 0xFF) / 255.0, Endian.host);
          byteData.setFloat32((pixelIndex - 1) * 12 + 8, (val & 0xFF) / 255.0, Endian.host);
        }
      }
    });
    return byteBuffer;
  }

  /*void readImage() async {
    final bytes = await controlImage!.readAsBytes();
    final decoder = Imagi.JpegDecoder();
    //final test = decoder.decode(bytes)
    final decodedImg = decoder.decodeImage(bytes);
    final decodedBytes = decodedImg!.getBytes(format: Imagi.Format.rgb);
    // print(decodedBytes);
    print(decodedBytes.length);

    // int loopLimit = decodedImg.width;
    int loopLimit =1000;
    for(int x = 0; x < loopLimit; x++) {
      int red = decodedBytes[decodedImg.width*3 + x*3];
      int green = decodedBytes[decodedImg.width*3 + x*3 + 1];
      int blue = decodedBytes[decodedImg.width*3 + x*3 + 2];
      imgArray.add([red, green, blue]);
    }
    if (kDebugMode) {
      print(imgArray);
    }
  }*/

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
                        Text(weatherText),
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
  }
}
