import 'package:app_ui/app_ui.dart';
import 'package:flutter_generative_ai_app_ask_dash/home/home.dart';
import 'package:flutter_generative_ai_app_ask_dash/question/question.dart';
import 'package:flutter_generative_ai_app_ask_dash/results/results.dart';
import 'package:flutter_generative_ai_app_ask_dash/thinking/thinking.dart';
import 'package:flutter_generative_ai_app_ask_dash/welcome/welcome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questions_repository/questions_repository.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc(context.read<QuestionsRepository>()),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  @visibleForTesting
  const HomeView({super.key});

  static const _dashRightKey = Key('dashAnimationContainer_right');
  static const _dashLeftKey = Key('dashAnimationContainer_left');

  @override
  Widget build(BuildContext context) {
    final status = context.select((HomeBloc bloc) => bloc.state.status);

    return Scaffold(
      backgroundColor:
          status.isWelcomeVisible ? VertexColors.arctic : VertexColors.white,
      body: Stack(
        children: [
          if (status.isWelcomeVisible)
            const Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: Background(),
            ),
          if (status.isWelcomeVisible) const WelcomeView(),
          if (status.isThinkingVisible) const ThinkingView(),
          if (status.isQuestionVisible) const QuestionView(),
          if (status.isResultsVisible) const ResultsView(),
          Positioned(
            top: 40,
            left: 48,
            child: Logo(hasDarkBackground: status.isSeeSourceAnswersVisible),
          ),
          if (status.isDashOnRight)
            const Positioned(
              bottom: 10,
              right: 10,
              child: DashAnimationContainer(
                right: true,
                key: _dashRightKey,
              ),
            ),
          if (status.isDashOnLeft)
            const Positioned(
              bottom: 10,
           //   right: 10,
              child: DashAnimationContainer(
                right: false,
                key: _dashLeftKey,
              ),
            ),
          // const Positioned.fill(
          //   child: EmojiBubbles(),
          // ),
        ],
      ),
    );
  }
}
