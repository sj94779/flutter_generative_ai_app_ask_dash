import 'package:api_client/api_client.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter_generative_ai_app_ask_dash/home/home.dart';
import 'package:flutter_generative_ai_app_ask_dash/results/results.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ResultsAnimationPhase {
  initial,
  results,
  resultsSourceAnswers,
}

const _searchBarTopPadding = 90.0;
const _questionBoxHeight = 84.0;
const _cardEnterDuration = Duration(seconds: 2);
const _cardExpandDuration = Duration(seconds: 1);
const _carouselEnterDuration = Duration(seconds: 1);

class ResultsView extends StatefulWidget {
  const ResultsView({super.key});

  @override
  State<ResultsView> createState() => ResultsViewState();
}

class ResultsViewState extends State<ResultsView>
    with TickerProviderStateMixin, TransitionScreenMixin {
  late Animation<double> _opacity;
  @override
  List<Status> get forwardEnterStatuses => [Status.thinkingToResults];

  @override
  List<Status> get backEnterStatuses => [Status.sourceAnswersBackToResults];

  @override
  void initializeTransitionController() {
    super.initializeTransitionController();

    enterTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    exitTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void initState() {
    super.initState();

    _opacity =
        Tween<double>(begin: 0, end: 1).animate(enterTransitionController);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: const _ResultsView(),
    );
  }
}

class _ResultsView extends StatelessWidget {
  const _ResultsView();

  @override
  Widget build(BuildContext context) {
    final status = context.select((HomeBloc bloc) => bloc.state.status);

    final response =
        context.select((HomeBloc bloc) => bloc.state.vertexResponse);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            BlueContainer(constraints: constraints),
            const Positioned(
              top: _searchBarTopPadding,
              left: 0,
              right: 0,
              child: Align(
                child: SearchBoxView(),
              ),
            ),
            if (status.isMovingToSeeSourceAnswers)
              Positioned(
                top: _questionBoxHeight + _searchBarTopPadding + 32,
                right: 100,
                child: CarouselView(documents: response.documents),
              ),
          ],
        );
      },
    );
  }
}

class BlueContainer extends StatefulWidget {
  @visibleForTesting
  const BlueContainer({
    required this.constraints,
    super.key,
  });

  final BoxConstraints constraints;

  @override
  State<BlueContainer> createState() => BlueContainerState();
}

