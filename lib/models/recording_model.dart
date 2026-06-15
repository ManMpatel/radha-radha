import 'package:hive/hive.dart';

part 'recording_model.g.dart';

@HiveType(typeId: 0)
class RecordingModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String filePath;

  @HiveField(3)
  String fileName;

  @HiveField(4)
  int intervalSeconds;

  @HiveField(5)
  bool isActive;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime? lastPlayedAt;

  @HiveField(8)
  int? audioDurationMs;

  RecordingModel({
    required this.id,
    required this.name,
    required this.filePath,
    required this.fileName,
    required this.intervalSeconds,
    this.isActive = false,
    required this.createdAt,
    this.lastPlayedAt,
    this.audioDurationMs,
  });

  Duration? get audioDuration =>
      audioDurationMs != null ? Duration(milliseconds: audioDurationMs!) : null;

  RecordingModel copyWith({
    String? id,
    String? name,
    String? filePath,
    String? fileName,
    int? intervalSeconds,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastPlayedAt,
    int? audioDurationMs,
  }) {
    return RecordingModel(
      id: id ?? this.id,
      name: name ?? this.name,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      intervalSeconds: intervalSeconds ?? this.intervalSeconds,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      audioDurationMs: audioDurationMs ?? this.audioDurationMs,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'filePath': filePath,
        'fileName': fileName,
        'intervalSeconds': intervalSeconds,
        'isActive': isActive,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'lastPlayedAt': lastPlayedAt?.millisecondsSinceEpoch,
        'audioDurationMs': audioDurationMs,
      };
}
