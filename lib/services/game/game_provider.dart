import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:touring_game/models/activity.dart';
import 'package:touring_game/models/note.dart';
import 'package:path/path.dart';

class FirebaseCloudGameProvider {
  final placesList = FirebaseFirestore.instance.collection('places');
  final storageInstance = FirebaseStorage.instance.ref();

  Future<String> getImage({required String path}) async {
    var imageRef = storageInstance.child(path);

    return await imageRef.getDownloadURL();
  }

  static final FirebaseCloudGameProvider _shared =
      FirebaseCloudGameProvider._sharedInstance();
  FirebaseCloudGameProvider._sharedInstance();
  factory FirebaseCloudGameProvider() => _shared;

  Future<QuerySnapshot<Map<String, dynamic>>> allPlaces() async {
    return await FirebaseFirestore.instance.collection('places').get();
  }

  Future<List<DatabaseActivity>> getPlaceActivities(
      {required String placeId}) async {
    List<DatabaseActivity> activitiesList = [];
    bool isDone = false;
    await FirebaseFirestore.instance
        .collection('places')
        .doc(placeId)
        .collection('activities')
        .get()
        .then((activities) async {
      for (var activity in activities.docs) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('activities_done')
            .doc(activity.id)
            .get()
            .then((value) => isDone = value.data()?['done'] ?? false);
        var databaseData = activity.data();

        activitiesList.add(DatabaseActivity.fromJson(
            databaseData, placeId, activity.id, isDone));
      }
    });

    return activitiesList;
  }

  void activityDoneChanged(DatabaseActivity activity) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('activities_done')
        .doc(activity.id)
        .set({'done': activity.isDone});
  }

  Future<void> addActivityNote({required DatabaseNote note}) async {
    String content = '';
    if (note.isImage) {
      content = note.imagePath!;
      var imageFirestorePath = storageInstance.child(
          "notes_images/${FirebaseAuth.instance.currentUser!.uid}/${basename(note.imagePath!)}");
      try {
        await imageFirestorePath.getDownloadURL();
      } on FirebaseException catch (error) {
        if (error.code == 'object-not-found') {
          await imageFirestorePath.putFile(File(note.imagePath!));
          //note.imagePath = imageFirestorePath.fullPath;
        }
      }
    } else {
      content = note.content;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('activities_notes')
        .doc(note.id)
        .set({
      'activity_id': note.activityId,
      'color': note.color,
      'id': note.id,
      'content': content,
      'position_x': note.positionX,
      'position_y': note.positionY,
      'is_image': note.isImage
    });
  }

  Future<List<DatabaseNote>> getActivityNotes(
      {required String activityId}) async {
    List<DatabaseNote> notesList = [];

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('activities_notes')
        .where('activity_id', isEqualTo: activityId)
        .get()
        .then((value) async {
      for (var note in value.docs) {
        var newNote = note.data();

        var content = newNote['content'];

        //check if note content is String or Image and get it
        if (newNote['is_image']) {
          try {
            var imageFirestorePath = storageInstance.child(
                "notes_images/${FirebaseAuth.instance.currentUser!.uid}/${basename(content)}");
            var imageUrl = await imageFirestorePath.getDownloadURL();
            // if path leads to Firebase Storage
            content = Image.network(imageUrl);
          } on FirebaseException catch (error) {
            if (error.code == 'object-not-found') {
              // if path is currently local
              content = Image.file(File(content));
            }
          }
        }

        notesList.add(DatabaseNote.fromJson(newNote, content, activityId));
      }
    });

    return notesList;
  }

  Future<void> deleteNote({required DatabaseNote note}) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('activities_notes')
        .doc(note.id)
        .delete();
  }

  Future<void> deleteImageFromStorage({required String imagePath}) async {
    var imageFirestorePathRef = storageInstance.child(
        "notes_images/${FirebaseAuth.instance.currentUser!.uid}/${basename(imagePath)}");
    await imageFirestorePathRef.delete();
  }
}
