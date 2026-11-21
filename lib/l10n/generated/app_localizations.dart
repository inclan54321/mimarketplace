import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';

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
    Locale('ja'),
    Locale('ko'),
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

  /// No description provided for @miPerfil.
  ///
  /// In es, this message translates to:
  /// **'Mi Perfil'**
  String get miPerfil;

  /// No description provided for @verPortafolio.
  ///
  /// In es, this message translates to:
  /// **'Ver Portafolio'**
  String get verPortafolio;

  /// No description provided for @verTodosMisProductos.
  ///
  /// In es, this message translates to:
  /// **'Ver todos mis productos publicados'**
  String get verTodosMisProductos;

  /// No description provided for @opcionesDelVendedor.
  ///
  /// In es, this message translates to:
  /// **'Opciones del Vendedor'**
  String get opcionesDelVendedor;

  /// No description provided for @desbloquear.
  ///
  /// In es, this message translates to:
  /// **'Desbloquear'**
  String get desbloquear;

  /// No description provided for @bloquear.
  ///
  /// In es, this message translates to:
  /// **'Bloquear'**
  String get bloquear;

  /// No description provided for @desbloquearA.
  ///
  /// In es, this message translates to:
  /// **'Desbloquear a {nombre}'**
  String desbloquearA(String nombre);

  /// No description provided for @bloquearA.
  ///
  /// In es, this message translates to:
  /// **'Bloquear a {nombre}'**
  String bloquearA(String nombre);

  /// No description provided for @verInformacionDePerfil.
  ///
  /// In es, this message translates to:
  /// **'Ver información de perfil'**
  String get verInformacionDePerfil;

  /// No description provided for @verDetallesDe.
  ///
  /// In es, this message translates to:
  /// **'Ver detalles de {nombre}'**
  String verDetallesDe(String nombre);

  /// No description provided for @verTodosLosProductosDe.
  ///
  /// In es, this message translates to:
  /// **'Ver todos los productos de {nombre}'**
  String verTodosLosProductosDe(String nombre);

  /// No description provided for @denunciarVendedor.
  ///
  /// In es, this message translates to:
  /// **'Denunciar vendedor'**
  String get denunciarVendedor;

  /// No description provided for @reportarA.
  ///
  /// In es, this message translates to:
  /// **'Reportar a {nombre} por incumplir las reglas'**
  String reportarA(String nombre);

  /// No description provided for @vendedorBloqueadoCorrectamente.
  ///
  /// In es, this message translates to:
  /// **'Vendedor bloqueado correctamente. Reiniciando...'**
  String get vendedorBloqueadoCorrectamente;

  /// No description provided for @vendedorDesbloqueadoCorrectamente.
  ///
  /// In es, this message translates to:
  /// **'Vendedor desbloqueado correctamente. Reiniciando...'**
  String get vendedorDesbloqueadoCorrectamente;

  /// No description provided for @errorAlBloquear.
  ///
  /// In es, this message translates to:
  /// **'Error al bloquear'**
  String get errorAlBloquear;

  /// No description provided for @errorAlDesbloquear.
  ///
  /// In es, this message translates to:
  /// **'Error al desbloquear'**
  String get errorAlDesbloquear;

  /// No description provided for @errorAlBloquearUsuario.
  ///
  /// In es, this message translates to:
  /// **'Error al bloquear usuario'**
  String get errorAlBloquearUsuario;

  /// No description provided for @errorAlDesbloquearUsuario.
  ///
  /// In es, this message translates to:
  /// **'Error al desbloquear usuario'**
  String get errorAlDesbloquearUsuario;

  /// No description provided for @denunciarVendedorTitulo.
  ///
  /// In es, this message translates to:
  /// **'⚠️ Denunciar vendedor'**
  String get denunciarVendedorTitulo;

  /// No description provided for @seleccionaMotivoDenuncia.
  ///
  /// In es, this message translates to:
  /// **'Selecciona el motivo de la denuncia:'**
  String get seleccionaMotivoDenuncia;

  /// No description provided for @denunciaRevisadaPorEquipo.
  ///
  /// In es, this message translates to:
  /// **'Esta denuncia será revisada por nuestro equipo de moderación.'**
  String get denunciaRevisadaPorEquipo;

  /// No description provided for @denunciar.
  ///
  /// In es, this message translates to:
  /// **'Denunciar'**
  String get denunciar;

  /// No description provided for @debesIniciarSesionParaDenunciar.
  ///
  /// In es, this message translates to:
  /// **'Debes iniciar sesión para denunciar'**
  String get debesIniciarSesionParaDenunciar;

  /// No description provided for @denunciaEnviada.
  ///
  /// In es, this message translates to:
  /// **'✅ Denuncia enviada. Será revisada por moderación.'**
  String get denunciaEnviada;

  /// No description provided for @errorAlEnviarDenuncia.
  ///
  /// In es, this message translates to:
  /// **'Error al enviar denuncia: {error}'**
  String errorAlEnviarDenuncia(String error);

  /// No description provided for @motivoProductoSospechoso.
  ///
  /// In es, this message translates to:
  /// **'Producto sospechoso'**
  String get motivoProductoSospechoso;

  /// No description provided for @motivoProductosProhibidos.
  ///
  /// In es, this message translates to:
  /// **'Publicación de productos prohibidos'**
  String get motivoProductosProhibidos;

  /// No description provided for @motivoEstafaFraude.
  ///
  /// In es, this message translates to:
  /// **'Estafa o fraude'**
  String get motivoEstafaFraude;

  /// No description provided for @motivoAcosoMaltrato.
  ///
  /// In es, this message translates to:
  /// **'Acoso o maltrato'**
  String get motivoAcosoMaltrato;

  /// No description provided for @motivoInformacionFalsa.
  ///
  /// In es, this message translates to:
  /// **'Información falsa o engañosa'**
  String get motivoInformacionFalsa;

  /// No description provided for @motivoOtro.
  ///
  /// In es, this message translates to:
  /// **'Otro motivo'**
  String get motivoOtro;

  /// No description provided for @vendedor.
  ///
  /// In es, this message translates to:
  /// **'Vendedor'**
  String get vendedor;

  /// No description provided for @esteVendedor.
  ///
  /// In es, this message translates to:
  /// **'este vendedor'**
  String get esteVendedor;

  /// No description provided for @miPortafolio.
  ///
  /// In es, this message translates to:
  /// **'Mi Portafolio'**
  String get miPortafolio;

  /// No description provided for @debesIniciarSesion.
  ///
  /// In es, this message translates to:
  /// **'Debes iniciar sesión'**
  String get debesIniciarSesion;

  /// No description provided for @editarProducto.
  ///
  /// In es, this message translates to:
  /// **'Editar Producto'**
  String get editarProducto;

  /// No description provided for @contactarVendedor.
  ///
  /// In es, this message translates to:
  /// **'Contactar Vendedor'**
  String get contactarVendedor;

  /// No description provided for @compartirProductoMensaje.
  ///
  /// In es, this message translates to:
  /// **'📱 Mira este producto en MiMarketplace:\n\n{enlace}'**
  String compartirProductoMensaje(String enlace);

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

  /// No description provided for @encuentroCaducado.
  ///
  /// In es, this message translates to:
  /// **'Encuentro caducado'**
  String get encuentroCaducado;

  /// No description provided for @esperandoVerificacionDelOtro.
  ///
  /// In es, this message translates to:
  /// **'Esperando que el otro verifique tu selfie'**
  String get esperandoVerificacionDelOtro;

  /// No description provided for @verificacionCompleta.
  ///
  /// In es, this message translates to:
  /// **'Verificación completa'**
  String get verificacionCompleta;

  /// No description provided for @premiumActivoTitulo.
  ///
  /// In es, this message translates to:
  /// **'¡Ya sos premium!'**
  String get premiumActivoTitulo;

  /// No description provided for @premiumActivoDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Los anuncios están eliminados'**
  String get premiumActivoDescripcion;

  /// No description provided for @planUnaSemana.
  ///
  /// In es, this message translates to:
  /// **'1 Semana'**
  String get planUnaSemana;

  /// No description provided for @sinAnunciosPor7Dias.
  ///
  /// In es, this message translates to:
  /// **'Sin anuncios por 7 días'**
  String get sinAnunciosPor7Dias;

  /// No description provided for @yaTenesAnunciosEliminados.
  ///
  /// In es, this message translates to:
  /// **'Ya tenés los anuncios eliminados'**
  String get yaTenesAnunciosEliminados;

  /// No description provided for @productoNoDisponible.
  ///
  /// In es, this message translates to:
  /// **'Producto no disponible'**
  String get productoNoDisponible;

  /// No description provided for @errorCompra.
  ///
  /// In es, this message translates to:
  /// **'Error: {detalle}'**
  String errorCompra(Object detalle);

  /// No description provided for @desconocido.
  ///
  /// In es, this message translates to:
  /// **'Desconocido'**
  String get desconocido;

  /// No description provided for @usuarioNoLogueado.
  ///
  /// In es, this message translates to:
  /// **'No hay usuario logueado'**
  String get usuarioNoLogueado;

  /// No description provided for @errorVerificarCompra.
  ///
  /// In es, this message translates to:
  /// **'Error al verificar compra'**
  String get errorVerificarCompra;

  /// No description provided for @compraExitosaAnunciosEliminados.
  ///
  /// In es, this message translates to:
  /// **'✅ ¡Listo! Los anuncios fueron eliminados.'**
  String get compraExitosaAnunciosEliminados;

  /// No description provided for @configurarImpulso.
  ///
  /// In es, this message translates to:
  /// **'Configurar impulso'**
  String get configurarImpulso;

  /// No description provided for @impulsarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Impulsar'**
  String get impulsarTitulo;

  /// No description provided for @impulsarPublicacion.
  ///
  /// In es, this message translates to:
  /// **'Impulsar publicación'**
  String get impulsarPublicacion;

  /// No description provided for @poneTuProductoPrimero.
  ///
  /// In es, this message translates to:
  /// **'Poné tu producto primero'**
  String get poneTuProductoPrimero;

  /// No description provided for @impulsarPunto1Titulo.
  ///
  /// In es, this message translates to:
  /// **'Subí al primer lugar'**
  String get impulsarPunto1Titulo;

  /// No description provided for @impulsarPunto1Desc.
  ///
  /// In es, this message translates to:
  /// **'Tu producto aparece primero en la lista de Productos Destacados del Home.'**
  String get impulsarPunto1Desc;

  /// No description provided for @impulsarPunto2Titulo.
  ///
  /// In es, this message translates to:
  /// **'Más visibilidad'**
  String get impulsarPunto2Titulo;

  /// No description provided for @impulsarPunto2Desc.
  ///
  /// In es, this message translates to:
  /// **'Al estar primero, más personas lo ven y tenés más chances de venderlo rápido.'**
  String get impulsarPunto2Desc;

  /// No description provided for @impulsarPunto3Titulo.
  ///
  /// In es, this message translates to:
  /// **'Duración limitada'**
  String get impulsarPunto3Titulo;

  /// No description provided for @impulsarPunto3Desc.
  ///
  /// In es, this message translates to:
  /// **'El impulso dura hasta que otro vendedor pague por subir. Ahí bajás un lugar.'**
  String get impulsarPunto3Desc;

  /// No description provided for @seleccionarArticulo.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar artículo'**
  String get seleccionarArticulo;

  /// No description provided for @proximamenteDisponiblePagos.
  ///
  /// In es, this message translates to:
  /// **'Próximamente disponible. Estamos habilitando los pagos.'**
  String get proximamenteDisponiblePagos;

  /// No description provided for @articuloAImpulsar.
  ///
  /// In es, this message translates to:
  /// **'Artículo a impulsar'**
  String get articuloAImpulsar;

  /// No description provided for @comoFuncionaImpulso.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo funciona?'**
  String get comoFuncionaImpulso;

  /// No description provided for @explicacionImpulso.
  ///
  /// In es, this message translates to:
  /// **'Al impulsar, tu producto sube al primer lugar del Home. Si otro vendedor impulsa su producto, vos bajás un lugar. El que pagó más recientemente siempre está primero.'**
  String get explicacionImpulso;

  /// No description provided for @procesando.
  ///
  /// In es, this message translates to:
  /// **'Procesando...'**
  String get procesando;

  /// No description provided for @cargando.
  ///
  /// In es, this message translates to:
  /// **'Cargando...'**
  String get cargando;

  /// No description provided for @impulsarAhora.
  ///
  /// In es, this message translates to:
  /// **'Impulsar ahora'**
  String get impulsarAhora;

  /// No description provided for @cambiarProducto.
  ///
  /// In es, this message translates to:
  /// **'Cambiar producto'**
  String get cambiarProducto;

  /// No description provided for @noTenesProductosPublicados.
  ///
  /// In es, this message translates to:
  /// **'No tenés productos publicados'**
  String get noTenesProductosPublicados;

  /// No description provided for @elegiUnArticulo.
  ///
  /// In es, this message translates to:
  /// **'Elegí un artículo'**
  String get elegiUnArticulo;

  /// No description provided for @elQueElijasApareceraPrimero.
  ///
  /// In es, this message translates to:
  /// **'El que elijas aparecerá primero en el Home'**
  String get elQueElijasApareceraPrimero;

  /// No description provided for @primeroElegiUnArticulo.
  ///
  /// In es, this message translates to:
  /// **'Primero elegí un artículo'**
  String get primeroElegiUnArticulo;

  /// No description provided for @productoImpulsoNoDisponible.
  ///
  /// In es, this message translates to:
  /// **'Producto de impulso no disponible. Revisá tu conexión.'**
  String get productoImpulsoNoDisponible;

  /// No description provided for @errorDesconocido.
  ///
  /// In es, this message translates to:
  /// **'Desconocido'**
  String get errorDesconocido;

  /// No description provided for @productoEstaPrimeroEnHome.
  ///
  /// In es, this message translates to:
  /// **'✅ \"{nombre}\" está primero en el Home'**
  String productoEstaPrimeroEnHome(String nombre);

  /// No description provided for @pagoNoVerificado.
  ///
  /// In es, this message translates to:
  /// **'El pago no se pudo verificar. Contactá a soporte.'**
  String get pagoNoVerificado;

  /// No description provided for @compraPendiente.
  ///
  /// In es, this message translates to:
  /// **'La compra quedó pendiente. Intentá de nuevo.'**
  String get compraPendiente;

  /// No description provided for @errorAlImpulsar.
  ///
  /// In es, this message translates to:
  /// **'Error al impulsar'**
  String get errorAlImpulsar;

  /// No description provided for @escudoActivoPor.
  ///
  /// In es, this message translates to:
  /// **'{nombre} activó el Escudo de Seguridad'**
  String escudoActivoPor(String nombre);

  /// No description provided for @escudoPaso0Titulo.
  ///
  /// In es, this message translates to:
  /// **'¿Qué es el Escudo de Seguridad?'**
  String get escudoPaso0Titulo;

  /// No description provided for @escudoPaso0Desc.
  ///
  /// In es, this message translates to:
  /// **'Es un conjunto de medidas de protección que se activan cuando ambos usuarios de un trato lo aceptan. Su objetivo es prevenir fraudes y garantizar que el encuentro sea seguro.\n\n¿Quién debe activarlo?\nAmbos usuarios del trato deben aceptar el Escudo. Si uno lo activa, el otro recibirá una notificación para aceptarlo o rechazarlo. Si el segundo usuario lo rechaza, el chat se cerrará para ambos.'**
  String get escudoPaso0Desc;

  /// No description provided for @escudoPaso1Titulo.
  ///
  /// In es, this message translates to:
  /// **'¿Qué ocurre cuando el Escudo está activo?'**
  String get escudoPaso1Titulo;

  /// No description provided for @escudoPaso1Desc.
  ///
  /// In es, this message translates to:
  /// **'3.1. Bloqueo de enlaces y teléfonos: La app detecta y bloquea automáticamente números de teléfono y enlaces externos en los mensajes. Esto evita compartir datos de contacto fuera de la plataforma y reduce el riesgo de estafas.'**
  String get escudoPaso1Desc;

  /// No description provided for @escudoPaso2Titulo.
  ///
  /// In es, this message translates to:
  /// **'Cómo cerrar el trato'**
  String get escudoPaso2Titulo;

  /// No description provided for @escudoPaso2Desc.
  ///
  /// In es, this message translates to:
  /// **'Para cerrar el trato, primero proponé un encuentro: tocá el escudo en la barra superior del chat y elegí \"Proponer encuentro\". Ahí seleccionás provincia, cantón, distrito, un lugar seguro y la fecha con hora. Enviás la propuesta y el otro usuario la recibe como tarjeta en el chat. Cuando la acepta, el encuentro queda agendado pero el chat sigue abierto: pueden seguir hablando. Para cerrar el trato, tocá el escudo otra vez y elegí \"Cerrar trato\". Se abre un cartel para confirmar. Cuando ambos confirman, el chat se bloquea y las protecciones se activan.'**
  String get escudoPaso2Desc;

  /// No description provided for @escudoPaso3Titulo.
  ///
  /// In es, this message translates to:
  /// **'Confirmación de asistencia'**
  String get escudoPaso3Titulo;

  /// No description provided for @escudoPaso3Desc.
  ///
  /// In es, this message translates to:
  /// **'Una hora antes del encuentro, ambos usuarios recibirán una notificación para confirmar su asistencia. Si alguno de los dos no confirma dentro de los 15 minutos posteriores a la notificación, el otro usuario podrá cancelar el encuentro hasta 15 minutos antes de la hora pactada.'**
  String get escudoPaso3Desc;

  /// No description provided for @escudoPaso4Titulo.
  ///
  /// In es, this message translates to:
  /// **'Seguimiento GPS'**
  String get escudoPaso4Titulo;

  /// No description provided for @escudoPaso4Desc.
  ///
  /// In es, this message translates to:
  /// **'3.3. Seguimiento GPS el día del encuentro: El día acordado, 15 minutos antes de la hora del encuentro, ambos usuarios deben estar en el lugar y activar el GPS para verificar su ubicación. Si faltando 5 minutos para la hora acordada el usuario no activó el GPS y no verificó su identidad, se considerará que llegó tarde. Si 15 minutos después de la hora acordada el usuario no lo hizo, se considerará que no llegó. En ambos casos, queda registrado y puede ser sancionado según las normas de MiMarketplace.'**
  String get escudoPaso4Desc;

  /// No description provided for @escudoPaso5Titulo.
  ///
  /// In es, this message translates to:
  /// **'Verificación facial'**
  String get escudoPaso5Titulo;

  /// No description provided for @escudoPaso5Desc.
  ///
  /// In es, this message translates to:
  /// **'3.4. Verificación de identidad antes del chat: Para liberar el chat del encuentro, ambos usuarios deben confirmar que son quienes dicen ser. Esto se habilita 15 minutos antes de la hora acordada y es un requisito obligatorio para poder abrir el chat. El sistema le pedirá a cada uno que se tome una foto en el momento. Luego, el otro usuario deberá comparar esa foto con la foto de perfil para confirmar que coinciden. Es importante estar atento, porque la verificación se habilita cuando el otro usuario la activa, y hay que seguir las instrucciones que aparecen en pantalla. Así se evita que alguien más use la cuenta.'**
  String get escudoPaso5Desc;

  /// No description provided for @escudoPaso6Titulo.
  ///
  /// In es, this message translates to:
  /// **'Consideraciones adicionales'**
  String get escudoPaso6Titulo;

  /// No description provided for @escudoPaso6Desc.
  ///
  /// In es, this message translates to:
  /// **'4.1. Cancelación voluntaria: Cualquier usuario puede cancelar su asistencia al encuentro siempre y cuando falte más de una hora para la hora acordada. Una vez que falte menos de una hora, la cancelación ya no estará disponible.\n\n¿Cómo cancelar? Entrá al chat del artículo, tocá el botón del escudo en la barra superior y elegí \"Cancelar trato\". Se va a abrir un cartel que te muestra la fecha del encuentro y te indica si todavía podés cancelar o si ya falta menos de una hora. Si se puede, confirmás y el encuentro se anula para los dos.\n\nRevisá siempre la sección de Alertas. Ahí llegan los recordatorios del encuentro, la confirmación de asistencia, la verificación de identidad y cualquier cambio de estado. Tenés que revisarlas seguido para no perderte nada importante.'**
  String get escudoPaso6Desc;

  /// No description provided for @noAceptar.
  ///
  /// In es, this message translates to:
  /// **'No aceptar'**
  String get noAceptar;

  /// No description provided for @aceptar.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get aceptar;

  /// No description provided for @cerrar.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get cerrar;

  /// No description provided for @siguiente.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get siguiente;

  /// No description provided for @iniciar.
  ///
  /// In es, this message translates to:
  /// **'Iniciar'**
  String get iniciar;

  /// No description provided for @verVideo.
  ///
  /// In es, this message translates to:
  /// **'Ver video'**
  String get verVideo;

  /// No description provided for @errorGenericoImpulsar.
  ///
  /// In es, this message translates to:
  /// **'Error: {error}'**
  String errorGenericoImpulsar(String error);

  /// No description provided for @ubicacionDelEncuentro.
  ///
  /// In es, this message translates to:
  /// **'Ubicación del encuentro'**
  String get ubicacionDelEncuentro;
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
      <String>['de', 'en', 'es', 'ja', 'ko'].contains(locale.languageCode);

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
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
