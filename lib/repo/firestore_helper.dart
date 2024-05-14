import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:public_rooster/data/app_data.dart';
import 'package:public_rooster/model/app_models.dart';
import 'package:public_rooster/service/dbs.dart';
import 'package:stack_trace/stack_trace.dart';

enum FsCol {
  logs,
  trainer,
  schemas,
  spreadsheet,
  mail,
  metadata,
  error;
}

class FirestoreHelper implements Dbs {
  FirestoreHelper._();
  static final FirestoreHelper instance = FirestoreHelper._();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// retrieve all spreadsheet
  @override
  Future<List<FsSpreadsheet>> retrieveAllSpreadsheets() async {
    CollectionReference colref = collectionRef(FsCol.spreadsheet);

    List<FsSpreadsheet> result = [];
    late QuerySnapshot querySnapshot;
    try {
      querySnapshot = await colref.get();
      for (var doc in querySnapshot.docs) {
        var map = doc.data() as Map<String, dynamic>;
        FsSpreadsheet fsSpreadsheet = FsSpreadsheet.fromMap(map);
        result.add(fsSpreadsheet);
      }
    } catch (ex, stackTrace) {
      _handleError(ex, stackTrace);
    }

    return result;
  }

  ///--------------------------------------------
  @override
  Future<List<TrainingGroup>> getTrainingGroups() async {
    List<TrainingGroup> result = [];
    CollectionReference colRef = collectionRef(FsCol.metadata);

    late DocumentSnapshot snapshot;
    try {
      snapshot = await colRef.doc('training_groups').get();
      if (snapshot.exists) {
        Map<String, dynamic> map = snapshot.data() as Map<String, dynamic>;
        List<dynamic> data = List<dynamic>.from(map['groups'] as List);
        result = data.map((e) => TrainingGroup.fromMap(e)).toList();
      }
    } catch (ex, stackTrace) {
      _handleError(ex, stackTrace);
    }

    return result;
  }

  @override
  Future<void> saveSpecialDays(SpecialDays specialDays) async {
    CollectionReference colRef = collectionRef(FsCol.metadata);

    Map<String, dynamic> map = specialDays.toMap();
    await colRef.doc('special_days').set(map).then((val) {}).catchError((e) {
      throw e;
    });
  }

  @override
  Future<SpecialDays> getSpecialsDays() async {
    SpecialDays result = SpecialDays(
        excludeDays: [],
        summerPeriod: SpecialPeriod.empty(),
        startersGroup: SpecialPeriod.empty());
    CollectionReference colRef = collectionRef(FsCol.metadata);

    late DocumentSnapshot snapshot;
    try {
      snapshot = await colRef.doc('special_days').get();
      if (snapshot.exists) {
        Map<String, dynamic> map = snapshot.data() as Map<String, dynamic>;
        result = SpecialDays.fromMap(map);
      }
    } catch (ex, stackTrace) {
      _handleError(ex, stackTrace);
    }

    return result;
  }

  ///--------------------------------------------
  CollectionReference collectionRef(FsCol fsCol) {
    String collectionName = AppData.instance.runMode == RunMode.prod
        ? fsCol.name
        : '${fsCol.name}_acc';

    if (collectionName.startsWith('mail')) {
      collectionName = 'mail';
    }

    return firestore.collection(collectionName);
  }

  ///-------- sendEmail
  ///@override
  @override
  Future<bool> sendEmail(
      {required String to,
      required String subject,
      required String html}) async {
    bool result = false;
    CollectionReference colRef = collectionRef(FsCol.mail);

    Map<String, dynamic> map = {};
    map['to'] = to;
    map['message'] = _buildEmailMessageMap(subject, html);

    await colRef
        .add(map)
        .then((DocumentReference doc) => result = true)
        .onError((e, _) {
      return false;
    });

    return result;
  }

  Map<String, dynamic> _buildEmailMessageMap(String subject, String html) {
    Map<String, dynamic> msgMap = {};
    msgMap['subject'] = subject;
    msgMap['html'] = html;
    return msgMap;
  }

  ///--------------------------------------------
  void _handleError(Object? ex, StackTrace stackTrace) {
    String traceMsg = _buildTraceMsg(stackTrace);
    _saveError(ex.toString(), traceMsg);

    String html =
        '<div>Error detected in public_rooster: $ex <br> $traceMsg</div>';
    sendEmail(to: "robin.bakkerus@gmail.com", subject: 'Error', html: html);

    // AppEvents.fireErrorEvent(ex.toString());
  }

  String _buildTraceMsg(StackTrace stackTrace) {
    String traceMsg = '';
    Trace trace = Trace.from(stackTrace).terse;
    List<Frame> frames = trace.frames;
    for (Frame frame in frames) {
      String s = frame.toString();
      if (s.contains('rooster')) {
        traceMsg += '$s;';
      }
    }
    return traceMsg;
  }

  ///--------------------------------------------
  void _saveError(String errMsg, String trace) {
    CollectionReference colRef = collectionRef(FsCol.error);

    Map<String, dynamic> map = {
      'at': DateTime.now(),
      'err': errMsg,
      'trace': trace,
    };

    String id = _uniqueDocId();
    colRef.doc(id).set(map);
  }

  ///----------------
  String _uniqueDocId() {
    String id = 'public_rooster-${DateTime.now().microsecondsSinceEpoch}';
    return id;
  }
}
