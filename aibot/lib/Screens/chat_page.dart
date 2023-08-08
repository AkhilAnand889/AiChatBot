import 'dart:convert';

import 'package:aibot/ChatGptApi/Api.dart';
import 'package:aibot/Screens/Auth.dart';
import 'package:aibot/Screens/appbarTitle.dart';
import 'package:aibot/Screens/neonglow.dart';
import 'package:aibot/Screens/signoutfade.dart';
import 'package:aibot/model/chatModel.dart';
import 'package:aibot/model/response_data.dart';
import 'package:aibot/model/sqflite.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../utils/colors.dart';
import 'chat_message.dart';

final storage = FlutterSecureStorage();

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final List<Map<String, dynamic>> _messagess = [];
  final List<ChatMessage> _historyMessages = [];
  late bool isLoading;
  bool showHistoryMessagesDialog = false;
  final storage = const FlutterSecureStorage();
  String? email;
  String? firstname;
  final _speechToText = SpeechToText();
  int start = 0;
  int delay = 200;
  final flutterTts = FlutterTts();
  String lastWords = '';
  bool _isSpeechToTextInitialized = false;
  final _responseMessages = [];
  @override
  void initState() {
    super.initState();
    isLoading = false;
    _loadUserInfo();
    initSpeechToText().then((value) {
      setState(() {
        _isSpeechToTextInitialized = true;
      });
    });
    start = 200;
    DatabaseHelper.initializeDatabase();
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    bool isAvailable = await _speechToText.initialize();
    if (!isAvailable) {
      print('Speech recognition not available');
      return;
    }
    setState(() {});
  }

  Future<void> startListening(BuildContext context) async {
    await _speechToText.listen(
      onResult: (result) async {
        setState(() {
          lastWords = result.recognizedWords;
        });

        await Future.delayed(Duration(seconds: 1));

        if (lastWords != result.recognizedWords) {
          return;
        }

        print(lastWords);
      },
    );

    setState(() {});
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
    print(lastWords);
  }

void _deleteAllData() async {
  await DatabaseHelper.deleteAllResponses();
  print('All data deleted from the database');
}


  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  @override
  void dispose() {
    super.dispose();
    _speechToText.stop();
    flutterTts.stop();
  }

//load user info
  Future<void> _loadUserInfo() async {
    email = await storage.read(key: 'email');
    firstname = await storage.read(key: 'firstname');
  }

  Future<void> deleteMessage(String messageId, int index) async {
    try {
      final storage = FlutterSecureStorage();
      final token = await storage.read(key: 'idToken');
      final response = await http.delete(
        Uri.parse(
            'https://hmwx95k5yi.execute-api.ap-south-1.amazonaws.com/dev/controller/deletemessage/$messageId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token!,
        },
        body: jsonEncode({
          'id': messageId,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _messagess.removeAt(index);
        });
      } else {
        print('Failed to delete message: ${response.statusCode}');
      }
    } catch (error) {
      print('Failed to delete message: $error');
    }
  }

  // Future<void> deleteAllMessages() async {
  //   final url =
  //       'https://xjscbnop1b.execute-api.ap-south-1.amazonaws.com/dev/controller/AllDeletemessage';

  //   try {
  //     final response = await http.delete(Uri.parse(url));

  //     if (response.statusCode == 200) {
  //       setState(() {
  //         _messagess.remove(_messagess);
  //       });
  //       print('All messages deleted successfully');
  //     } else {
  //       print('Error deleting messages: ${response.statusCode}');
  //     }
  //   } catch (error) {
  //     print('Error deleting messages: $error');
  //   }
  // }
