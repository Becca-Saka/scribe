import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:scribe/components/faderoute.dart';
import 'package:scribe/data/models.dart';
import 'package:scribe/screens/editor.dart';
import 'package:scribe/services/database.dart';
import 'package:scribe/services/sharedPref.dart';

enum viewType {
  List,
  Staggered
}


class MyHomePager extends StatefulWidget {
  Function(Brightness brightness) changeTheme;
  MyHomePager({Key key, this.title, Function(Brightness brightness) changeTheme})
      : super(key: key) {
    this.changeTheme = changeTheme;
  }

  final String title;
  bool isList;

  @override
  _MyHomePagerState createState() => _MyHomePagerState();
}

class _MyHomePagerState extends State<MyHomePager> {
  var notesViewType ;
  bool isFlagOn = false;
  bool headerShouldHide = false;
  List<NotesModel> notesList = [];
  TextEditingController searchController = TextEditingController();

  bool isSearchEmpty = true;
  String selectedTheme;

  @override
  void initState() {
    super.initState();
    NotesDatabaseService.db.init();
    setNotesFromDB();

    notesViewType = viewType.Staggered;
  }

  setNotesFromDB() async {
    print("Entered setNotes");
    var fetchedNotes = await NotesDatabaseService.db.getNotesFromDB();
    setState(() {
      notesList = fetchedNotes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () => gotoEditNote(),
        label: Text('Add note'.toUpperCase()),
        icon: Icon(Icons.add),),
      body: notesList.length !=0? ListView(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(left: 8),
                  padding: EdgeInsets.only(left: 16),
                  height: 50,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.all(Radius.circular(16))),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          maxLines: 1,
                          onChanged: (value) {
                            handleSearch(value);
                          },
                          autofocus: false,
                          keyboardType: TextInputType.text,
                          style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration.collapsed(
                            hintText: 'Search',
                            hintStyle: TextStyle(
                                color: Colors.grey.shade300,
                                fontSize: 18,
                                fontWeight: FontWeight.w500),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(isSearchEmpty ? Icons.search : Icons.cancel,
                            color: Colors.grey.shade400),
                        onPressed: cancelSearch,
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                 showGeneralDialog(context: context,
                     barrierDismissible: true,
                     barrierLabel:'Barrier',
                     transitionDuration: Duration(microseconds: 700),
                     barrierColor: Colors.black.withOpacity(0.5),

                     pageBuilder: (BuildContext context,Animation  animation,
                         Animation secondaryAnimation){
                   return Center(child: Material(color: Colors.transparent,
                       child: Dialog(changeTheme: widget.changeTheme,)));
                 });
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  padding: EdgeInsets.all(16),
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.settings,
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.grey.shade600
                        : Colors.grey.shade300,
                  ),
                ),
              ),
//              Row(
//                children: [
//                  IconButton(
//                    icon: Icon(  notesViewType == viewType.List ?  Icons.developer_board :
//                    Icons.view_headline,
//                      color: Theme.of(context).brightness == Brightness.light ?
//                      Colors.black : Colors.grey.shade300,
//                    ),
//                    onPressed: ()=>_toggleViewType(),
//                  ),
//                  GestureDetector(
//                    behavior: HitTestBehavior.opaque,
//                    onTap: () {
//                     showDialog(context: context,
//                     builder: (BuildContext context){
//                       return Dialog();
//                     });
//                    },
//                    child: AnimatedContainer(
//                      duration: Duration(milliseconds: 200),
//                      padding: EdgeInsets.all(16),
//                      alignment: Alignment.centerRight,
//                      child: Icon(
//                        OMIcons.settings,
//                        color: Theme.of(context).brightness == Brightness.light
//                            ? Colors.grey.shade600
//                            : Colors.grey.shade300,
//                      ),
//                    ),
//                  ),
//                ],
//              ),
            ],
          ),
          SizedBox(height: 20,),
          grid(),],
      ): Stack(children: [
        ListView(children: <Widget>[Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(left: 8),
                    padding: EdgeInsets.only(left: 16),
                    height: 50,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.all(Radius.circular(16))),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            maxLines: 1,
                            onChanged: (value) {
                              handleSearch(value);
                            },
                            autofocus: false,
                            keyboardType: TextInputType.text,
                            style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration.collapsed(
                              hintText: 'Search',
                              hintStyle: TextStyle(
                                  color: Colors.grey.shade300,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(isSearchEmpty ? Icons.search : Icons.cancel,
                              color: Colors.grey.shade400),
                          onPressed: cancelSearch,
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    showGeneralDialog(context: context,
                        barrierDismissible: true,
                        barrierLabel:'Barrier',
                        transitionDuration: Duration(microseconds: 700),
                        barrierColor: Colors.black.withOpacity(0.5),

                        pageBuilder: (BuildContext context,Animation  animation,
                            Animation secondaryAnimation){
                          return Center(child: Material(color: Colors.transparent,
                              child: Dialog(changeTheme: widget.changeTheme,)));
                        });
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    padding: EdgeInsets.all(16),
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.settings,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.grey.shade600
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
//              Row(
//                children: [
//                  IconButton(
//                    icon: Icon(  notesViewType == viewType.List ?  Icons.developer_board :
//                    Icons.view_headline,
//                      color: Theme.of(context).brightness == Brightness.light ?
//                      Colors.black : Colors.grey.shade300,
//                    ),
//                    onPressed: ()=>_toggleViewType(),
//                  ),
//                  GestureDetector(
//                    behavior: HitTestBehavior.opaque,
//                    onTap: () {
//                     showDialog(context: context,
//                     builder: (BuildContext context){
//                       return Dialog();
//                     });
//                    },
//                    child: AnimatedContainer(
//                      duration: Duration(milliseconds: 200),
//                      padding: EdgeInsets.all(16),
//                      alignment: Alignment.centerRight,
//                      child: Icon(
//                        OMIcons.settings,
//                        color: Theme.of(context).brightness == Brightness.light
//                            ? Colors.grey.shade600
//                            : Colors.grey.shade300,
//                      ),
//                    ),
//                  ),
//                ],
//              ),
              ],
            ),],),
        Center(child: Text('Your Notes appear here')),],),
    );
  }



  Widget grid(){
    List<NotesModel> noteComponentsList = [];

    notesList.sort((a, b) {
      return b.date.compareTo(a.date);
    });
    if (searchController.text.isNotEmpty) {

      notesList.forEach((note) {
        if (note.title
            .toLowerCase()
            .contains(searchController.text.toLowerCase()) ||
            note.content
                .toLowerCase()
                .contains(searchController.text.toLowerCase()))

          noteComponentsList.add(note);
      });
    } else {
      notesList.forEach((note) {
        noteComponentsList.add(note);
      });
    }

   return new StaggeredGridView.countBuilder(

     physics: NeverScrollableScrollPhysics(),
     shrinkWrap: true,
     crossAxisCount:4,
        itemCount: noteComponentsList.length,
        itemBuilder: (BuildContext context, int index) {
      return InkWell(
        onTap: ()=>openNoteToRead(noteComponentsList[index]),
        child: Card(
          child: Container(

            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${noteComponentsList[index].title.trim().length <= 10 ?
                  noteComponentsList[index].title.trim() :
                  noteComponentsList[index].title.trim().substring(0, 10) + '...'}',
                  style: TextStyle(
                      fontFamily: 'ZillaSlab',
                      fontSize: 18,
                      fontWeight: noteComponentsList[index].isImportant
                          ? FontWeight.w800
                          : FontWeight.normal),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: 8),
                    child: Text(
                      '${noteComponentsList[index].content.trim().split('\n').first.length <= 30 ?
                      noteComponentsList[index].content.trim().split('\n').first :
                      noteComponentsList[index].content.trim().split('\n').first.substring(0, 30) + '...'}',
                      style:
                      TextStyle(fontSize: 14, color: Colors.grey.shade400),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
        }
      ,
        staggeredTileBuilder:(int index)=>
            StaggeredTile.count(2, index.isEven? 2:1),
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
    );
  }

  void handleSearch(String value) {
    if (value.isNotEmpty) {
      setState(() {
        isSearchEmpty = false;
      });
    } else {
      setState(() {
        isSearchEmpty = true;
      });
    }
  }

  void gotoEditNote() {
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) =>
                Editor(triggerRefetch: reFetchNotesFromDB)));
