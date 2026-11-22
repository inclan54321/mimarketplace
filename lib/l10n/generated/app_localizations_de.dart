// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Mein Marketplace';

  @override
  String bienvenido(String nombre) {
    return 'Willkommen, $nombre';
  }

  @override
  String get categorias => 'Kategorien';

  @override
  String get productosDestacados => 'Hervorgehobene Produkte';

  @override
  String get verTodas => 'Alle ansehen';

  @override
  String get buscarProductos => 'Produkte suchen...';

  @override
  String get noHayResultados => 'Keine Ergebnisse';

  @override
  String get noHayProductosDestacados => 'Keine hervorgehobenen Produkte';

  @override
  String get noHayProductosConFiltros => 'Keine Produkte mit diesen Filtern';

  @override
  String get quitarFiltros => 'Filter entfernen';

  @override
  String get filtrarProductos => 'Produkte filtern';

  @override
  String get canton => '📍 Kanton';

  @override
  String get rangoPrecio => '💰 Preisspanne (₡)';

  @override
  String get limpiar => 'Leeren';

  @override
  String get aplicarFiltros => 'Filter anwenden';

  @override
  String get filtrosAplicados => '✅ Filter angewendet';

  @override
  String get sinFiltrosAplicados => 'Keine Filter angewendet';

  @override
  String get todos => 'Alle';

  @override
  String get iniciarSesion => 'Anmelden';

  @override
  String get correoElectronico => 'E-Mail';

  @override
  String get contrasena => 'Passwort';

  @override
  String get continuarConGoogle => 'Mit Google fortfahren';

  @override
  String get noTienesCuenta => 'Noch kein Konto? Registrieren';

  @override
  String get inicio => 'Start';

  @override
  String get avisos => 'Hinweise';

  @override
  String get vender => 'Verkaufen';

  @override
  String get mensajes => 'Nachrichten';

  @override
  String get perfil => 'Profil';

  @override
  String get editarPerfil => 'Profil bearbeiten';

  @override
  String get impulsar => 'Befördern';

  @override
  String get eliminarPublicidad => 'Werbung entfernen';

  @override
  String get cerrarSesion => 'Abmelden';

  @override
  String get privacidadYSeguridad => 'Datenschutz und Sicherheit';

  @override
  String get soporte => 'Support';

  @override
  String get terminosDeServicio => 'Nutzungsbedingungen';

  @override
  String get misArticulos => 'Meine Artikel';

  @override
  String get masVistos => 'Meistgesehen';

  @override
  String get favoritos => 'Favoriten';

  @override
  String get miPerfil => 'Mein Profil';

  @override
  String get verPortafolio => 'Portfolio ansehen';

  @override
  String get verTodosMisProductos =>
      'Alle meine veröffentlichten Produkte ansehen';

  @override
  String get opcionesDelVendedor => 'Verkäuferoptionen';

  @override
  String get desbloquear => 'Entsperren';

  @override
  String get bloquear => 'Sperren';

  @override
  String desbloquearA(String nombre) {
    return '$nombre entsperren';
  }

  @override
  String bloquearA(String nombre) {
    return '$nombre sperren';
  }

  @override
  String get verInformacionDePerfil => 'Profilinformationen ansehen';

  @override
  String verDetallesDe(String nombre) {
    return 'Details von $nombre ansehen';
  }

  @override
  String verTodosLosProductosDe(String nombre) {
    return 'Alle Produkte von $nombre ansehen';
  }

  @override
  String get denunciarVendedor => 'Verkäufer melden';

  @override
  String reportarA(String nombre) {
    return '$nombre wegen Regelverstoß melden';
  }

  @override
  String get vendedorBloqueadoCorrectamente =>
      'Verkäufer erfolgreich gesperrt. Neustart...';

  @override
  String get vendedorDesbloqueadoCorrectamente =>
      'Verkäufer erfolgreich entsperrt. Neustart...';

  @override
  String get errorAlBloquear => 'Fehler beim Sperren';

  @override
  String get errorAlDesbloquear => 'Fehler beim Entsperren';

  @override
  String get errorAlBloquearUsuario => 'Fehler beim Sperren des Benutzers';

  @override
  String get errorAlDesbloquearUsuario =>
      'Fehler beim Entsperren des Benutzers';

  @override
  String get denunciarVendedorTitulo => '⚠️ Verkäufer melden';

  @override
  String get seleccionaMotivoDenuncia => 'Wähle den Grund der Meldung:';

  @override
  String get denunciaRevisadaPorEquipo =>
      'Diese Meldung wird von unserem Moderationsteam geprüft.';

  @override
  String get denunciar => 'Melden';

  @override
  String get debesIniciarSesionParaDenunciar =>
      'Du musst dich anmelden, um zu melden';

  @override
  String get denunciaEnviada =>
      '✅ Meldung gesendet. Wird von der Moderation geprüft.';

  @override
  String errorAlEnviarDenuncia(String error) {
    return 'Fehler beim Senden der Meldung: $error';
  }

  @override
  String get motivoProductoSospechoso => 'Verdächtiges Produkt';

  @override
  String get motivoProductosProhibidos =>
      'Veröffentlichung verbotener Produkte';

  @override
  String get motivoEstafaFraude => 'Betrug oder Schwindel';

  @override
  String get motivoAcosoMaltrato => 'Belästigung oder Missbrauch';

  @override
  String get motivoInformacionFalsa =>
      'Falsche oder irreführende Informationen';

  @override
  String get motivoOtro => 'Anderer Grund';

  @override
  String get vendedor => 'Verkäufer';

  @override
  String get esteVendedor => 'dieser Verkäufer';

  @override
  String get miPortafolio => 'Mein Portfolio';

  @override
  String get debesIniciarSesion => 'Du musst dich anmelden';

  @override
  String get editarProducto => 'Produkt bearbeiten';

  @override
  String get contactarVendedor => 'Verkäufer kontaktieren';

  @override
  String compartirProductoMensaje(String enlace) {
    return '📱 Schau dir dieses Produkt auf MiMarketplace an:\n\n$enlace';
  }

  @override
  String get noHasPublicadoNingunArticulo =>
      'Du hast noch keinen Artikel veröffentlicht';

  @override
  String get noTienesProductosFavoritos => 'Du hast keine Favoritenprodukte';

  @override
  String get reintentar => 'Erneut versuchen';

  @override
  String get noHayCalificacionesAun => 'Noch keine Bewertungen';

  @override
  String get sinComentario => 'Kein Kommentar';

  @override
  String get usuario => 'Benutzer';

  @override
  String get cerrarSesionExitoso => 'Sitzung beendet';

  @override
  String get estiloVisualDelPerfil => '🎨 Visueller Stil des Profils';

  @override
  String get eligeElFondoQueMasTeGuste =>
      'Wähle den Hintergrund, der dir am besten gefällt';

  @override
  String get atardecer => 'Sonnenuntergang';

  @override
  String get galaxia => 'Galaxie';

  @override
  String get oceano => 'Ozean';

  @override
  String get volcan => 'Vulkan';

  @override
  String get cancelar => 'Abbrechen';

  @override
  String get eliminar => 'Löschen';

  @override
  String get confirmar => 'Bestätigen';

  @override
  String get yaSeVendio => 'Schon verkauft?';

  @override
  String get calificacion => 'Bewertung';

  @override
  String get calificaciones => 'Bewertungen';

  @override
  String get queVasAVender => 'Was möchtest du verkaufen?';

  @override
  String get seleccionaCategoria =>
      'Wähle die Kategorie, die deinen Artikel am besten beschreibt';

  @override
  String get buscarCategoria => 'Kategorie suchen...';

  @override
  String get noSeEncontraronCategorias => 'Keine Kategorien gefunden';

  @override
  String get todasLasCategorias => 'Alle Kategorien';

  @override
  String get seleccionar => 'Auswählen';

  @override
  String get chateaConCompradoresVendedores =>
      'Chatte mit Käufern und Verkäufern';

  @override
  String get tabChats => 'CHATS';

  @override
  String get tabAgenda => 'AGENDA';

  @override
  String get tabEncuentros => 'TREFFEN';

  @override
  String get noTienesConversaciones => 'Du hast keine Unterhaltungen';

  @override
  String get encuentroAceptado => 'TREFFEN AKZEPTIERT';

  @override
  String get articuloVendido => 'ARTIKEL VERKAUFT';

  @override
  String get nuevoMensaje => 'NEUE NACHRICHT';

  @override
  String get fijarChat => 'Chat anheften';

  @override
  String get desfijarChat => 'Chat loslösen';

  @override
  String get quitarDeLaParteSuperior => 'Von oben entfernen';

  @override
  String get mantenerEnLaParteSuperior => 'Oben halten';

  @override
  String get chatFijado => '📌 Chat angeheftet';

  @override
  String get chatDesfijado => '📌 Chat losgelöst';

  @override
  String errorAlFijar(String codigo) {
    return 'Fehler beim Anheften: $codigo';
  }

  @override
  String get eliminarChat => 'Chat löschen';

  @override
  String confirmarEliminarChat(String nombre) {
    return 'Möchtest du die Unterhaltung mit $nombre wirklich löschen?';
  }

  @override
  String get chatEliminado => '🗑️ Chat gelöscht';

  @override
  String guardadoConProductos(int cantidad) {
    return '✅ Gespeichert ($cantidad Produkte)';
  }

  @override
  String get eliminado => '🗑️ Gelöscht';

  @override
  String get buscarContactosProductos => 'Kontakte oder Produkte suchen...';

  @override
  String get noHayContactosGuardados => 'Keine gespeicherten Kontakte';

  @override
  String noHayResultadosPara(String busqueda) {
    return 'Keine Ergebnisse für \"$busqueda\"';
  }

  @override
  String get tocaBotonParaGuardarContacto =>
      'Tippe auf die Schaltfläche in einem Chat, um den Kontakt in deiner Agenda zu speichern';

  @override
  String get producto => 'Produkt';

  @override
  String get sinMensajes => 'Keine Nachrichten';

  @override
  String get fechaDesconocida => 'Unbekanntes Datum';

  @override
  String haceDias(int cantidad) {
    return 'vor $cantidad Tagen';
  }

  @override
  String haceHoras(int cantidad) {
    return 'vor $cantidad Stunden';
  }

  @override
  String haceMinutos(int cantidad) {
    return 'vor $cantidad Minuten';
  }

  @override
  String get haceUnosSegundos => 'vor wenigen Sekunden';

  @override
  String get lun => 'Mo';

  @override
  String get mar => 'Di';

  @override
  String get mie => 'Mi';

  @override
  String get jue => 'Do';

  @override
  String get vie => 'Fr';

  @override
  String get sab => 'Sa';

  @override
  String errorGenerico(String error) {
    return 'Fehler: $error';
  }

  @override
  String errorGenericoAlerta(String error) {
    return 'Error: $error';
  }

  @override
  String get errorDesconocido => 'Error desconocido';

  @override
  String get catElectronicos => 'Elektronik';

  @override
  String get catDeportes => 'Sport';

  @override
  String get catHogar => 'Haushalt';

  @override
  String get catMusica => 'Musik';

  @override
  String get catCocina => 'Küche';

  @override
  String get catPeliculas => 'Filme';

  @override
  String get catFotografia => 'Fotografie';

  @override
  String get catVideojuegos => 'Videospiele';

  @override
  String get catJuegosDeMesa => 'Brettspiele';

  @override
  String get catJuguetes => 'Spielzeug';

  @override
  String get catFiguras => 'Figuren';

  @override
  String get catAutomoviles => 'Autos';

  @override
  String get catHerramientas => 'Werkzeuge';

  @override
  String get catRopaYCalzado => 'Kleidung & Schuhe';

  @override
  String get subElectronicos => 'Handys, Laptops, Audio';

  @override
  String get subDeportes => 'Fußball, Tennis, Laufen';

  @override
  String get subHogar => 'Möbel, Dekoration, Küche';

  @override
  String get subMusica => 'Gitarren, Klaviere, Audio';

  @override
  String get subCocina => 'Töpfe, Utensilien, Geschirr';

  @override
  String get subPeliculas => 'Action, Komödie, Drama';

  @override
  String get subFotografia => 'Kameras, Objektive, Zubehör';

  @override
  String get subVideojuegos => 'Konsolen, Spiele, Controller';

  @override
  String get subJuegosDeMesa => 'Karten, Bretter, Strategie';

  @override
  String get subJuguetes => 'Plüschtiere, Bausteine, Autos';

  @override
  String get subFiguras => 'Action, Sammlerstücke, Anime';

  @override
  String get alertasTitulo => 'Benachrichtigungen';

  @override
  String get recargar => 'Neu laden';

  @override
  String get limpiarTodasLasAlertas => 'Alle Benachrichtigungen löschen';

  @override
  String get noTienesAlertas => 'Du hast keine Benachrichtigungen';

  @override
  String get aquiApareceranAvisos =>
      'Hier erscheinen deine Hinweise und Treffen.';

  @override
  String get noHayAlertasParaLimpiar => 'Keine Benachrichtigungen zum Löschen';

  @override
  String get limpiarAlertas => '🗑️ Benachrichtigungen löschen';

  @override
  String get confirmarLimpiarAlertas =>
      'Möchtest du wirklich alle Benachrichtigungen löschen?';

  @override
  String get eliminarTodo => 'Alles löschen';

  @override
  String get todasLasAlertasEliminadas =>
      '✅ Alle Benachrichtigungen wurden gelöscht';

  @override
  String errorAlLimpiarAlertas(String error) {
    return 'Fehler beim Löschen der Benachrichtigungen: $error';
  }

  @override
  String get cargandoAnuncio => '⏳ Anzeige wird geladen... bitte warten';

  @override
  String get noSePudoCargarAnuncio =>
      '❌ Anzeige konnte nicht geladen werden. Versuche es erneut.';

  @override
  String get productoRenovado => '✅ Produkt für 30 weitere Tage erneuert';

  @override
  String errorAlRenovar(String error) {
    return 'Fehler beim Erneuern: $error';
  }

  @override
  String get debesVerAnuncioCompleto =>
      '❌ Du musst die Anzeige vollständig ansehen, um zu erneuern';

  @override
  String get renovarPor30Dias => 'Für 30 Tage erneuern';

  @override
  String get ambosConfirmaron => 'Beide haben bestätigt';

  @override
  String get esperandoAlOtro => 'Warten auf die andere Person';

  @override
  String get confirmarEncuentro => 'Treffen bestätigen';

  @override
  String get verificarIdentidad => 'Identität überprüfen';

  @override
  String get verificarIdentidadDelOtro =>
      'Identität der anderen Person überprüfen';

  @override
  String get identidadRechazada => 'Identität abgelehnt';

  @override
  String get revisarComparacion => 'Vergleich prüfen';

  @override
  String get ambosConfirmaronExito => '✅ Beide haben bestätigt. Bis bald!';

  @override
  String get confirmasteAsistencia =>
      '✅ Du hast deine Teilnahme bestätigt. Warten auf die andere Person.';

  @override
  String get eliminarPublicidadTitulo => 'Werbung entfernen';

  @override
  String get eliminaLosAnuncios => 'Werbung entfernen';

  @override
  String get descripcionEliminarPublicidad =>
      'Zahle einen Plan und navigiere werbefrei durch die gesamte App. Keine Werbung, keine Unterbrechungen.';

  @override
  String get beneficioSinAnuncios => 'Keine Werbung in der gesamten App';

  @override
  String get beneficioNavegacionRapida => 'Schnellere Navigation';

  @override
  String get beneficioSinInterrupciones => 'Unterbrechungsfreies Erlebnis';

  @override
  String get elegiTuPlan => 'Wähle deinen Plan';

  @override
  String get plan1Mes => '1 Monat';

  @override
  String get plan6Meses => '6 Monate';

  @override
  String get sinAnunciosPor30Dias => '30 Tage werbefrei';

  @override
  String get sinAnunciosPor180Dias => '180 Tage werbefrei';

  @override
  String ahorrasMonto(String monto) {
    return 'Du sparst $monto';
  }

  @override
  String get elegiUnPlan => 'Wähle einen Plan';

  @override
  String pagarMonto(String monto) {
    return '$monto bezahlen';
  }

  @override
  String get pagoSeguro => 'Die Zahlung wird sicher verarbeitet';

  @override
  String get confirmarCompra => 'Kauf bestätigen';

  @override
  String confirmarCompraPregunta(String precio, String duracion) {
    return 'Möchtest du $precio für $duracion werbefrei bezahlen?';
  }

  @override
  String get pagar => 'Bezahlen';

  @override
  String get integracionPagoEnDesarrollo =>
      '🚧 Zahlungsintegration in Entwicklung';

  @override
  String get encuentroCaducado => 'Treffen abgelaufen';

  @override
  String get esperandoVerificacionDelOtro =>
      'Warten, bis die andere Person dein Selfie überprüft';

  @override
  String get verificacionCompleta => 'Überprüfung abgeschlossen';

  @override
  String get premiumActivoTitulo => 'Du bist jetzt Premium!';

  @override
  String get premiumActivoDescripcion => 'Die Werbung wurde entfernt';

  @override
  String get planUnaSemana => '1 Woche';

  @override
  String get sinAnunciosPor7Dias => '7 Tage werbefrei';

  @override
  String get yaTenesAnunciosEliminados =>
      'Du hast die Werbung bereits entfernt';

  @override
  String get productoNoDisponible => 'Produkt nicht verfügbar';

  @override
  String errorCompra(String detalle) {
    return 'Fehler: $detalle';
  }

  @override
  String get desconocido => 'Unbekannt';

  @override
  String get usuarioNoLogueado => 'Kein Benutzer angemeldet';

  @override
  String get errorVerificarCompra => 'Fehler beim Überprüfen des Kaufs';

  @override
  String get compraExitosaAnunciosEliminados =>
      '✅ Fertig! Die Werbung wurde entfernt.';

  @override
  String get configurarImpulso => 'Beförderung konfigurieren';

  @override
  String get impulsarTitulo => 'Befördern';

  @override
  String get impulsarPublicacion => 'Veröffentlichung befördern';

  @override
  String get poneTuProductoPrimero => 'Stelle dein Produkt an die erste Stelle';

  @override
  String get impulsarPunto1Titulo => 'Auf den ersten Platz';

  @override
  String get impulsarPunto1Desc =>
      'Dein Produkt erscheint zuerst in der Liste der hervorgehobenen Produkte auf der Startseite.';

  @override
  String get impulsarPunto2Titulo => 'Mehr Sichtbarkeit';

  @override
  String get impulsarPunto2Desc =>
      'An erster Stelle sehen es mehr Leute und du hast bessere Chancen, es schnell zu verkaufen.';

  @override
  String get impulsarPunto3Titulo => 'Begrenzte Dauer';

  @override
  String get impulsarPunto3Desc =>
      'Die Beförderung dauert, bis ein anderer Verkäufer für das Hochstufen zahlt. Dann rückst du einen Platz nach unten.';

  @override
  String get seleccionarArticulo => 'Artikel auswählen';

  @override
  String get proximamenteDisponiblePagos =>
      'Demnächst verfügbar. Wir aktivieren gerade die Zahlungen.';

  @override
  String get articuloAImpulsar => 'Zu befördernder Artikel';

  @override
  String get comoFuncionaImpulso => 'Wie funktioniert es?';

  @override
  String get explicacionImpulso =>
      'Beim Befördern rückt dein Produkt auf den ersten Platz der Startseite. Wenn ein anderer Verkäufer sein Produkt befördert, rückst du einen Platz nach unten. Wer zuletzt gezahlt hat, ist immer zuerst.';

  @override
  String get procesando => 'Wird verarbeitet...';

  @override
  String get cargando => 'Wird geladen...';

  @override
  String get impulsarAhora => 'Jetzt befördern';

  @override
  String get cambiarProducto => 'Produkt ändern';

  @override
  String get noTenesProductosPublicados =>
      'Du hast keine veröffentlichten Produkte';

  @override
  String get elegiUnArticulo => 'Wähle einen Artikel';

  @override
  String get elQueElijasApareceraPrimero =>
      'Der ausgewählte Artikel erscheint zuerst auf der Startseite';

  @override
  String get primeroElegiUnArticulo => 'Wähle zuerst einen Artikel';

  @override
  String get productoImpulsoNoDisponible =>
      'Beförderungsprodukt nicht verfügbar. Überprüfe deine Verbindung.';

  @override
  String productoEstaPrimeroEnHome(String nombre) {
    return '✅ \"$nombre\" ist zuerst auf der Startseite';
  }

  @override
  String get pagoNoVerificado =>
      'Die Zahlung konnte nicht überprüft werden. Kontaktiere den Support.';

  @override
  String get compraPendiente => 'Der Kauf steht aus. Versuche es erneut.';

  @override
  String get errorAlImpulsar => 'Fehler beim Befördern';

  @override
  String escudoActivoPor(String nombre) {
    return '$nombre hat den Sicherheitsschild aktiviert';
  }

  @override
  String get escudoPaso0Titulo => 'Was ist der Sicherheitsschild?';

  @override
  String get escudoPaso0Desc =>
      'Er ist eine Reihe von Schutzmaßnahmen, die aktiviert werden, wenn beide Nutzer eines Geschäfts ihn akzeptieren. Sein Ziel ist es, Betrug zu verhindern und sicherzustellen, dass das Treffen sicher ist.\n\nWer sollte ihn aktivieren?\nBeide Nutzer des Geschäfts müssen den Schild akzeptieren. Wenn einer ihn aktiviert, erhält der andere eine Benachrichtigung, um ihn zu akzeptieren oder abzulehnen. Wenn der zweite Nutzer ihn ablehnt, wird der Chat für beide geschlossen.';

  @override
  String get escudoPaso1Titulo => 'Was passiert, wenn der Schild aktiv ist?';

  @override
  String get escudoPaso1Desc =>
      '3.1. Sperrung von Links und Telefonnummern: Die App erkennt und blockiert automatisch Telefonnummern und externe Links in Nachrichten. Dies verhindert das Teilen von Kontaktdaten außerhalb der Plattform und reduziert das Betrugsrisiko.';

  @override
  String get escudoPaso2Titulo => 'Wie man das Geschäft abschließt';

  @override
  String get escudoPaso2Desc =>
      'Um das Geschäft abzuschließen, schlage zuerst ein Treffen vor: Tippe auf den Schild in der oberen Leiste des Chats und wähle \"Treffen vorschlagen\". Dort wählst du Provinz, Kanton, Bezirk, einen sicheren Ort und Datum mit Uhrzeit. Du sendest den Vorschlag und der andere Nutzer erhält ihn als Karte im Chat. Wenn er ihn akzeptiert, ist das Treffen geplant, aber der Chat bleibt offen: Ihr könnt weiter reden. Um das Geschäft abzuschließen, tippe erneut auf den Schild und wähle \"Geschäft abschließen\". Es öffnet sich ein Dialog zur Bestätigung. Wenn beide bestätigen, wird der Chat gesperrt und die Schutzmaßnahmen werden aktiviert.';

  @override
  String get escudoPaso3Titulo => 'Teilnahmebestätigung';

  @override
  String get escudoPaso3Desc =>
      'Eine Stunde vor dem Treffen erhalten beide Nutzer eine Benachrichtigung, um ihre Teilnahme zu bestätigen. Wenn einer der beiden nicht innerhalb von 15 Minuten nach der Benachrichtigung bestätigt, kann der andere Nutzer das Treffen bis 15 Minuten vor der vereinbarten Zeit absagen.';

  @override
  String get escudoPaso4Titulo => 'GPS-Verfolgung';

  @override
  String get escudoPaso4Desc =>
      '3.3. GPS-Verfolgung am Tag des Treffens: Am vereinbarten Tag müssen beide Nutzer 15 Minuten vor der Treffenszeit am Ort sein und das GPS aktivieren, um ihren Standort zu überprüfen. Wenn 5 Minuten vor der vereinbarten Zeit der Nutzer das GPS nicht aktiviert und seine Identität nicht überprüft hat, gilt er als zu spät gekommen. Wenn der Nutzer es 15 Minuten nach der vereinbarten Zeit nicht getan hat, gilt er als nicht erschienen. In beiden Fällen wird es registriert und kann gemäß den Regeln von MiMarketplace sanktioniert werden.';

  @override
  String get escudoPaso5Titulo => 'Gesichtserkennung';

  @override
  String get escudoPaso5Desc =>
      '3.4. Identitätsüberprüfung vor dem Chat: Um den Chat des Treffens freizuschalten, müssen beide Nutzer bestätigen, dass sie die sind, die sie vorgeben zu sein. Dies wird 15 Minuten vor der vereinbarten Zeit aktiviert und ist eine Pflichtvoraussetzung, um den Chat öffnen zu können. Das System fordert jeden auf, ein Foto in diesem Moment zu machen. Dann muss der andere Nutzer dieses Foto mit dem Profilfoto vergleichen, um zu bestätigen, dass sie übereinstimmen. Es ist wichtig, aufmerksam zu sein, denn die Überprüfung wird aktiviert, wenn der andere Nutzer sie startet, und man muss den Anweisungen auf dem Bildschirm folgen. So wird verhindert, dass jemand anderes das Konto benutzt.';

  @override
  String get escudoPaso6Titulo => 'Zusätzliche Überlegungen';

  @override
  String get escudoPaso6Desc =>
      '4.1. Freiwillige Stornierung: Jeder Nutzer kann seine Teilnahme am Treffen absagen, solange mehr als eine Stunde bis zur vereinbarten Zeit verbleibt. Sobald weniger als eine Stunde verbleibt, ist die Stornierung nicht mehr verfügbar.\n\nWie stornieren? Gehe in den Chat des Artikels, tippe auf die Schild-Schaltfläche in der oberen Leiste und wähle \"Geschäft stornieren\". Es öffnet sich ein Dialog, der dir das Datum des Treffens zeigt und anzeigt, ob du noch stornieren kannst oder ob weniger als eine Stunde verbleibt. Wenn es möglich ist, bestätigst du und das Treffen wird für beide annulliert.\n\nÜberprüfe immer den Bereich Benachrichtigungen. Dort kommen die Erinnerungen an das Treffen, die Teilnahmebestätigung, die Identitätsüberprüfung und alle Statusänderungen an. Du musst sie regelmäßig prüfen, um nichts Wichtiges zu verpassen.';

  @override
  String get noAceptar => 'Nicht akzeptieren';

  @override
  String get aceptar => 'Akzeptieren';

  @override
  String get cerrar => 'Schließen';

  @override
  String get siguiente => 'Weiter';

  @override
  String get iniciar => 'Starten';

  @override
  String get verVideo => 'Video ansehen';

  @override
  String errorGenericoImpulsar(String error) {
    return 'Fehler: $error';
  }

  @override
  String get ubicacionDelEncuentro => 'Ort des Treffens';

  @override
  String get verificarCuenta => 'Konto verifizieren';

  @override
  String get verificaTuCuenta => 'Verifiziere dein Konto';

  @override
  String get obteneLaInsigniaDeVerificado =>
      'Erhalte das Verifiziert-Abzeichen in deinem Profil';

  @override
  String get paso1EnviaSinpe => 'Schritt 1: Sende das SINPE Móvil';

  @override
  String realizaSinpeDeMontoANumero(String monto) {
    return 'Führe ein SINPE Móvil von $monto an die Nummer durch:';
  }

  @override
  String get paso2IngresaTuNumero => 'Schritt 2: Gib deine Nummer ein';

  @override
  String get ingresaNumeroDesdeElQueEnviaste =>
      'Gib die Telefonnummer ein, von der du das SINPE gesendet hast:';

  @override
  String get ejemploTelefono => 'Z.B.: 88888888';

  @override
  String get confirmarPago => 'Zahlung bestätigen';

  @override
  String get enviando => 'Wird gesendet...';

  @override
  String get porFavorIngresaTuTelefono => 'Bitte gib deine Telefonnummer ein';

  @override
  String get solicitudEnviada => 'Anfrage gesendet!';

  @override
  String get estamosVerificandoTuPago =>
      'Wir überprüfen deine Zahlung. In Kürze erhältst du das Verifiziert-Abzeichen in deinem Profil.';

  @override
  String get porFavorEscribeUnMensaje => 'Bitte schreibe eine Nachricht';

  @override
  String get porFavorEscribeUnAsunto => 'Bitte schreibe einen Betreff';

  @override
  String get mensajeEnviadoExito =>
      '✅ Nachricht gesendet. Wir melden uns bald.';

  @override
  String get necesitasAyuda => 'Brauchst du Hilfe?';

  @override
  String get cuentanosTuProblema =>
      'Erzähl uns dein Problem und wir helfen dir, es zu lösen.';

  @override
  String get tipoDeConsulta => 'Art der Anfrage';

  @override
  String get asunto => 'Betreff';

  @override
  String get ejemploProblemaCuenta => 'Z.B.: Problem mit meinem Konto';

  @override
  String get mensaje => 'Nachricht';

  @override
  String get describeTuProblema =>
      'Beschreibe dein Problem so detailliert wie möglich...';

  @override
  String get enviarMensaje => 'Nachricht senden';

  @override
  String get tiempoRespuestaEstimado => 'Geschätzte Antwortzeit: 24-48 Stunden';

  @override
  String get mensajeEnviado => 'Nachricht gesendet!';

  @override
  String get hemosRecibidoTuConsulta =>
      'Wir haben deine Anfrage erhalten. Unser Support-Team antwortet innerhalb der nächsten 24-48 Stunden.';

  @override
  String get enviarOtroMensaje => 'Weitere Nachricht senden';

  @override
  String get volver => 'Zurück';

  @override
  String get categoria => 'Kategorie';

  @override
  String get direccion => 'Adresse';

  @override
  String get nombreDelProducto => 'Produktname';

  @override
  String get ejemploNombreProducto => 'Z.B. iPhone 13, Laptop, usw.';

  @override
  String get ingresaNombreProducto => 'Gib den Produktnamen ein';

  @override
  String get nombreMinimoCaracteres =>
      'Der Name muss mindestens 3 Zeichen haben';

  @override
  String get precio => 'Preis (₡)';

  @override
  String get ingresePrecioProducto => 'Gib den Produktpreis ein';

  @override
  String get ingresaPrecio => 'Gib den Preis ein';

  @override
  String get ingresaPrecioValido => 'Gib einen gültigen Preis ein';

  @override
  String get precioMayorCero => 'Der Preis muss größer als 0 sein';

  @override
  String get descripcion => 'Beschreibung';

  @override
  String get escribeDescripcionDetallada =>
      'Schreibe eine detaillierte Beschreibung des Produkts...';

  @override
  String get ingresaDescripcion => 'Gib eine Beschreibung ein';

  @override
  String get publicarProducto => 'Produkt veröffentlichen';

  @override
  String get compartaProductoComunidad =>
      'Teile dein Produkt mit der Community';

  @override
  String get anuncioCompletado =>
      '✅ Anzeige abgeschlossen. Produkt wird veröffentlicht...';

  @override
  String get debesVerAnuncioParaPublicar =>
      '❌ Du musst die Anzeige vollständig ansehen, um zu veröffentlichen';

  @override
  String get productoEnviadoRevision =>
      '📝 Produkt zur Überprüfung gesendet. Du wirst bei Genehmigung benachrichtigt.';

  @override
  String errorAlPublicar(String error) {
    return 'Fehler beim Veröffentlichen: $error';
  }

  @override
  String get paraPublicarNecesitasVerAnuncio =>
      'Um dein Produkt zu veröffentlichen, musst du eine kurze Anzeige ansehen.';

  @override
  String get verAnuncio => 'Anzeige ansehen';

  @override
  String get agregarImagenes => 'Bilder hinzufügen';

  @override
  String get imagenDestacada => 'Hauptbild';

  @override
  String get estaImagenApareceraPortada =>
      'Dieses Bild erscheint auf dem Produktcover und im Bereich der hervorgehobenen Produkte.';

  @override
  String get soloImagenesCalidadEstudio =>
      'Es werden nur Bilder in Studioqualität akzeptiert (gute Beleuchtung, scharfer Fokus, sauberer Hintergrund).';

  @override
  String get tocaParaSeleccionarImagen => 'Tippe, um ein Bild auszuwählen';

  @override
  String get formatosImagenPermitidos => 'JPG, PNG oder WEBP · Max. 10 MB';

  @override
  String get enRevisionPuntos => '🔍 In Prüfung...';

  @override
  String get enviadoARevision => '🔄 Zur Prüfung gesendet';

  @override
  String get enviarARevision => '🛡️ Zur Prüfung senden';

  @override
  String get imagenRevisadaIA =>
      'Das Bild wird von einer KI geprüft. Du wirst bei Genehmigung benachrichtigt.';

  @override
  String get imagenesRealesProducto => 'Echte Produktbilder';

  @override
  String get subeHasta4Fotos =>
      'Lade bis zu 4 echte Produktfotos hoch (erforderlich)';

  @override
  String get agregar => 'Hinzufügen';

  @override
  String get maximo4ImagenesReales =>
      '⚠️ Du kannst nur bis zu 4 echte Bilder hochladen';

  @override
  String get escribeDescripcionMejorarImagen =>
      'Schreibe eine Beschreibung, um das Bild zu verbessern';

  @override
  String get primeroSeleccionaImagen => 'Wähle zuerst ein Bild aus';

  @override
  String get imagenMejoradaCorrectamente => '✅ Bild erfolgreich verbessert';

  @override
  String get errorGenerarImagen => 'Fehler beim Generieren des Bildes';

  @override
  String get imagenEnviadaRevision =>
      '🔄 Bild zur Prüfung gesendet. Du wirst bei Genehmigung benachrichtigt.';

  @override
  String errorEnviarImagen(String codigo) {
    return 'Fehler beim Senden des Bildes: $codigo';
  }

  @override
  String get revisionDeImagen => '🛡️ Bildprüfung';

  @override
  String get tuImagenSeraEnviadaModeracion =>
      'Dein Bild wird zur Prüfung an unser Moderationsteam gesendet. Um fortzufahren, musst du eine kurze Anzeige ansehen.';

  @override
  String get revisionPuedeTomar24Horas =>
      'Die Prüfung kann bis zu 24 Stunden dauern.';

  @override
  String get verAnuncioConEmoji => 'Anzeige ansehen 🎬';

  @override
  String get anuncioCompletadoEnviandoImagen =>
      '✅ Anzeige abgeschlossen. Bild wird zur Prüfung gesendet...';

  @override
  String get debesVerAnuncioParaEnviarImagen =>
      '❌ Du musst die Anzeige vollständig ansehen, um das Bild zu senden';

  @override
  String get seleccionaAlMenos1Imagen => 'Wähle mindestens 1 echtes Bild aus';

  @override
  String get siguienteConFlecha => 'Weiter →';

  @override
  String get recoleccionDeDatos => 'Datenerfassung';

  @override
  String get tuPrivacidadImportante =>
      'Deine Privatsphäre ist uns wichtig. Du kannst wählen, ob deine Surf-Daten und Präferenzen erfasst werden dürfen, um personalisierte Produktvorschläge zu erhalten.';

  @override
  String get aceptoRecoleccionDatos =>
      'Ich stimme zu, dass meine Surf-Daten und Präferenzen erfasst werden, um personalisierte Produktvorschläge zu erhalten.';

  @override
  String get guardarPreferencias => 'Einstellungen speichern';

  @override
  String get preferenciasGuardadas => '✅ Einstellungen gespeichert';

  @override
  String get errorAlGuardar => 'Fehler beim Speichern';

  @override
  String get historialDePagos => 'Zahlungsverlauf';

  @override
  String get consultaTodosLosPagos =>
      'Überprüfe alle Zahlungen, die du in der App vorgenommen hast: Anzeigen-Boosts, Verlängerungen, Werbeentfernung und andere Dienste.';

  @override
  String get verHistorialDePagos => 'Zahlungsverlauf ansehen';

  @override
  String get todosTusPagosTransacciones =>
      'Alle deine Zahlungen und Transaktionen';

  @override
  String get estadoDeCuenta => 'Kontostatus';

  @override
  String get revisaTusAdvertencias =>
      'Überprüfe deine Verwarnungen und aktiven Sperren auf der Plattform.';

  @override
  String get advertencias => 'Verwarnungen';

  @override
  String get suspensionesTemporales => 'Vorübergehende Sperren';

  @override
  String get asistenciaAEncuentros => 'Treffen-Teilnahme';

  @override
  String get llegadasTardias => 'Verspätungen';

  @override
  String get noVerificaste5Min =>
      'Du hast nicht innerhalb von 5 Minuten verifiziert. 3 = 1 Verwarnung';

  @override
  String get ausencias => 'Abwesenheiten';

  @override
  String get noLlegasteEncuentro =>
      'Du bist nicht zum Treffen erschienen. 1 = 1 Verwarnung';

  @override
  String minutosTardeAcumulados(int cantidad) {
    return '⏱️ Angesammelte Verspätungsminuten: $cantidad';
  }

  @override
  String get informacion => 'Information';

  @override
  String get comoFunciona => 'Wie funktioniert es?';

  @override
  String get comoFuncionaEstadoCuenta =>
      'Dein Konto sammelt Verwarnungen und vorübergehende Sperren wegen Verstößen gegen die Community-Regeln.\n\nTreffen-Teilnahme:\n• 3 Verspätungen (0/3) = 1 Verwarnung.\n• 1 Abwesenheit = 1 Verwarnung.\n\nEskalation:\n• 3 Verwarnungen = 1 vorübergehende Sperre (7 Tage).\n• 3 Sperren = dauerhafte Sperrung.\n\nErholung:\n• Jeden Monat werden 2 Verspätungen abgezogen.\n• Alle 3 Monate wird 1 Verwarnung abgezogen.';

  @override
  String get advertenciasInfo =>
      'Verwarnungen (max. 3): entstehen durch leichte Meldungen wie unangemessene Sprache, irreführende Anzeigen oder geringfügige Regelverstöße. Sie blockieren dein Konto nicht.';

  @override
  String get suspensionesInfo =>
      'Vorübergehende Sperren (max. 3): werden bei schwereren Vergehen wie Betrug, Belästigung, Identitätsdiebstahl oder wiederholten Verwarnungen angewendet. Jede Sperre blockiert dein Konto für einen Zeitraum.';

  @override
  String get baneoInfo =>
      'Wenn du 3 Sperren erreichst, wird dein Konto dauerhaft gesperrt und die E-Mail kann nicht erneut registriert werden.';

  @override
  String get entendido => 'Verstanden';

  @override
  String get guardar => 'Speichern';

  @override
  String get guardarCambios => 'Änderungen speichern';

  @override
  String get nombreCompleto => 'Vollständiger Name';

  @override
  String get telefono => 'Telefon';

  @override
  String get usuarioNoAutenticado => 'Benutzer nicht authentifiziert';

  @override
  String get errorAlCargarDatos => 'Fehler beim Laden der Daten';

  @override
  String get nombreNoPuedeEstarVacio => 'Der Name darf nicht leer sein';

  @override
  String get perfilActualizadoCorrectamente =>
      '✅ Profil erfolgreich aktualisiert';

  @override
  String get errorAlGuardarEnServidor => 'Fehler beim Speichern auf dem Server';

  @override
  String get volverAlPerfil => 'Zurück zum Profil';
}
