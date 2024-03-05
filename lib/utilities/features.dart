import 'package:todo_app/models/model.dart';

class AdditionslFeature {
  Future<dynamic> saveTask({
    required String title,
    required String note,
    required String date,
    required String startTime,
    required String endTime,
    required String reminder,
  }) async {
    NoteModel n = NoteModel(
      title: title,
      note: note,
      date: date,
      starttime: startTime,
      endtime: endTime,
      reminder: reminder,
    );
    return null;
  }

}
