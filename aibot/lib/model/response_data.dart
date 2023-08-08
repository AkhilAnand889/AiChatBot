class ResponseData {
  final String id;
  final String question;
  final String data;

  ResponseData({
    required this.id,
    required this.question,
    required this.data,
  });

  // Use the main constructor to create a history ResponseData object
  factory ResponseData.history({
    required String id,
    required String question,
    required String data,
  }) {
    return ResponseData(
      id: id,
      question: question,
      data: data,
    );
  }

  // Convert ResponseData object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'data': data,
    };
  }

  // Convert a Map object to ResponseData
  static ResponseData fromMap(Map<String, dynamic> map) {
    return ResponseData(
      id: map['id'],
      question: map['question'],
      data: map['data'],
    );
  }

  @override
  String toString() {
    return 'ResponseData{id: $id, question: $question, data: $data}';
  }
}
