// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hostelapplication/presentation/screen/auth/logInScreen.dart';
import 'package:hostelapplication/presentation/screen/auth/registrationScreen.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:page_transition/page_transition.dart';

class AnimationInfo {
  final AnimationTrigger trigger;
  final List<AnimationEffect> effects;

  AnimationInfo({required this.trigger, required this.effects});
}

enum AnimationTrigger {
  onPageLoad,
  onTap,
  onHover,
  onActionTrigger,
}

abstract class AnimationEffect {}

class VisibilityEffect extends AnimationEffect {
  final Duration duration;

  VisibilityEffect({required this.duration});
}

class FadeEffect extends AnimationEffect {
  final Curve curve;
  final Duration delay;
  final Duration duration;
  final double begin;
  final double end;

  FadeEffect({
    required this.curve,
    required this.delay,
    required this.duration,
    required this.begin,
    required this.end,
  });
}

class MoveEffect extends AnimationEffect {
  final Curve curve;
  final Duration delay;
  final Duration duration;
  final Offset begin;
  final Offset end;

  MoveEffect({
    required this.curve,
    required this.delay,
    required this.duration,
    required this.begin,
    required this.end,
  });
}

class ScaleEffect extends AnimationEffect {
  final Curve curve;
  final Duration delay;
  final Duration duration;
  final Offset begin;
  final Offset end;

  ScaleEffect({
    required this.curve,
    required this.delay,
    required this.duration,
    required this.begin,
    required this.end,
  });
}

extension AnimationExtensions on Widget {
  Widget animateOnPageLoad(AnimationInfo animationInfo) {
    final visibilityEffect = animationInfo.effects[0] as VisibilityEffect;
    final fadeEffect = animationInfo.effects[1] as FadeEffect;
    final moveEffect = animationInfo.effects[2] as MoveEffect;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: fadeEffect.begin, end: fadeEffect.end),
      duration: fadeEffect.duration,
      curve: fadeEffect.curve,
      builder: (BuildContext context, double value, Widget? child) {
        final opacity = value.clamp(0.0, 1.0);

        return Visibility(
          visible: visibilityEffect.duration > Duration.zero,
          child: Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(
                moveEffect.begin.dx +
                    (moveEffect.end.dx - moveEffect.begin.dx) * opacity,
                moveEffect.begin.dy +
                    (moveEffect.end.dy - moveEffect.begin.dy) * opacity,
              ),
              child: child,
            ),
          ),
        );
      },
      child: this,
    );
  }
}

