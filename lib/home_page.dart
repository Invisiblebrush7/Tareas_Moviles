// ignore_for_file: avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, prefer_const_constructors, sort_child_properties_last,avoid_single_cascade_in_expression_statements

//import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practica_2/auth/bloc/google_auth_bloc.dart';
import 'package:practica_2/bloc/fav_songs_bloc.dart';
import 'package:practica_2/bloc/recorder_bloc.dart';
import 'package:practica_2/favorites.dart';
import 'package:practica_2/song.dart';
import 'package:practica_2/song_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
// Create and initialize a recorder.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text("Toque para escuchar", style: TextStyle(fontSize: 20)),
              // SizedBox(height: 500),
              BlocConsumer<RecorderBloc, RecorderState>(
                listener: (context, state) {
                  const snackBar = SnackBar(
                    content: Text('Listening...'),
                  );
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(snackBar);
                },
                builder: (context, state) {
                  if (state is RecorderInitial) {
                    return GestureDetector(
                      onTap: () async {
                        BlocProvider.of<RecorderBloc>(context)..add(StartRecordingEvent());
                      },
                      child: CircleAvatar(
                        minRadius: 50.0,
                        maxRadius: 75.0,
                        backgroundColor: Colors.blue[800],
                        child: const Text(
                          'Listen',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  } else if (state is RecorderSuccessState) {
                    return ElevatedButton(
                      onPressed: () {
                        Song song = state.song;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SongPage(
                              song: song,
                            ),
                          ),
                        );
                      },
                      child: Text('Ver canción'),
                    );
                  }
                  return Center(
                    child: Text(
                      'Loading...',
                    ),
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MaterialButton(
                    color: Colors.white,
                    child: Text("Ver Favoritos", style: TextStyle(color: Colors.black)),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const FavsPage()));
                      BlocProvider.of<FavSongsBloc>(context)..add(GetAllFavsEvent());
                    },
                  ),
                  MaterialButton(
                    color: Colors.white,
                    child: Text("Cerrar Sesión", style: TextStyle(color: Colors.black)),
                    onPressed: () {
                      BlocProvider.of<GoogleAuthBloc>(context)..add(SignOutGoogleAuthEvent());
                    },
                  ),
                ],
              )
            ],
          )
        ],
      )),
    );
  }
}
