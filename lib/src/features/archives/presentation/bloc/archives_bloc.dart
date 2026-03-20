import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_archives_usecase.dart';
import 'archives_event.dart';
import 'archives_state.dart';

@injectable
class ArchivesBloc extends Bloc<ArchivesEvent, ArchivesState> {
  final GetArchivesUseCase _getArchivesUseCase;

  ArchivesBloc(this._getArchivesUseCase) : super(ArchivesInitial()) {
    on<LoadArchives>(_onLoadArchives);
  }

  Future<void> _onLoadArchives(
    LoadArchives event,
    Emitter<ArchivesState> emit,
  ) async {
    emit(ArchivesLoading());
    try {
      final reports = await _getArchivesUseCase();
      emit(ArchivesLoaded(reports));
    } catch (e) {
      emit(ArchivesError(e.toString()));
    }
  }
}
