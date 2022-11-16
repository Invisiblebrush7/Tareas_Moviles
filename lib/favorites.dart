// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, duplicate_import

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practica_2/bloc/fav_songs_bloc.dart';
import 'package:practica_2/components/small_card.dart';

//import '../bloc/favsongs_bloc.dart';

class FavsPage extends StatefulWidget {
  const FavsPage({Key? key}) : super(key: key);

  @override
  State<FavsPage> createState() => _FavsPageState();
}

class _FavsPageState extends State<FavsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [],
        title: Text("Favoritos"),
      ),
      body: Container(
        child: BlocConsumer<FavSongsBloc, FavSongsState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is FavSongsSuccessState) {
              return ListView.builder(
                itemCount: state.favSongs.length,
                itemBuilder: (BuildContext context, int index) {
                  return SmallCard(
                    author: state.favSongs[index]["author"],
                    title: state.favSongs[index]["title"],
                    imageUrl: state.favSongs[index]["imageUrl"],
                  );
                },
              );
            } else if (state is FavSongsEmptyState) {
              return Center(
                child: Text("Sin favoritos. Trata de agregar alguna canción"),
              );
            } else if (state is FavSongsLoadingState) {
              return CircularProgressIndicator();
            } else {
              return Row(
                children: [
                  Text('Error :('),
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              );
            }
          },
        ),
      ),
    );
  }
}
