import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'Mi Marketplace'**
  String get appTitle;

  /// No description provided for @bienvenido.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido, {nombre}'**
  String bienvenido(String nombre);

  /// No description provided for @categorias.
  ///
  /// In es, this message translates to:
  /// **'Categorías'**
  String get categorias;

  /// No description provided for @productosDestacados.
  ///
  /// In es, this message translates to:
  /// **'Productos Destacados'**
  String get productosDestacados;

  /// No description provided for @verTodas.
  ///
  /// In es, this message translates to:
  /// **'Ver todas'**
  String get verTodas;

  /// No description provided for @buscarProductos.
  ///
  /// In es, this message translates to:
  /// **'Buscar productos...'**
  String get buscarProductos;

  /// No description provided for @noHayResultados.
  ///
  /// In es, this message translates to:
  /// **'No hay resultados'**
  String get noHayResultados;

  /// No description provided for @noHayProductosDestacados.
  ///
  /// In es, this message translates to:
  /// **'No hay productos destacados'**
  String get noHayProductosDestacados;

  /// No description provided for @noHayProductosConFiltros.
  ///
  /// In es, this message translates to:
  /// **'No hay productos con esos filtros'**
  String get noHayProductosConFiltros;

  /// No description provided for @quitarFiltros.
  ///
  /// In es, this message translates to:
  /// **'Quitar filtros'**
  String get quitarFiltros;

  /// No description provided for @filtrarProductos.
  ///
  /// In es, this message translates to:
  /// **'Filtrar productos'**
  String get filtrarProductos;

  /// No description provided for @canton.
  ///
  /// In es, this message translates to:
  /// **'📍 Cantón'**
  String get canton;

  /// No description provided for @rangoPrecio.
  ///
  /// In es, this message translates to:
  /// **'💰 Rango de precio (₡)'**
  String get rangoPrecio;

  /// No description provided for @limpiar.
  ///
  /// In es, this message translates to:
  /// **'Limpiar'**
  String get limpiar;

  /// No description provided for @aplicarFiltros.
  ///
  /// In es, this message translates to:
  /// **'Aplicar filtros'**
  String get aplicarFiltros;

  /// No description provided for @filtrosAplicados.
  ///
  /// In es, this message translates to:
  /// **'✅ Filtros aplicados'**
  String get filtrosAplicados;

  /// No description provided for @sinFiltrosAplicados.
  ///
  /// In es, this message translates to:
  /// **'Sin filtros aplicados'**
  String get sinFiltrosAplicados;

  /// No description provided for @todos.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get todos;

  /// No description provided for @iniciarSesion.
  ///
  /// In es, this message translates to:
  /// **'Iniciar Sesión'**
  String get iniciarSesion;

  /// No description provided for @correoElectronico.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get correoElectronico;

  /// No description provided for @contrasena.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get contrasena;

  /// No description provided for @continuarConGoogle.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get continuarConGoogle;

  /// No description provided for @noTienesCuenta.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta? Regístrate'**
  String get noTienesCuenta;

  /// No description provided for @inicio.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get inicio;

  /// No description provided for @avisos.
  ///
  /// In es, this message translates to:
  /// **'Avisos'**
  String get avisos;

  /// No description provided for @vender.
  ///
  /// In es, this message translates to:
  /// **'Vender'**
  String get vender;

  /// No description provided for @mensajes.
  ///
  /// In es, this message translates to:
  /// **'Mensajes'**
  String get mensajes;

  /// No description provided for @perfil.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get perfil;

  /// No description provided for @editarPerfil.
  ///
  /// In es, this message translates to:
  /// **'Editar Perfil'**
  String get editarPerfil;

  /// No description provided for @impulsar.
  ///
  /// In es, this message translates to:
  /// **'Impulsar'**
  String get impulsar;

  /// No description provided for @eliminarPublicidad.
  ///
  /// In es, this message translates to:
  /// **'Eliminar publicidad'**
  String get eliminarPublicidad;

  /// No description provided for @cerrarSesion.
  ///
  /// In es, this message translates to:
  /// **'Cerrar Sesión'**
  String get cerrarSesion;

  /// No description provided for @privacidadYSeguridad.
  ///
  /// In es, this message translates to:
  /// **'Privacidad y Seguridad'**
  String get privacidadYSeguridad;

  /// No description provided for @soporte.
  ///
  /// In es, this message translates to:
  /// **'Soporte'**
  String get soporte;

  /// No description provided for @terminosDeServicio.
  ///
  /// In es, this message translates to:
  /// **'Términos de Servicio'**
  String get terminosDeServicio;

  /// No description provided for @misArticulos.
  ///
  /// In es, this message translates to:
  /// **'Mis artículos'**
  String get misArticulos;

  /// No description provided for @masVistos.
  ///
  /// In es, this message translates to:
  /// **'Más vistos'**
  String get masVistos;

  /// No description provided for @favoritos.
  ///
  /// In es, this message translates to:
  /// **'Favoritos'**
  String get favoritos;

  /// No description provided for @noHasPublicadoNingunArticulo.
  ///
  /// In es, this message translates to:
  /// **'No has publicado ningún artículo'**
  String get noHasPublicadoNingunArticulo;

  /// No description provided for @noTienesProductosFavoritos.
  ///
  /// In es, this message translates to:
  /// **'No tienes productos favoritos'**
  String get noTienesProductosFavoritos;

  /// No description provided for @reintentar.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get reintentar;

  /// No description provided for @noHayCalificacionesAun.
  ///
  /// In es, this message translates to:
  /// **'No hay calificaciones aún'**
  String get noHayCalificacionesAun;

  /// No description provided for @sinComentario.
  ///
  /// In es, this message translates to:
  /// **'Sin comentario'**
  String get sinComentario;

  /// No description provided for @usuario.
  ///
  /// In es, this message translates to:
  /// **'Usuario'**
  String get usuario;

  /// No description provided for @cerrarSesionExitoso.
  ///
  /// In es, this message translates to:
  /// **'Sesión cerrada'**
  String get cerrarSesionExitoso;

  /// No description provided for @estiloVisualDelPerfil.
  ///
  /// In es, this message translates to:
  /// **'🎨 Estilo visual del perfil'**
  String get estiloVisualDelPerfil;

  /// No description provided for @eligeElFondoQueMasTeGuste.
  ///
  /// In es, this message translates to:
  /// **'Elige el fondo que más te guste'**
  String get eligeElFondoQueMasTeGuste;

  /// No description provided for @atardecer.
  ///
  /// In es, this message translates to:
  /// **'Atardecer'**
  String get atardecer;

  /// No description provided for @galaxia.
  ///
  /// In es, this message translates to:
  /// **'Galaxia'**
  String get galaxia;

  /// No description provided for @oceano.
  ///
  /// In es, this message translates to:
  /// **'Océano'**
  String get oceano;

  /// No description provided for @volcan.
  ///
  /// In es, this message translates to:
  /// **'Volcán'**
  String get volcan;

  /// No description provided for @cancelar.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancelar;

  /// No description provided for @eliminar.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get eliminar;

  /// No description provided for @confirmar.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get confirmar;

  /// No description provided for @yaSeVendio.
  ///
  /// In es, this message translates to:
  /// **'¿Ya se vendió?'**
  String get yaSeVendio;

  /// No description provided for @calificacion.
  ///
  /// In es, this message translates to:
  /// **'calificación'**
  String get calificacion;

  /// No description provided for @calificaciones.
  ///
  /// In es, this message translates to:
  /// **'calificaciones'**
  String get calificaciones;

  /// No description provided for @queVasAVender.
  ///
  /// In es, this message translates to:
  /// **'¿Qué vas a vender?'**
  String get queVasAVender;

  /// No description provided for @seleccionaCategoria.
  ///
  /// In es, this message translates to:
  /// **'Selecciona la categoría que mejor describe tu artículo'**
  String get seleccionaCategoria;

  /// No description provided for @buscarCategoria.
  ///
  /// In es, this message translates to:
  /// **'Buscar categoría...'**
  String get buscarCategoria;

  /// No description provided for @noSeEncontraronCategorias.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron categorías'**
  String get noSeEncontraronCategorias;

  /// No description provided for @todasLasCategorias.
  ///
  /// In es, this message translates to:
  /// **'Todas las categorías'**
  String get todasLasCategorias;

  /// No description provided for @seleccionar.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar'**
  String get seleccionar;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
