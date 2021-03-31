import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:scribe/data/models.dart';
import 'package:scribe/services/database.dart';
import 'package:share/share.dart';

class Editor extends StatefulWidget {
  Function() triggerRefetch;
  NotesModel currentNote;
  Editor({Key key, Function() triggerRefetch, NotesModel currentNote})
      : super(key: key) {
    this.triggerRefetch = triggerRefetch;
    this.currentNote = currentNote;
  }
  @override
  _EditorState createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  bool isNoteNew = true;
  FocusNode titleFocus = FocusNode();
  FocusNode contentFocus = FocusNode();

  NotesModel currentNote;
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  @override
  void initState() {
    super.initState();
    if (widget.currentNote == null) {
      currentNote = NotesModel(
          content: '', title: '', date: DateTime.now(), isImportant: false);
      isNoteNew = true;
    } else {
      currentNote = widget.currentNote;
      isNoteNew = false;
    }
    titleController.text = currentNote.title;
    contentController.text = currentNote.content;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _readyToPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).brightness == Brightness.dark?
          Colors.black12:Colors.white,
          leading: IconButton(icon: Icon(Icons.arrow_back,
            color: Theme.of(context).brightness == Brightness.dark?
            Colors.white:Colors.black ,),
          onPressed: ()=> handleBackSave(),),
          title: Text(
            DateFormat.yMd().add_jm().format(currentNote.date),
            style: TextStyle(
              fontSize: 16,
                fontWeight: FontWeight.w500, color: Colors.grey.shade500),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.delete_outline,
                  color: Theme.of(context).brightness == Brightness.dark?
                  Colors.white:Colors.black),
              onPressed: () {
                handleDelete();
              },
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: InkWell(
                child: GestureDetector(
                  onTap: () => share(),
                  child: Icon(
                    Icons.share,
                      color: Theme.of(context).brightness == Brightness.dark?
                      Colors.white:Colors.black
                  ),
                ),
              ),
            ),
          ],
        ),
          body: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 24.0, right: 24.0, top: 40.0, bottom: 16),
                child: AnimatedOpacity(
                  opacity: 1,
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeIn,
                  child: TextField(
                    controller: titleController,
                    autofocus: isNoteNew?true:false,
                    focusNode: titleFocus,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    onSubmitted: (text) {
                      titleFocus.unfocus();
                      FocusScope.of(context).requestFocus(contentFocus);
                    },
                    textInputAction: TextInputAction.next,
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700),
                    decoration: InputDecoration.collapsed(
                      hintText: 'Title',
                      hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 30,
                          fontWeight: FontWeight.w700),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 24.0, top: 36, bottom: 24, right: 24),
                child: TextField(
                  focusNode: contentFocus,
                  controller: contentController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  decoration: InputDecoration.collapsed(
                    hintText: 'Tap to start writing',
                    hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                    border: InputBorder.none,
                  ),
                ),
              )
            ],
          )
      ),
    );
  }
  void handleSave() async {
    if(titleController.text.isEmpty&&contentController.text.isEmpty){
      Navigator.pop(context);
      if(!isNoteNew){
        await NotesDatabaseService.db
            .deleteNoteInDB(widget.currentNote);
        widget.triggerRefetch();
      }
    }else {
      setState(() {
        currentNote.title = titleController.text;
        currentNote.content = contentController.text;
      });
      if (isNoteNew) {
        var latestNote = await NotesDatabaseService.db.addNoteInDB(currentNote);
        setState(() {
          currentNote = latestNote;
        });
      } else {
        await NotesDatabaseService.db.updateNoteInDB(currentNote);
      }
      widget.triggerRefetch();
      titleFocus.unfocus();
      contentFocus.unfocus();
    }
  }
  void handleBackSave() async {
    if(titleController.text.isEmpty&&contentController.text.isEmpty){
      Navigator.pop(context);
      if(!isNoteNew){
        await NotesDatabaseService.db
            .deleteNoteInDB(widget.currentNote);
        widget.triggerRefetch();
      }
    }else {
      setState(() {
        currentNote.title = titleController.text;
        currentNote.content = contentController.text;
      });
      if (isNoteNew) {
        var latestNote = await NotesDatabaseService.db.addNoteInDB(currentNote);
        setState(() {
          currentNote = latestNote;
        });
      } else {
        await NotesDatabaseService.db.updateNoteInDB(currentNote);
      }
      widget.triggerRefetch();
      titleFocus.unfocus();
      contentFocus.unfocus();
      Navigator.pop(context);
    }
  }


  void handleDelete() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text('Delete Note?'),
            content: Text('This note will be deleted permanently'),
            actions: <Widget>[
              FlatButton(
                child: Text('DELETE',
                    style: TextStyle(
                        color: Colors.red.shade300,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1)),
                onPressed: () async {
                  await NotesDatabaseService.db
                      .deleteNoteInDB(widget.currentNote);
                  widget.triggerRefetch();
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text('CANCEL',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1)),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  Future<bool> _readyToPop() async {
    handleSave();
    return true;
  }

  share() {
    if (currentNote.content.isNotEmpty) {
      Share.share("${currentNote.title}\n${currentNote.content}");
    }
  }
}
