import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:test_1/Chat_gpt_API/consts.dart';
import 'package:test_1/Components/weather_start_btn.dart';
//import 'package:flutter_sound/flutter_sound.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  void handleWeather() {}

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
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

 /* void _startRecording() async {
    //String path = await
  }*/

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
                  messageOptions: const MessageOptions( currentUserContainerColor: Colors.green ),
                  onSend: (ChatMessage m) { getChatMessage(m); },
                  messages: _messages,
                  inputOptions: InputOptions(
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
                          onPressed: () {}),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.mic),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/weather_icon.jpg',
                          width: 220,
                          height: 220,
                        ),
                        const Text(
                          'Weather',
                          style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'ForeCasts',
                          style: TextStyle(
                            fontSize: 35,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(height: 25),
                        WeatherStartButton(
                          text: "Get Started",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ChatPage()),
                            );
                          },
                        ),
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