class BlueContainerState extends State<BlueContainer>
    with TickerProviderStateMixin, TransitionScreenMixin {
  late Animation<Offset> _offsetEnterIn;
  late Animation<double> _rotationEnterIn;
  late Animation<RelativeRect> _positionExitOut;
  late Animation<double> _borderRadiusExitOut;
  @visibleForTesting
  late Animation<Size> sizeIn;

  @override
  List<Status> get forwardEnterStatuses => [Status.thinkingToResults];

  @override
  List<Status> get forwardExitStatuses => [Status.resultsToSourceAnswers];

  @override
  List<Status> get backEnterStatuses => [Status.sourceAnswersBackToResults];

  @override
  void initializeTransitionController() {
    super.initializeTransitionController();

    enterTransitionController = AnimationController(
      vsync: this,
      duration: _cardEnterDuration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          context.read<HomeBloc>().add(const HomeNavigated(Status.results));
        }
      });

    exitTransitionController = AnimationController(
      vsync: this,
      duration: _cardExpandDuration,
    )..addStatusListener((status) {
        final state = context.read<HomeBloc>().state;

        if (status == AnimationStatus.completed &&
            state.status == Status.resultsToSourceAnswers) {
          context.read<HomeBloc>().add(
                const HomeNavigated(
                  Status.seeSourceAnswers,
                ),
              );
        }

        if (status == AnimationStatus.dismissed &&
            state.status == Status.sourceAnswersBackToResults) {
          context.read<HomeBloc>().add(const HomeNavigated(Status.results));
        }
      });
  }

  @override
  void initState() {
    super.initState();

    _offsetEnterIn =
        Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: enterTransitionController,
        curve: Curves.decelerate,
      ),
    );

    _rotationEnterIn = Tween<double>(begin: 0.2, end: 0).animate(
      CurvedAnimation(
        parent: enterTransitionController,
        curve: Curves.decelerate,
      ),
    );

    _positionExitOut = RelativeRectTween(
      begin: const RelativeRect.fromLTRB(0, 230, 0, 0),
      end: RelativeRect.fill,
    ).animate(
      CurvedAnimation(
        parent: exitTransitionController,
        curve: Curves.decelerate,
      ),
    );

    _borderRadiusExitOut = Tween<double>(begin: 24, end: 0).animate(
      CurvedAnimation(
        parent: exitTransitionController,
        curve: Curves.easeInExpo,
      ),
    );

    _initSizeIn();
  }

  @override
  void didUpdateWidget(covariant BlueContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    _initSizeIn();
  }

  void _initSizeIn() {
    sizeIn = Tween<Size>(
      begin: const Size(659, 732),
      end: Size(
        widget.constraints.maxWidth,
        widget.constraints.maxHeight,
      ),
    ).animate(
      CurvedAnimation(
        parent: exitTransitionController,
        curve: Curves.decelerate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PositionedTransition(
      rect: _positionExitOut,
      child: Align(
        child: SlideTransition(
          position: _offsetEnterIn,
          child: RotationTransition(
            turns: _rotationEnterIn,
            child: AnimatedBuilder(
              animation: sizeIn,
              builder: (context, child) {
                return Container(
                  width: sizeIn.value.width,
                  height: sizeIn.value.height,
                  decoration: BoxDecoration(
                    color: VertexColors.googleBlue,
                    borderRadius: BorderRadius.all(
                      Radius.circular(_borderRadiusExitOut.value),
                    ),
                  ),
                  child: const _AiResponse(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _AiResponse extends StatefulWidget {
  const _AiResponse();

  @override
  State<_AiResponse> createState() => _AiResponseState();
}

class _AiResponseState extends State<_AiResponse>
    with TickerProviderStateMixin, TransitionScreenMixin {
  late Animation<double> _leftPaddingExitOut;
  late Animation<double> _topPaddingExitOut;

  @override
  List<Status> get forwardExitStatuses => [Status.resultsToSourceAnswers];

  @override
  List<Status> get backEnterStatuses => [Status.sourceAnswersBackToResults];

  @override
  void initializeTransitionController() {
    super.initializeTransitionController();

    enterTransitionController = AnimationController(
      vsync: this,
      duration: _cardEnterDuration,
    );

    exitTransitionController = AnimationController(
      vsync: this,
      duration: _cardExpandDuration,
    );
  }

  @override
  void initState() {
    super.initState();

    _leftPaddingExitOut = Tween<double>(begin: 48, end: 165).animate(
      CurvedAnimation(
        parent: exitTransitionController,
        curve: Curves.decelerate,
      ),
    );

    _topPaddingExitOut = Tween<double>(
      begin: 64,
      end: _questionBoxHeight + _searchBarTopPadding + 32,
    ).animate(
      CurvedAnimation(
        parent: exitTransitionController,
        curve: Curves.decelerate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HomeBloc>().state;

    return AnimatedBuilder(
      animation: _leftPaddingExitOut,
      builder: (context, child) => Padding(
        padding: EdgeInsets.fromLTRB(
          _leftPaddingExitOut.value,
          _topPaddingExitOut.value,
          48,
          64,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizeTransition(
                    sizeFactor: CurvedAnimation(
                      parent: exitTransitionController,
                      curve: Curves.decelerate,
                    ),
                    child: const BackToAnswerButton(),
                  ),
                  if (state.status == Status.results ||
                      state.status == Status.thinkingToResults ||
                      state.status == Status.sourceAnswersBackToResults)
                    const Expanded(child: SummaryView())
                  else
                    const Flexible(child: SummaryView()),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: SizedBox(
                      width: 563,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FeedbackButtons(
                            onLike: () {
                              context.read<HomeBloc>().add(
                                    const HomeAnswerFeedbackAdded(
                                      AnswerFeedback.good,
                                    ),
                                  );
                            },
                            onDislike: () {
                              context.read<HomeBloc>().add(
                                    const HomeAnswerFeedbackAdded(
                                      AnswerFeedback.bad,
                                    ),
                                  );
                            },
                          ),
                          if (!state.status.isSeeSourceAnswersVisible)
                            const SeeSourceAnswersButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CarouselView extends StatefulWidget {
  @visibleForTesting
  const CarouselView({
    required this.documents,
    super.key,
  });

  final List<VertexDocument> documents;

  @override
  State<CarouselView> createState() => CarouselViewState();
}

class CarouselViewState extends State<CarouselView>
    with TickerProviderStateMixin, TransitionScreenMixin {
  late Animation<Offset> _offsetEnterIn;
  late Animation<double> _rotationEnterIn;

  @override
  List<Status> get forwardEnterStatuses => [Status.resultsToSourceAnswers];

  @override
  List<Status> get backExitStatuses => [Status.sourceAnswersBackToResults];

  @override
  void initializeTransitionController() {
    super.initializeTransitionController();

    enterTransitionController = AnimationController(
      vsync: this,
      duration: _carouselEnterDuration,
    );

    exitTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void initState() {
    super.initState();

    _offsetEnterIn =
        Tween<Offset>(begin: const Offset(1.5, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: enterTransitionController,
        curve: Curves.decelerate,
      ),
    );

    _rotationEnterIn = Tween<double>(begin: 0.1, end: 0).animate(
      CurvedAnimation(
        parent: enterTransitionController,
        curve: Curves.decelerate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final index = context.watch<HomeBloc>().state.selectedIndex;
    return SlideTransition(
      position: _offsetEnterIn,
      child: RotationTransition(
        turns: _rotationEnterIn,
        child: SourcesCarouselView(
          documents: widget.documents,
          previouslySelectedIndex: index,
        ),
      ),
    );
  }
}
