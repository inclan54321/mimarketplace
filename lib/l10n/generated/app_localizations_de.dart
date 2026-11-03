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
}
