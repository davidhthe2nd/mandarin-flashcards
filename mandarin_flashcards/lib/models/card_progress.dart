// lib/models/card_progress.dart
import 'package:hive/hive.dart';
import 'enums.dart'; // AnswerQuality, LearningStatus

const int kCardProgressTypeId = 101;
const int kLearningStatusTypeId = 102;

class CardProgress {
  final String cardId;
  int timesSeen;
  DateTime? lastReviewed;
  DateTime? nextDue;

  // NEW: what the user last answered (wrong/unsure/correct)
  AnswerQuality? lastAnswer;

  // Learning lifecycle status
  LearningStatus status;

  CardProgress({
    required this.cardId,
    this.timesSeen = 0,
    this.lastReviewed,
    this.nextDue,
    this.lastAnswer,
    this.status = LearningStatus.toLearn,
  });

  CardProgress copyWith({
    String? cardId,
    int? timesSeen,
    DateTime? lastReviewed,
    DateTime? nextDue,
    AnswerQuality? lastAnswer,
    LearningStatus? status,
  }) {
    return CardProgress(
      cardId: cardId ?? this.cardId,
      timesSeen: timesSeen ?? this.timesSeen,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      nextDue: nextDue ?? this.nextDue,
      lastAnswer: lastAnswer ?? this.lastAnswer,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'CardProgress(cardId: $cardId, timesSeen: $timesSeen, '
        'lastReviewed: $lastReviewed, nextDue: $nextDue, '
        'lastAnswer: $lastAnswer, status: $status)';
  }
}

/// Manual adapter for the LearningStatus enum (stores index as a byte).
class LearningStatusAdapter extends TypeAdapter<LearningStatus> {
  @override
  final int typeId = kLearningStatusTypeId;

  @override
  LearningStatus read(BinaryReader reader) {
    final idx = reader.readByte();
    if (idx < 0 || idx >= LearningStatus.values.length) {
      return LearningStatus.toLearn;
    }
    return LearningStatus.values[idx];
  }

  @override
  void write(BinaryWriter writer, LearningStatus obj) {
    writer.writeByte(obj.index);
  }
}

/// Manual adapter for CardProgress.
/// Order in write() MUST match order in read().
class CardProgressAdapter extends TypeAdapter<CardProgress> {
  @override
  final int typeId = kCardProgressTypeId;

  @override
  CardProgress read(BinaryReader reader) {
    final cardId = reader.readString();
    final timesSeen = reader.readInt();

    final hasLast = reader.readBool();
    final lastMs = hasLast ? reader.readInt() : null;
    final lastReviewed =
        (lastMs != null) ? DateTime.fromMillisecondsSinceEpoch(lastMs) : null;

    final hasNext = reader.readBool();
    final nextMs = hasNext ? reader.readInt() : null;
    final nextDue =
        (nextMs != null) ? DateTime.fromMillisecondsSinceEpoch(nextMs) : null;

    // NEW: lastAnswer as a nullable enum index
    final hasLastAnswer = reader.readBool();
    AnswerQuality? lastAnswer;
    if (hasLastAnswer) {
      final byte = reader.readByte();
      if (byte >= 0 && byte < AnswerQuality.values.length) {
        lastAnswer = AnswerQuality.values[byte];
      }
    }

    final status = reader.read() as LearningStatus; // via LearningStatusAdapter

    return CardProgress(
      cardId: cardId,
      timesSeen: timesSeen,
      lastReviewed: lastReviewed,
      nextDue: nextDue,
      lastAnswer: lastAnswer,
      status: status,
    );
  }

  @override
  void write(BinaryWriter writer, CardProgress obj) {
    writer
      ..writeString(obj.cardId)
      ..writeInt(obj.timesSeen)
      ..writeBool(obj.lastReviewed != null);
    if (obj.lastReviewed != null) {
      writer.writeInt(obj.lastReviewed!.millisecondsSinceEpoch);
    }

    writer.writeBool(obj.nextDue != null);
    if (obj.nextDue != null) {
      writer.writeInt(obj.nextDue!.millisecondsSinceEpoch);
    }

    // NEW: lastAnswer as a nullable enum index
    writer.writeBool(obj.lastAnswer != null);
    if (obj.lastAnswer != null) {
      writer.writeByte(obj.lastAnswer!.index);
    }

    writer.write(obj.status); // uses LearningStatusAdapter
  }
}
