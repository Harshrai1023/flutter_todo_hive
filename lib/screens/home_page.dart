import 'package:flutter/material.dart';
import 'package:flutter_todo_app/constants/colors.dart';
import 'package:flutter_todo_app/models/todo_modal.dart';
import 'package:flutter_todo_app/widgets/todo_items_widget.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _myBox = Hive.box("box");
  final todoList = TodoModel.todoList();
  final _todoController = TextEditingController();
  List<TodoModel> _foundTodo = [];
  late bool _isEmpty = true;

  @override
  void initState() {
    // TODO: implement initState
    if (_myBox.get(1) != null) {
      for (var task in _myBox.get(1)) {
        _boxTodoItem(task.id, task.todoText, task.isDone);
      }
    }
    _foundTodo = todoList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tdBGColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 10,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Visibility(
                    visible: _isEmpty,
                    child: Center(
                      child: Text(
                        "No tasks yet!\nClick on '+' to add a task",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: tdGrey,
                        ),
                      ),
                    ),
                  ),
                  Visibility(visible: !_isEmpty, child: searchBox()),
                  Visibility(
                    visible: !_isEmpty,
                    child: Expanded(
                      child: ListView(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 20),
                            child: const Text(
                              "Today's Task",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          for (TodoModel todoModel in _foundTodo.reversed)
                            TodoItemWidget(
                              todo: todoModel,
                              onToDoChanged: _handleTodoChange,
                              onDeleteItem: _deleteTodoItem,
                            ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(
                      bottom: 20,
                      right: 20,
                      left: 20,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 0.0),
                          blurRadius: 10.0,
                          spreadRadius: 0.0,
                        )
                      ],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _todoController,
                      decoration: const InputDecoration(
                        hintText: "Add a new task",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    bottom: 20,
                    right: 20,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tdBlue,
                      minimumSize: const Size(55, 55),
                      elevation: 10,
                    ),
                    child: const Icon(Icons.add),
                    onPressed: () {
                      if (_todoController.text.isNotEmpty) {
                        _addTodoItem(_todoController.text);
                      }
                    },
                  ),
                )
              ]),
            )
          ],
        ),
      ),
    );
  }

  void _handleTodoChange(TodoModel todoModel) {
    setState(() {
      todoModel.isDone = !todoModel.isDone;
    });
    _myBox.put(1, todoList);
  }

  void _deleteTodoItem(String id) {
    setState(() {
      todoList.removeWhere(
        (item) => item.id == id,
      );
      if (todoList.isEmpty) {
        _isEmpty = true;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Congratulations! All tasks completed.")));
      }
      _myBox.put(1, todoList);
    });
  }

  void _addTodoItem(String todoText) {
    setState(() {
      todoList.add(TodoModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        todoText: todoText,
      ));
      _isEmpty = false;
    });
    _todoController.clear();
    _myBox.put(1, todoList);
  }

  void _boxTodoItem(String id, String todoText, bool isDone) {
    setState(() {
      todoList.add(TodoModel(
        id: id,
        todoText: todoText,
        isDone: isDone,
      ));
      _isEmpty = false;
    });
  }

  void _runFilter(String enteredKeyword) {
    List<TodoModel> results = [];
    if (enteredKeyword.isEmpty) {
      results = todoList;
    } else {
      results = todoList
          .where((item) => item.todoText!
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      _foundTodo = results;
    });
  }

  Container searchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        onChanged: _runFilter,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(0),
          prefixIcon: Icon(
            Icons.search,
            color: tdBlack,
            size: 20,
          ),
          prefixIconConstraints: const BoxConstraints(
            maxHeight: 20,
            minWidth: 25,
          ),
          border: InputBorder.none,
          hintText: "Search",
          hintStyle: TextStyle(color: tdGrey),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: tdBGColor,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 30,
            width: 30,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset("assets/images/TaskMateIcon.ico"),
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            "TaskMate",
            style: TextStyle(color: Colors.blue.shade600, fontSize: 25),
          )
        ],
      ),
    );
  }
}
