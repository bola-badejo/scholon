import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:isapp/features/ai_tutor/models/ai_models.dart';
import 'package:isapp/features/ai_tutor/services/knowledge_index.dart';
import 'package:isapp/features/ai_tutor/services/prompt_builder.dart';

/// Build-time configuration:
///   flutter run --dart-define=SCHOLON_AI_URL=https://ai.example.com
///   flutter run --dart-define=SCHOLON_AI_MODEL=<model name served by the gateway>
/// Users never enter keys. The gateway authenticates them with their Firebase login.
class ScholonAiConfig {
  static const endpoint = String.fromEnvironment('SCHOLON_AI_URL');
  static const model = String.fromEnvironment('SCHOLON_AI_MODEL', defaultValue: 'scholon-tutor');
  static bool get configured => endpoint.isNotEmpty;
}

abstract class InferenceProvider {
  Future<ModelInfo> status();
  Stream<String> generate(PromptBundle prompt);
}

/// Scholon-operated inference (Layer B). Talks to the gateway in
/// server/ai_gateway, which speaks the OpenAI-compatible chat API in front of
/// a self-hosted model server. Streams tokens (SSE).
class ScholonHostedProvider implements InferenceProvider {
  ScholonHostedProvider({http.Client Function()? clientFactory}) : _clientFactory = clientFactory ?? http.Client.new;
  final http.Client Function() _clientFactory;

  @override
  Future<ModelInfo> status() async {
    if (!ScholonAiConfig.configured) {
      return const ModelInfo(name: 'Scholon hosted model', runtime: 'scholon-hosted', available: false, detail: 'The AI server is not configured for this build.');
    }
    try {
      final c = _clientFactory();
      final res = await c.get(Uri.parse('${ScholonAiConfig.endpoint}/health')).timeout(const Duration(seconds: 5));
      c.close();
      final ok = res.statusCode == 200;
      return ModelInfo(name: ScholonAiConfig.model, runtime: 'scholon-hosted', available: ok, detail: ok ? 'Online' : 'The AI server is unavailable (${res.statusCode}).');
    } catch (_) {
      return const ModelInfo(name: 'Scholon hosted model', runtime: 'scholon-hosted', available: false, detail: 'Cannot reach the AI server.');
    }
  }

  @override
  Stream<String> generate(PromptBundle prompt) {
    final controller = StreamController<String>();
    final client = _clientFactory();
    () async {
      try {
        final token = await FirebaseAuth.instance.currentUser?.getIdToken();
        if (token == null) throw StateError('Please sign in to use the AI tutor.');
        final req = http.Request('POST', Uri.parse('${ScholonAiConfig.endpoint}/v1/chat/completions'))
          ..headers.addAll({'Content-Type': 'application/json', 'Authorization': 'Bearer $token', 'Accept': 'text/event-stream'})
          ..body = jsonEncode({
            'model': ScholonAiConfig.model,
            'stream': true,
            'temperature': 0.3,
            'max_tokens': 900,
            'messages': [
              {'role': 'system', 'content': prompt.system},
              ...prompt.messages,
            ],
          });
        final res = await client.send(req).timeout(const Duration(seconds: 30));
        if (res.statusCode == 429) throw StateError('You are asking very quickly. Please wait a moment.');
        if (res.statusCode != 200) throw StateError('The AI server returned an error (${res.statusCode}).');
        await for (final line in res.stream.transform(utf8.decoder).transform(const LineSplitter())) {
          if (!line.startsWith('data:')) continue;
          final data = line.substring(5).trim();
          if (data == '[DONE]') break;
          try {
            final delta = (jsonDecode(data)['choices'][0]['delta']['content']) as String?;
            if (delta != null && delta.isNotEmpty) controller.add(delta);
          } catch (_) {/* ignore keep-alive or partial frames */}
        }
      } catch (e) {
        controller.addError(e);
      } finally {
        client.close();
        await controller.close();
      }
    }();
    controller.onCancel = client.close;
    return controller.stream;
  }
}

/// Layer A placeholder. On-device inference needs a native runtime
/// (llama.cpp / MediaPipe LLM / MLC / WebGPU), a downloaded model file and a
/// device-capability check. Until one is integrated and benchmarked this
/// reports itself as unavailable instead of pretending.
class OnDeviceProvider implements InferenceProvider {
  @override
  Future<ModelInfo> status() async => const ModelInfo(
        name: 'On-device model',
        runtime: 'on-device',
        available: false,
        detail: 'Not installed. On-device models are not yet bundled in this build.',
      );

  @override
  Stream<String> generate(PromptBundle prompt) => Stream.error(StateError('No on-device model is installed.'));
}

/// Layer C. Deterministic lookup in Scholon's own materials. NOT generative AI:
/// it returns the closest course passages and says so.
class OfflineLookup {
  static String answer(String question, List<ScoredChunk> hits) {
    if (hits.isEmpty) {
      return 'I could not find this in the Scholon materials available on your device. '
          'The AI tutor is not reachable right now, so I cannot explain it from general knowledge. '
          'Try different keywords, browse the course, or ask again when you are online.';
    }
    final b = StringBuffer('The AI tutor is not reachable, so here are the most relevant passages from your course materials:\n\n');
    for (var i = 0; i < hits.length && i < 3; i++) {
      final c = hits[i].chunk;
      var t = c.text.trim();
      if (t.length > 420) t = '${t.substring(0, 420)}...';
      b.writeln('**${i + 1}. ${c.title}**\n$t\n_${c.locator}_\n');
    }
    return b.toString().trim();
  }
}
