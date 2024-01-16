import 'package:api_client/api_client.dart';
import 'package:flutter_generative_ai_app_ask_dash/animations.dart';
import 'package:flutter_generative_ai_app_ask_dash/app/app.dart';
import 'package:flutter_generative_ai_app_ask_dash/bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:questions_repository/questions_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrap(
    () async {
      final apiClient = ApiClient(
        baseUrl: 'https://us-central1-api-project-331331052067.cloudfunctions.net/function-1',
      );

      final questionsRepository =
          QuestionsRepository(apiClient.questionsResource);

      final dashAnimations = DashAnimations();

      await dashAnimations.load();

      return App(
        questionsRepository: questionsRepository,
        dashAnimations: dashAnimations,
      );
    },
  );
}
