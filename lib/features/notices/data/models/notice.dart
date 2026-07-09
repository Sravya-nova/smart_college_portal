class Notice {
  final String id;
  final String title;
  final String category; // Academic, Events, Placement, Administrative
  final String date;
  final String snippet;
  final String description;
  final String imageUrl;

  const Notice({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.snippet,
    required this.description,
    required this.imageUrl,
  });

  Notice copyWith({
    String? id,
    String? title,
    String? category,
    String? date,
    String? snippet,
    String? description,
    String? imageUrl,
  }) {
    return Notice(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      date: date ?? this.date,
      snippet: snippet ?? this.snippet,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
