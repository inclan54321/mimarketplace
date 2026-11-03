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

  /// No description provided for @chateaConCompradoresVendedores.
  ///
  /// In es, this message translates to:
  /// **'Chatea con compradores y vendedores'**
  String get chateaConCompradoresVendedores;

  /// No description provided for @tabChats.
  ///
  /// In es, this message translates to:
  /// **'CHATS'**
  String get tabChats;

  /// No description provided for @tabAgenda.
  ///
  /// In es, this message translates to:
  /// **'AGENDA'**
  String get tabAgenda;

  /// No description provided for @tabEncuentros.
  ///
  /// In es, this message translates to:
  /// **'ENCUENTROS'**
  String get tabEncuentros;

  /// No description provided for @noTienesConversaciones.
  ///
  /// In es, this message translates to:
  /// **'No tienes conversaciones'**
  String get noTienesConversaciones;

  /// No description provided for @encuentroAceptado.
  ///
  /// In es, this message translates to:
  /// **'ENCUENTRO ACEPTADO'**
  String get encuentroAceptado;

  /// No description provided for @articuloVendido.
  ///
  /// In es, this message translates to:
  /// **'ARTÍCULO VENDIDO'**
  String get articuloVendido;

  /// No description provided for @nuevoMensaje.
  ///
  /// In es, this message translates to:
  /// **'NUEVO MENSAJE'**
  String get nuevoMensaje;

  /// No description provided for @fijarChat.
  ///
  /// In es, this message translates to:
  /// **'Fijar chat'**
  String get fijarChat;

  /// No description provided for @desfijarChat.
  ///
  /// In es, this message translates to:
  /// **'Desfijar chat'**
  String get desfijarChat;

  /// No description provided for @quitarDeLaParteSuperior.
  ///
  /// In es, this message translates to:
  /// **'Quitar de la parte superior'**
  String get quitarDeLaParteSuperior;

  /// No description provided for @mantenerEnLaParteSuperior.
  ///
  /// In es, this message translates to:
  /// **'Mantener en la parte superior'**
  String get mantenerEnLaParteSuperior;

  /// No description provided for @chatFijado.
  ///
  /// In es, this message translates to:
  /// **'📌 Chat fijado'**
  String get chatFijado;

  /// No description provided for @chatDesfijado.
  ///
  /// In es, this message translates to:
  /// **'📌 Chat desfijado'**
  String get chatDesfijado;

  /// No description provided for @errorAlFijar.
  ///
  /// In es, this message translates to:
  /// **'Error al fijar: {codigo}'**
  String errorAlFijar(String codigo);

  /// No description provided for @eliminarChat.
  ///
  /// In es, this message translates to:
  /// **'Eliminar chat'**
  String get eliminarChat;

  /// No description provided for @confirmarEliminarChat.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de borrar la conversación con {nombre}?'**
  String confirmarEliminarChat(String nombre);

  /// No description provided for @chatEliminado.
  ///
  /// In es, this message translates to:
  /// **'🗑️ Chat eliminado'**
  String get chatEliminado;

  /// No description provided for @guardadoConProductos.
  ///
  /// In es, this message translates to:
  /// **'✅ Guardado ({cantidad} productos)'**
  String guardadoConProductos(int cantidad);

  /// No description provided for @eliminado.
  ///
  /// In es, this message translates to:
  /// **'🗑️ Eliminado'**
  String get eliminado;

  /// No description provided for @buscarContactosProductos.
  ///
  /// In es, this message translates to:
  /// **'Buscar contactos o productos...'**
  String get buscarContactosProductos;

  /// No description provided for @noHayContactosGuardados.
  ///
  /// In es, this message translates to:
  /// **'No hay contactos guardados'**
  String get noHayContactosGuardados;

  /// No description provided for @noHayResultadosPara.
  ///
  /// In es, this message translates to:
  /// **'No hay resultados para \"{busqueda}\"'**
  String noHayResultadosPara(String busqueda);

  /// No description provided for @tocaBotonParaGuardarContacto.
  ///
  /// In es, this message translates to:
  /// **'Toca el botón en un chat para guardar el contacto en tu agenda'**
  String get tocaBotonParaGuardarContacto;

  /// No description provided for @producto.
  ///
  /// In es, this message translates to:
  /// **'Producto'**
  String get producto;

  /// No description provided for @sinMensajes.
  ///
  /// In es, this message translates to:
  /// **'Sin mensajes'**
  String get sinMensajes;

  /// No description provided for @fechaDesconocida.
  ///
  /// In es, this message translates to:
  /// **'Fecha desconocida'**
  String get fechaDesconocida;

  /// No description provided for @haceDias.
  ///
  /// In es, this message translates to:
  /// **'hace {cantidad} días'**
  String haceDias(int cantidad);

  /// No description provided for @haceHoras.
  ///
  /// In es, this message translates to:
  /// **'hace {cantidad} horas'**
  String haceHoras(int cantidad);

  /// No description provided for @haceMinutos.
  ///
  /// In es, this message translates to:
  /// **'hace {cantidad} minutos'**
  String haceMinutos(int cantidad);

  /// No description provided for @haceUnosSegundos.
  ///
  /// In es, this message translates to:
  /// **'hace unos segundos'**
  String get haceUnosSegundos;

  /// No description provided for @lun.
  ///
  /// In es, this message translates to:
  /// **'Lun'**
  String get lun;

  /// No description provided for @mar.
  ///
  /// In es, this message translates to:
  /// **'Mar'**
  String get mar;

  /// No description provided for @mie.
  ///
  /// In es, this message translates to:
  /// **'Mié'**
  String get mie;

  /// No description provided for @jue.
  ///
  /// In es, this message translates to:
  /// **'Jue'**
  String get jue;

  /// No description provided for @vie.
  ///
  /// In es, this message translates to:
  /// **'Vie'**
  String get vie;

  /// No description provided for @sab.
  ///
  /// In es, this message translates to:
  /// **'Sáb'**
  String get sab;

  /// No description provided for @errorGenerico.
  ///
  /// In es, this message translates to:
  /// **'Error: {error}'**
  String errorGenerico(String error);

  /// No description provided for @catElectronicos.
  ///
  /// In es, this message translates to:
  /// **'Electrónicos'**
  String get catElectronicos;

  /// No description provided for @catDeportes.
  ///
  /// In es, this message translates to:
  /// **'Deportes'**
  String get catDeportes;

  /// No description provided for @catHogar.
  ///
  /// In es, this message translates to:
  /// **'Hogar'**
  String get catHogar;

  /// No description provided for @catMusica.
  ///
  /// In es, this message translates to:
  /// **'Música'**
  String get catMusica;

  /// No description provided for @catCocina.
  ///
  /// In es, this message translates to:
  /// **'Cocina'**
  String get catCocina;

  /// No description provided for @catPeliculas.
  ///
  /// In es, this message translates to:
  /// **'Películas'**
  String get catPeliculas;

  /// No description provided for @catFotografia.
  ///
  /// In es, this message translates to:
  /// **'Fotografía'**
  String get catFotografia;

  /// No description provided for @catVideojuegos.
  ///
  /// In es, this message translates to:
  /// **'Videojuegos'**
  String get catVideojuegos;

  /// No description provided for @catJuegosDeMesa.
  ///
  /// In es, this message translates to:
  /// **'Juegos de Mesa'**
  String get catJuegosDeMesa;

  /// No description provided for @catJuguetes.
  ///
  /// In es, this message translates to:
  /// **'Juguetes'**
  String get catJuguetes;

  /// No description provided for @catFiguras.
  ///
  /// In es, this message translates to:
  /// **'Figuras'**
  String get catFiguras;

  /// No description provided for @subElectronicos.
  ///
  /// In es, this message translates to:
  /// **'Móviles, Laptops, Audio'**
  String get subElectronicos;

  /// No description provided for @subDeportes.
  ///
  /// In es, this message translates to:
  /// **'Fútbol, Tenis, Running'**
  String get subDeportes;

  /// No description provided for @subHogar.
  ///
  /// In es, this message translates to:
  /// **'Muebles, Decoración, Cocina'**
  String get subHogar;

  /// No description provided for @subMusica.
  ///
  /// In es, this message translates to:
  /// **'Guitarras, Pianos, Audio'**
  String get subMusica;

  /// No description provided for @subCocina.
  ///
  /// In es, this message translates to:
  /// **'Ollas, Utensilios, Vajilla'**
  String get subCocina;

  /// No description provided for @subPeliculas.
  ///
  /// In es, this message translates to:
  /// **'Acción, Comedia, Drama'**
  String get subPeliculas;

  /// No description provided for @subFotografia.
  ///
  /// In es, this message translates to:
  /// **'Cámaras, Lentes, Accesorios'**
  String get subFotografia;

  /// No description provided for @subVideojuegos.
  ///
  /// In es, this message translates to:
  /// **'Consolas, Juegos, Controles'**
  String get subVideojuegos;

  /// No description provided for @subJuegosDeMesa.
  ///
  /// In es, this message translates to:
  /// **'Cartas, Tableros, Estrategia'**
  String get subJuegosDeMesa;

  /// No description provided for @subJuguetes.
  ///
  /// In es, this message translates to:
  /// **'Peluches, Bloques, Carros'**
  String get subJuguetes;

  /// No description provided for @subFiguras.
  ///
  /// In es, this message translates to:
  /// **'Acción, Coleccionables, Anime'**
  String get subFiguras;

  /// No description provided for @alertasTitulo.
  ///
  /// In es, this message translates to:
  /// **'Alertas'**
  String get alertasTitulo;

  /// No description provided for @recargar.
  ///
  /// In es, this message translates to:
  /// **'Recargar'**
  String get recargar;

  /// No description provided for @limpiarTodasLasAlertas.
  ///
  /// In es, this message translates to:
  /// **'Limpiar todas las alertas'**
  String get limpiarTodasLasAlertas;

  /// No description provided for @noTienesAlertas.
  ///
  /// In es, this message translates to:
  /// **'No tienes alertas'**
  String get noTienesAlertas;

  /// No description provided for @aquiApareceranAvisos.
  ///
  /// In es, this message translates to:
  /// **'Aquí aparecerán tus avisos y encuentros.'**
  String get aquiApareceranAvisos;

  /// No description provided for @noHayAlertasParaLimpiar.
  ///
  /// In es, this message translates to:
  /// **'No hay alertas para limpiar'**
  String get noHayAlertasParaLimpiar;

  /// No description provided for @limpiarAlertas.
  ///
  /// In es, this message translates to:
  /// **'🗑️ Limpiar alertas'**
  String get limpiarAlertas;

  /// No description provided for @confirmarLimpiarAlertas.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres eliminar todas las alertas?'**
  String get confirmarLimpiarAlertas;

  /// No description provided for @eliminarTodo.
  ///
  /// In es, this message translates to:
  /// **'Eliminar todo'**
  String get eliminarTodo;

  /// No description provided for @todasLasAlertasEliminadas.
  ///
  /// In es, this message translates to:
  /// **'✅ Todas las alertas han sido eliminadas'**
  String get todasLasAlertasEliminadas;

  /// No description provided for @errorAlLimpiarAlertas.
  ///
  /// In es, this message translates to:
  /// **'Error al limpiar alertas: {error}'**
  String errorAlLimpiarAlertas(String error);

  /// No description provided for @cargandoAnuncio.
  ///
  /// In es, this message translates to:
  /// **'⏳ Cargando anuncio... espera un momento'**
  String get cargandoAnuncio;

  /// No description provided for @noSePudoCargarAnuncio.
  ///
  /// In es, this message translates to:
  /// **'❌ No se pudo cargar el anuncio. Intentá de nuevo.'**
  String get noSePudoCargarAnuncio;

  /// No description provided for @productoRenovado.
  ///
  /// In es, this message translates to:
  /// **'✅ Producto renovado por 30 días más'**
  String get productoRenovado;

  /// No description provided for @errorAlRenovar.
  ///
  /// In es, this message translates to:
  /// **'Error al renovar: {error}'**
  String errorAlRenovar(String error);

  /// No description provided for @debesVerAnuncioCompleto.
  ///
  /// In es, this message translates to:
  /// **'❌ Debes ver el anuncio completo para renovar'**
  String get debesVerAnuncioCompleto;

  /// No description provided for @renovarPor30Dias.
  ///
  /// In es, this message translates to:
  /// **'Renovar por 30 días'**
  String get renovarPor30Dias;

  /// No description provided for @ambosConfirmaron.
  ///
  /// In es, this message translates to:
  /// **'Ambos confirmaron'**
  String get ambosConfirmaron;

  /// No description provided for @esperandoAlOtro.
  ///
  /// In es, this message translates to:
  /// **'Esperando al otro'**
  String get esperandoAlOtro;

  /// No description provided for @confirmarEncuentro.
  ///
  /// In es, this message translates to:
  /// **'Confirmar encuentro'**
  String get confirmarEncuentro;

  /// No description provided for @verificarIdentidad.
  ///
  /// In es, this message translates to:
  /// **'Verificar identidad'**
  String get verificarIdentidad;

  /// No description provided for @verificarIdentidadDelOtro.
  ///
  /// In es, this message translates to:
  /// **'Verificar identidad del otro'**
  String get verificarIdentidadDelOtro;

  /// No description provided for @identidadRechazada.
  ///
  /// In es, this message translates to:
  /// **'Identidad rechazada'**
  String get identidadRechazada;

  /// No description provided for @revisarComparacion.
  ///
  /// In es, this message translates to:
  /// **'Revisar comparación'**
  String get revisarComparacion;

  /// No description provided for @ambosConfirmaronExito.
  ///
  /// In es, this message translates to:
  /// **'✅ Ambos confirmaron. ¡Nos vemos!'**
  String get ambosConfirmaronExito;

  /// No description provided for @confirmasteAsistencia.
  ///
  /// In es, this message translates to:
  /// **'✅ Confirmaste tu asistencia. Esperando al otro.'**
  String get confirmasteAsistencia;

  /// No description provided for @errorGenericoAlerta.
  ///
  /// In es, this message translates to:
  /// **'Error: {error}'**
  String errorGenericoAlerta(String error);

  /// No description provided for @eliminarPublicidadTitulo.
  ///
  /// In es, this message translates to:
  /// **'Eliminar publicidad'**
  String get eliminarPublicidadTitulo;

  /// No description provided for @eliminaLosAnuncios.
  ///
  /// In es, this message translates to:
  /// **'Eliminá los anuncios'**
  String get eliminaLosAnuncios;

  /// No description provided for @descripcionEliminarPublicidad.
  ///
  /// In es, this message translates to:
  /// **'Pagá un plan y navegá sin publicidad en toda la app. Sin anuncios, sin interrupciones.'**
  String get descripcionEliminarPublicidad;

  /// No description provided for @beneficioSinAnuncios.
  ///
  /// In es, this message translates to:
  /// **'Sin anuncios en toda la app'**
  String get beneficioSinAnuncios;

  /// No description provided for @beneficioNavegacionRapida.
  ///
  /// In es, this message translates to:
  /// **'Navegación más rápida'**
  String get beneficioNavegacionRapida;

  /// No description provided for @beneficioSinInterrupciones.
  ///
  /// In es, this message translates to:
  /// **'Experiencia sin interrupciones'**
  String get beneficioSinInterrupciones;

  /// No description provided for @elegiTuPlan.
  ///
  /// In es, this message translates to:
  /// **'Elegí tu plan'**
  String get elegiTuPlan;

  /// No description provided for @plan1Mes.
  ///
  /// In es, this message translates to:
  /// **'1 mes'**
  String get plan1Mes;

  /// No description provided for @plan6Meses.
  ///
  /// In es, this message translates to:
  /// **'6 meses'**
  String get plan6Meses;

  /// No description provided for @sinAnunciosPor30Dias.
  ///
  /// In es, this message translates to:
  /// **'Sin anuncios por 30 días'**
  String get sinAnunciosPor30Dias;

  /// No description provided for @sinAnunciosPor180Dias.
  ///
  /// In es, this message translates to:
  /// **'Sin anuncios por 180 días'**
  String get sinAnunciosPor180Dias;

  /// No description provided for @ahorrasMonto.
  ///
  /// In es, this message translates to:
  /// **'Ahorrás {monto}'**
  String ahorrasMonto(String monto);

  /// No description provided for @elegiUnPlan.
  ///
  /// In es, this message translates to:
  /// **'Elegí un plan'**
  String get elegiUnPlan;

  /// No description provided for @pagarMonto.
  ///
  /// In es, this message translates to:
  /// **'Pagar {monto}'**
  String pagarMonto(String monto);

  /// No description provided for @pagoSeguro.
  ///
  /// In es, this message translates to:
  /// **'El pago se procesa de forma segura'**
  String get pagoSeguro;

  /// No description provided for @confirmarCompra.
  ///
  /// In es, this message translates to:
  /// **'Confirmar compra'**
  String get confirmarCompra;

  /// No description provided for @confirmarCompraPregunta.
  ///
  /// In es, this message translates to:
  /// **'¿Querés pagar {precio} por {duracion} sin anuncios?'**
  String confirmarCompraPregunta(String precio, String duracion);

  /// No description provided for @pagar.
  ///
  /// In es, this message translates to:
  /// **'Pagar'**
  String get pagar;

  /// No description provided for @integracionPagoEnDesarrollo.
  ///
  /// In es, this message translates to:
  /// **'🚧 Integración de pago en desarrollo'**
  String get integracionPagoEnDesarrollo;
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
