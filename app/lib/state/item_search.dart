import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openapi/api.dart';

class SearchFilters {
  final String query;
  final List<String> categories;
  final double? maxDistanceKm;
  final double? minScore;
  final ItemSearchRequestSortByEnum sortBy;

  const SearchFilters({
    this.query = '',
    this.categories = const [],
    this.maxDistanceKm,
    this.minScore,
    this.sortBy = ItemSearchRequestSortByEnum.relevance,
  });

  SearchFilters copyWith({
    String? query,
    List<String>? categories,
    double? maxDistanceKm,
    double? minScore,
    ItemSearchRequestSortByEnum? sortBy,
  }) {
    return SearchFilters(
      query: query ?? this.query,
      categories: categories ?? this.categories,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      minScore: minScore ?? this.minScore,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  ItemSearchRequest toRequest(LatLng? location) {
    return ItemSearchRequest(
      query: query.isEmpty ? null : query,
      categories: categories.isEmpty ? const [] : categories,
      maxDistanceKm: maxDistanceKm,
      minScore: minScore,
      lat: location?.lat,
      lng: location?.lng,
      sortBy: sortBy,
    );
  }
}

class SearchFiltersNotifier extends Notifier<SearchFilters> {
  @override
  SearchFilters build() => const SearchFilters();

  void setQuery(String v) => state = state.copyWith(query: v);
  void setCategories(List<String> v) => state = state.copyWith(categories: v);
  void toggleCategory(String cat) {
    final cats = List<String>.from(state.categories);
    if (cats.contains(cat)) {
      cats.remove(cat);
    } else {
      cats.add(cat);
    }
    state = state.copyWith(categories: cats);
  }

  void setMaxDistanceKm(double? v) {
    state = SearchFilters(
      query: state.query,
      categories: state.categories,
      maxDistanceKm: v,
      minScore: state.minScore,
      sortBy: state.sortBy,
    );
  }

  void setMinScore(double? v) {
    state = SearchFilters(
      query: state.query,
      categories: state.categories,
      maxDistanceKm: state.maxDistanceKm,
      minScore: v,
      sortBy: state.sortBy,
    );
  }
  void setSortBy(ItemSearchRequestSortByEnum v) => state = state.copyWith(sortBy: v);
  void reset() => state = const SearchFilters();
}

final searchFiltersProvider = NotifierProvider<SearchFiltersNotifier, SearchFilters>(
  SearchFiltersNotifier.new,
);
