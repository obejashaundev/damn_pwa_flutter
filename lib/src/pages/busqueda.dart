// ignore_for_file: prefer_typing_uninitialized_variables, must_be_immutable
import 'dart:convert';
import 'dart:html' as html;
import 'package:audioplayers/audioplayers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../providers/server.dart' as server;

class Busqueda extends StatefulWidget {
  const Busqueda({Key? key}) : super(key: key);

  @override
  State<Busqueda> createState() => _BusquedaState();
}

class _BusquedaState extends State<Busqueda> {
  final audioPlayer = AudioPlayer();

  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  String songTitle = "Reproduzca una vista previa";

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }

  Future setAudio(String url) async {
    Fluttertoast.showToast(msg: "Cargando... espere");
    audioPlayer.play(url, isLocal: false).then((v) {
      Fluttertoast.showToast(msg: "Reproduciendo!");
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.PLAYING;
      });
    });

    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    audioPlayer.onAudioPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });

    audioPlayer.onPlayerError.listen((error) {
      Fluttertoast.showToast(msg: error, toastLength: Toast.LENGTH_LONG);
      print("ERRORSOTE: " + error);
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    var searchText = ModalRoute.of(context)?.settings.arguments;
    //print('Text to Search $searchText');
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the Busqueda object that was created by
        // the App.build method, and use it to set our appbar title.
        title: tituloBar(),
        backgroundColor: Colors.grey,
      ),
      body: degradadoContenedor(searchText.toString()),
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
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 30,
                    color: Colors.green,
                  ),
                  onPressed: () async {
                    String message = isPlaying
                        ? "Audio pausado..."
                        : "Reproduciendo audio...";
                    Fluttertoast.showToast(msg: message);
                    if (isPlaying) {
                      await audioPlayer.pause();
                    } else {
                      await audioPlayer.resume();
                    }
                  },
                )),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [Text(songTitle), Text(formatTime(position))],
            ),
          ],
        ),
      ),
    );
  }

  Widget tituloBar() {
    return const Text(
      'TECMOBILE',
      style: TextStyle(fontFamily: 'Komika', fontSize: 20),
    );
  }

  Widget degradadoContenedor(String searchText) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
        Color.fromARGB(255, 95, 221, 119),
        Color.fromARGB(255, 10, 159, 126),
        Color.fromARGB(255, 10, 159, 126),
        Color.fromARGB(255, 95, 221, 119),
      ], begin: FractionalOffset.topLeft, end: FractionalOffset.bottomRight)),
      child: Center(
        child: Column(
          children: <Widget>[
            tituloBusqueda(),
            barraBusqueda(searchText),
            Expanded(
                child: FutureBuilder<List<Song>>(
              future: getSongs(searchText),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  Fluttertoast.showToast(msg: snapshot.error.toString());
                }
                return snapshot.hasData
                    ? listadoCanciones(snapshot.data)
                    : const Center(child: CircularProgressIndicator());
              },
            ))
          ],
        ),
      ),
    );
  }

  Widget tituloBusqueda() {
    return Container(
      margin: const EdgeInsets.fromLTRB(50, 50, 50, 0),
      child: const Text(
        'Canción o Artista',
        textAlign: TextAlign.center,
        style: TextStyle(
            fontFamily: 'ActionMan',
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                  blurRadius: 5.0,
                  color: Color.fromARGB(165, 0, 0, 0),
                  offset: Offset(5.0, 5.0))
            ]),
      ),
    );
  }

  Widget barraBusqueda(String searchText) {
    TextEditingController ctrlBusqueda =
        TextEditingController(text: searchText);
    return Container(
        margin: const EdgeInsets.fromLTRB(45, 50, 45, 60),
        child: TextField(
            controller: ctrlBusqueda,
            decoration: const InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Color.fromARGB(255, 255, 255, 255), width: 3)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Color.fromARGB(255, 238, 238, 238), width: 3)),
              filled: true,
              fillColor: Color.fromARGB(255, 215, 250, 245),
              /* suffixIcon: IconButton(
                    onPressed: () {
                      Fluttertoast.showToast(msg: "Busqueda nueva");
                    },
                    icon: const Icon(Icons.search) )*/
            )));
  }

  Widget itemCancion(String url, String title, String thumbnailURL) {
    return Container(
      margin: const EdgeInsets.fromLTRB(46, 0, 46, 20),
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: const BoxDecoration(
          color: Color.fromARGB(255, 2, 115, 100),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Flexible(flex: 1, child: Image.network(thumbnailURL)),
          Expanded(
            flex: 3,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Dustismo',
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
          Flexible(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    Fluttertoast.showToast(msg: "Descargando... espere");
                    downloadSong(title, url);
                    Fluttertoast.showToast(msg: "Descargado con éxito");
                  },
                  icon: const Icon(Icons.download, color: Colors.yellow),
                ),
                IconButton(
                  onPressed: () async {
                    String linkTemp = server.link;
                    String route =
                        "$linkTemp/downloadPwa?titulo=$title&url=$url";
                    songTitle = title;
                    setAudio(route);
                  },
                  icon:
                      const Icon(Icons.play_arrow_rounded, color: Colors.green),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  NetworkImage getImage(String thumbnailURL) {
    return NetworkImage(thumbnailURL);
  }

  Future<List<Song>> getSongs(String searchText) async {
    String linkTemp = server.link;
    final respuesta = await http.get(Uri.parse("$linkTemp/search/$searchText"));
    List<dynamic> jsonData = json.decode(respuesta.body);
    List<Song> songs = [];
    for (Map<String, dynamic> s in jsonData) {
      Song song = Song(s['url'], s['title'], s['thumbnailURL']);
      songs.add(song);
    }
    return songs;
  }

  ListView listadoCanciones(List<Song> songs) {
    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (BuildContext context, int index) {
        return itemCancion(
            songs[index].url, songs[index].title, songs[index].thumbnailURL);
      },
    );
  }

  void downloadSong(String title, String url) async {
    String linkTemp = server.link;
    String route = "$linkTemp/downloadPwa?titulo=$title&url=$url";
    html.window.open(route, "new tab");
  }
}

class Song {
  final String url;
  final String title;
  final String thumbnailURL;
  Song(this.url, this.title, this.thumbnailURL);
}
