import 'package:flutter/material.dart';
import 'package:touring_game/models/note.dart';

class ActivityNote extends StatefulWidget {
  const ActivityNote({
    super.key,
    required this.databaseNote,
    required this.containerKey,
    required this.notesTextController,
    required this.onRemove,
    required this.onEdit,
    required this.onDragEnd,
    required this.onColorChange,
  });

  final DatabaseNote databaseNote;
  final GlobalKey<State<StatefulWidget>> containerKey;
  final TextEditingController notesTextController;
  final Function onRemove;
  final Function onEdit;
  final Function onDragEnd;
  final Function onColorChange;

  @override
  State<ActivityNote> createState() => _ActivityNoteState();
}

class _ActivityNoteState extends State<ActivityNote> {
  Offset position = const Offset(0, 0);
  Offset containerPosition = const Offset(0, 0);
  late Color noteColor;
  bool changed = false;
  @override
  void initState() {
    noteColor = Color(int.parse(widget.databaseNote.color));

    final renderBox =
        widget.containerKey.currentContext?.findRenderObject() as RenderBox;
    containerPosition = renderBox.localToGlobal(Offset.zero);

    //check if note is new
    if (widget.databaseNote.positionX == -999 &&
        widget.databaseNote.positionY == -999) {
      position = containerPosition;
    } else {
      position =
          Offset(widget.databaseNote.positionX, widget.databaseNote.positionY);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double noteSize = MediaQuery.of(context).size.width / 3;
    late Widget contents;
    widget.onColorChange(noteColor.value.toString());
    if (widget.databaseNote.isImage == false) {
      contents = Text(
        widget.databaseNote.content,
        textAlign: TextAlign.center,
        style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 16),
      );
    } else if (widget.databaseNote.isImage == true) {
      contents = widget.databaseNote.content;
    }
    return Positioned(
      left: position.dx - containerPosition.dx - 5,
      top: position.dy - containerPosition.dy - 5,
      child: Draggable(
        onDraggableCanceled: (velocity, offset) {
          widget.onDragEnd(offset);
          setState(() {
            position = offset;
          });
        },
        feedback: Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 17.0),
              child: GestureDetector(
                child: Container(
                  height: noteSize,
                  width: noteSize,
                  color: noteColor,
                  child: Center(child: contents),
                ),
              ),
            ),
            const Icon(Icons.push_pin),
          ],
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 17.0),
              child: GestureDetector(
                child: Container(
                  height: MediaQuery.of(context).size.width / 3,
                  width: MediaQuery.of(context).size.width / 3,
                  color: noteColor,
                  child: Center(child: contents),
                ),
                onTap: () async {
                  await showDialog(
                      context: context,
                      builder: ((context) {
                        return AlertDialog(
                          backgroundColor: noteColor,
                          content: ConstrainedBox(
                              constraints: BoxConstraints(
                                  minHeight: 0,
                                  maxHeight:
                                      MediaQuery.of(context).size.height / 2),
                              child: InteractiveViewer(
                                  child: Center(child: contents))),
                        );
                      }));
                },
                onLongPress: () async {
                  await showMenu(
                      context: context,
                      position: RelativeRect.fromLTRB(
                          position.dx + MediaQuery.of(context).size.width / 3,
                          position.dy,
                          position.dx + MediaQuery.of(context).size.width / 3,
                          0),
                      items: [
                        PopupMenuItem(
                          child: const Text('Color'),
                          onTap: () async {
                            await showMenu(
                                context: context,
                                position: RelativeRect.fromLTRB(
                                    position.dx +
                                        MediaQuery.of(context).size.width / 3,
                                    position.dy,
                                    position.dx +
                                        MediaQuery.of(context).size.width / 3,
                                    0),
                                items: [
                                  PopupMenuItem(
                                    child: Container(
                                      height: kMinInteractiveDimension,
                                      color: Colors.green,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        noteColor = Colors.green;
                                      });
                                    },
                                  ),
                                  PopupMenuItem(
                                    child: Container(
                                      height: kMinInteractiveDimension,
                                      color: Colors.yellow,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        noteColor = Colors.yellow;
                                      });
                                    },
                                  ),
                                  PopupMenuItem(
                                    child: Container(
                                      height: kMinInteractiveDimension,
                                      color: Colors.blue,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        noteColor = Colors.blue;
                                      });
                                    },
                                  ),
                                  PopupMenuItem(
                                    child: Container(
                                      height: kMinInteractiveDimension,
                                      color: Colors.pink,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        noteColor = Colors.pink;
                                      });
                                    },
                                  ),
                                  PopupMenuItem(
                                    child: Container(
                                      height: kMinInteractiveDimension,
                                      color: Colors.orange,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        noteColor = Colors.orange;
                                      });
                                    },
                                  ),
                                  PopupMenuItem(
                                    child: Container(
                                      height: kMinInteractiveDimension,
                                      color: Colors.cyan[50]!,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        noteColor = Colors.cyan[50]!;
                                      });
                                    },
                                  ),
                                ]);
                          },
                        ),
                        PopupMenuItem(
                          child: const Text('Edit'),
                          onTap: () {
                            widget.onEdit();
                          },
                        ),
                        PopupMenuItem(
                          child: const Text('Delete'),
                          onTap: () {
                            setState(() {
                              widget.onRemove();
                            });
                          },
                        )
                      ]);
                },
              ),
            ),
            const Icon(Icons.push_pin),
          ],
        ),
      ),
    );
  }
}
