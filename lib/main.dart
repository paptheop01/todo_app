
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/task.dart';
import 'package:todo_app/camera.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;



late List<CameraDescription> cameras;
late CameraDescription firstCamera;



Future <void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
// can be called before `runApp()`
WidgetsFlutterBinding.ensureInitialized();

// Obtain a list of the available cameras on the device.
 cameras = await availableCameras();

// Get a specific camera from the list of available cameras.
 firstCamera = cameras.first;
  runApp(const ToDoApp());
}

class ToDoApp extends StatelessWidget {
  const ToDoApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TDTD',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const TaskListScreenWidget(),
    );
  }
}

class TaskListScreenWidget extends StatefulWidget {
  const TaskListScreenWidget({Key?key}) : super(key:key);

  
  @override
  _TaskListScreenWidgetState createState() => _TaskListScreenWidgetState();
}

class _TaskListScreenWidgetState extends State<TaskListScreenWidget> {
  late CameraController camcontroller;
  late SQLservice sqLiteservice;
  List<Task> _tasks=<Task>[];
  void _addNewTask() async{
     Task? newTask= await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ViewEditTaskWidget() ));
      if(newTask!=null){
        final newId=await sqLiteservice.addTask(newTask);
        newTask.id=newId;

        _tasks.add(newTask);
        setState(() {
          
        });

      }

  }
  @override
  void initState(){
    super.initState();
    sqLiteservice=SQLservice();
    sqLiteservice.initDB().whenComplete(() async{
      final tasks= await sqLiteservice.getTasks();
      setState(() {
        _tasks=tasks;
      });
    });
    camcontroller=CameraController(cameras[0], ResolutionPreset.max);
    camcontroller.initialize().then((_) {
      if(!mounted){
        return ;
      }
      setState(() {
        
      });
    });
  }
  @override
  void dispose(){
    camcontroller.dispose();
    super.dispose();
  }

  Widget _buildTaskList() {
    return ListView.separated(
      padding: const EdgeInsets.all(8.0),
      itemBuilder: (context, index)  {
        IconData iconData;
        String toolTip;
        TextDecoration textDEc;

        iconData=_tasks[index].completed ?  Icons.check_box_outlined:  Icons.check_box_outline_blank_outlined;
        toolTip=_tasks[index].completed ?  'Mark as Incomplete':  'Mark as completed';
        textDEc=_tasks[index].completed ?  TextDecoration.lineThrough:  TextDecoration.none;
        return ListTile(
          

          leading: IconButton(
            icon:  Icon(iconData),
            onPressed: () {
              _tasks[index].completed = _tasks[index].completed? false:true ;
              sqLiteservice.updateComplete(_tasks[index]);
              setState(() {
                
              });
            },
            tooltip: toolTip,),
          title: Text(_tasks[index].title,
              style: TextStyle(decoration: textDEc),),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Visibility(
                visible: _tasks[index].alarm==null? false:true,
                child: Text(_tasks[index].alarm!=null ? _tasks[index].alarm!.format(context):'',
                style: TextStyle(decoration: textDEc),)
                ),
                IconButton(onPressed: () {_deleteTask(index);}, 
                icon: Icon(Icons.delete),
                tooltip: 'Delete Task',),
                
            ],
          ),
        
        );},
        
      separatorBuilder: (context, index) =>const Divider(),
      itemCount: _tasks.length,
    );
  }

  void _deleteTask(int idx) async{
    bool? delTask = await showDialog<bool>(
      context: context, 
      builder: (BuildContext context) => AlertDialog(
        content: const Text('Delete Task?'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context,false), 
          child: const Text('cancel')),
          TextButton(onPressed: () => Navigator.pop(context,true), 
          child: const Text('delete')),
        ],
      ));
    if(delTask!){
      final task=_tasks.elementAt(idx);
      try{
        sqLiteservice.deleteTask(task.id);
        _tasks.removeAt(idx);
      } catch (err) {
          debugPrint('Could not delete task $task : $err');
      }
      setState(() {
        
      });

    }  

  }
  double timeOfDaytoDouble(TimeOfDay myTime) => myTime.hour+myTime.minute /60;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: PopupMenuButton<int>(
          icon : const Icon(Icons.menu),
          itemBuilder: (context) => <PopupMenuEntry<int>>[
            const PopupMenuItem(child: ListTile(
              title: Text('Clear Checked'),
              
            ),
            value: 1,
            ),
             const PopupMenuItem(child: ListTile(
              title: Text('Clear All'),
            ),
            value: 2,
            ),
             const PopupMenuItem(child: ListTile(
              title: Text('Order by Time'),
            ),
            value: 3,
            ),
             const PopupMenuItem(child: ListTile(
              title: Text('Order by name'),
            ),
            value: 4,
            ),
          ],
          onSelected: (value) => {
            
            setState(() {
              
            
              if(value==1){
                _tasks.removeWhere((element) => element.completed);
                sqLiteservice.deleteCompleted();


              } 
              else if(value==2){
                _tasks.clear();
                sqLiteservice.deleteAllTasks();

              } 
              else if(value==3){
                _tasks.sort((a, b) {
                  if(a.alarm==null) return 1;
                  if(b.alarm==null) return -1;

                  return timeOfDaytoDouble(a.alarm!).compareTo(timeOfDaytoDouble(b.alarm!));
                });

              } 
              else if(value==4){
                _tasks.sort((a, b) => a.title.compareTo(b.title));

              }
            })
          }, 
          
        ),
        title: Text('Task List'),
        actions: [
          IconButton(
            onPressed: () {},
             icon: Image.asset('assets/images/steer.png'),
             tooltip: 'CarMode',
             ),
          IconButton(
            onPressed: () {
               Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => CameraScreenWidget(camera:firstCamera) ));
            },
             icon: Image.asset('assets/images/trail3.png.png'),
             tooltip: 'Camera',
             ),   
        ],

      ),
      body : _buildTaskList(),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(onPressed: () {}, icon: const Icon(null))
          ],
        ),
        color: Colors.blue,),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addNewTask,
        backgroundColor: Colors.teal,
        tooltip: 'Add Task',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
  
}


