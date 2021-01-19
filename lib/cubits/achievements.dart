import '../models/index.dart';
import '../repositories/index.dart';
import 'base/index.dart';

class AchievementsCubit
    extends RequestPersistantCubit<AchievementsRepository, List<Achievement>> {
  AchievementsCubit(AchievementsRepository repository) : super(repository);

  @override
  Future<void> loadData() async {
    emit(RequestState.loading());

    try {
      final data = await repository.fetchData();

      emit(RequestState.loaded(data));
    } catch (e) {
      emit(RequestState.error(e));
    }
  }
}