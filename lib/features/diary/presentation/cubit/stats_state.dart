import 'package:equatable/equatable.dart';
import 'package:questlog/features/diary/domain/entities/diary_stats.dart';

sealed class StatsState extends Equatable {
  const StatsState();

  @override
  List<Object?> get props => [];
}

class StatsLoading extends StatsState {
  const StatsLoading();
}

class StatsEmpty extends StatsState {
  const StatsEmpty();
}

class StatsLoaded extends StatsState {
  const StatsLoaded(this.stats);
  final DiaryStats stats;

  @override
  List<Object?> get props => [stats];
}

class StatsFailed extends StatsState {
  const StatsFailed(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
