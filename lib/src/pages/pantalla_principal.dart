// ignore_for_file: prefer_const_constructors, prefer_const_constructors_in_immutables, avoid_print
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:soundpool/soundpool.dart';

class PantallaPrincipal extends StatefulWidget {
  PantallaPrincipal({Key? key}) : super(key: key);

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  TextEditingController searchControl = TextEditingController();
  late FilePickerCross _myFile;
  String fileTitle = "Selecciona un archivo para reproducir...";
  final _soundpool = Soundpool.fromOptions();
  int _soundId = 0;
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
          Color.fromARGB(255, 95, 221, 119),
          Color.fromARGB(255, 10, 159, 126),
          Color.fromARGB(255, 10, 159, 126),
          Color.fromARGB(255, 95, 221, 119),
        ], begin: FractionalOffset.topLeft, end: FractionalOffset.bottomRight)),
        child: Container(
          margin: EdgeInsets.fromLTRB(45, 50, 45, 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              //NOMBRE APP
              Text(
                'CANCIÓN O ARTISTA',
                style: TextStyle(
                  fontFamily: 'Komika',
                  color: Colors.white,
                  fontSize: 30,
                ),
              ),
              //CAJA BUSQUEDA
              TextField(
                  controller: searchControl,
                  keyboardType: TextInputType.text,
                  // obscureText: false,

                  //alineación del texto y estilo al escribir
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Dustismo',
                    fontSize: 15,
                  ),

                  //cursos
                  cursorColor: Colors.black87,

                  //decoracion de la caja
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 255, 255, 255),
                            width: 3)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 238, 238, 238),
                            width: 3)),
                    hintText: 'Buscar...',
                    hintStyle: TextStyle(
                      color: Colors.black87,
                      fontFamily: 'Dustismo',
                      fontSize: 15,
                    ),
                    filled: true,
                    fillColor: Color.fromARGB(255, 215, 250, 245),
                    //contentPadding: EdgeInsets.all(15),
                  )),
              //BOTON ACCEDER
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  onPrimary: Colors.white,
                  primary: Color.fromARGB(255, 5, 93, 74),
                  padding: EdgeInsets.symmetric(horizontal: 41, vertical: 20),
                ),
                child: const Text(
                  'Buscar',
                  style: TextStyle(
                    fontFamily: 'Dustismo',
                    fontSize: 15,
                  ),
                ),
                onPressed: () {
                  if (searchControl.text.isNotEmpty) {
                    Navigator.of(context).pushNamed(
                        '/pantalla_principal/busqueda',
                        arguments: searchControl.text);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        color: Colors.grey[350],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: IconButton(
                  icon: const Icon(
                    Icons.file_open_rounded,
                    size: 30,
                    color: Colors.green,
                  ),
                  onPressed: () async {
                    Fluttertoast.showToast(msg: "Elija un archivo!!!");
                    await FilePickerCross.importFromStorage(
                      type: FileTypeCross.audio,
                    ).then((value) {
                      _myFile = value;
                      fileTitle = _myFile.fileName!;
                      Fluttertoast.showToast(
                          msg: "Archivo cargado... listo para reproducir!");
                    });
                    setState(() {});
                  },
                )),
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: IconButton(
                  icon: Icon(
                    isPlaying ? Icons.stop : Icons.play_arrow,
                    size: 30,
                    color: Colors.green,
                  ),
                  onPressed: () {
                    String message = isPlaying
                        ? "Audio detenido..."
                        : "Reproduciendo audio...";
                    Fluttertoast.showToast(msg: message);
                    if (!isPlaying) {
                      _soundpool
                          .loadAndPlayUint8List(_myFile.toUint8List())
                          .then((id) {
                        _soundId = id;
                      });
                      isPlaying = true;
                    } else {
                      _soundpool.stop(_soundId);
                      isPlaying = false;
                    }
                    setState(() {});
                  },
                )),
            Text(fileTitle),
          ],
        ),
      ),
    );
  }
}