const colors = Color.fromARGB(255, 6, 22, 33);

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final animationsMap = {
    'imageOnPageLoadAnimation1': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        VisibilityEffect(duration: 50.ms),
        FadeEffect(
          curve: Curves.elasticOut,
          delay: 50.ms,
          duration: 900.ms,
          begin: 0,
          end: 1,
        ),
        MoveEffect(
          curve: Curves.elasticOut,
          delay: 50.ms,
          duration: 900.ms,
          begin: const Offset(71, 0),
          end: const Offset(0, 0),
        ),
      ],
    ),
    'textOnPageLoadAnimation1': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        VisibilityEffect(duration: 150.ms),
        FadeEffect(
          curve: Curves.elasticOut,
          delay: 150.ms,
          duration: 900.ms,
          begin: 0,
          end: 1,
        ),
        MoveEffect(
          curve: Curves.elasticOut,
          delay: 150.ms,
          duration: 900.ms,
          begin: const Offset(71, 0),
          end: const Offset(0, 0),
        ),
      ],
    ),
    'textOnPageLoadAnimation2': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        VisibilityEffect(duration: 300.ms),
        FadeEffect(
          curve: Curves.elasticOut,
          delay: 300.ms,
          duration: 900.ms,
          begin: 0,
          end: 1,
        ),
        MoveEffect(
          curve: Curves.elasticOut,
          delay: 300.ms,
          duration: 900.ms,
          begin: const Offset(71, 0),
          end: const Offset(0, 0),
        ),
      ],
    ),
    'textOnPageLoadAnimation3': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        VisibilityEffect(duration: 400.ms),
        FadeEffect(
          curve: Curves.elasticOut,
          delay: 400.ms,
          duration: 900.ms,
          begin: 0,
          end: 1,
        ),
        MoveEffect(
          curve: Curves.elasticOut,
          delay: 400.ms,
          duration: 900.ms,
          begin: const Offset(71, 0),
          end: const Offset(0, 0),
        ),
      ],
    ),
    'buttonOnPageLoadAnimation1': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        VisibilityEffect(duration: 550.ms),
        FadeEffect(
          curve: Curves.elasticOut,
          delay: 550.ms,
          duration: 900.ms,
          begin: 0,
          end: 1,
        ),
        MoveEffect(
          curve: Curves.elasticOut,
          delay: 550.ms,
          duration: 900.ms,
          begin: const Offset(-79, 0),
          end: const Offset(0, 0),
        ),
      ],
    ),
    'rowOnPageLoadAnimation1': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        VisibilityEffect(duration: 650.ms),
        FadeEffect(
          curve: Curves.elasticOut,
          delay: 650.ms,
          duration: 600.ms,
          begin: 0,
          end: 1,
        ),
        MoveEffect(
          curve: Curves.elasticOut,
          delay: 650.ms,
          duration: 600.ms,
          begin: const Offset(-74, 0),
          end: const Offset(0, 0),
        ),
      ],
    ),
    'imageOnPageLoadAnimation2': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        VisibilityEffect(duration: 50.ms),
        FadeEffect(
          curve: Curves.elasticOut,
          delay: 50.ms,
          duration: 900.ms,
          begin: 0,
          end: 1,
        ),
        MoveEffect(
          curve: Curves.elasticOut,
          delay: 50.ms,
          duration: 900.ms,
          begin: const Offset(71, 0),
          end: const Offset(0, 0),
        ),
      ],
    ),
    'textOnPageLoadAnimation4': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        VisibilityEffect(duration: 300.ms),
        FadeEffect(
          curve: Curves.elasticOut,
          delay: 300.ms,
          duration: 900.ms,
          begin: 0,
          end: 1,
        ),
        MoveEffect(
          curve: Curves.elasticOut,
          delay: 300.ms,
          duration: 900.ms,
          begin: const Offset(71, 0),
          end: const Offset(0, 0),
        ),
      ],
    ),
    'textOnPageLoadAnimation5': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        VisibilityEffect(duration: 400.ms),
        FadeEffect(
          curve: Curves.elasticOut,
          delay: 400.ms,
          duration: 900.ms,
          begin: 0,
          end: 1,
        ),
        MoveEffect(
          curve: Curves.elasticOut,
          delay: 400.ms,
          duration: 900.ms,
          begin: const Offset(71, 0),
          end: const Offset(0, 0),
        ),
      ],
    ),
    'rowOnPageLoadAnimation2': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        VisibilityEffect(duration: 650.ms),
        FadeEffect(
          curve: Curves.elasticOut,
          delay: 650.ms,
          duration: 600.ms,
          begin: 0,
          end: 1,
        ),
        MoveEffect(
          curve: Curves.elasticOut,
          delay: 650.ms,
          duration: 600.ms,
          begin: const Offset(-74, 0),
          end: const Offset(0, 0),
        ),
      ],
    ),
    'imageOnPageLoadAnimation3': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        VisibilityEffect(duration: 50.ms),
        FadeEffect(
          curve: Curves.elasticOut,
          delay: 50.ms,
          duration: 900.ms,
          begin: 0,
          end: 1,
        ),
        MoveEffect(
          curve: Curves.elasticOut,
          delay: 50.ms,
          duration: 900.ms,
          begin: const Offset(71, 0),
          end: const Offset(0, 0),
        ),
      ],
    ),
    'textOnPageLoadAnimation6': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        VisibilityEffect(duration: 300.ms),
        FadeEffect(
          curve: Curves.elasticOut,
          delay: 300.ms,
          duration: 900.ms,
          begin: 0,
          end: 1,
        ),
        MoveEffect(
          curve: Curves.elasticOut,
          delay: 300.ms,
          duration: 900.ms,
          begin: const Offset(71, 0),
          end: const Offset(0, 0),
        ),
      ],
    ),
    'textOnPageLoadAnimation7': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        VisibilityEffect(duration: 400.ms),
        FadeEffect(
          curve: Curves.elasticOut,
          delay: 400.ms,
          duration: 900.ms,
          begin: 0,
          end: 1,
        ),
        MoveEffect(
          curve: Curves.elasticOut,
          delay: 400.ms,
          duration: 900.ms,
          begin: const Offset(71, 0),
          end: const Offset(0, 0),
        ),
      ],
    ),
    'buttonOnPageLoadAnimation2': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        VisibilityEffect(duration: 550.ms),
        FadeEffect(
          curve: Curves.elasticOut,
          delay: 550.ms,
          duration: 900.ms,
          begin: 0,
          end: 1,
        ),
        MoveEffect(
          curve: Curves.elasticOut,
          delay: 550.ms,
          duration: 900.ms,
          begin: const Offset(-79, 0),
          end: const Offset(0, 0),
        ),
      ],
    ),
    'rowOnPageLoadAnimation3': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        VisibilityEffect(duration: 650.ms),
        FadeEffect(
          curve: Curves.elasticOut,
          delay: 650.ms,
          duration: 600.ms,
          begin: 0,
          end: 1,
        ),
        MoveEffect(
          curve: Curves.elasticOut,
          delay: 650.ms,
          duration: 600.ms,
          begin: const Offset(-74, 0),
          end: const Offset(0, 0),
        ),
      ],
    ),
    'iconButtonOnPageLoadAnimation1': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        VisibilityEffect(duration: 600.ms),
        FadeEffect(
          curve: Curves.easeInOut,
          delay: 600.ms,
          duration: 600.ms,
          begin: 0,
          end: 1,
        ),
        MoveEffect(
          curve: Curves.easeInOut,
          delay: 600.ms,
          duration: 600.ms,
          begin: const Offset(66, 0),
          end: const Offset(0, 0),
        ),
      ],
    ),
    'iconButtonOnPageLoadAnimation2': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        VisibilityEffect(duration: 600.ms),
        FadeEffect(
          curve: Curves.easeInOut,
          delay: 600.ms,
          duration: 600.ms,
          begin: 0,
          end: 1,
        ),
        MoveEffect(
          curve: Curves.easeInOut,
          delay: 600.ms,
          duration: 600.ms,
          begin: const Offset(-51, 0),
          end: const Offset(0, 0),
        ),
      ],
    ),
  };

  // late SplashModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  T createModel<T>(BuildContext context, T Function() create) {
    return Provider.of<T>(context, listen: false) ?? create();
  }

  PageController? pageViewController;
  int get pageViewCurrentIndex => pageViewController != null &&
          pageViewController!.hasClients &&
          pageViewController!.page != null
      ? pageViewController!.page!.round()
      : 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          alignment: const AlignmentDirectional(0, 0),
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Stack(
                children: [
                  PageView(
                    controller: pageViewController ??=
                        PageController(initialPage: 0),
                    scrollDirection: Axis.horizontal,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: Stack(
                          alignment: const AlignmentDirectional(0, 0),
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      40, 0, 40, 0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(8, 0, 0, 0),
                                        child: const Text(
                                          'H HOUSE',
                                          style: TextStyle(
                                            fontFamily: 'Brazila',
                                            color: Colors.black,
                                            fontSize: 24,
                                          ),
                                        ).animateOnPageLoad(animationsMap[
                                            'textOnPageLoadAnimation1']!),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      40, 0, 40, 0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Expanded(
                                            child: const Text('FIND \nPROBLEM',
                                                    style: TextStyle(
                                                      fontFamily: 'Brazila',
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 38,
                                                    ))
                                                .animateOnPageLoad(animationsMap[
                                                    'textOnPageLoadAnimation2']!),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0, 40, 0, 0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Expanded(
                                              child: const Text(
                                                      'Find the problems yoy are facing in your hostel',
                                                      strutStyle: StrutStyle(
                                                          height: 1.2),
                                                      style: TextStyle(
                                                        fontFamily: 'Brazila',
                                                        color: Colors.black,
                                                        wordSpacing: 1,
                                                        fontSize: 16,
                                                      ))
                                                  .animateOnPageLoad(animationsMap[
                                                      'textOnPageLoadAnimation3']!),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      40, 0, 40, 0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Expanded(
                                              child: GestureDetector(
                                            onTap: () async {
                                              // Navigator.pushNamed(
                                              //     context, logInScreenRoute);

                                              await Navigator
                                                  .pushAndRemoveUntil(
                                                context,
                                                PageTransition(
                                                  type: PageTransitionType.fade,
                                                  duration: const Duration(
                                                      milliseconds: 300),
                                                  reverseDuration:
                                                      const Duration(
                                                          milliseconds: 300),
                                                  child:
                                                      const RegistrationScreen(),
                                                ),
                                                (r) => false,
                                              );
                                            },
                                            child: Container(
                                              width: 130,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: colors,
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                              ),
                                              alignment: Alignment.center,
                                              child: const Text(
                                                'Sign up',
                                                style: TextStyle(
                                                  fontFamily: 'Brazila',
                                                  color: Colors.white,
                                                  fontSize: 19,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            ).animateOnPageLoad(animationsMap[
                                                'buttonOnPageLoadAnimation1']!),
                                          )),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0, 16, 0, 0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text('Already have account?',
                                                style: TextStyle(
                                                  fontFamily: 'Brazila',
                                                  color: Colors.black,
                                                )),
                                            GestureDetector(
                                              onTap: () async {
                                                await Navigator
                                                    .pushAndRemoveUntil(
                                                  context,
                                                  PageTransition(
                                                    type:
                                                        PageTransitionType.fade,
                                                    duration: const Duration(
                                                        milliseconds: 300),
                                                    reverseDuration:
                                                        const Duration(
                                                            milliseconds: 300),
                                                    child: LogInScreen(),
                                                  ),
                                                  (r) => false,
                                                );
                                              },
                                              child: const Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(4, 0, 0, 0),
                                                child: Text('Log in',
                                                    style: TextStyle(
                                                      fontFamily: 'Brazila',
                                                      color: Colors.black,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    )),
                                              ),
                                            ),
                                          ],
                                        ).animateOnPageLoad(animationsMap[
                                            'rowOnPageLoadAnimation1']!),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: Stack(
                          alignment: const AlignmentDirectional(0, 0),
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              40, 0, 40, 0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Image.asset(
                                            'assets/images/logo1.png',
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                          ).animateOnPageLoad(animationsMap[
                                              'imageOnPageLoadAnimation2']!),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 10,
                                      height: 200,
                                      decoration: const BoxDecoration(),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              40, 0, 40, 0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Expanded(
                                                child: const Text(
                                                        'POST YOUR COMPLAINTS',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Brazila',
                                                            color: Colors.black,
                                                            fontSize: 42,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500))
                                                    .animateOnPageLoad(
                                                        animationsMap[
                                                            'textOnPageLoadAnimation4']!),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0, 16, 0, 0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Expanded(
                                                  child: const Text(
                                                          'FiLog in to your account and upload the problem you are facing',
                                                          strutStyle:
                                                              StrutStyle(
                                                                  height: 1.2),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Brazila',
                                                            color: Colors.black,
                                                            wordSpacing: 1,
                                                            fontSize: 16,
                                                          ))
                                                      .animateOnPageLoad(
                                                          animationsMap[
                                                              'textOnPageLoadAnimation5']!),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              40, 36, 40, 0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0, 16, 0, 0),
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await Navigator
                                                    .pushAndRemoveUntil(
                                                  context,
                                                  PageTransition(
                                                    type:
                                                        PageTransitionType.fade,
                                                    duration: const Duration(
                                                        milliseconds: 300),
                                                    reverseDuration:
                                                        const Duration(
                                                            milliseconds: 300),
                                                    child: LogInScreen(),
                                                  ),
                                                  (r) => false,
                                                );
                                              },
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Text('',
                                                      style: TextStyle(
                                                        fontFamily: 'Brazila',
                                                        color: Colors.black,
                                                      )),
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                4, 0, 0, 0),
                                                    child: Text('',
                                                        style: TextStyle(
                                                          fontFamily: 'Brazila',
                                                          color: Colors.black,
                                                        )),
                                                  ),
                                                ],
                                              ),
                                            ).animateOnPageLoad(animationsMap[
                                                'rowOnPageLoadAnimation2']!),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: Stack(
                          alignment: const AlignmentDirectional(0, 0),
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      40, 0, 40, 0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Image.asset(
                                        'assets/images/logo1.png',
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ).animateOnPageLoad(animationsMap[
                                          'imageOnPageLoadAnimation3']!),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      40, 0, 40, 0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Expanded(
                                            child: const Text(
                                                    'BE SMART \nSOLVE PROBLEM',
                                                    style: TextStyle(
                                                      fontFamily: 'Brazila',
                                                      color: Colors.black,
                                                      fontSize: 36,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ))
                                                .animateOnPageLoad(animationsMap[
                                                    'textOnPageLoadAnimation6']!),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0, 24, 0, 0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Expanded(
                                              child: const Text(
                                                      'Thats it! your problem will be shown to the management and will be solved soon',
                                                      strutStyle: StrutStyle(
                                                          height: 1.2),
                                                      style: TextStyle(
                                                        fontFamily: 'Brazila',
                                                        color: Colors.black,
                                                        wordSpacing: 1,
                                                        fontSize: 16,
                                                      ))
                                                  .animateOnPageLoad(animationsMap[
                                                      'textOnPageLoadAnimation7']!),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      40, 0, 40, 0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Expanded(
                                              child: GestureDetector(
                                            onTap: () async {
                                              await Navigator
                                                  .pushAndRemoveUntil(
                                                context,
                                                PageTransition(
                                                  type: PageTransitionType.fade,
                                                  duration: const Duration(
                                                      milliseconds: 300),
                                                  reverseDuration:
                                                      const Duration(
                                                          milliseconds: 300),
                                                  child: LogInScreen(),
                                                ),
                                                (r) => false,
                                              );
                                            },
                                            child: Container(
                                              width: 130,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: colors,
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                              ),
                                              alignment: Alignment.center,
                                              child: const Text(
                                                'Login',
                                                style: TextStyle(
                                                  fontFamily: 'Brazila',
                                                  color: Colors.white,
                                                  fontSize: 19,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            ).animateOnPageLoad(animationsMap[
                                                'buttonOnPageLoadAnimation1']!),
                                          )),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0, 16, 0, 0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text('Don\'t have account?',
                                                style: TextStyle(
                                                  fontFamily: 'Brazila',
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.normal,
                                                )),
                                            GestureDetector(
                                              onTap: () async {
                                                await Navigator
                                                    .pushAndRemoveUntil(
                                                  context,
                                                  PageTransition(
                                                    type:
                                                        PageTransitionType.fade,
                                                    duration: const Duration(
                                                        milliseconds: 300),
                                                    reverseDuration:
                                                        const Duration(
                                                            milliseconds: 300),
                                                    child:
                                                        const RegistrationScreen(),
                                                  ),
                                                  (r) => false,
                                                );
                                              },
                                              child: const Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(4, 0, 0, 0),
                                                child: Text('Sign up',
                                                    style: TextStyle(
                                                      fontFamily: 'Brazila',
                                                      color: Colors.black,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    )),
                                              ),
                                            ),
                                          ],
                                        ).animateOnPageLoad(animationsMap[
                                            'rowOnPageLoadAnimation3']!),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: const AlignmentDirectional(0, 1),
                    child: Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 30),
                      child: SmoothPageIndicator(
                        controller: pageViewController ??=
                            PageController(initialPage: 0),
                        count: 3,
                        axisDirection: Axis.horizontal,
                        onDotClicked: (i) async {
                          await pageViewController!.animateToPage(
                            i,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.ease,
                          );
                        },
                        effect: const ExpandingDotsEffect(
                          expansionFactor: 4,
                          spacing: 8,
                          radius: 16,
                          dotWidth: 8,
                          dotHeight: 8,
                          dotColor: Color(0xFF9E9E9E),
                          activeDotColor: colors,
                          paintStyle: PaintingStyle.fill,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: const AlignmentDirectional(0, 1),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(40, 0, 40, 12),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () async {
                        await pageViewController?.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.longArrowAltLeft,
                        color: colors,
                        size: 14,
                      ),
                    ).animateOnPageLoad(
                        animationsMap['iconButtonOnPageLoadAnimation1']!),
                    IconButton(
                      onPressed: () async {
                        await pageViewController?.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.longArrowAltRight,
                        color: colors,
                        size: 14,
                      ),
                    ).animateOnPageLoad(
                        animationsMap['iconButtonOnPageLoadAnimation2']!),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
