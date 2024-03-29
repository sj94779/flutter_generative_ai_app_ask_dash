import 'package:app_ui/app_ui.dart';
import 'package:flutter_generative_ai_app_ask_dash/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phased/phased.dart';

class Background extends StatefulWidget {
  const Background({
    super.key,
    this.backgroundState,
  });

  final PhasedState<BackgroundPhase>? backgroundState;

  @override
  State<Background> createState() => _BackgroundState();
}

class _BackgroundState extends State<Background> {
  late final _circlesState = widget.backgroundState ??
      PhasedState<BackgroundPhase>(
        values: BackgroundPhase.values,
        initialValue: BackgroundPhase.initial,
        autostart: false,
      );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _circlesState.value = BackgroundPhase.circlesIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listener: (BuildContext context, state) {
        if (state.status == Status.welcomeToAskQuestion) {
          _circlesState.value = BackgroundPhase.circlesOut;
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final baseRadius = constraints.maxWidth / 7;
          final offset = (baseRadius * 8) - constraints.maxWidth;
          final baseMediumRadius = baseRadius * .84;
          final baseSmallRadius = baseRadius * .61;

          return _Circles(
            state: _circlesState,
            baseRadius: baseRadius,
            offset: offset,
            baseMediumRadius: baseMediumRadius,
            baseSmallRadius: baseSmallRadius,
            baseContainerHeight: constraints.maxHeight,
          );
        },
      ),
    );
  }
}

@visibleForTesting
enum BackgroundPhase {
  initial,
  circlesIn,
  circlesOut,
}

class _Circles extends Phased<BackgroundPhase> {
  const _Circles({
    required super.state,
    required this.baseRadius,
    required this.offset,
    required this.baseMediumRadius,
    required this.baseSmallRadius,
    required this.baseContainerHeight,
  });

  final double baseRadius;
  final double offset;
  final double baseMediumRadius;
  final double baseSmallRadius;
  final double baseContainerHeight;

  @override
  Widget build(BuildContext context) {
    final size = baseRadius * 2;
    const duration = Duration(seconds: 1);
    const scaleDuration = Duration(milliseconds: 500);
    const curve = Curves.decelerate;
    return Stack(
      children: [
        AnimatedPositioned(
          curve: curve,
          left: state.phaseValue(
            values: {
              BackgroundPhase.circlesOut: -offset * 2,
            },
            defaultValue: -offset,
          ),
          duration: duration,
          top: state.phaseValue(
            values: {
              BackgroundPhase.initial: baseContainerHeight,
            },
            defaultValue: baseContainerHeight / 2 - baseRadius,
          ),
          child: Circle(radius: baseRadius),
        ),
        AnimatedPositioned(
          curve: curve,
          duration: duration,
          left: state.phaseValue(
            values: {
              BackgroundPhase.circlesOut: -(size * 2 - offset),
            },
            defaultValue: size - offset,
          ),
          top: state.phaseValue(
            values: {
              BackgroundPhase.initial: -size,
            },
            defaultValue: baseContainerHeight / 2 - baseRadius,
          ),
          child: SizedBox.square(
            dimension: baseRadius * 2,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Circle(
                  radius: baseRadius,
                ),
                Circle(
                  radius: baseMediumRadius,
                  borderColor: VertexColors.lilac,
                ),
                Circle(
                  radius: baseSmallRadius,
                  borderColor: VertexColors.lilac,
                  dotted: true,
                ),
              ],
            ),
          ),
        ),
        AnimatedPositioned(
          curve: curve,
          duration: duration,
          left: size * 2 - offset,
          top: state.phaseValue(
            values: {
              BackgroundPhase.initial: baseContainerHeight,
            },
            defaultValue: baseContainerHeight / 2 - baseRadius,
          ),
          child: AnimatedScale(
            duration: scaleDuration,
            scale: state.phaseValue(
              values: {
                BackgroundPhase.circlesOut: 4,
              },
              defaultValue: 1,
            ),
            child: Circle(radius: baseRadius),
          ),
        ),
        AnimatedPositioned(
          curve: curve,
          duration: duration,
          left: state.phaseValue(
            values: {
              BackgroundPhase.circlesOut: size * 4,
            },
            defaultValue: size * 3 - offset,
          ),
          top: state.phaseValue(
            values: {
              BackgroundPhase.initial: -size,
            },
            defaultValue: baseContainerHeight / 2 - baseRadius,
          ),
          child: Circle(radius: baseRadius),
        ),
      ],
    );
  }
}
