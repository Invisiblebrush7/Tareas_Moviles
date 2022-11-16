part of 'fav_songs_bloc.dart';

abstract class FavSongsState extends Equatable {
  const FavSongsState();

  @override
  List<Object> get props => [];
}

class FavSongsInitial extends FavSongsState {}

class FavSongsSuccessState extends FavSongsState {
  final List<dynamic> favSongs;

  FavSongsSuccessState({required this.favSongs});

  @override
  List<Object> get props => [this.favSongs];
}

class FavSongsErrorState extends FavSongsState {}

class FavSongsEmptyState extends FavSongsState {}

class FavSongsLoadingState extends FavSongsState {}
