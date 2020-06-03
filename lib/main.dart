import 'package:flare_dart/math/mat2d.dart';
import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controller.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flare Animation Looping',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StackedDisplay(),
    );
  }
}

class StackedDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (BuildContext context, orientation) {
        MediaQueryData media = MediaQuery.of(context);
        double width = media.size.width;
        double height = media.size.height;
        if (orientation == Orientation.portrait) {
          height /= 2.0;
        } else {
          width /= 2.0;
        }

        final List<Widget> children = [
          Container(
            width: width,
            height: height,
            child: WavingFlagDualPage(),
          ),
          Container(
            width: width,
            height: height,
            child: WavingFlagPage(),
          )
        ];

        return orientation == Orientation.portrait
            ? (Column(children: children))
            : (Row(children: children));
      },
    );
  }
}

class DualAnimationLoopController with FlareController {
  final String _startAnimationName;
  final String _loopAnimationName;
  final double _mix;

  DualAnimationLoopController(this._startAnimationName, this._loopAnimationName,
      [this._mix = 1.0]);

  bool _looping = false;
  double _duration = 0.0;
  ActorAnimation _startAnimation;
  ActorAnimation _loopAnimation;

  @override
  void initialize(FlutterActorArtboard artboard) {
    _startAnimation = artboard.getAnimation(_startAnimationName);
    _loopAnimation = artboard.getAnimation(_loopAnimationName);
  }

  @override
  bool advance(FlutterActorArtboard artboard, double elapsed) {
    _duration += elapsed;

    if (!_looping) {
      if (_duration < _startAnimation.duration) {
        _startAnimation.apply(_duration, artboard, _mix);
      } else {
        _looping = true;
        _duration -= _startAnimation.duration;
      }
    }
    if (_looping) {
      _duration %= _loopAnimation.duration;
      _loopAnimation.apply(_duration, artboard, _mix);
    }
    return true;
  }

  @override
  void setViewTransform(Mat2D viewTransform) {}
}

class WavingFlagDualPage extends StatefulWidget {
  @override
  State createState() => _WavingFlagDualPageState();
}

class _WavingFlagDualPageState extends State<WavingFlagDualPage> {
  final DualAnimationLoopController _loopController = DualAnimationLoopController('raise', 'wave');

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(25.0),
      child: FlareActor(
        'assets/flare/waving_golf_flag_dual_animation.flr',
        alignment: Alignment.bottomCenter,
        fit: BoxFit.contain,
        controller: _loopController,
        isPaused: !mounted,
      ),
    );
  }
}

class EndLoopController with FlareController {
  final String _animation;
  final double _loopAmount;
  final double _mix;

  double _duration = 0.0;
  ActorAnimation _actor;

  EndLoopController(this._animation, this._loopAmount, [this._mix = 0.5]);

  @override
  void initialize(FlutterActorArtboard artboard) {
    _actor = artboard.getAnimation(_animation);
  }

  @override
  bool advance(FlutterActorArtboard artboard, double elapsed) {
    _duration += elapsed;

    if (_duration > _actor.duration) {
      final double loopStart = _actor.duration - _loopAmount;
      final double loopProgress = _duration - _actor.duration;
      _duration = loopStart + loopProgress;
    }
    _actor.apply(_duration, artboard, _mix);
    return true;
  }

  @override
  void setViewTransform(Mat2D viewTransform) {}
}

class WavingFlagPage extends StatefulWidget {
  @override
  State createState() => _WavingFlagState();
}

class _WavingFlagState extends State<WavingFlagPage> {
  final EndLoopController _loopController =
      EndLoopController('up_and_wave', 2.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(25.0),
      child: FlareActor(
        'assets/flare/waving_golf_flag.flr',
        alignment: Alignment.bottomCenter,
        fit: BoxFit.contain,
        controller: _loopController,
        isPaused: !mounted,
      ),
    );
  }
}