class Task {
  int? id;
  String title;
  String? description;
  TimeOfDay? alarm;
  bool completed;
  Task({
    this.id,
    required this.title, 
    this.description, 
    this.alarm, 
    required this.completed }); 


  Map<String,dynamic> toMap(){
    final record={'title':title,'completed':completed?1:0};
    if(description!=null){
      record.addAll({'description':'$description'});
    }
    if(alarm!=null){
      record.addAll({'alarm':'${alarm!.hour}:${alarm!.minute}'});
    }
    return record;

  }
  Task.fromMap(Map<String,dynamic> task):
    id=task['id'],
    title=task['title'],
    description=task['description'],
    alarm=(task['alarm']!=null) ? TimeOfDay(hour: int.parse(task['alarm'].split(':')[0]), minute:int.parse(task['alarm'].split(':')[1]) ):null ,
    completed= task['completed']==1 ? true : false;



}



class SQLservice{
  Future <Database> initDB() async{
    return openDatabase(
      p.join(await getDatabasesPath(), 'todo.db'),
      onCreate:(db, version) {
        return db.execute(
          'CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT,description TEXT, alarm TEXT, completed INTEGER)'
        );
      },
      version: 1, 
    );
  
  }
  Future <List<Task>> getTasks() async{
    final db=await initDB();
    final List<Map<String,Object?>> queryResult= await db.query('tasks');
    return queryResult.map((e) => Task.fromMap(e)).toList();
  }
  Future<int> addTask(Task task) async{
    final db= await initDB();
    return db.insert('tasks', task.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future <void> deleteTask(final id) async{
    final db= await initDB();
    await db.delete('tasks',where: 'id=?',whereArgs: [id]);
  }


  Future <void> updateComplete(Task task) async{
    final db= await initDB();
    await db.update('tasks',{'completed':task.completed?1:0},where: 'id=?',whereArgs: [task.id],conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future <void> deleteCompleted() async{
    final db= await initDB();
    await db.delete('tasks',where: 'completed=1');
  }
  Future <void> deleteAllTasks() async{
    final db= await initDB();
    await db.delete('tasks');
  }

}