import 'package:bloc_test/bloc_test.dart';
import 'package:cherry/cubits/base/index.dart';
import 'package:cherry/cubits/index.dart';
import 'package:cherry/models/index.dart';
import 'package:cherry/repositories-cubit/index.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockVehiclesRepository extends Mock implements VehiclesRepository {}

void main() {
  group('VehiclesCubit', () {
    VehiclesCubit cubit;
    MockVehiclesRepository repository;

    setUp(() {
      repository = MockVehiclesRepository();
      cubit = VehiclesCubit(repository);
    });

    tearDown(() {
      cubit.close();
    });

    test('fails when null service is provided', () {
      expect(() => VehiclesCubit(null), throwsAssertionError);
    });

    test('initial state is RequestState.init()', () {
      expect(cubit.state, RequestState<List<Vehicle>>.init());
    });

    group('fetchData', () {
      blocTest<VehiclesCubit, RequestState>(
        'fetches data correctly',
        build: () {
          when(repository.fetchData()).thenAnswer(
            (_) => Future.value(const [RocketVehicle(id: '1')]),
          );
          return cubit;
        },
        act: (cubit) async => cubit.loadData(),
        verify: (_) => verify(repository.fetchData()).called(1),
        expect: [
          RequestState<List<Vehicle>>.loading(),
          RequestState<List<Vehicle>>.loaded(const [RocketVehicle(id: '1')]),
        ],
      );

      blocTest<VehiclesCubit, RequestState>(
        'can throw an exception',
        build: () {
          when(repository.fetchData()).thenThrow(Exception('wtf'));
          return cubit;
        },
        act: (cubit) async => cubit.loadData(),
        verify: (_) => verify(repository.fetchData()).called(1),
        expect: [
          RequestState<List<Vehicle>>.loading(),
          RequestState<List<Vehicle>>.error(Exception('wtf').toString()),
        ],
      );
    });
  });
}
