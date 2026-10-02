import 'package:flutter/material.dart';

void main() => runApp(const TodoApp());

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1F6F78),
        useMaterial3: true,
      ),
      home: const TodoPage(),
    );
  }
}

class Todo {
  Todo(this.title) : id = DateTime.now().microsecondsSinceEpoch;

  final int id;
  final String title;
  bool done = false;
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final List<Todo> _todos = [];
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  int get _remaining => _todos.where((t) => !t.done).length;
  bool get _hasCompleted => _todos.any((t) => t.done);

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addTodo() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _todos.add(Todo(text)));
    _controller.clear();
    _focusNode.requestFocus(); // keep the keyboard open for the next task
  }

  void _toggle(Todo todo) {
    setState(() => todo.done = !todo.done);
  }

  void _remove(Todo todo) {
    final index = _todos.indexOf(todo);
    setState(() => _todos.removeAt(index));

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Deleted "${todo.title}"'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => setState(() => _todos.insert(index, todo)),
          ),
        ),
      );
  }

  void _clearCompleted() {
    setState(() => _todos.removeWhere((t) => t.done));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Todos'),
        actions: [
          if (_hasCompleted)
            TextButton(
              onPressed: _clearCompleted,
              child: const Text('Clear done'),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _addTodo(),
                    decoration: const InputDecoration(
                      hintText: 'What do you need to do?',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addTodo,
                  icon: const Icon(Icons.add),
                  tooltip: 'Add task',
                ),
              ],
            ),
          ),
          if (_todos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _remaining == 0
                      ? 'All done!'
                      : '$_remaining of ${_todos.length} left',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              ),
            ),
          Expanded(
            child: _todos.isEmpty
                ? Center(
                    child: Text(
                      'Nothing to do yet.\nAdd a task above.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    itemCount: _todos.length,
                    itemBuilder: (context, index) {
                      final todo = _todos[index];
                      return Dismissible(
                        key: ValueKey(todo.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _remove(todo),
                        background: Container(
                          color: colors.errorContainer,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: Icon(Icons.delete, color: colors.onErrorContainer),
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: todo.done,
                            onChanged: (_) => _toggle(todo),
                          ),
                          title: Text(
                            todo.title,
                            style: TextStyle(
                              decoration:
                                  todo.done ? TextDecoration.lineThrough : null,
                              color: todo.done ? colors.outline : null,
                            ),
                          ),
                          onTap: () => _toggle(todo),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: 'Delete',
                            onPressed: () => _remove(todo),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
