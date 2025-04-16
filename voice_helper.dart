import 'package:speech_to_text/speech_to_text.dart';

class VoiceHelper {
  final SpeechToText _speech = SpeechToText();

  Future<void> initSpeech(Function(String command) onResult) async {
    bool available = await _speech.initialize(
      onStatus: (status) => print("Speech status: $status"),
      onError: (error) => print("Speech error: $error"),
    );

    if (available) {
      _speech.listen(
        onResult: (result) {
          print("Speech result: ${result.recognizedWords}");
          if (result.finalResult) {
            onResult(result.recognizedWords);
          }
        },
        listenMode: ListenMode.confirmation,
        pauseFor: Duration(seconds: 3),
      );
    } else {
      print("Speech recognition not available");
    }
  }

  void stopListening() {
    _speech.stop();
  }
}