// Function to retrieve data from SQLite database based on id
  Future<List<ResponseData>> fetchResponse(String id,String question) async {
    List<ResponseData> responses = await DatabaseHelper.getAllResponsesByIdAndQuestion(id, question);
    print('???????????????????????????????????????????$responses');
    return responses;
  }

  void _showResponseDialog(
    String id,
    String question
  ) async {
    List<ResponseData> responses = await fetchResponse(
      id,
      question
    );
    print(responses);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Response Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: responses.map((response) {
              return Text(response.data); // Display response data
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              userLogOut();
              Navigator.pushReplacement(
                context,
                FadeScaleRoute(builder: (context) => LoginScreen()),
              );
            },
            icon: const Icon(Iconsax.logout),
            color: Theme.of(context).colorScheme.background,
          ),
        ],
        toolbarHeight: 60,
        title: AppBarTitle(),
        backgroundColor: ColorSets.botBackgroundColor,
      ),
      backgroundColor: ColorSets.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Text(
              lastWords,
              style: const TextStyle(fontSize: 23.0, color: Colors.white),
            ),
            _buildList(),
            Visibility(
              visible: isLoading,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  _buildInput(),
                  _buildSubmit(),
                ],
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: ColorSets.backgroundColor,
              ),
              child: FutureBuilder<Map<String, dynamic>>(
                future: fetchUserAttributes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const AlertDialog(
                      content: Text('Loading....'),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final userAttributes = snapshot.data ?? {};
                    final firstName = userAttributes['given_name'] ?? '';
                    final email = userAttributes['email'] ?? '';

                    return UserAccountsDrawerHeader(
                      decoration:
                          const BoxDecoration(color: ColorSets.backgroundColor),
                      currentAccountPictureSize: const Size.square(60),
                      accountName: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage:
                                const AssetImage('Assets/images/2156652.png'),
                            child: Text(
                              firstName.isNotEmpty ? firstName[0] : 'U',
                              style:
                                  TextStyle(fontSize: 25.0, color: Colors.blue),
                            ),
                          ),
                          SizedBox(width: 20.0),
                          Text(
                            firstName,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 5,
                            ),
                          ),
                        ],
                      ),
                      accountEmail: Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Text(
                          email,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w400),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: retrieveUserMessages(),
                builder: (BuildContext context,
                    AsyncSnapshot<Map<String, dynamic>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return AlertDialog(
                      content: Text('Loading....'),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final filteredItems = snapshot.data?['filteredItems'] ?? [];
                    final responseItems = snapshot.data?['responseItems'] ?? [];

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredItems.length,
                      itemBuilder: (BuildContext context, int index) {
                        final filteredItem = filteredItems[index];
                        final responseItem = responseItems[index];

                        final text = filteredItem['message'] as String?;
                        final messageId = responseItem['messageId'] as String;

                        return ListTile(
                          leading: const Icon(Icons.message),
                          title: GestureDetector(
                            child: Text(text ?? 'No text'),
                            onTap: () async {
                              print(
                                  '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<$messageId');
                                  print('))))))))))))))))))))))))))))))))))))))))))))))$text');
                                final xx = await DatabaseHelper.getAllIds();
                                print('......................................................................$xx');
                                if (xx.contains(messageId)) {
                                  _showResponseDialog(messageId,text!);
                                }else{print(' ********************************there is no id youre provided');}
                              
                            },
                          ),
                          trailing: InkWell(
                            child: const Icon(Icons.delete),
                            onTap: () {
                              setState(() {
                                deleteMessage(messageId, index);
                              });
                              print('id sucessfully deleted from sqflite');
                            },
                          ),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
            Row(
              children: [
                const SizedBox(width: 45),
                // GestureDetector(
                //   onTap: deleteAllMessages,
                //   child: Container(
                //     width: 160,
                //     height: 40,
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(25),
                //       gradient: LinearGradient(
                //         colors: [
                //           Color.fromARGB(255, 106, 101, 101),
                //           Color.fromARGB(255, 0, 0, 0),
                //         ],
                //         begin: Alignment.topLeft,
                //         end: Alignment.bottomCenter,
                //       ),
                //       boxShadow: [
                //         BoxShadow(
                //           color: Color.fromARGB(255, 74, 145, 183)
                //               .withOpacity(0.4),
                //           offset: Offset(0, 4),
                //           blurRadius: 9,
                //           spreadRadius: 2,
                //         ),
                //       ],
                //     ),
                //     child: Center(
                //       child: isLoading
                //           ? SizedBox(
                //               width: 20,
                //               height: 20,
                //               child: CircularProgressIndicator(
                //                 strokeWidth: 2.0,
                //                 valueColor:
                //                     AlwaysStoppedAnimation<Color>(Colors.white),
                //               ),
                //             )
                //           : Text(
                //               'Delete All',
                //               style: TextStyle(
                //                 color: Colors.white,
                //                 fontWeight: FontWeight.bold,
                //                 fontSize: 17,
                //                 letterSpacing: 3.0,
                //               ),
                //             ),
                //     ),
                //   ),
                // ),
                // const SizedBox(width: 4),
                // IconButton(
                //     icon: Icon(Icons.delete),
                //     onPressed: () => deleteAllMessages()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmit() {
    return Visibility(
      visible: !isLoading,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: NeonGlowButton(
          onPressed: () async {
            var question = _textController.text;
            setState(() {
              _historyMessages.add(
                ChatMessage(
                  text: question,
                  chatMessageType: ChatMessageType.user,
                ),
              );
              _messages.add(
                ChatMessage(
                  text: question,
                  chatMessageType: ChatMessageType.user,
                ),
              );
              isLoading = true;
            });
            var input = _textController.text;
            _textController.clear();
            Future.delayed(const Duration(milliseconds: 50))
                .then((_) => _scrollDown());
            try {
              sendMessageToBackend(input).then((response) async {
                setState(() {
                  isLoading = false;
                  final responseData = response['response'];
                  final messageId = response['id'];

                  if (responseData is List<dynamic>) {
                    final responseList = responseData;
                    final joinedResponse = responseList.join('\n');
                    _responseMessages.add(joinedResponse);

                    if (joinedResponse.isNotEmpty) {
                      _messages.add(
                        ChatMessage(
                          text: joinedResponse,
                          chatMessageType: ChatMessageType.bot,
                        ),
                      );
                    }
                    DatabaseHelper.insertResponse(
                      ResponseData(
                        id: messageId,
                        question: question,
                        data: joinedResponse,
                      ),
                    );
                    print(
                        '________________________________successfully saved to sqflite');
                  } else if (responseData is String) {
                    final responseString = responseData;
                    _responseMessages.add(responseString);
                    if (responseString.isNotEmpty) {
                      _messages.add(
                        ChatMessage(
                          text: responseString,
                          chatMessageType: ChatMessageType.bot,
                        ),
                      );
                    }
                  } else if (responseData is List<dynamic> &&
                      responseData.isEmpty) {
                    _messages.add(
                      ChatMessage(
                        chatMessageType: ChatMessageType.bot,
                        text: response['message'] as String,
                      ),
                    );
                  } else if (response.isEmpty) {
                    _messages.add(
                      ChatMessage(
                        chatMessageType: ChatMessageType.bot,
                        text:
                            'As an AI language model, I am not capable of doing this',
                      ),
                    );
                  }
                });

                _textController.clear();
                Future.delayed(const Duration(milliseconds: 50))
                    .then((_) => _scrollDown());
              });
            } catch (err) {
              print('+++++++++++++++++++++++++++++++++++++++++++++$err');
            }
          },
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        margin: const EdgeInsets.only(bottom: 12, left: 12),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 0, 0, 0),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(12),
            bottom: Radius.circular(12),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _textController,
                minLines: 1,
                maxLines: 6,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color.fromARGB(255, 4, 4, 4),
                  hintText: 'Type in...',
                  hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(left: 12.0),
                ),
              ),
            ),
            Container(
              width: 35,
              height: 43,
              child: ZoomIn(
                delay: Duration(milliseconds: start + 3 * delay),
                child: FloatingActionButton(
                  onPressed: _isSpeechToTextInitialized
                      ? () async {
                          try {
                            if (await _speechToText.hasPermission &&
                                _speechToText.isNotListening) {
                              await startListening(context);
                            } else if (_speechToText.isListening) {
                              await stopListening();
                              await sendMessageToBackend(lastWords)
                                  .then((response) {
                                setState(() {
                                  isLoading = false;
                                  if (response['response'] is List<dynamic>) {
                                    final responseList =
                                        response['response'] as List<dynamic>;
                                    final joinedResponse =
                                        responseList.join('\n');
                                    _messages.add(
                                      ChatMessage(
                                        text: joinedResponse,
                                        chatMessageType: ChatMessageType.bot,
                                      ),
                                    );
                                  } else if (response['response'] is String) {
                                    _messages.add(
                                      ChatMessage(
                                        text: response['response'] as String,
                                        chatMessageType: ChatMessageType.bot,
                                      ),
                                    );
                                  }
                                });
                              });
                            }
                          } catch (err) {
                            print(err);
                          }
                        }
                      : null,
                  child: Icon(
                    _speechToText.isListening ? Icons.stop : Icons.mic,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return Expanded(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height,
        ),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _messages.length,
          itemBuilder: (context, index) {
            var message = _messages[index];
            return Align(
              alignment: Alignment.topRight,
              child: ChatMessageWidget(
                text: message.text,
                chatMessageType: message.chatMessageType,
              ),
            );
          },
        ),
      ),
    );
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}
