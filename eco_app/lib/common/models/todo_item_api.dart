class TodoItemAPI {
  final String id;
  final String name;
  final String? parent;
  final List<TodoItemAPI> children;
  final String userId;

  TodoItemAPI({
    required this.id,
    required this.name,
    required this.parent,
    required this.children,
    required this.userId,
  });

  factory TodoItemAPI.fromJson(Map<String, dynamic> json) {
    return TodoItemAPI(
      id: json['_id'],
      name: json['name'],
      parent: json['parent'],
      children: json['children']
          .map<TodoItemAPI>((e) => TodoItemAPI.fromJson(e))
          .toList(),
      userId: json['userId'],
    );
  }

  TodoItemAPI? findParent(String parentId) {
    if (id == parentId) {
      return this;
    }
    for (var child in children) {
      var parent = child.findParent(parentId);
      if (parent != null) {
        return parent;
      }
    }
    return null;
  }

  void addListChild(List<TodoItemAPI> listChild) {
    children.addAll(listChild);
  }
}
