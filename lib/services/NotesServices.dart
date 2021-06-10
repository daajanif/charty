import 'package:mighty_notes/main.dart';
import 'package:mighty_notes/model/NotesModel.dart';
import 'package:mighty_notes/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

import 'BaseService.dart';

class NotesServices extends BaseService {
  NotesServices({String userID}) {
    ref = db.collection('notes');
  }

  Stream<List<NotesModel>> fetchNotes({String color = ''}) {
    return color.isEmpty
        ? ref.where('collaborateWith', arrayContains: getStringAsync(USER_EMAIL)).orderBy('updatedAt', descending: true).snapshots().map(
            (event) {
              return event.docs.map((e) => NotesModel.fromJson(e.data())).toList();
            },
          )
        : ref.where('collaborateWith', arrayContains: getStringAsync(USER_EMAIL)).where('color', isEqualTo: color).orderBy('updatedAt', descending: true).snapshots().map(
            (event) {
              return event.docs.map((e) => NotesModel.fromJson(e.data())).toList();
            },
          );
  }
}
