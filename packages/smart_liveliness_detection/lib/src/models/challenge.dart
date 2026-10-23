import 'package:smart_liveliness_detection/src/utils/enums.dart';

/// Represents a liveness detection challenge that the user must complete
class Challenge {
  /// The type of challenge
  final ChallengeType type;

  /// Whether the challenge has been completed
  bool isCompleted;

  /// Custom instruction text (overrides default)
  final String? customInstruction;

  /// Map of default challenge instructions
  static final Map<ChallengeType, String> _defaultInstructions = {
    ChallengeType.blink: 'Parpadeá lentamente',
    ChallengeType.turnLeft: 'Girá tu cabeza a la izquierda',
    ChallengeType.turnRight: 'Girá tu cabeza a la derecha',
    ChallengeType.smile: 'Mostrame tu mejor sonrisa',
    ChallengeType.tiltUp: 'Incliná tu cabeza hacia arriba',
    ChallengeType.tiltDown: 'Incliná tu cabeza hacia abajo',
    ChallengeType.zoom: 'Acercá tu rostro lentamente',
    ChallengeType.normal: 'Centrá tu rostro en el óvalo',
    ChallengeType.nod: 'Asentí con la cabeza',
  };

  Challenge(
    this.type, {
    this.isCompleted = false,
    this.customInstruction,
  });

  /// Get the instruction text for this challenge
  String get instruction => customInstruction ?? _defaultInstructions[type]!;

  /// Get the default instruction for a challenge type
  static String getDefaultInstruction(ChallengeType type) {
    return _defaultInstructions[type]!;
  }

  /// Create a copy of this challenge with some values replaced
  Challenge copyWith({
    ChallengeType? type,
    bool? isCompleted,
    String? customInstruction,
  }) {
    return Challenge(
      type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
      customInstruction: customInstruction ?? this.customInstruction,
    );
  }
}
