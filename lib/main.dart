import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late double _width,_height;
  late DatabaseReference todoListRef;

  @override
  void initState() {
    todoListRef = FirebaseDatabase.instance.reference().child('todoList');
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
     _width = MediaQuery.of(context).size.width;
     _height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: Text("ToDo App"),

        ),
        body: Container(
          height: _height,
          width: _width,
          color: Colors.white,
          child: FirebaseAnimatedList(
            key: ValueKey<bool>(false),
            query: todoListRef,
            reverse: false,
            itemBuilder: (BuildContext context, DataSnapshot snapshot,
                Animation<double> animation, int index) {
              return SizeTransition(
                sizeFactor: animation,
                child: ListTile(
                  trailing: IconButton(
                    onPressed: () =>
                        todoListRef.child(snapshot.key!).remove(),
                    icon: const Icon(Icons.delete),
                  ),
                  title: Text(
                    '${snapshot.value['event']}',
                  ),
                ),
              );
            },
          ),
        ),
        floatingActionButton: GestureDetector(
          onTap: (){
            addTodoDialog();
          },
          child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue
            ),
            child: Center(
              child: Icon(Icons.add,color: Colors.white,size: 25,),
            ),
          ),
        ),
    );
  }


  static const Color yellowColor=Color(0xFFFFC010);
  static  Color addNewTextFieldText=Color(0xFF787878);

  addTodoDialog(){
    TextEditingController event=new TextEditingController();
    bool textFieldGlow=false;
    bool istextInvalid=false;

    return showGeneralDialog(context: context,
      barrierDismissible: true,
      barrierLabel: "add",
      barrierColor: Colors.black54,
      transitionDuration: Duration(milliseconds: 300),
      transitionBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.linear)).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        final Widget pageChild = Builder(builder: (ctx){
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), ),
            child: StatefulBuilder(
                  builder:(context,setState){
                    return Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white
                      ),
                      height: 250,
                      width: _width*0.7,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 50,
                            width: _width,
                            margin: EdgeInsets.only(left: 20,right: 20,top: 10,bottom: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(color:textFieldGlow? yellowColor:Colors.transparent),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color:textFieldGlow?yellowColor.withOpacity(0.2):  addNewTextFieldText.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 15,
                                    offset: Offset(0, 0), // changes position of shadow
                                  )
                                ]
                            ),
                            child: Container(
                              width: _width*0.45,
                              padding: EdgeInsets.only(left: 20),
                              child: TextFormField(
                                  onTap: (){
                                    setState(() {
                                      textFieldGlow=true;
                                    });
                                  },
                                  controller: event,
                                  style:  TextStyle(fontFamily: 'RR',fontSize: 15,color:addNewTextFieldText,letterSpacing: 0.2),
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      focusedErrorBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,

                                  ),

                                  keyboardType: TextInputType.emailAddress,
                                  onEditingComplete: () async {
                                    setState(() {
                                      textFieldGlow=false;
                                    });
                                  }
                              ),
                            ),
                          ),
                          istextInvalid?Container(
                              margin: EdgeInsets.only(left:25),
                              alignment: Alignment.centerLeft,
                              child: Text("* Required",style: TextStyle(color: Colors.red,fontSize: 16),textAlign: TextAlign.left,)
                          ):Container(height: 0,width: 0,),
                          SizedBox(height: 25,),
                          GestureDetector(
                            onTap: (){
                              if(event.text.isEmpty){
                                setState(() {
                                  istextInvalid=true;
                                });
                              }
                              else{
                                setState(() {
                                  istextInvalid=false;
                                });
                                todoListRef.push().set({
                                  "event":event.text
                                });
                                Navigator.pop(context);
                              }
                            },
                            child: Container(
                              height: 45,
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(35),
                                color: yellowColor,
                              ),
                              child: Center(
                                child: Text("Add",style: TextStyle(color: addNewTextFieldText,fontSize: 20),),
                              ),
                            ),
                          )


                        ],
                      ),
                    );
                  }
              ),
          );
        } );
        return SafeArea(
          top: false,
          child: Builder(builder: (BuildContext context) {
            return pageChild;
          }),
        );
      },

    );
  }
}