//                EditNotePage(triggerRefetch: refetchNotesFromDB)));
  }

  void reFetchNotesFromDB() async {
    await setNotesFromDB();
    print("Refetched notes");
  }

  openNoteToRead(NotesModel noteData) async {
    setState(() {
      headerShouldHide = true;
    });
    await Future.delayed(Duration(milliseconds: 230), () {});
    Navigator.push(
        context,
        FadeRoute(
            page: Editor(
                triggerRefetch: reFetchNotesFromDB, currentNote: noteData)));
    await Future.delayed(Duration(milliseconds: 300), () {});

    setState(() {
      headerShouldHide = false;
    });
  }

  void cancelSearch() {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      searchController.clear();
      isSearchEmpty = true;
    });
  }

  //Todo:implement different viewtypes
//  void _toggleViewType(){
//    setState(() {
//      if(notesViewType == viewType.List)
//      {
//        notesViewType = viewType.Staggered;
//
//      } else {
//        notesViewType = viewType.List;
//      }
//
//    });
//  }
//  List<Widget> buildNoteComponentsList() {
//    List<Widget> noteComponentsList = [];
//
//
//    notesList.sort((a, b) {
//      return b.date.compareTo(a.date);
//    });
//    if (searchController.text.isNotEmpty) {
//      notesList.forEach((note) {
//        if (note.title
//            .toLowerCase()
//            .contains(searchController.text.toLowerCase()) ||
//            note.content
//                .toLowerCase()
//                .contains(searchController.text.toLowerCase()))
//          noteComponentsList.add(NoteCardComponent(
//            noteData: note,
//            onTapAction: openNoteToRead,
//          ));
//      });
//      return noteComponentsList;
//    }
//    if (isFlagOn) {
//      notesList.forEach((note) {
//        if (note.isImportant)
//          noteComponentsList.add(NoteCardComponent(
//            noteData: note,
//            onTapAction: openNoteToRead,
//          ));
//      });
//    } else {
//      notesList.forEach((note) {
//        noteComponentsList.add(NoteCardComponent(
//          noteData: note,
//          onTapAction: openNoteToRead,
//        ));
//      });
//    }
//    return noteComponentsList;
//  }
//  Widget list(){
//    List<NotesModel> noteComponentsList = [];
//
//    notesList.sort((a, b) {
//      return b.date.compareTo(a.date);
//    });
//    if (searchController.text.isNotEmpty) {
//
//      notesList.forEach((note) {
//        if (note.title
//            .toLowerCase()
//            .contains(searchController.text.toLowerCase()) ||
//            note.content
//                .toLowerCase()
//                .contains(searchController.text.toLowerCase()))
//
//          noteComponentsList.add(note);
//      });
//    } else {
//      notesList.forEach((note) {
//        noteComponentsList.add(note);
//      });
//    }
//    return Expanded(
//      child: ListView.builder(
//          shrinkWrap: true,
//          itemCount: noteComponentsList.length,
//          physics: NeverScrollableScrollPhysics(),
//          itemBuilder: (BuildContext context, int index){
//            return InkWell(
//              onTap: ()=>openNoteToRead(noteComponentsList[index]),
//              child: Card(
//                child: Container(
//
//                  padding: EdgeInsets.all(16),
//                  child: Column(
//                    crossAxisAlignment: CrossAxisAlignment.start,
//                    children: <Widget>[
//                      Text(
//                        '${noteComponentsList[index].title.trim().length <= 10 ?
//                        noteComponentsList[index].title.trim() :
//                        noteComponentsList[index].title.trim().substring(0, 10) + '...'}',
//                        style: TextStyle(
//                            fontFamily: 'ZillaSlab',
//                            fontSize: 18,
//                            fontWeight: noteComponentsList[index].isImportant
//                                ? FontWeight.w800
//                                : FontWeight.normal),
//                      ),
//                      Expanded(
//                        child: Container(
//                          margin: EdgeInsets.only(top: 8),
//                          child: Text(
//                            '${noteComponentsList[index].content.trim().split('\n').first.length <= 30 ?
//                            noteComponentsList[index].content.trim().split('\n').first :
//                            noteComponentsList[index].content.trim().split('\n').first.substring(0, 30) + '...'}',
//                            style:
//                            TextStyle(fontSize: 14, color: Colors.grey.shade400),
//                          ),
//                        ),
//                      ),
//                    ],
//                  ),
//                ),
//              ),
//            );}),
//    );
//  }

}

