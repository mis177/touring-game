import 'dart:io';

import 'package:flutter/material.dart';
import 'package:touring_game/models/note.dart';
import 'package:touring_game/utilities/notes/note_position.dart';

enum _NoteMenuAction { color, edit, delete }

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
  final _menuKey = GlobalKey<PopupMenuButtonState<_NoteMenuAction>>();
  Offset position = const Offset(0, 0);
  Offset normalizedPosition = const Offset(0, 0);
  Offset? legacyGlobalPosition;

  void _changeColor(Color color) {
    widget.onColorChange(color.toARGB32().toString());
  }

  Color get noteColor => Color(int.parse(widget.databaseNote.color));

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
    _readStoredPosition();
  }

  @override
  void didUpdateWidget(covariant ActivityNote oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldNote = oldWidget.databaseNote;
    final note = widget.databaseNote;
    if (oldNote.positionX != note.positionX ||
        oldNote.positionY != note.positionY) {
      _readStoredPosition();
      _schedulePositionUpdate();
    }
  }

  void _readStoredPosition() {
    final x = widget.databaseNote.positionX;
    final y = widget.databaseNote.positionY;
    final isNew = x == -999 && y == -999;
    final isNormalized = x >= 0 && x <= 1 && y >= 0 && y <= 1;
    normalizedPosition = const Offset(0, 0);
    legacyGlobalPosition = null;
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
    final updatedPosition = normalizeNotePosition(
      localPosition: local,
      availableSize: availableSize,
    );
    widget.onDragEnd(updatedPosition);
  }

  RelativeRect? _colorMenuPosition() {
    final overlay = Overlay.of(context).context.findRenderObject();
    final button = _menuKey.currentContext?.findRenderObject();
    if (overlay is! RenderBox || button is! RenderBox) {
      return null;
    }
    final buttonTopLeft = overlay.globalToLocal(
      button.localToGlobal(Offset.zero),
    );
    return RelativeRect.fromRect(
      Rect.fromLTWH(
        buttonTopLeft.dx,
        buttonTopLeft.dy + button.size.height,
        button.size.width,
        0,
      ),
      Offset.zero & overlay.size,
    );
  }

  Future<void> _handleMenuAction(_NoteMenuAction action) async {
    switch (action) {
      case _NoteMenuAction.color:
        final menuPosition = _colorMenuPosition();
        if (menuPosition == null) {
          return;
        }
        final color = await showMenu<Color>(
          context: context,
          position: menuPosition,
          items: [
            _colorMenuItem(Colors.green),
            _colorMenuItem(Colors.yellow),
            _colorMenuItem(Colors.blue),
            _colorMenuItem(Colors.pink),
            _colorMenuItem(Colors.orange),
            _colorMenuItem(Colors.cyan[50]!),
          ],
        );
        if (mounted && color != null) {
          _changeColor(color);
        }
      case _NoteMenuAction.edit:
        widget.onEdit();
      case _NoteMenuAction.delete:
        widget.onRemove();
    }
  }

  void _showNoteMenu() => _menuKey.currentState?.showButtonMenu();

  PopupMenuItem<Color> _colorMenuItem(Color color) {
    return PopupMenuItem(
      value: color,
      child: Container(height: kMinInteractiveDimension, color: color),
    );
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
                onLongPress: _showNoteMenu,
                child: Container(
                  height: MediaQuery.of(context).size.width / 3,
                  width: MediaQuery.of(context).size.width / 3,
                  color: noteColor,
                  child: Center(child: contents),
                ),
              ),
            ),
            const Icon(Icons.push_pin),
            Positioned(
              top: 17,
              right: 0,
              child: PopupMenuButton<_NoteMenuAction>(
                key: _menuKey,
                position: PopupMenuPosition.under,
                tooltip: 'Note actions',
                onSelected: _handleMenuAction,
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _NoteMenuAction.color,
                    child: Text('Color'),
                  ),
                  PopupMenuItem(
                    value: _NoteMenuAction.edit,
                    child: Text('Edit'),
                  ),
                  PopupMenuItem(
                    value: _NoteMenuAction.delete,
                    child: Text('Delete'),
                  ),
                ],
                icon: const Icon(Icons.more_vert),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
