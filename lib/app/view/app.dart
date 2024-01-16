import 'package:app_ui/app_ui.dart';
import 'package:flutter_generative_ai_app_ask_dash/animations.dart';
import 'package:flutter_generative_ai_app_ask_dash/home/home.dart';
import 'package:flutter_generative_ai_app_ask_dash/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questions_repository/questions_repository.dart';

class App extends StatelessWidget {
  const App({
    required this.questionsRepository,
    required this.dashAnimations,
    super.key,
  });

  final QuestionsRepository questionsRepository;
  final DashAnimations dashAnimations;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(
          value: questionsRepository,
        ),
        RepositoryProvider.value(
          value: dashAnimations,
        ),
      ],
      child: MaterialApp(
        theme: VertexTheme.standard,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HomePage(),
      ),
    );
  }
}
