class Tutorial {
  final String id;
  final String title;
  final String description;
  final String thumbnail;
  final String videoUrl;

  Tutorial({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.videoUrl,
  });

  factory Tutorial.fromJson(Map<String, dynamic> json) {
    return Tutorial(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      thumbnail: json['thumbnail'],
      videoUrl: json['videoUrl'],
    );
  }
}