import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ina_17_test/main.dart';

class CalculatorBloc extends Bloc<CalculatorEvent, CalculatorState> {
  CalculatorBloc() : super(CalculatorState.initial()) {
    on<ProcessImage>(_onProcessImage);
    on<ToggleStorage>(_onToggleStorage);
  }

  Stream<CalculatorState> mapEventToState(CalculatorEvent event) async* {
    if (event is ProcessImage) {
      final expression = await _detectExpressionFromImage(event.imagePath);
      final result = _calculateExpression(expression);

      final List<CalculationResult> updatedResults =
          List.from(state.recentResults)
            ..add(CalculationResult(expression, result));

      if (state.useFileStorage) {
        _saveToEncryptedFile(expression, result);
      } else {
        _saveToDatabase(expression, result);
      }

      yield state.copyWith(recentResults: updatedResults);
    } else if (event is ToggleStorage) {
      yield state.copyWith(useFileStorage: event.useFileStorage);
    }
  }

  Future<void> _onProcessImage(
      ProcessImage event, Emitter<CalculatorState> emit) async {
    final expression = await _detectExpressionFromImage(event.imagePath);
    final result = _calculateExpression(expression);
    final List<CalculationResult> updatedResults =
        List.from(state.recentResults)
          ..add(CalculationResult(expression, result));

    if (state.useFileStorage) {
      _saveToEncryptedFile(expression, result);
    } else {
      _saveToDatabase(expression, result);
    }

    emit(state.copyWith(recentResults: updatedResults));
  }

  // Handler untuk ToggleStorage
  void _onToggleStorage(ToggleStorage event, Emitter<CalculatorState> emit) {
    emit(state.copyWith(useFileStorage: event.useFileStorage));
  }

  Future<String> _detectExpressionFromImage(String imagePath) async {
    return "1+1";
  }

  double _calculateExpression(String expression) {
    return 2.0;
  }

  void _saveToEncryptedFile(String expression, double result) {}

  void _saveToDatabase(String expression, double result) {}
}

class CalculationResult {
  final String expression;
  final double result;

  CalculationResult(this.expression, this.result);
}

class CalculatorState {
  final List<CalculationResult> recentResults;
  final bool useFileStorage;

  CalculatorState({
    required this.recentResults,
    required this.useFileStorage,
  });

  factory CalculatorState.initial() {
    return CalculatorState(
      recentResults: [],
      useFileStorage: true,
    );
  }

  CalculatorState copyWith({
    List<CalculationResult>? recentResults,
    bool? useFileStorage,
  }) {
    return CalculatorState(
      recentResults: recentResults ?? this.recentResults,
      useFileStorage: useFileStorage ?? this.useFileStorage,
    );
  }
}
