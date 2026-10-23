/// A class to hold customizable messages for the liveness detection UI.
class LivenessMessages {
  //region ## Face centering messages
  /// Message displayed when the user's face is too far from the camera.
  final String moveFartherAway;

  /// Message displayed when the user's face is too close to the camera.
  final String moveCloser;

  /// Message displayed when the user needs to move their face to the right.
  final String moveRight;

  /// Message displayed when the user needs to move their face to the left.
  final String moveLeft;

  /// Message displayed when the user needs to move their face up.
  final String moveUp;

  /// Message displayed when the user needs to move their face down.
  final String moveDown;

  /// Message displayed when the user's face is perfectly positioned.
  final String perfectHoldStill;

  /// Message displayed when no face is detected.
  final String noFaceDetected;

  /// Message displayed when there is an error checking face position.
  final String errorCheckingFacePosition;
  //endregion

  //region ## Status messages
  /// Message displayed when the session is initializing.
  final String initializing;

  /// Message displayed when the camera is initializing.
  final String initializingCamera;

  /// Error message if camera initialization fails.
  final String errorInitializingCamera;

  /// Initial instruction for positioning the face.
  final String initialInstruction;

  /// Message for when lighting is poor.
  final String poorLighting;

  /// Message displayed during final processing.
  final String processingVerification;

  /// Message displayed when verification is complete.
  final String verificationComplete;

  /// Message for a possible spoofing attempt.
  final String spoofingDetected;

  ///Message displayed when there is a processing error.
  final String errorProcessing;

  /// Message displayed when face quality score is below the required threshold.
  final String lowFaceQuality;

  /// Message shown during the screen-flash anti-spoofing test.
  final String screenFlashInstruction;

  /// Message shown when the screen-flash test detects a spoofing attempt.
  final String screenFlashSpoofingDetected;
  //endregion

  /// Constructs a [LivenessMessages] object.
  const LivenessMessages({
    this.moveFartherAway = 'Alejate un poco',
    this.moveCloser = 'Acercate un poco',
    this.moveRight = 'Movete a la derecha',
    this.moveLeft = 'Movete a la izquierda',
    this.moveUp = 'Subí un poco',
    this.moveDown = 'Bajá un poco',
    this.perfectHoldStill = '¡Perfecto! Quedate quieto',
    this.noFaceDetected = 'No se detecta rostro',
    this.errorCheckingFacePosition = 'Error al verificar la posición del rostro',

    // -------------------------------------------------------------------------

    this.initializing = 'Iniciando...',
    this.initializingCamera = 'Iniciando cámara...',
    this.errorInitializingCamera = 'Error al iniciar la cámara. Reiniciá la app.',
    this.initialInstruction = 'Colocá tu rostro en el óvalo',
    this.poorLighting = 'Movete a un lugar con mejor iluminación',
    this.processingVerification = 'Procesando verificación...',
    this.verificationComplete = '¡Verificación de vida completada!',
    this.spoofingDetected = 'Posible intento de suplantación detectado.',
    this.errorProcessing = 'Ocurrió un error al procesar',
    this.lowFaceQuality = 'Mejorá la calidad de la imagen para continuar',
    this.screenFlashInstruction = 'Quedate quieto, analizando...',
    this.screenFlashSpoofingDetected = 'Verificación fallida. Intentá de nuevo.',
  });
}