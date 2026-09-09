import 'dart:io';

import 'package:flutter/material.dart';
import 'package:touring_game/models/note.dart';
import 'package:touring_game/utilities/notes/note_position.dart';

class ActivityNote extends StatefulWidget {
  const ActivityNote({
    super.key,
    required this.databaseNote,
    required this.containerKey,
    required this.onRemove,
    required this.onEdit,
    required this.onDragEnd,
    required this.onColorChange,
  });

  final DatabaseNote databaseNote;
  final GlobalKey containerKey;
  final VoidCallback onRemove;
  final VoidCallback onEdit;
  final ValueChanged<Offset> onDragEnd;
  final ValueChanged<String> onColorChange;

  @override
  State<ActivityNote> createState() => _ActivityNoteState();
}

class _ActivityNoteState extends State<ActivityNote> {
  Offset position = const Offset(0, 0);
  Offset normalizedPosition = const Offset(0, 0);
  Offset? legacyGlobalPosition;
  late Color noteColor;

  void _changeColor(Color color) {
    setState(() => noteColor = color);
    widget.onColorChange(color.toARGB32().toString());
  }

  Widget _buildContents() {
    if (!widget.databaseNote.isImage) {
      return Text(
        widget.databaseNote.content,
        textAlign: TextAlign.center,
        style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 16),
      );
    }
    final imagePath = widget.databaseNote.imagePath;
    if (imagePath != null && File(imagePath).existsSync()) {
      return Image.file(File(imagePath));
    }
    final imageUrl = widget.databaseNote.imageUrl;
    if (imageUrl != null) {
      return Image.network(imageUrl);
    }
    return const Icon(Icons.broken_image_outlined);
  }

  @override
  void initState() {
    super.initState();
    noteColor = Color(int.parse(widget.databaseNote.color));
    final x = widget.databaseNote.positionX;
    final y = widget.databaseNote.positionY;
    final isNew = x == -999 && y == -999;
    final isNormalized = x >= 0 && x <= 1 && y >= 0 && y <= 1;
    if (!isNew && isNormalized) {
      normalizedPosition = Offset(x, y);
    } else if (!isNew) {
      legacyGlobalPosition = Offset(x, y);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _schedulePositionUpdate();
  }

  void _schedulePositionUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderObject = widget.containerKey.currentContext
          ?.findRenderObject();
      if (!mounted || renderObject is! RenderBox) {
        return;
      }
      final noteSize = MediaQuery.sizeOf(context).width / 3;
      final maxX = (renderObject.size.width - noteSize).clamp(
        0,
        double.infinity,
      );
      final maxY = (renderObject.size.height - noteSize - 17).clamp(
        0,
        double.infinity,
      );
      final availableSize = Size(maxX.toDouble(), maxY.toDouble());
      final legacy = legacyGlobalPosition;
      if (legacy != null) {
        final local = renderObject.globalToLocal(legacy);
        normalizedPosition = normalizeNotePosition(
          localPosition: local,
          availableSize: availableSize,
        );
        legacyGlobalPosition = null;
      }
      setState(() {
        position = resolveNotePosition(
          normalizedPosition: normalizedPosition,
          availableSize: availableSize,
        );
      });
    });
  }

  void _handleDragEnd(DraggableDetails details) {
    final renderObject = widget.containerKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox) {
      return;
    }
    final noteSize = MediaQuery.sizeOf(context).width / 3;
    final maxX = (renderObject.size.width - noteSize).clamp(0, double.infinity);
    final maxY = (renderObject.size.height - noteSize - 17).clamp(
      0,
      double.infinity,
    );
    final local = renderObject.globalToLocal(details.offset);
    final availableSize = Size(maxX.toDouble(), maxY.toDouble());
    normalizedPosition = normalizeNotePosition(
      localPosition: local,
      availableSize: availableSize,
    );
    final clampedPosition = resolveNotePosition(
      normalizedPosition: normalizedPosition,
      availableSize: availableSize,
    );
    setState(() => position = clampedPosition);
    widget.onDragEnd(normalizedPosition);
  }

  @override
  Widget build(BuildContext context) {
    double noteSize = MediaQuery.of(context).size.width / 3;
    final contents = _buildContents();
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Draggable(
        onDragEnd: _handleDragEnd,
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
                            maxHeight: MediaQuery.of(context).size.height / 2,
                          ),
                          child: InteractiveViewer(
                            child: Center(child: contents),
                          ),
                        ),
                      );
                    }),
                  );
                },
                onLongPress: () async {
                  await showMenu(
                    context: context,
                    position: RelativeRect.fromLTRB(
                      position.dx + MediaQuery.of(context).size.width / 3,
                      position.dy,
                      position.dx + MediaQuery.of(context).size.width / 3,
                      0,
                    ),
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
                              0,
                            ),
                            items: [
                              PopupMenuItem(
                                child: Container(
                                  height: kMinInteractiveDimension,
                                  color: Colors.green,
                                ),
                                onTap: () {
                                  _changeColor(Colors.green);
                                },
                              ),
                              PopupMenuItem(
                                child: Container(
                                  height: kMinInteractiveDimension,
                                  color: Colors.yellow,
                                ),
                                onTap: () {
                                  _changeColor(Colors.yellow);
                                },
                              ),
                              PopupMenuItem(
                                child: Container(
                                  height: kMinInteractiveDimension,
                                  color: Colors.blue,
                                ),
                                onTap: () {
                                  _changeColor(Colors.blue);
                                },
                              ),
                              PopupMenuItem(
                                child: Container(
                                  height: kMinInteractiveDimension,
                                  color: Colors.pink,
                                ),
                                onTap: () {
                                  _changeColor(Colors.pink);
                                },
                              ),
                              PopupMenuItem(
                                child: Container(
                                  height: kMinInteractiveDimension,
                                  color: Colors.orange,
                                ),
                                onTap: () {
                                  _changeColor(Colors.orange);
                                },
                              ),
                              PopupMenuItem(
                                child: Container(
                                  height: kMinInteractiveDimension,
                                  color: Colors.cyan[50]!,
                                ),
                                onTap: () {
                                  _changeColor(Colors.cyan[50]!);
                                },
                              ),
                            ],
                          );
                        },
                      ),
                      PopupMenuItem(
                        child: const Text('Edit'),
                        onTap: () {
                          widget.onEdit();
                        },
                      ),
                      PopupMenuItem(
                        onTap: widget.onRemove,
                        child: const Text('Delete'),
                      ),
                    ],
                  );
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
