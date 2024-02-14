import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:test_1/Chat_gpt_API/consts.dart';
import 'package:test_1/auth/auth_service.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final _OpenAI = OpenAI.instance.build(
      token: OPENAI_API_KEY,
      baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 5,
      ),
      ),
      enableLog: true,
  );

  void logout(){
    final _auth =AuthService();
    _auth.signOut();
  }

  
  final ChatUser _currentUser = ChatUser(id: '1', firstName: 'User', lastName: 'Account');
  final ChatUser _gptChatUser = ChatUser(id: '2', firstName: 'Chat', lastName: 'GPT');
  List<ChatMessage> _messages = <ChatMessage> [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AgidiScan'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        actions: [
          // Logout button
          IconButton(onPressed: logout, icon: const Icon(Icons.logout))
        ],
      ),
      body: DashChat(
          currentUser: _currentUser,
          messageOptions: const MessageOptions(
            currentUserContainerColor: Colors.green,
          ),
          onSend: (ChatMessage m){
        getChatMessage(m);
      },messages: _messages),
    );
  }
  Future<void>getChatMessage(ChatMessage m) async{
    setState(() {
      _messages.insert(0, m);

    });

    // Dummy response in wait of Chatgpt API

    String dummyResponse = "Welcome to AgridiScan";

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

    // Message History
  //  List<Messages> _messagesHistory = _messages.reversed.map((m){
  //    if (m.user == _currentUser){
  //      return Messages(role:Role.user,content: m.text);
  //    }else{
  //      return Messages(role: Role.assistant, content: m.text);
  //    }
 //   }).toList();
  //  final request =
 //   ChatCompleteText(
  //    model: GptTurbo0301ChatModel(),
  //    messages: _messagesHistory,
  //    maxToken: 200,
 //   );
  //  final response = await _OpenAI.onChatCompletion(request: request);
//    for(var element in response!.choices){
  //    if(element.message !=null){
   //     setState(() {
         // _messages.insert(
         //   0,
         //   ChatMessage(user: _gptChatUser,
          //    createdAt: DateTime.now(),
           //   text: element.message!.content
         //   ),
        //  );
       // });
    //  }
  //  }
  }
}
