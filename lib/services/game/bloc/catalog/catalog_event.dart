import 'package:equatable/equatable.dart';

sealed class CatalogEvent extends Equatable {
  const CatalogEvent();

  @override
  List<Object?> get props => const [];
}

final class CatalogLoadRequested extends CatalogEvent {
  const CatalogLoadRequested();
}

final class CatalogSearchChanged extends CatalogEvent {
  const CatalogSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}
