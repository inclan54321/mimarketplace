// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Mein Marktplatz';

  @override
  String bienvenido(String nombre) {
    return 'Willkommen, $nombre';
  }

  @override
  String get categorias => 'Kategorien';

  @override
  String get productosDestacados => 'Empfohlene Produkte';

  @override
  String get verTodas => 'Alle anzeigen';

  @override
  String get buscarProductos => 'Produkte suchen...';

  @override
  String get noHayResultados => 'Keine Ergebnisse';

  @override
  String get noHayProductosDestacados => 'Keine empfohlenen Produkte';

  @override
  String get noHayProductosConFiltros => 'Keine Produkte mit diesen Filtern';

  @override
  String get quitarFiltros => 'Filter löschen';

  @override
  String get filtrarProductos => 'Produkte filtern';

  @override
  String get canton => '📍 Kanton';

  @override
  String get rangoPrecio => '💰 Preisspanne (₡)';

  @override
  String get limpiar => 'Löschen';

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
  String get noTienesCuenta => 'Kein Konto? Registrieren';

  @override
  String get inicio => 'Start';

  @override
  String get avisos => 'Benachrichtigungen';

  @override
  String get vender => 'Verkaufen';

  @override
  String get mensajes => 'Nachrichten';

  @override
  String get perfil => 'Profil';

  @override
  String get editarPerfil => 'Profil bearbeiten';

  @override
  String get impulsar => 'Bewerben';

  @override
  String get eliminarPublicidad => 'Werbung entfernen';

  @override
  String get cerrarSesion => 'Abmelden';

  @override
  String get privacidadYSeguridad => 'Datenschutz & Sicherheit';

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
  String get bloquear => 'Blockieren';

  @override
  String desbloquearA(String nombre) {
    return '$nombre entsperren';
  }

  @override
  String bloquearA(String nombre) {
    return '$nombre blockieren';
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
    return '$nombre wegen Regelverstoßes melden';
  }

  @override
  String get vendedorBloqueadoCorrectamente =>
      'Verkäufer erfolgreich blockiert. Neustart...';

  @override
  String get vendedorDesbloqueadoCorrectamente =>
      'Verkäufer erfolgreich entsperrt. Neustart...';

  @override
  String get errorAlBloquear => 'Fehler beim Blockieren';

  @override
  String get errorAlDesbloquear => 'Fehler beim Entsperren';

  @override
  String get errorAlBloquearUsuario => 'Fehler beim Blockieren des Benutzers';

  @override
  String get errorAlDesbloquearUsuario =>
      'Fehler beim Entsperren des Benutzers';

  @override
  String get denunciarVendedorTitulo => '⚠️ Verkäufer melden';

  @override
  String get seleccionaMotivoDenuncia => 'Wähle den Grund für die Meldung:';

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
      '✅ Meldung gesendet. Sie wird von der Moderation geprüft.';

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
      'Du hast noch keine Artikel veröffentlicht';

  @override
  String get noTienesProductosFavoritos => 'Du hast keine Favoriten';

  @override
  String get reintentar => 'Erneut versuchen';

  @override
  String get noHayCalificacionesAun => 'Noch keine Bewertungen';

  @override
  String get sinComentario => 'Kein Kommentar';

  @override
  String get usuario => 'Benutzer';

  @override
  String get cerrarSesionExitoso => 'Abgemeldet';

  @override
  String get estiloVisualDelPerfil => '🎨 Visueller Profilstil';

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
  String get desfijarChat => 'Chat lösen';

  @override
  String get quitarDeLaParteSuperior => 'Von oben entfernen';

  @override
  String get mantenerEnLaParteSuperior => 'Oben halten';

  @override
  String get chatFijado => '📌 Chat angeheftet';

  @override
  String get chatDesfijado => '📌 Chat gelöst';

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
      'Tippe im Chat auf die Schaltfläche, um den Kontakt in deiner Agenda zu speichern';

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
  String get subElectronicos => 'Handys, Laptops, Audio';

  @override
  String get subDeportes => 'Fußball, Tennis, Laufen';

  @override
  String get subHogar => 'Möbel, Deko, Küche';

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
  String get subJuguetes => 'Plüsch, Bausteine, Autos';

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
    return 'Fehler beim Löschen: $error';
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
      '❌ Du musst die ganze Anzeige sehen, um zu erneuern';

  @override
  String get renovarPor30Dias => 'Für 30 Tage erneuern';

  @override
  String get ambosConfirmaron => 'Beide bestätigt';

  @override
  String get esperandoAlOtro => 'Warten auf den anderen';

  @override
  String get confirmarEncuentro => 'Treffen bestätigen';

  @override
  String get verificarIdentidad => 'Identität verifizieren';

  @override
  String get verificarIdentidadDelOtro => 'Identität des anderen verifizieren';

  @override
  String get identidadRechazada => 'Identität abgelehnt';

  @override
  String get revisarComparacion => 'Vergleich prüfen';

  @override
  String get ambosConfirmaronExito => '✅ Beide bestätigt. Bis bald!';

  @override
  String get confirmasteAsistencia =>
      '✅ Du hast deine Teilnahme bestätigt. Warten auf den anderen.';

  @override
  String errorGenericoAlerta(String error) {
    return 'Fehler: $error';
  }

  @override
  String get eliminarPublicidadTitulo => 'Werbung entfernen';

  @override
  String get eliminaLosAnuncios => 'Entferne die Werbung';

  @override
  String get descripcionEliminarPublicidad =>
      'Zahle für einen Plan und surfe werbefrei in der ganzen App. Keine Werbung, keine Unterbrechungen.';

  @override
  String get beneficioSinAnuncios => 'Keine Werbung in der ganzen App';

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
  String get sinAnunciosPor30Dias => 'Keine Werbung für 30 Tage';

  @override
  String get sinAnunciosPor180Dias => 'Keine Werbung für 180 Tage';

  @override
  String ahorrasMonto(String monto) {
    return 'Du sparst $monto';
  }

  @override
  String get elegiUnPlan => 'Wähle einen Plan';

  @override
  String pagarMonto(String monto) {
    return '$monto zahlen';
  }

  @override
  String get pagoSeguro => 'Die Zahlung wird sicher verarbeitet';

  @override
  String get confirmarCompra => 'Kauf bestätigen';

  @override
  String confirmarCompraPregunta(String precio, String duracion) {
    return 'Möchtest du $precio für $duracion ohne Werbung zahlen?';
  }

  @override
  String get pagar => 'Zahlen';

  @override
  String get integracionPagoEnDesarrollo =>
      '🚧 Zahlungsintegration in Entwicklung';

  @override
  String get encuentroCaducado => 'Treffen abgelaufen';

  @override
  String get esperandoVerificacionDelOtro =>
      'Warten darauf, dass die andere Person dein Selfie überprüft';

  @override
  String get verificacionCompleta => 'Verifizierung abgeschlossen';

  @override
  String get premiumActivoTitulo => 'Du bist Premium!';

  @override
  String get premiumActivoDescripcion => 'Die Werbung wurde entfernt';

  @override
  String get planUnaSemana => '1 Woche';

  @override
  String get sinAnunciosPor7Dias => '7 Tage ohne Werbung';

  @override
  String get yaTenesAnunciosEliminados => 'Die Werbung wurde bereits entfernt';

  @override
  String get productoNoDisponible => 'Produkt nicht verfügbar';

  @override
  String errorCompra(Object detalle) {
    return 'Fehler: $detalle';
  }

  @override
  String get desconocido => 'Unbekannt';

  @override
  String get usuarioNoLogueado => 'Kein Benutzer ist angemeldet';

  @override
  String get errorVerificarCompra => 'Fehler beim Überprüfen des Kaufs';

  @override
  String get compraExitosaAnunciosEliminados =>
      '✅ Geschafft! Die Werbung wurde entfernt.';

  @override
  String get configurarImpulso => 'Bewerbung konfigurieren';

  @override
  String get impulsarTitulo => 'Bewerben';

  @override
  String get impulsarPublicacion => 'Anzeige bewerben';

  @override
  String get poneTuProductoPrimero => 'Stelle dein Produkt an die erste Stelle';

  @override
  String get impulsarPunto1Titulo => 'Auf den ersten Platz';

  @override
  String get impulsarPunto1Desc =>
      'Dein Produkt erscheint zuerst in der Liste der empfohlenen Produkte auf der Startseite.';

  @override
  String get impulsarPunto2Titulo => 'Mehr Sichtbarkeit';

  @override
  String get impulsarPunto2Desc =>
      'Da es zuerst erscheint, sehen es mehr Leute und du hast bessere Chancen, es schnell zu verkaufen.';

  @override
  String get impulsarPunto3Titulo => 'Begrenzte Dauer';

  @override
  String get impulsarPunto3Desc =>
      'Die Bewerbung dauert, bis ein anderer Verkäufer zahlt, um aufzusteigen. Dann gehst du einen Platz nach unten.';

  @override
  String get seleccionarArticulo => 'Artikel auswählen';

  @override
  String get proximamenteDisponiblePagos =>
      'Demnächst verfügbar. Wir aktivieren die Zahlungen.';

  @override
  String get articuloAImpulsar => 'Zu bewerbender Artikel';

  @override
  String get comoFuncionaImpulso => 'Wie funktioniert es?';

  @override
  String get explicacionImpulso =>
      'Beim Bewerben steigt dein Produkt an die erste Stelle der Startseite. Wenn ein anderer Verkäufer sein Produkt bewirbt, gehst du einen Platz nach unten. Wer zuletzt gezahlt hat, ist immer zuerst.';

  @override
  String get procesando => 'Wird verarbeitet...';

  @override
  String get cargando => 'Wird geladen...';

  @override
  String get impulsarAhora => 'Jetzt bewerben';

  @override
  String get cambiarProducto => 'Produkt ändern';

  @override
  String get noTenesProductosPublicados =>
      'Du hast keine veröffentlichten Produkte';

  @override
  String get elegiUnArticulo => 'Wähle einen Artikel';

  @override
  String get elQueElijasApareceraPrimero =>
      'Der Artikel, den du wählst, erscheint zuerst auf der Startseite';

  @override
  String get primeroElegiUnArticulo => 'Wähle zuerst einen Artikel';

  @override
  String get productoImpulsoNoDisponible =>
      'Bewerbungsprodukt nicht verfügbar. Prüfe deine Verbindung.';

  @override
  String get errorDesconocido => 'Unbekannt';

  @override
  String productoEstaPrimeroEnHome(String nombre) {
    return '✅ \"$nombre\" ist zuerst auf der Startseite';
  }

  @override
  String get pagoNoVerificado =>
      'Die Zahlung konnte nicht überprüft werden. Kontaktiere den Support.';

  @override
  String get compraPendiente => 'Der Kauf ist ausstehend. Versuche es erneut.';

  @override
  String get errorAlImpulsar => 'Fehler beim Bewerben';

  @override
  String escudoActivoPor(String nombre) {
    return '$nombre hat das Sicherheitsschild aktiviert';
  }

  @override
  String get escudoPaso0Titulo => 'Was ist das Sicherheitsschild?';

  @override
  String get escudoPaso0Desc =>
      'Es ist eine Reihe von Schutzmaßnahmen, die aktiviert werden, wenn beide Nutzer eines Geschäfts sie akzeptieren. Ziel ist es, Betrug zu verhindern und sicherzustellen, dass das Treffen sicher ist.\n\nWer sollte es aktivieren?\nBeide Nutzer des Geschäfts müssen das Schild akzeptieren. Wenn einer es aktiviert, erhält der andere eine Benachrichtigung, um es zu akzeptieren oder abzulehnen. Wenn der zweite Nutzer es ablehnt, wird der Chat für beide geschlossen.';

  @override
  String get escudoPaso1Titulo => 'Was passiert, wenn das Schild aktiv ist?';

  @override
  String get escudoPaso1Desc =>
      '3.1. Blockierung von Links und Telefonnummern: Die App erkennt und blockiert automatisch Telefonnummern und externe Links in Nachrichten. Dies verhindert das Teilen von Kontaktdaten außerhalb der Plattform und reduziert das Betrugsrisiko.';

  @override
  String get escudoPaso2Titulo => 'Wie man das Geschäft abschließt';

  @override
  String get escudoPaso2Desc =>
      'Um das Geschäft abzuschließen, schlage zuerst ein Treffen vor: Tippe auf das Schild in der oberen Leiste des Chats und wähle \"Treffen vorschlagen\". Dort wählst du Provinz, Kanton, Bezirk, einen sicheren Ort und das Datum mit Uhrzeit. Sende den Vorschlag und der andere Nutzer erhält ihn als Karte im Chat. Wenn er akzeptiert, ist das Treffen geplant, aber der Chat bleibt offen: ihr könnt weiter reden. Um das Geschäft abzuschließen, tippe erneut auf das Schild und wähle \"Geschäft abschließen\". Ein Bestätigungsdialog öffnet sich. Wenn beide bestätigen, wird der Chat blockiert und die Schutzmaßnahmen aktiviert.';

  @override
  String get escudoPaso3Titulo => 'Teilnahmebestätigung';

  @override
  String get escudoPaso3Desc =>
      'Eine Stunde vor dem Treffen erhalten beide Nutzer eine Benachrichtigung, um ihre Teilnahme zu bestätigen. Wenn einer der beiden nicht innerhalb von 15 Minuten nach der Benachrichtigung bestätigt, kann der andere Nutzer das Treffen bis 15 Minuten vor der vereinbarten Zeit absagen.';

  @override
  String get escudoPaso4Titulo => 'GPS-Verfolgung';

  @override
  String get escudoPaso4Desc =>
      '3.3. GPS-Verfolgung am Tag des Treffens: Am vereinbarten Tag müssen beide Nutzer 15 Minuten vor der Treffenszeit am Ort sein und das GPS aktivieren, um ihren Standort zu überprüfen. Wenn 5 Minuten vor der vereinbarten Zeit der Nutzer das GPS nicht aktiviert und seine Identität nicht überprüft hat, gilt er als zu spät. Wenn 15 Minuten nach der vereinbarten Zeit der Nutzer dies nicht getan hat, gilt er als nicht erschienen. In beiden Fällen wird es registriert und kann gemäß den MiMarketplace-Regeln sanktioniert werden.';

  @override
  String get escudoPaso5Titulo => 'Gesichtsverifizierung';

  @override
  String get escudoPaso5Desc =>
      '3.4. Identitätsprüfung vor dem Chat: Um den Treffens-Chat freizuschalten, müssen beide Nutzer bestätigen, dass sie die sind, die sie vorgeben zu sein. Dies wird 15 Minuten vor der vereinbarten Zeit aktiviert und ist eine zwingende Voraussetzung, um den Chat zu öffnen. Das System fordert jeden auf, sofort ein Foto zu machen. Dann muss der andere Nutzer dieses Foto mit dem Profilfoto vergleichen, um zu bestätigen, dass sie übereinstimmen. Es ist wichtig, aufmerksam zu sein, denn die Verifizierung wird aktiviert, wenn der andere Nutzer sie startet, und du musst die Anweisungen auf dem Bildschirm befolgen. So wird verhindert, dass jemand anderes das Konto benutzt.';

  @override
  String get escudoPaso6Titulo => 'Zusätzliche Überlegungen';

  @override
  String get escudoPaso6Desc =>
      '4.1. Freiwillige Stornierung: Jeder Nutzer kann seine Teilnahme am Treffen stornieren, solange mehr als eine Stunde vor der vereinbarten Zeit verbleibt. Sobald weniger als eine Stunde verbleibt, ist eine Stornierung nicht mehr möglich.\n\nWie stornieren? Gehe in den Artikel-Chat, tippe auf die Schild-Schaltfläche in der oberen Leiste und wähle \"Geschäft stornieren\". Ein Dialog öffnet sich, der das Treffensdatum zeigt und dir mitteilt, ob du noch stornieren kannst oder ob weniger als eine Stunde verbleibt. Wenn möglich, bestätige und das Treffen wird für beide annulliert.\n\nÜberprüfe immer den Benachrichtigungsbereich. Dort kommen Treffens-Erinnerungen, Teilnahmebestätigung, Identitätsprüfung und Statusänderungen an. Du musst sie oft überprüfen, um nichts Wichtiges zu verpassen.';

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
  String get ubicacionDelEncuentro => 'Treffensort';
}
