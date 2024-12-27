// Model for fetching questions with a particular topic.
class QuesModel{
  final List<Question>? ques_lst;
  final String topic;
  final String? Subject;
  final Duration? duration;
  final DateTime timeStamp;
  final int? score;
  QuesModel(this.ques_lst, this.topic, this.duration, this.timeStamp, this.score, this.Subject);
}
 
// Model for each question.
class Question{
  final String question;
  final int answer_indx;
  final int? attempted_indx;
  final List<String> choices;
  Question(this.question, this.answer_indx, this.choices, this.attempted_indx);
}