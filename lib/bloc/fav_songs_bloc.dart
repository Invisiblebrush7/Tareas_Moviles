import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth/auth_repo.dart';
import '../song.dart';

part 'fav_songs_event.dart';
part 'fav_songs_state.dart';

class FavSongsBloc extends Bloc<FavSongsEvent, FavSongsState> {
  FavSongsBloc() : super(FavSongsInitial()) {
    on<GetAllFavsEvent>(getAllFavSongs);
    on<RemoveFavEvent>(removeFavSong);
    on<AddFavSongEvent>(addFavSong);
  }

  FutureOr<void> getAllFavSongs(event, emit) async {
    emit(FavSongsLoadingState());
    try {
      // Get songs from user - Gets array of IDS
      DocumentSnapshot<Map<String, dynamic>> docsRef = await getDocsFromCurrentUser();
      List<dynamic> userSongs = docsRef.data()?["favsList"] ?? [];

      // Get all songs
      QuerySnapshot<Map<String, dynamic>> allSongs = await FirebaseFirestore.instance.collection("favs").get();

      // JOIN user.songs with allSongs - Array of docs (Songs)
      var listOfSongsJoined = allSongs.docs.where((doc) => userSongs.contains(doc.id)).toList();
      // Convert list of docs, to list of Map<String, dynamic>
      var favSongsList = listOfSongsJoined.map((doc) => doc.data().cast<String, dynamic>()).toList();

      if (favSongsList.isEmpty) {
        emit(FavSongsEmptyState());
      } else {
        emit(FavSongsSuccessState(favSongs: favSongsList));
      }
    } catch (e) {
      print("Error while getting disabled items: $e");
    }
  }

  FutureOr<void> removeFavSong(event, emit) async {
    emit(FavSongsLoadingState());
    try {
      // Query to get pictures from current user
      DocumentSnapshot<Map<String, dynamic>> docsRef = await getDocsFromCurrentUser();
      List<dynamic> songsIDs = docsRef.data()?["favsList"] ?? [];

      // query to get documents from favs
      var querySongs = await FirebaseFirestore.instance.collection("favs").get();

      // filter everything (that it belongs to current user

      var listOfIDs = querySongs.docs.where((doc) => doc["title"] != event.title && songsIDs.contains(doc.id));

      var favSongsList = listOfIDs.map((doc) => doc.data().cast<String, dynamic>()).toList();

      List<String> newFavsIDS = [];

      for (var doc in listOfIDs) {
        newFavsIDS.add(doc.id);
      }

      if (favSongsList.isEmpty) {
        emit(FavSongsEmptyState());
      } else {
        UserAuthRepository repo = UserAuthRepository();
        repo.createUserCollectionFromCopy(FirebaseAuth.instance.currentUser!.uid, newFavsIDS);
        emit(FavSongsSuccessState(favSongs: favSongsList));
      }
    } catch (e) {
      print("Error while getting items: $e");
    }
  }

  FutureOr<void> addFavSong(event, emit) async {
    emit(FavSongsLoadingState());
    try {
      // Upload the new song to all songs
      String newId = await uploadNewSong(event.songToAdd);

      // Get songs from user + newFavSong - Gets array of IDS
      DocumentSnapshot<Map<String, dynamic>> docsRef = await getDocsFromCurrentUser();
      List<dynamic> userSongs = docsRef.data()?["favsList"] ?? [];
      userSongs.add(newId);

      // Get all songs
      QuerySnapshot<Map<String, dynamic>> allSongs = await FirebaseFirestore.instance.collection("favs").get();

      // JOIN user.songs with allSongs - Array of docs (Songs)
      var listOfSongsJoined = allSongs.docs.where((doc) => userSongs.contains(doc.id)).toList();

      // Convert list of docs, to list of Map<String, dynamic>
      var favSongsList = listOfSongsJoined.map((doc) => doc.data().cast<String, dynamic>()).toList();

      // Get all joined songs, get ID and push it to a new array
      // We will set the user favsList to this new array
      List<String> newUserFavSongsList = [];
      for (var doc in listOfSongsJoined) {
        newUserFavSongsList.add(doc.id);
      }

      if (favSongsList.isEmpty) {
        emit(FavSongsEmptyState());
      } else {
        UserAuthRepository repo = UserAuthRepository();
        // We switch the user's favsList with newUserFavSongsList (The updated one)
        repo.createUserCollectionFromCopy(FirebaseAuth.instance.currentUser!.uid, newUserFavSongsList);
        emit(FavSongsSuccessState(favSongs: favSongsList));
      }
    } catch (e) {
      print("Error while getting items: $e");
    }
  }

  // Just reusable method to get current user's docs
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocsFromCurrentUser() async {
    var queryUser = FirebaseFirestore.instance.collection("users").doc("${FirebaseAuth.instance.currentUser!.uid}");
    // get data from document
    DocumentSnapshot<Map<String, dynamic>> docsRef = await queryUser.get();
    return docsRef;
  }

  // Create a new document and add it to favs collection
  Future<String> uploadNewSong(Song newSong) async {
    try {
      DocumentReference addedSong = await FirebaseFirestore.instance.collection('favs').add(newSong.getSongAsMap());
      // await addedSong.get().then((value) => print(value.data()));
      return addedSong.id;
    } catch (e) {
      print("Error while adding a new song to all songs: $e");
      return "";
    }
  }
}
