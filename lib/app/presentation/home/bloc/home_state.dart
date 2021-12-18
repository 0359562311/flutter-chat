abstract class HomeState {}

class HomeLoadingUserCompleteState extends HomeState {}

class HomeLoadingState extends HomeState {}

class HomeErrorState extends HomeState {
  final String message;
  HomeErrorState({
    required this.message,
  });
}
