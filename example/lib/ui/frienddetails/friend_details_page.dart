import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'dart:async';

import 'package:example/ui/frienddetails/footer/friend_detail_footer.dart';
import 'package:example/ui/frienddetails/footer/skills_showcase.dart';
import 'package:example/ui/frienddetails/friend_detail_body.dart';
import 'package:example/ui/frienddetails/header/friend_detail_header.dart';
import 'package:example/ui/friends/friend.dart';

import 'package:highlighter_coachmark/highlighter_coachmark.dart';

bool _coachMarkIsShown = false;

class FriendDetailsPage extends StatefulWidget {
  FriendDetailsPage(
    this.friend, {
    @required this.avatarTag,
  });

  final Friend friend;
  final Object avatarTag;

  @override
  _FriendDetailsPageState createState() => new _FriendDetailsPageState();
}

class _FriendDetailsPageState extends State<FriendDetailsPage> {
  @override
  void initState() {
    super.initState();
    if (!_coachMarkIsShown) {
      Timer(Duration(seconds: 1), () => showCoachMarkBadges());
    }
  }

  @override
  Widget build(BuildContext context) {
    var linearGradient = const BoxDecoration(
      gradient: const LinearGradient(
        begin: FractionalOffset.centerRight,
        end: FractionalOffset.bottomLeft,
        colors: <Color>[
          const Color(0xFF413070),
          const Color(0xFF2B264A),
        ],
      ),
    );

    return new Scaffold(
      body: new SingleChildScrollView(
        child: new Container(
          decoration: linearGradient,
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new FriendDetailHeader(
                widget.friend,
                avatarTag: widget.avatarTag,
              ),
              new Padding(
                padding: const EdgeInsets.all(24.0),
                child: new FriendDetailBody(widget.friend),
              ),
              new FriendShowcase(widget.friend),
            ],
          ),
        ),
      ),
    );
  }

  void showCoachMarkBadges() {
    CoachMark coachMarkBadges = CoachMark();
    RenderBox target =
        FriendDetailBody.badgesRowKey.currentContext.findRenderObject();

    Rect markRect = target.localToGlobal(Offset.zero) & target.size;

    coachMarkBadges.show(
        targetContext: FriendDetailBody.badgesRowKey.currentContext,
        markRect: markRect.inflate(15.0),
        markShape: BoxShape.rectangle,
        children: [
          Positioned(
              top: markRect.top,
              left: markRect.right + 25.0,
              child: Text("State icons:",
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ))),
          Positioned(
              top: markRect.bottom + 30.0,
              left: markRect.left + 50.0,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(
                        Icons.beach_access,
                        color: Colors.white,
                      ),
                      Text("  friend on vacation",
                          style: const TextStyle(
                            fontSize: 18.0,
                            color: Colors.white,
                          ))
                    ]),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(
                        Icons.cloud,
                        color: Colors.white,
                      ),
                      Text("  weather",
                          style: const TextStyle(
                            fontSize: 18.0,
                            color: Colors.white,
                          ))
                    ]),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(
                        Icons.shop,
                        color: Colors.white,
                      ),
                      Text("  send friend an invitation",
                          style: const TextStyle(
                            fontSize: 18.0,
                            color: Colors.white,
                          ))
                    ]),
                    Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: RaisedButton(
                          onPressed: () {},
                          child: Text("Got it"),
                          color: Colors.blueGrey[600],
                        )),
                  ])),
        ],
        duration: null,
        onClose: () {
          Timer(Duration(seconds: 3), () => showCoachMarkSliders());
        });
  }

  void showCoachMarkSliders() {
    CoachMark coachMarkSlider = CoachMark();
    RenderBox target =
        SkillsShowcase.sliderKey.currentContext.findRenderObject();

    Rect markRect = target.localToGlobal(Offset.zero) & target.size;
print("$markRect");
    coachMarkSlider.show(
        targetContext: SkillsShowcase.sliderKey.currentContext,
        markRect: markRect.inflate(5.0),
        markShape: BoxShape.rectangle,
        children: [
          Positioned(
              top: markRect.top - 50.0,
              left: 25.0,
              child: Text("Rate skill by drag the thumb",
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ))),
        ],
        duration: null,
        onClose: () {
          _coachMarkIsShown = true;
        });
  }
}