class Dialog extends StatefulWidget {
  Function(Brightness brightness) changeTheme;
  Dialog({Key key, Function(Brightness brightness) changeTheme})
      : super(key: key) {
    this.changeTheme = changeTheme;
  }
  @override
  _DialogState createState() => _DialogState();
}

class _DialogState extends State<Dialog> {
  String selectedTheme;
  @override
  Widget build(BuildContext context) {
    setState(() {
      if (Theme.of(context).brightness == Brightness.dark) {
        selectedTheme = 'dark';
      } else {
        selectedTheme = 'light';
      }
    });
    var width = MediaQuery.of(context).size.width;
    return Container(
      color: Colors.transparent,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
          InkWell(
            onTap: (){
              handleThemeSelection('light');
            },
              child: Card(child: Container(
                color: Colors.white,
                height: 200,
            width: width/2.5,
            child: Icon(Icons.wb_sunny, size: 60,color: Colors.orange[800],),),)),
          SizedBox(width:10),
          InkWell(
              onTap: (){
                handleThemeSelection('dark');
              },
              child: Card(child: Container(height: 200,
            width: width/2.5, color: Colors.black,
            child: Icon(Icons.ac_unit, size: 60,color: Colors.orange[800],),),)),
        ],),
      ),
    );
  }


  void handleThemeSelection(String value) {
    setState(() {
      selectedTheme = value;
    });
    if (value == 'light') {
      widget.changeTheme(Brightness.light);
    } else {
      widget.changeTheme(Brightness.dark);
    }
    setThemeinSharedPref(value);
  }
}
