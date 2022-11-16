import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:practica_2/services/storage.dart';
import 'package:practica_2/song.dart';
import 'package:record/record.dart';

import '../services/network.dart';

part 'recorder_event.dart';
part 'recorder_state.dart';

class RecorderBloc extends Bloc<RecorderEvent, RecorderState> {
  Storage storage = Storage();
  Record record = Record();

  RecorderBloc() : super(RecorderInitial()) {
    on<StartRecordingEvent>(startRecording);
  }

  FutureOr<void> startRecording(event, emit) async {
    // Check and request permission
    if (!await record.hasPermission()) {
      emit(RecorderFailedState);
    }
    String tempPath = await storage.getLocalPath();
    await record.start(
      path: tempPath,
    );
    emit(RecorderRecordingState());
    bool isRecording = await record.isRecording();

    if (!isRecording) {
      print('Error while stopping recording');
      emit(RecorderFailedState());
    }
    sleep(Duration(seconds: 5));
    String? path = await record.stop();
    File file = File(path!);
    String? fileBytes = await storage.readFile(file);
    if (fileBytes == null) {
      emit(RecorderFailedState());
    }

    Network myNetworkRepo = Network();
    dynamic songFound = await myNetworkRepo.getSong(fileBytes!);
    if (songFound['result'] == null) {
      emit(RecorderFailedState());
    } else {
      Song song = Song(
        author: songFound['result']?['artist'] ?? 'No author',
        title: songFound['result']?['title'] ?? 'No Title',
        imageUrl: songFound['result']?['apple_music']?['artwork']?['url'] ?? 'No imageUrl',
        songLink: songFound['result']?['song_link'] ?? 'No song link',
      );
      emit(RecorderSuccessState(song: song));
    }
  }
}
