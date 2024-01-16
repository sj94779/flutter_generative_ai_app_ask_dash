import 'package:api_client/api_client.dart';

Future<void> main() async {
  final apiClient = ApiClient(
   baseUrl: 'http://development',
  //  baseUrl: 'https://us-central1-api-project-331331052067.cloudfunctions.net/function-1',
  );
  final questionsResource = apiClient.questionsResource;
  final answer = await questionsResource.getVertexResponse('random');
  // ignore: avoid_print
  print(answer);
}
