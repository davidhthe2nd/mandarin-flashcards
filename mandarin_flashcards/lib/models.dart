import 'package:flutter/foundation.dart';
import 'models/enums.dart';


@immutable
class VocabCard {
final String id; // stable unique id (e.g., hanzi or UUID)
final String hanzi;
final String pinyin;
final String translation;


const VocabCard({
required this.id,
required this.hanzi,
required this.pinyin,
required this.translation,
});
}


@immutable
class CardProgress {
final String cardId;
final LearningStatus status;
final AnswerQuality? lastAnswer;
final int timesSeen;
final DateTime? lastReviewed;
final DateTime? nextDue;


const CardProgress({
required this.cardId,
required this.status,
required this.lastAnswer,
required this.timesSeen,
required this.lastReviewed,
required this.nextDue,
});


CardProgress copyWith({
LearningStatus? status,
AnswerQuality? lastAnswer,
int? timesSeen,
DateTime? lastReviewed,
DateTime? nextDue,
}) => CardProgress(
cardId: cardId,
status: status ?? this.status,
lastAnswer: lastAnswer ?? this.lastAnswer,
timesSeen: timesSeen ?? this.timesSeen,
lastReviewed: lastReviewed ?? this.lastReviewed,
nextDue: nextDue ?? this.nextDue,
);


factory CardProgress.initial(String cardId) => CardProgress(
cardId: cardId,
status: LearningStatus.toLearn,
lastAnswer: null,
timesSeen: 0,
lastReviewed: null,
nextDue: DateTime.now(),
);
}