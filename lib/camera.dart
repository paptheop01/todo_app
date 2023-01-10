import 'package:camera/camera.dart';
import 'package:flutter/material.dart';


class CameraScreenWidget extends StatefulWidget{
  const CameraScreenWidget({super.key,required this.camera});
  final CameraDescription camera;
  @override
  _CameraScreenWidgetState createState() => _CameraScreenWidgetState();

}

class _CameraScreenWidgetState extends State<CameraScreenWidget>{
  late CameraController _camcontroller;
  @override 
  void initState() {
   
    super.initState();
    _camcontroller=CameraController(widget.camera, ResolutionPreset.max);
  }
  @override 
  void dispose(){
    _camcontroller.dispose();
    super.dispose();

  }
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FutureBuilder<void>(builder: ((context, snapshot) {
            if(snapshot.connectionState==ConnectionState.done){
              return CameraPreview(_camcontroller);
            }
            else{
              return const Center(child: CircularProgressIndicator(),);
            }
          })),
          Text('text to be identified'),
        ]),
        floatingActionButton: FloatingActionButton(onPressed: () {
          
        },),

    );

}
}