import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:example/ui/frienddetails/friend_details_page.dart';
import 'package:example/ui/friends/friend.dart';

import 'package:highlighter_coachmark/highlighter_coachmark.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.purple,
        accentColor: const Color(0xFFF850DD),
      ),
      home: FriendsListPage(),
    );
  }
}

class FriendsListPage extends StatefulWidget {
  @override
  _FriendsListPageState createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  List<Friend> _friends = [];
  ScrollController _scrollController;
  GlobalKey _fabKey = GlobalObjectKey("fab");
  GlobalKey _tileKey = GlobalObjectKey("tile_2");

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    http.Response response =
        await http.get('https://randomuser.me/api/?results=5');

    setState(() {
      _friends = Friend.allFromResponse(response.body);
    });

    // Here is how you can launch CoachMark.
    // Management of coach mark tutorials is another topic not covered in this lib
    Timer(Duration(seconds: 1), () => showCoachMarkFAB());
  }

  //Here is example of CoachMark usage
  void showCoachMarkFAB() {
    CoachMark coachMarkFAB = CoachMark();
    RenderBox target = _fabKey.currentContext.findRenderObject();

    Rect markRect = target.localToGlobal(Offset.zero) & target.size;
    markRect = Rect.fromCircle(
        center: markRect.center, radius: markRect.longestSide * 0.6);

    coachMarkFAB.show(
        targetContext: _fabKey.currentContext,
        markRect: markRect,
        children: [
          Center(
              child: Text("Tap on button\nto add a friend",
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  )))
        ],
        duration: null,
        onClose: () {
          Timer(Duration(seconds: 3), () => showCoachMarkTile());
        });
  }

  //And here is example of CoachMark usage.
  //One more example you can see in FriendDetailsPage - showCoachMarkBadges()
  void showCoachMarkTile() {
    CoachMark coachMarkTile = CoachMark();
    RenderBox target = _tileKey.currentContext.findRenderObject();

    Rect markRect = target.localToGlobal(Offset.zero) & target.size;
    markRect = markRect.inflate(5.0);

    coachMarkTile.show(
        targetContext: _fabKey.currentContext,
        markRect: markRect,
        markShape: BoxShape.rectangle,
        children: [
          Positioned(
              top: markRect.bottom + 15.0,
              right: 5.0,
              child: Text("Tap on friend to see details",
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  )))
        ],
        duration: Duration(seconds: 3));
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_friends.isEmpty) {
      content = Center(
        child: CircularProgressIndicator(),
      );
    } else {
      content = ListView.builder(
        itemExtent: 70.0,
        controller: _scrollController,
        itemCount: _friends.length,
        itemBuilder: _buildFriendListTile,
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Friends')),
      body: content,
      floatingActionButton: _friends.isEmpty
          ? null
          : FloatingActionButton(
              key: _fabKey,
              child: Icon(Icons.add),
              onPressed: () async {
                Friend friend = await buildShowDialog(context);
                if (friend != null) {
                  setState(() {
                    _friends.add(friend);
                  });
                  Future.delayed(
                      Duration(milliseconds: 200),
                      () => _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: Duration(seconds: 1),
                          curve: Curves.easeOut));
                }
              },
            ),
    );
  }

  Widget _buildFriendListTile(BuildContext context, int index) {
    var friend = _friends[index];
    GlobalKey key = index == 2 ? _tileKey : null;

    return ListTile(
      key: key,
      onTap: () => _navigateToFriendDetails(friend, index),
      leading: Hero(
        tag: index,
        child: CircleAvatar(
          backgroundImage: NetworkImage(friend.avatar),
        ),
      ),
      title: Text(friend.name),
      subtitle: Text(friend.email),
    );
  }

  void _navigateToFriendDetails(Friend friend, Object avatarTag) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (c) {
          return FriendDetailsPage(friend, avatarTag: avatarTag);
        },
      ),
    );
  }

  Future<Friend> buildShowDialog(BuildContext context) {
    return showDialog<Friend>(
        context: context,
        builder: (BuildContext context) {
          return FutureBuilder<Friend>(
              future: _loadRandomFriend(),
              builder: (BuildContext context, AsyncSnapshot<Friend> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return SimpleDialog(
                      title: _buildDialogAddFriend(snapshot.data));
                } else {
                  return SimpleDialog(
                      title: Container(
                          height: 100.0,
                          width: 200.0,
                          alignment: Alignment.center,
                          color: Colors.white,
                          child: CircularProgressIndicator()));
                }
              });
        });
  }

  Future<Friend> _loadRandomFriend() async {
    http.Response response =
        await http.get('https://randomuser.me/api/?results=1');
    var friends = Friend.allFromResponse(response.body);
    return friends.first;
  }

  Widget _buildDialogAddFriend(Friend friend) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(friend.avatar),
          ),
          title: Text(friend.name),
          subtitle: Text(friend.email),
        ),
        Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cansel'),
                ),
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, friend);
                  },
                  child: const Text('Save'),
                ),
              ],
            )),
      ],
    );
  }
}
