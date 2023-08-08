import 'package:aibot/model/chatModel.dart';
import 'package:aibot/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:iconsax/iconsax.dart';

final flutterTts = FlutterTts();

class ChatMessageWidget extends StatelessWidget {
  const ChatMessageWidget({
    Key? key,
    required this.text,
    required this.chatMessageType,
    this.showTypingIndicator = false,
  }) : super(key: key);

  final String text;
  final ChatMessageType chatMessageType;
  final bool showTypingIndicator;

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: chatMessageType == ChatMessageType.bot
          ? Alignment.bottomLeft
          : Alignment.bottomRight,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              if (chatMessageType == ChatMessageType.bot)
                Container(
                  margin: const EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(
                    backgroundColor: const Color.fromRGBO(16, 163, 127, 1),
                    child: Image.asset(
                      'Assets/images/4859906.png',
                      color: Colors.white,
                      scale: 1.5,
                    ),
                  ),
                )
              else
                Expanded(child: Container()),
              Expanded(
                flex: 5,
                child: Align(
                  alignment: chatMessageType == ChatMessageType.bot
                      ? Alignment.topLeft
                      : Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: chatMessageType == ChatMessageType.bot
                          ? ColorSets.botBackgroundColor
                          : const Color.fromARGB(255, 44, 44, 52),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        if (showTypingIndicator) TypingIndicator(),
                        if (!showTypingIndicator)
                          Text(
                            text,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        // Add the text-to-speech IconButton here
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (chatMessageType != ChatMessageType.bot)
                Container(
                  margin: const EdgeInsets.only(left: 16.0),
                  child: CircleAvatar(
                    child: Image.asset(
                      'Assets/images/chat.png',
                      color: Colors.white,
                      scale: 1.5,
                    ),
                  ),
                )
              else
                Expanded(child: Container()),
            ],
          ),
          if (!showTypingIndicator && chatMessageType == ChatMessageType.bot)
            Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                onPressed: () {
                  systemSpeak(text); // Trigger text-to-speech here
                },
                icon: Icon(Iconsax.voice_cricle),
              ),
            ),
        ],
      ),
    );
  }
}

class TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 16,
      width: 120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 8,
            width: 8,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          Container(
            height: 8,
            width: 8,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          Container(
            height: 8,
            width: 8,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
