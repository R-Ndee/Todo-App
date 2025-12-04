class TodoModel {
  int? id;
  String title;
  String? description;
  DateTime deadline;
  String priority; // 'high', 'medium', 'low'
  String category; // 'kuliah', 'kerja', 'pribadi', 'lainnya'
  String status; // 'pending', 'in_progress', 'completed'
  bool isCompleted;
  DateTime createdAt;
  DateTime updatedAt;

  TodoModel({
    this.id,
    required this.title,
    this.description,
    required this.deadline,
    required this.priority,
    required this.category,
    this.status = 'pending',
    this.isCompleted = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'priority': priority,
      'category': category,
      'status': status,
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create from Map (from database)
  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      deadline: DateTime.parse(map['deadline']),
      priority: map['priority'],
      category: map['category'],
      status: map['status'],
      isCompleted: map['is_completed'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  // Copy with method for updating
  TodoModel copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? deadline,
    String? priority,
    String? category,
    String? status,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      status: status ?? this.status,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'TodoModel(id: $id, title: $title, priority: $priority, deadline: $deadline)';
  }
}