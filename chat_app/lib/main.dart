import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;

final ThemeData iOSTheme = new ThemeData(
  primarySwatch: Colors.red,
  primaryColor: Colors.grey[400],
  primaryColorBrightness: Brightness.dark,
);
final ThemeData androidTheme = new ThemeData(
  primarySwatch: Colors.blue,
  accentColor: Colors.green,
);

class MockUser{
  const MockUser({this.name});
  final String name;
}

const List<MockUser> _users = [
  const MockUser(name: "Neel Jain"),
  const MockUser(name: "Jain Neel"),
  const MockUser(name: "John Doe"),
  const MockUser(name: "Real Name"),
  const MockUser(name: "Fake Name")
];

MockUser messenger = _users[1];
final MockUser person = _users[0];


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext ctx){
    return new MaterialApp(
      title: "Chat Application",
      theme: defaultTargetPlatform == TargetPlatform.iOS
        ? iOSTheme
        : androidTheme,
      home: new UsersList(),
    );
  }
}

class UsersList extends StatefulWidget{
  @override
  State createState() => new ListState();
}



class ListState extends State<UsersList>{
  Widget _buildRow(MockUser user) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: 15.0),
      title: Text(
        user.name,
      ),
      onTap:(){
        messenger = user;
        Navigator.of(context).push(MaterialPageRoute<void>(builder: (context) => Chat()));
      }
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Friends'),
      ),
      body: ListView.separated(
          separatorBuilder: (context, i) => Divider(
            color: Colors.black,
          ),
          itemCount: _users.length,
          itemBuilder: (context, i){
            return _buildRow(_users[i]);
          }),
    );
  }
}

class Chat extends StatefulWidget{
  @override
  State createState() => new ChatWindow();
}

class ChatWindow extends State<Chat> with TickerProviderStateMixin {
  final List<Msg> _messages = <Msg>[];
  final TextEditingController _textController = new TextEditingController();
  bool _isWriting = false;

  @override
  Widget build(BuildContext ctx) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(messenger.name),
          elevation:
          Theme
              .of(ctx)
              .platform == TargetPlatform.iOS ? 0.0 : 6.0,
        ),
        body: new Column(children: <Widget>[
          new Flexible(
              child: new ListView.builder(
                itemBuilder: (_, int index) => _messages[index],
                itemCount: _messages.length,
                reverse: true,
                padding: new EdgeInsets.all(6.0),
              )
          ),
          new Divider(height: 1.0),
          new Container(
            child: _buildComposer(),
            decoration: new BoxDecoration(color: Theme.of(ctx).cardColor),
          ),
        ],
        )

    );
  }
  Widget _buildComposer(){
    return new IconTheme(
        data: new IconThemeData(color: Theme.of(context).accentColor),
        child: new Container(
          margin: const EdgeInsets.symmetric(horizontal: 9.0),
          child: new Row(
            children: <Widget>[
              new Flexible(
                  child: new TextField(
                    controller: _textController,
                    onChanged: (String txt){
                      setState(() {
                        _isWriting = txt.length >0;
                      });
                    },
                    onSubmitted: _submitMsg,
                    decoration:
                      new InputDecoration.collapsed(hintText: "Type a message..."),
                  ),
              ),
              new Container(
                margin: new EdgeInsets.symmetric(horizontal:3.0),
                child: Theme.of(context).platform == TargetPlatform.iOS
                  ? new CupertinoButton(
                    child: new Text("Submit"),
                    onPressed: _isWriting ? () => _submitMsg(_textController.text)
                        : null
                )
                    : new IconButton(
                    icon: new Icon(Icons.message),
                    onPressed: _isWriting
                    ? () => _submitMsg(_textController.text)
                        : null,
                )
              )
            ],
          ),
          decoration: Theme.of(context).platform == TargetPlatform.iOS
            ? new BoxDecoration(
              border:
                new Border(top: new BorderSide(color: Colors.brown))) :
                null
        ),
    );
  }
  void _submitMsg(String txt){
    _textController.clear();
    setState(() {
      _isWriting = false;
    });
    Msg msg = new Msg(
      txt: txt,
      animationController: new AnimationController(
          vsync: this,
        duration: new Duration(milliseconds: 800)
    ),
    );
    setState(() {
      _messages.insert(0,msg);
    });
    msg.animationController.forward();
  }
  @override
  void dispose(){
    for(Msg msg in _messages){
      msg.animationController.dispose();
    }
    super.dispose();
  }

}

class Msg extends StatelessWidget{
  Msg({this.txt, this.animationController});
  final String txt;
  final AnimationController animationController;

  @override
  Widget build(BuildContext ctx) {
    return new SizeTransition(sizeFactor: new CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOut
    ),
    axisAlignment: 0.0,
      child: new Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
              margin: const EdgeInsets.only(right: 18.0),
              child: new CircleAvatar(child: new Text((person.name)[0])),
            ),
            new Expanded(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text(person.name, style: Theme.of(ctx).textTheme.subhead),
                  new Container(
                    margin: const EdgeInsets.only(top: 6.0),
                    child: new Text(txt),
                  ),
                ],
              )
            )
          ],
        ),
      ),
    );
  }
}