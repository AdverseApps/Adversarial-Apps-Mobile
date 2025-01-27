import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:adversarialapps/services/cik_service.dart';

// Basic model
class Company {
  final String name;
  final String cik;
  Company({required this.name, required this.cik});
}

// State
class SearchState extends Equatable {
  final bool isLoading;
  final List<Company> results;
  final String? error;

  const SearchState({
    this.isLoading = false,
    this.results = const [],
    this.error,
  });

  SearchState copyWith({
    bool? isLoading,
    List<Company>? results,
    String? error,
  }) {
    return SearchState(
      isLoading: isLoading ?? this.isLoading,
      results: results ?? this.results,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, results, error];
}

// Cubit
class SearchCubit extends Cubit<SearchState> {
  final CikService _cikService;

  SearchCubit(this._cikService) : super(const SearchState());

  Future<void> search(String query) async {
    if (query.isEmpty) {
      // If user cleared the box, reset
      emit(state.copyWith(isLoading: false, results: [], error: null));
      return;
    }

    // Indicate loading
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final rawResults = await _cikService.obtainCikNumber(query);

      // Convert to our model
      final companies = rawResults.map((item) {
        return Company(
          name: item['name'] ?? '',
          cik: item['cik'] ?? '',
        );
      }).toList();

      emit(state.copyWith(isLoading: false, results: companies));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }
}
