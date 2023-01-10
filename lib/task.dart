
import 'main.dart';
import 'package:flutter/material.dart';


class ViewEditTaskWidget extends StatefulWidget{
  const ViewEditTaskWidget({Key?key}) : super(key:key);

  
  @override
  _ViewEditTaskWidgetState createState() => _ViewEditTaskWidgetState();
}

class _ViewEditTaskWidgetState extends State<ViewEditTaskWidget>{
  final _formKey=GlobalKey<FormState>();
  final _titleController= TextEditingController();
  final _descriptionController= TextEditingController();
  TimeOfDay? _alarmTime;
  bool _visibleAlarmTime=false;

  void _show() async {
    final TimeOfDay? result=
      await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (result!=null) {
      setState(() {
        _alarmTime=result;
        _visibleAlarmTime=true;
      });
    }

  }
  @override
  void dispose(){
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
    appBar: AppBar(
      title: const Text('View/Edit Task'),
    ),
    body: Form(
      key: _formKey,
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            decoration: const InputDecoration(
              hintText: 'Title',
              border: OutlineInputBorder(
                borderSide: BorderSide()
              )
            ),
            controller: _titleController,
            validator: (value) {
              if(value==null || value.isEmpty){
                return 'Title cannot by empty';
              }
              return null;
              
            },
          
          ),
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            minLines: 2,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText: 'Description',
              border: OutlineInputBorder(
                borderSide: BorderSide()
              )
            ),
          controller: _descriptionController,
          ),
          
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: _show,
                icon: Image.asset('assets/images/notifications_24px.png.png'),
                tooltip: 'Notification',
             ),
             Visibility(
              visible: _visibleAlarmTime,
              child: Text( _alarmTime != null ? _alarmTime!.format(context) : '')),
              Visibility(
              visible: _visibleAlarmTime,
              child: IconButton(
                onPressed: () {setState(() {
                  _alarmTime=null;
                  _visibleAlarmTime=false;
                  
                });} ,
                icon: Icon(Icons.cancel),)),
             const Flexible(fit: FlexFit.tight ,child: SizedBox()),
             Padding(padding: const EdgeInsets.all(8.0),
             child: ElevatedButton(child: const Text('Cancel', 
             style: TextStyle(color: Colors.blue),),
             style: ButtonStyle(backgroundColor: 
             MaterialStateProperty.all(Colors.white)),
             onPressed: () {
              Navigator.pop(context);
             },),
             ),
             Padding(padding: const EdgeInsets.all(8.0),
             child: ElevatedButton(child: const Text('Save', 
             ),
             
             onPressed: () {
              if(_formKey.currentState!.validate()){
                
                final task= Task(title: _titleController.text,
                description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
                alarm: _alarmTime,
                completed: false );
                
                Navigator.pop(context,task);
              }
             },),
             )
               
            ],
          ),
          ),
  


      ],
      )),
   );
  }

}



