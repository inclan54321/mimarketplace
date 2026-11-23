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

  /// No description provided for @errorGenericoAlerta.
  ///
  /// In es, this message translates to:
  /// **'Error: {error}'**
  String errorGenericoAlerta(String error);

  /// No description provided for @errorDesconocido.
  ///
  /// In es, this message translates to:
  /// **'Error desconocido'**
  String get errorDesconocido;

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

  /// No description provided for @catAutomoviles.
  ///
  /// In es, this message translates to:
  /// **'Automóviles'**
  String get catAutomoviles;

  /// No description provided for @catHerramientas.
  ///
  /// In es, this message translates to:
  /// **'Herramientas'**
  String get catHerramientas;

  /// No description provided for @catRopaYCalzado.
  ///
  /// In es, this message translates to:
  /// **'Ropa y Calzado'**
  String get catRopaYCalzado;

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
  String errorCompra(String detalle);

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

  /// No description provided for @verificarCuenta.
  ///
  /// In es, this message translates to:
  /// **'Verificar cuenta'**
  String get verificarCuenta;

  /// No description provided for @verificaTuCuenta.
  ///
  /// In es, this message translates to:
  /// **'Verificá tu cuenta'**
  String get verificaTuCuenta;

  /// No description provided for @obteneLaInsigniaDeVerificado.
  ///
  /// In es, this message translates to:
  /// **'Obtené la insignia de verificado en tu perfil'**
  String get obteneLaInsigniaDeVerificado;

  /// No description provided for @paso1EnviaSinpe.
  ///
  /// In es, this message translates to:
  /// **'Paso 1: Enviá el SINPE Móvil'**
  String get paso1EnviaSinpe;

  /// No description provided for @realizaSinpeDeMontoANumero.
  ///
  /// In es, this message translates to:
  /// **'Realizá un SINPE Móvil de {monto} al número:'**
  String realizaSinpeDeMontoANumero(String monto);

  /// No description provided for @paso2IngresaTuNumero.
  ///
  /// In es, this message translates to:
  /// **'Paso 2: Ingresá tu número'**
  String get paso2IngresaTuNumero;

  /// No description provided for @ingresaNumeroDesdeElQueEnviaste.
  ///
  /// In es, this message translates to:
  /// **'Ingresá el número de teléfono desde el que enviaste el SINPE:'**
  String get ingresaNumeroDesdeElQueEnviaste;

  /// No description provided for @ejemploTelefono.
  ///
  /// In es, this message translates to:
  /// **'Ej: 88888888'**
  String get ejemploTelefono;

  /// No description provided for @confirmarPago.
  ///
  /// In es, this message translates to:
  /// **'Confirmar pago'**
  String get confirmarPago;

  /// No description provided for @enviando.
  ///
  /// In es, this message translates to:
  /// **'Enviando...'**
  String get enviando;

  /// No description provided for @porFavorIngresaTuTelefono.
  ///
  /// In es, this message translates to:
  /// **'Por favor, ingresá tu número de teléfono'**
  String get porFavorIngresaTuTelefono;

  /// No description provided for @solicitudEnviada.
  ///
  /// In es, this message translates to:
  /// **'¡Solicitud enviada!'**
  String get solicitudEnviada;

  /// No description provided for @estamosVerificandoTuPago.
  ///
  /// In es, this message translates to:
  /// **'Estamos verificando tu pago. En breve recibirás la insignia de verificado en tu perfil.'**
  String get estamosVerificandoTuPago;

  /// No description provided for @porFavorEscribeUnMensaje.
  ///
  /// In es, this message translates to:
  /// **'Por favor, escribe un mensaje'**
  String get porFavorEscribeUnMensaje;

  /// No description provided for @porFavorEscribeUnAsunto.
  ///
  /// In es, this message translates to:
  /// **'Por favor, escribe un asunto'**
  String get porFavorEscribeUnAsunto;

  /// No description provided for @mensajeEnviadoExito.
  ///
  /// In es, this message translates to:
  /// **'✅ Mensaje enviado. Te responderemos pronto.'**
  String get mensajeEnviadoExito;

  /// No description provided for @necesitasAyuda.
  ///
  /// In es, this message translates to:
  /// **'¿Necesitas ayuda?'**
  String get necesitasAyuda;

  /// No description provided for @cuentanosTuProblema.
  ///
  /// In es, this message translates to:
  /// **'Cuéntanos tu problema y te ayudaremos a resolverlo.'**
  String get cuentanosTuProblema;

  /// No description provided for @tipoDeConsulta.
  ///
  /// In es, this message translates to:
  /// **'Tipo de consulta'**
  String get tipoDeConsulta;

  /// No description provided for @asunto.
  ///
  /// In es, this message translates to:
  /// **'Asunto'**
  String get asunto;

  /// No description provided for @ejemploProblemaCuenta.
  ///
  /// In es, this message translates to:
  /// **'Ej: Problema con mi cuenta'**
  String get ejemploProblemaCuenta;

  /// No description provided for @mensaje.
  ///
  /// In es, this message translates to:
  /// **'Mensaje'**
  String get mensaje;

  /// No description provided for @describeTuProblema.
  ///
  /// In es, this message translates to:
  /// **'Describe tu problema con el mayor detalle posible...'**
  String get describeTuProblema;

  /// No description provided for @enviarMensaje.
  ///
  /// In es, this message translates to:
  /// **'Enviar mensaje'**
  String get enviarMensaje;

  /// No description provided for @tiempoRespuestaEstimado.
  ///
  /// In es, this message translates to:
  /// **'Tiempo de respuesta estimado: 24-48 horas'**
  String get tiempoRespuestaEstimado;

  /// No description provided for @mensajeEnviado.
  ///
  /// In es, this message translates to:
  /// **'¡Mensaje enviado!'**
  String get mensajeEnviado;

  /// No description provided for @hemosRecibidoTuConsulta.
  ///
  /// In es, this message translates to:
  /// **'Hemos recibido tu consulta. Nuestro equipo de soporte te responderá en las próximas 24-48 horas.'**
  String get hemosRecibidoTuConsulta;

  /// No description provided for @enviarOtroMensaje.
  ///
  /// In es, this message translates to:
  /// **'Enviar otro mensaje'**
  String get enviarOtroMensaje;

  /// No description provided for @volver.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get volver;

  /// No description provided for @categoria.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get categoria;

  /// No description provided for @direccion.
  ///
  /// In es, this message translates to:
  /// **'Dirección'**
  String get direccion;

  /// No description provided for @nombreDelProducto.
  ///
  /// In es, this message translates to:
  /// **'Nombre del producto'**
  String get nombreDelProducto;

  /// No description provided for @ejemploNombreProducto.
  ///
  /// In es, this message translates to:
  /// **'Ej. iPhone 13, Laptop, etc.'**
  String get ejemploNombreProducto;

  /// No description provided for @ingresaNombreProducto.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el nombre del producto'**
  String get ingresaNombreProducto;

  /// No description provided for @nombreMinimoCaracteres.
  ///
  /// In es, this message translates to:
  /// **'El nombre debe tener al menos 3 caracteres'**
  String get nombreMinimoCaracteres;

  /// No description provided for @precio.
  ///
  /// In es, this message translates to:
  /// **'Precio (₡)'**
  String get precio;

  /// No description provided for @ingresePrecioProducto.
  ///
  /// In es, this message translates to:
  /// **'Ingrese el precio del producto'**
  String get ingresePrecioProducto;

  /// No description provided for @ingresaPrecio.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el precio'**
  String get ingresaPrecio;

  /// No description provided for @ingresaPrecioValido.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un precio válido'**
  String get ingresaPrecioValido;

  /// No description provided for @precioMayorCero.
  ///
  /// In es, this message translates to:
  /// **'El precio debe ser mayor a 0'**
  String get precioMayorCero;

  /// No description provided for @descripcion.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get descripcion;

  /// No description provided for @escribeDescripcionDetallada.
  ///
  /// In es, this message translates to:
  /// **'Escriba una descripción detallada del producto...'**
  String get escribeDescripcionDetallada;

  /// No description provided for @ingresaDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Ingresa una descripción'**
  String get ingresaDescripcion;

  /// No description provided for @publicarProducto.
  ///
  /// In es, this message translates to:
  /// **'Publicar Producto'**
  String get publicarProducto;

  /// No description provided for @compartaProductoComunidad.
  ///
  /// In es, this message translates to:
  /// **'Comparta su producto con la comunidad'**
  String get compartaProductoComunidad;

  /// No description provided for @anuncioCompletado.
  ///
  /// In es, this message translates to:
  /// **'✅ Anuncio completado. Publicando producto...'**
  String get anuncioCompletado;

  /// No description provided for @debesVerAnuncioParaPublicar.
  ///
  /// In es, this message translates to:
  /// **'❌ Debes ver el anuncio completo para publicar'**
  String get debesVerAnuncioParaPublicar;

  /// No description provided for @productoEnviadoRevision.
  ///
  /// In es, this message translates to:
  /// **'📝 Producto enviado para revisión. Recibirás notificación al aprobarse.'**
  String get productoEnviadoRevision;

  /// No description provided for @errorAlPublicar.
  ///
  /// In es, this message translates to:
  /// **'Error al publicar: {error}'**
  String errorAlPublicar(String error);

  /// No description provided for @paraPublicarNecesitasVerAnuncio.
  ///
  /// In es, this message translates to:
  /// **'Para publicar tu producto, necesitas ver un breve anuncio.'**
  String get paraPublicarNecesitasVerAnuncio;

  /// No description provided for @verAnuncio.
  ///
  /// In es, this message translates to:
  /// **'Ver anuncio'**
  String get verAnuncio;

  /// No description provided for @agregarImagenes.
  ///
  /// In es, this message translates to:
  /// **'Agregar imágenes'**
  String get agregarImagenes;

  /// No description provided for @imagenDestacada.
  ///
  /// In es, this message translates to:
  /// **'Imagen Destacada'**
  String get imagenDestacada;

  /// No description provided for @estaImagenApareceraPortada.
  ///
  /// In es, this message translates to:
  /// **'Esta imagen aparecerá en la portada del producto y en la sección de destacados.'**
  String get estaImagenApareceraPortada;

  /// No description provided for @soloImagenesCalidadEstudio.
  ///
  /// In es, this message translates to:
  /// **'Solo se aceptan imágenes con calidad de estudio fotográfico (buena iluminación, enfoque nítido, fondo limpio).'**
  String get soloImagenesCalidadEstudio;

  /// No description provided for @tocaParaSeleccionarImagen.
  ///
  /// In es, this message translates to:
  /// **'Toca para seleccionar una imagen'**
  String get tocaParaSeleccionarImagen;

  /// No description provided for @formatosImagenPermitidos.
  ///
  /// In es, this message translates to:
  /// **'JPG, PNG o WEBP · Máx. 10 MB'**
  String get formatosImagenPermitidos;

  /// No description provided for @enRevisionPuntos.
  ///
  /// In es, this message translates to:
  /// **'🔍 En revisión...'**
  String get enRevisionPuntos;

  /// No description provided for @enviadoARevision.
  ///
  /// In es, this message translates to:
  /// **'🔄 Enviado a revisión'**
  String get enviadoARevision;

  /// No description provided for @enviarARevision.
  ///
  /// In es, this message translates to:
  /// **'🛡️ Enviar a revisión'**
  String get enviarARevision;

  /// No description provided for @imagenRevisadaIA.
  ///
  /// In es, this message translates to:
  /// **'La imagen será revisada por IA. Recibirás una notificación cuando sea aprobada.'**
  String get imagenRevisadaIA;

  /// No description provided for @imagenesRealesProducto.
  ///
  /// In es, this message translates to:
  /// **'Imágenes Reales del Producto'**
  String get imagenesRealesProducto;

  /// No description provided for @subeHasta4Fotos.
  ///
  /// In es, this message translates to:
  /// **'Sube hasta 4 fotos reales del producto (obligatorio)'**
  String get subeHasta4Fotos;

  /// No description provided for @agregar.
  ///
  /// In es, this message translates to:
  /// **'Agregar'**
  String get agregar;

  /// No description provided for @maximo4ImagenesReales.
  ///
  /// In es, this message translates to:
  /// **'⚠️ Solo puedes subir máximo 4 imágenes reales'**
  String get maximo4ImagenesReales;

  /// No description provided for @escribeDescripcionMejorarImagen.
  ///
  /// In es, this message translates to:
  /// **'Escribe una descripción para mejorar la imagen'**
  String get escribeDescripcionMejorarImagen;

  /// No description provided for @primeroSeleccionaImagen.
  ///
  /// In es, this message translates to:
  /// **'Primero selecciona una imagen'**
  String get primeroSeleccionaImagen;

  /// No description provided for @imagenMejoradaCorrectamente.
  ///
  /// In es, this message translates to:
  /// **'✅ Imagen mejorada correctamente'**
  String get imagenMejoradaCorrectamente;

  /// No description provided for @errorGenerarImagen.
  ///
  /// In es, this message translates to:
  /// **'Error al generar imagen'**
  String get errorGenerarImagen;

  /// No description provided for @imagenEnviadaRevision.
  ///
  /// In es, this message translates to:
  /// **'🔄 Imagen enviada a revisión. Recibirás una notificación cuando sea aprobada.'**
  String get imagenEnviadaRevision;

  /// No description provided for @errorEnviarImagen.
  ///
  /// In es, this message translates to:
  /// **'Error al enviar imagen: {codigo}'**
  String errorEnviarImagen(String codigo);

  /// No description provided for @revisionDeImagen.
  ///
  /// In es, this message translates to:
  /// **'🛡️ Revisión de imagen'**
  String get revisionDeImagen;

  /// No description provided for @tuImagenSeraEnviadaModeracion.
  ///
  /// In es, this message translates to:
  /// **'Tu imagen será enviada a nuestro equipo de moderación para su revisión. Para continuar, necesitas ver un breve anuncio.'**
  String get tuImagenSeraEnviadaModeracion;

  /// No description provided for @revisionPuedeTomar24Horas.
  ///
  /// In es, this message translates to:
  /// **'La revisión puede tomar hasta 24 horas.'**
  String get revisionPuedeTomar24Horas;

  /// No description provided for @verAnuncioConEmoji.
  ///
  /// In es, this message translates to:
  /// **'Ver anuncio 🎬'**
  String get verAnuncioConEmoji;

  /// No description provided for @anuncioCompletadoEnviandoImagen.
  ///
  /// In es, this message translates to:
  /// **'✅ Anuncio completado. Enviando imagen a revisión...'**
  String get anuncioCompletadoEnviandoImagen;

  /// No description provided for @debesVerAnuncioParaEnviarImagen.
  ///
  /// In es, this message translates to:
  /// **'❌ Debes ver el anuncio completo para enviar la imagen'**
  String get debesVerAnuncioParaEnviarImagen;

  /// No description provided for @seleccionaAlMenos1Imagen.
  ///
  /// In es, this message translates to:
  /// **'Selecciona al menos 1 imagen real'**
  String get seleccionaAlMenos1Imagen;

  /// No description provided for @siguienteConFlecha.
  ///
  /// In es, this message translates to:
  /// **'Siguiente →'**
  String get siguienteConFlecha;

  /// No description provided for @recoleccionDeDatos.
  ///
  /// In es, this message translates to:
  /// **'Recolección de datos'**
  String get recoleccionDeDatos;

  /// No description provided for @tuPrivacidadImportante.
  ///
  /// In es, this message translates to:
  /// **'Tu privacidad es importante para nosotros. Puedes elegir si permites que tus datos de navegación y preferencias sean recolectados para recibir sugerencias de productos personalizados.'**
  String get tuPrivacidadImportante;

  /// No description provided for @aceptoRecoleccionDatos.
  ///
  /// In es, this message translates to:
  /// **'Acepto que mis datos de navegación y preferencias sean recolectados para recibir sugerencias de productos personalizados.'**
  String get aceptoRecoleccionDatos;

  /// No description provided for @guardarPreferencias.
  ///
  /// In es, this message translates to:
  /// **'Guardar preferencias'**
  String get guardarPreferencias;

  /// No description provided for @preferenciasGuardadas.
  ///
  /// In es, this message translates to:
  /// **'✅ Preferencias guardadas'**
  String get preferenciasGuardadas;

  /// No description provided for @errorAlGuardar.
  ///
  /// In es, this message translates to:
  /// **'Error al guardar'**
  String get errorAlGuardar;

  /// No description provided for @historialDePagos.
  ///
  /// In es, this message translates to:
  /// **'Historial de pagos'**
  String get historialDePagos;

  /// No description provided for @consultaTodosLosPagos.
  ///
  /// In es, this message translates to:
  /// **'Consultá todos los pagos que hiciste dentro de la app: impulsos de publicaciones, renovaciones, eliminación de publicidad y otros servicios.'**
  String get consultaTodosLosPagos;

  /// No description provided for @verHistorialDePagos.
  ///
  /// In es, this message translates to:
  /// **'Ver historial de pagos'**
  String get verHistorialDePagos;

  /// No description provided for @todosTusPagosTransacciones.
  ///
  /// In es, this message translates to:
  /// **'Todos tus pagos y transacciones'**
  String get todosTusPagosTransacciones;

  /// No description provided for @estadoDeCuenta.
  ///
  /// In es, this message translates to:
  /// **'Estado de cuenta'**
  String get estadoDeCuenta;

  /// No description provided for @revisaTusAdvertencias.
  ///
  /// In es, this message translates to:
  /// **'Revisá tus advertencias y suspensiones activas en la plataforma.'**
  String get revisaTusAdvertencias;

  /// No description provided for @advertencias.
  ///
  /// In es, this message translates to:
  /// **'Advertencias'**
  String get advertencias;

  /// No description provided for @suspensionesTemporales.
  ///
  /// In es, this message translates to:
  /// **'Suspensiones temporales'**
  String get suspensionesTemporales;

  /// No description provided for @asistenciaAEncuentros.
  ///
  /// In es, this message translates to:
  /// **'Asistencia a encuentros'**
  String get asistenciaAEncuentros;

  /// No description provided for @llegadasTardias.
  ///
  /// In es, this message translates to:
  /// **'Llegadas tardías'**
  String get llegadasTardias;

  /// No description provided for @noVerificaste5Min.
  ///
  /// In es, this message translates to:
  /// **'No verificaste a 5 min o menos. 3 = 1 advertencia'**
  String get noVerificaste5Min;

  /// No description provided for @ausencias.
  ///
  /// In es, this message translates to:
  /// **'Ausencias'**
  String get ausencias;

  /// No description provided for @noLlegasteEncuentro.
  ///
  /// In es, this message translates to:
  /// **'No llegaste al encuentro. 1 = 1 advertencia'**
  String get noLlegasteEncuentro;

  /// No description provided for @minutosTardeAcumulados.
  ///
  /// In es, this message translates to:
  /// **'⏱️ Minutos tarde acumulados: {cantidad}'**
  String minutosTardeAcumulados(int cantidad);

  /// No description provided for @informacion.
  ///
  /// In es, this message translates to:
  /// **'Información'**
  String get informacion;

  /// No description provided for @comoFunciona.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo funciona?'**
  String get comoFunciona;

  /// No description provided for @comoFuncionaEstadoCuenta.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta acumula advertencias y suspensiones temporales por incumplir las normas de la comunidad.\n\nAsistencia a encuentros:\n• 3 llegadas tardías (0/3) = 1 advertencia.\n• 1 ausencia = 1 advertencia.\n\nEscalado:\n• 3 advertencias = 1 suspensión temporal (7 días).\n• 3 suspensiones = baneo permanente.\n\nRecuperación:\n• Cada mes se descuentan 2 llegadas tardías.\n• Cada 3 meses se descuenta 1 advertencia.'**
  String get comoFuncionaEstadoCuenta;

  /// No description provided for @advertenciasInfo.
  ///
  /// In es, this message translates to:
  /// **'Advertencias (máx. 3): se generan por reportes leves como lenguaje inapropiado, publicaciones con información engañosa o incumplimiento menor de las reglas. No bloquean tu cuenta.'**
  String get advertenciasInfo;

  /// No description provided for @suspensionesInfo.
  ///
  /// In es, this message translates to:
  /// **'Suspensiones temporales (máx. 3): se aplican por faltas más graves como estafas, acoso, suplantación de identidad o reincidencia en advertencias. Cada suspensión bloquea tu cuenta por un período.'**
  String get suspensionesInfo;

  /// No description provided for @baneoInfo.
  ///
  /// In es, this message translates to:
  /// **'Si llegás a 3 suspensiones, tu cuenta será baneada de forma permanente y su correo no podrá volver a registrarse.'**
  String get baneoInfo;

  /// No description provided for @entendido.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get entendido;

  /// No description provided for @guardar.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get guardar;

  /// No description provided for @guardarCambios.
  ///
  /// In es, this message translates to:
  /// **'Guardar Cambios'**
  String get guardarCambios;

  /// No description provided for @nombreCompleto.
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get nombreCompleto;

  /// No description provided for @telefono.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get telefono;

  /// No description provided for @usuarioNoAutenticado.
  ///
  /// In es, this message translates to:
  /// **'Usuario no autenticado'**
  String get usuarioNoAutenticado;

  /// No description provided for @errorAlCargarDatos.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar datos'**
  String get errorAlCargarDatos;

  /// No description provided for @nombreNoPuedeEstarVacio.
  ///
  /// In es, this message translates to:
  /// **'El nombre no puede estar vacío'**
  String get nombreNoPuedeEstarVacio;

  /// No description provided for @perfilActualizadoCorrectamente.
  ///
  /// In es, this message translates to:
  /// **'✅ Perfil actualizado correctamente'**
  String get perfilActualizadoCorrectamente;

  /// No description provided for @errorAlGuardarEnServidor.
  ///
  /// In es, this message translates to:
  /// **'Error al guardar en el servidor'**
  String get errorAlGuardarEnServidor;

  /// No description provided for @volverAlPerfil.
  ///
  /// In es, this message translates to:
  /// **'Volver al perfil'**
  String get volverAlPerfil;

  /// No description provided for @chatShieldAccepted.
  ///
  /// In es, this message translates to:
  /// **'🛡️ Escudo aceptado'**
  String get chatShieldAccepted;

  /// No description provided for @chatShieldRejected.
  ///
  /// In es, this message translates to:
  /// **'🚫 Escudo rechazado. El chat quedó cerrado.'**
  String get chatShieldRejected;

  /// No description provided for @chatRatingSent.
  ///
  /// In es, this message translates to:
  /// **'¡Calificación enviada! Gracias por tu opinión.'**
  String get chatRatingSent;

  /// No description provided for @chatMessageBlocked.
  ///
  /// In es, this message translates to:
  /// **'Mensaje bloqueado'**
  String get chatMessageBlocked;

  /// No description provided for @chatPhoneBlocked.
  ///
  /// In es, this message translates to:
  /// **'El Escudo de Seguridad bloqueó este mensaje.\n\nMotivo: No se permiten números de teléfono.'**
  String get chatPhoneBlocked;

  /// No description provided for @chatUnderstood.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get chatUnderstood;

  /// No description provided for @chatMeetingNotHeld.
  ///
  /// In es, this message translates to:
  /// **'El encuentro no se realizó. Eliminá este chat y volvé a abrirlo para seguir conversando.'**
  String get chatMeetingNotHeld;

  /// No description provided for @chatGallery.
  ///
  /// In es, this message translates to:
  /// **'Galería'**
  String get chatGallery;

  /// No description provided for @chatCamera.
  ///
  /// In es, this message translates to:
  /// **'Cámara'**
  String get chatCamera;

  /// No description provided for @chatShareLocation.
  ///
  /// In es, this message translates to:
  /// **'Compartir ubicación'**
  String get chatShareLocation;

  /// No description provided for @chatSharePortfolio.
  ///
  /// In es, this message translates to:
  /// **'Compartir portafolio'**
  String get chatSharePortfolio;

  /// No description provided for @chatEnableGps.
  ///
  /// In es, this message translates to:
  /// **'Activa el GPS del teléfono para compartir tu ubicación'**
  String get chatEnableGps;

  /// No description provided for @chatLocationPermission.
  ///
  /// In es, this message translates to:
  /// **'Se necesita permiso de ubicación'**
  String get chatLocationPermission;

  /// No description provided for @chatGettingLocation.
  ///
  /// In es, this message translates to:
  /// **'📍 Obteniendo tu ubicación...'**
  String get chatGettingLocation;

  /// No description provided for @chatCannotOpenApp.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir la aplicación'**
  String get chatCannotOpenApp;

  /// No description provided for @chatOpenLocationWith.
  ///
  /// In es, this message translates to:
  /// **'Abrir ubicación con...'**
  String get chatOpenLocationWith;

  /// No description provided for @chatPortfolioShared.
  ///
  /// In es, this message translates to:
  /// **'📤 Portafolio compartido'**
  String get chatPortfolioShared;

  /// No description provided for @chatDontShowAgain.
  ///
  /// In es, this message translates to:
  /// **'No volver a mostrar'**
  String get chatDontShowAgain;

  /// No description provided for @chatCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get chatCancel;

  /// No description provided for @chatContinue.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get chatContinue;

  /// No description provided for @chatOtherUser.
  ///
  /// In es, this message translates to:
  /// **'El otro usuario'**
  String get chatOtherUser;

  /// No description provided for @chatGenericError.
  ///
  /// In es, this message translates to:
  /// **'Error: {error}'**
  String chatGenericError(String error);

  /// No description provided for @chatLocationSendError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo enviar la ubicación ({statusCode})'**
  String chatLocationSendError(String statusCode);

  /// No description provided for @chatLocationGetError.
  ///
  /// In es, this message translates to:
  /// **'Error al obtener la ubicación: {error}'**
  String chatLocationGetError(String error);

  /// No description provided for @chatImageSendError.
  ///
  /// In es, this message translates to:
  /// **'Error al enviar imagen: {error}'**
  String chatImageSendError(String error);

  /// No description provided for @chatAudioPermissionRequired.
  ///
  /// In es, this message translates to:
  /// **'Se necesita permiso para grabar audio'**
  String get chatAudioPermissionRequired;

  /// No description provided for @chatRecordingTapToStop.
  ///
  /// In es, this message translates to:
  /// **'🎤 Grabando... toca de nuevo para detener'**
  String get chatRecordingTapToStop;

  /// No description provided for @chatRecordingError.
  ///
  /// In es, this message translates to:
  /// **'Error al grabar: {error}'**
  String chatRecordingError(String error);

  /// No description provided for @chatVerifyingAudio.
  ///
  /// In es, this message translates to:
  /// **'🛡️ Verificando audio...'**
  String get chatVerifyingAudio;

  /// No description provided for @chatAudioSent.
  ///
  /// In es, this message translates to:
  /// **'🎤 Audio enviado'**
  String get chatAudioSent;

  /// No description provided for @chatAudioSendError.
  ///
  /// In es, this message translates to:
  /// **'Error al enviar audio: {error}'**
  String chatAudioSendError(String error);

  /// No description provided for @chatRecordingLimitReached.
  ///
  /// In es, this message translates to:
  /// **'⏱️ Límite de 25 segundos alcanzado'**
  String get chatRecordingLimitReached;

  /// No description provided for @chatRecordingCancelled.
  ///
  /// In es, this message translates to:
  /// **'🗑️ Grabación cancelada'**
  String get chatRecordingCancelled;

  /// No description provided for @chatSendingAudio.
  ///
  /// In es, this message translates to:
  /// **'📤 Enviando audio...'**
  String get chatSendingAudio;

  /// No description provided for @chatStopRecordingError.
  ///
  /// In es, this message translates to:
  /// **'Error al detener grabación: {error}'**
  String chatStopRecordingError(String error);

  /// No description provided for @chatAudioPlaybackError.
  ///
  /// In es, this message translates to:
  /// **'Error al reproducir audio: {error}'**
  String chatAudioPlaybackError(String error);

  /// No description provided for @chatSellerBlocked.
  ///
  /// In es, this message translates to:
  /// **'Vendedor bloqueado correctamente'**
  String get chatSellerBlocked;

  /// No description provided for @chatSellerBlockError.
  ///
  /// In es, this message translates to:
  /// **'Error al bloquear'**
  String get chatSellerBlockError;

  /// No description provided for @chatSellerUnblocked.
  ///
  /// In es, this message translates to:
  /// **'Vendedor desbloqueado correctamente'**
  String get chatSellerUnblocked;

  /// No description provided for @chatSellerUnblockError.
  ///
  /// In es, this message translates to:
  /// **'Error al desbloquear'**
  String get chatSellerUnblockError;

  /// No description provided for @chatReportSeller.
  ///
  /// In es, this message translates to:
  /// **'Denunciar vendedor'**
  String get chatReportSeller;

  /// No description provided for @chatReport.
  ///
  /// In es, this message translates to:
  /// **'Denunciar'**
  String get chatReport;

  /// No description provided for @chatReportLoginRequired.
  ///
  /// In es, this message translates to:
  /// **'Debes iniciar sesión para denunciar'**
  String get chatReportLoginRequired;

  /// No description provided for @chatReportSent.
  ///
  /// In es, this message translates to:
  /// **'Denuncia enviada. Será revisada por moderación.'**
  String get chatReportSent;

  /// No description provided for @chatReportSendError.
  ///
  /// In es, this message translates to:
  /// **'Error al enviar denuncia: {error}'**
  String chatReportSendError(String error);

  /// No description provided for @chatInternetSearchComingSoon.
  ///
  /// In es, this message translates to:
  /// **'La función \"Buscar en internet\" está en desarrollo'**
  String get chatInternetSearchComingSoon;

  /// No description provided for @chatSelectText.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar texto'**
  String get chatSelectText;

  /// No description provided for @chatSelectTextToCopy.
  ///
  /// In es, this message translates to:
  /// **'Selecciona el texto que quieres copiar:'**
  String get chatSelectTextToCopy;

  /// No description provided for @chatClose.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get chatClose;

  /// No description provided for @chatAccept.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get chatAccept;

  /// No description provided for @chatReject.
  ///
  /// In es, this message translates to:
  /// **'Rechazar'**
  String get chatReject;

  /// No description provided for @chatConfirmMeetingQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Confirmar encuentro?'**
  String get chatConfirmMeetingQuestion;

  /// No description provided for @chatConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get chatConfirm;

  /// No description provided for @chatMeetingConfirmed.
  ///
  /// In es, this message translates to:
  /// **'Encuentro confirmado'**
  String get chatMeetingConfirmed;

  /// No description provided for @chatMeetingNotFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontró el encuentro agendado'**
  String get chatMeetingNotFound;

  /// No description provided for @chatMeetingCancelledReopened.
  ///
  /// In es, this message translates to:
  /// **'Encuentro cancelado. El chat volvió a abrirse.'**
  String get chatMeetingCancelledReopened;

  /// No description provided for @chatCannotCancelMeeting.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cancelar'**
  String get chatCannotCancelMeeting;

  /// No description provided for @chatRecordingNotActive.
  ///
  /// In es, this message translates to:
  /// **'La grabación no está activa'**
  String get chatRecordingNotActive;

  /// No description provided for @chatRecordingStopped.
  ///
  /// In es, this message translates to:
  /// **'Grabación detenida'**
  String get chatRecordingStopped;

  /// No description provided for @chatWriteMessage.
  ///
  /// In es, this message translates to:
  /// **'Escribe un mensaje...'**
  String get chatWriteMessage;

  /// No description provided for @chatSellerBlockException.
  ///
  /// In es, this message translates to:
  /// **'Error al bloquear: {error}'**
  String chatSellerBlockException(String error);

  /// No description provided for @chatSellerUnblockException.
  ///
  /// In es, this message translates to:
  /// **'Error al desbloquear: {error}'**
  String chatSellerUnblockException(String error);

  /// No description provided for @chatSelectReportReason.
  ///
  /// In es, this message translates to:
  /// **'Selecciona el motivo de la denuncia:'**
  String get chatSelectReportReason;

  /// No description provided for @chatReportModerationNotice.
  ///
  /// In es, this message translates to:
  /// **'Esta denuncia será revisada por nuestro equipo de moderación.'**
  String get chatReportModerationNotice;

  /// No description provided for @chatSellerOptions.
  ///
  /// In es, this message translates to:
  /// **'Opciones del Vendedor'**
  String get chatSellerOptions;

  /// No description provided for @chatUnblock.
  ///
  /// In es, this message translates to:
  /// **'Desbloquear'**
  String get chatUnblock;

  /// No description provided for @chatBlock.
  ///
  /// In es, this message translates to:
  /// **'Bloquear'**
  String get chatBlock;

  /// No description provided for @chatUnblockUser.
  ///
  /// In es, this message translates to:
  /// **'Desbloquear a {userName}'**
  String chatUnblockUser(String userName);

  /// No description provided for @chatBlockUser.
  ///
  /// In es, this message translates to:
  /// **'Bloquear a {userName}'**
  String chatBlockUser(String userName);

  /// No description provided for @chatViewProfileInfo.
  ///
  /// In es, this message translates to:
  /// **'Ver información de perfil'**
  String get chatViewProfileInfo;

  /// No description provided for @chatViewUserDetails.
  ///
  /// In es, this message translates to:
  /// **'Ver detalles de {userName}'**
  String chatViewUserDetails(String userName);

  /// No description provided for @chatViewPortfolio.
  ///
  /// In es, this message translates to:
  /// **'Ver Portafolio'**
  String get chatViewPortfolio;

  /// No description provided for @chatViewUserProducts.
  ///
  /// In es, this message translates to:
  /// **'Ver todos los productos de {userName}'**
  String chatViewUserProducts(String userName);

  /// No description provided for @chatReportUserRules.
  ///
  /// In es, this message translates to:
  /// **'Reportar a {userName} por incumplir las reglas'**
  String chatReportUserRules(String userName);

  /// No description provided for @chatStrikeMessage.
  ///
  /// In es, this message translates to:
  /// **'Tachar mensaje'**
  String get chatStrikeMessage;

  /// No description provided for @chatStrikeMessageDescription.
  ///
  /// In es, this message translates to:
  /// **'Tachar este mensaje para indicar que está resuelto'**
  String get chatStrikeMessageDescription;

  /// No description provided for @chatMessageStruck.
  ///
  /// In es, this message translates to:
  /// **'Mensaje tachado'**
  String get chatMessageStruck;

  /// No description provided for @chatStrikeRemoved.
  ///
  /// In es, this message translates to:
  /// **'Tachado eliminado'**
  String get chatStrikeRemoved;

  /// No description provided for @chatSearchInternet.
  ///
  /// In es, this message translates to:
  /// **'Buscar en internet'**
  String get chatSearchInternet;

  /// No description provided for @chatSearchMessageGoogle.
  ///
  /// In es, this message translates to:
  /// **'Buscar este mensaje en Google'**
  String get chatSearchMessageGoogle;

  /// No description provided for @chatOnline.
  ///
  /// In es, this message translates to:
  /// **'en línea'**
  String get chatOnline;

  /// No description provided for @chatLastSeen.
  ///
  /// In es, this message translates to:
  /// **'última vez'**
  String get chatLastSeen;

  /// No description provided for @chatLastSeenToday.
  ///
  /// In es, this message translates to:
  /// **'última vez hoy'**
  String get chatLastSeenToday;

  /// No description provided for @chatLastSeenYesterday.
  ///
  /// In es, this message translates to:
  /// **'última vez ayer'**
  String get chatLastSeenYesterday;

  /// No description provided for @chatLastSeenOn.
  ///
  /// In es, this message translates to:
  /// **'última vez el {date}'**
  String chatLastSeenOn(String date);

  /// No description provided for @chatPortfolioSharedByYou.
  ///
  /// In es, this message translates to:
  /// **'Compartiste tu portafolio'**
  String get chatPortfolioSharedByYou;

  /// No description provided for @chatPortfolioOfUser.
  ///
  /// In es, this message translates to:
  /// **'Portafolio de {userName}'**
  String chatPortfolioOfUser(String userName);

  /// No description provided for @chatTapToViewProducts.
  ///
  /// In es, this message translates to:
  /// **'Toca para ver los productos'**
  String get chatTapToViewProducts;

  /// No description provided for @chatView.
  ///
  /// In es, this message translates to:
  /// **'Ver'**
  String get chatView;

  /// No description provided for @chatYou.
  ///
  /// In es, this message translates to:
  /// **'Tú'**
  String get chatYou;

  /// No description provided for @chatShieldAudioTitle.
  ///
  /// In es, this message translates to:
  /// **'Audios con el Escudo'**
  String get chatShieldAudioTitle;

  /// No description provided for @chatShieldImageTitle.
  ///
  /// In es, this message translates to:
  /// **'Imágenes con el Escudo'**
  String get chatShieldImageTitle;

  /// No description provided for @chatShieldAudioInstructions.
  ///
  /// In es, this message translates to:
  /// **'• Solo puedes grabar 25 segundos.\n• El audio se revisa con IA: debe hablar únicamente de \"{productName}\".\n• No se permiten teléfonos, redes sociales, pagos fuera de la app, insultos ni otros temas.\n\nCuando cierres esta ventana, mantén presionado el micrófono para grabar.'**
  String chatShieldAudioInstructions(String productName);

  /// No description provided for @chatShieldImageInstructions.
  ///
  /// In es, this message translates to:
  /// **'• Solo puedes enviar 1 imagen en este chat.\n• La imagen se revisa con IA: debe mostrar el producto \"{productName}\".\n• No se permiten teléfonos, QR, redes sociales, pagos fuera de la app, contenido sexual, violento u ofensivo.'**
  String chatShieldImageInstructions(String productName);

  /// No description provided for @chatImageLimitTitle.
  ///
  /// In es, this message translates to:
  /// **'Límite de imágenes'**
  String get chatImageLimitTitle;

  /// No description provided for @chatImageLimitBody.
  ///
  /// In es, this message translates to:
  /// **'Con el Escudo activo solo puedes enviar 1 imagen en este chat.'**
  String get chatImageLimitBody;

  /// No description provided for @chatCropImage.
  ///
  /// In es, this message translates to:
  /// **'Recortar imagen'**
  String get chatCropImage;

  /// No description provided for @chatDone.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get chatDone;

  /// No description provided for @chatImageRejected.
  ///
  /// In es, this message translates to:
  /// **'Imagen rechazada'**
  String get chatImageRejected;

  /// No description provided for @chatAudioRejected.
  ///
  /// In es, this message translates to:
  /// **'Audio rechazado'**
  String get chatAudioRejected;

  /// No description provided for @chatStatusNeutral.
  ///
  /// In es, this message translates to:
  /// **'Estado Neutral'**
  String get chatStatusNeutral;

  /// No description provided for @chatNeutralDescription.
  ///
  /// In es, this message translates to:
  /// **'La conversación está en curso. Aún no hay suficiente información para determinar el estado de la transacción.'**
  String get chatNeutralDescription;

  /// No description provided for @chatNeutralRecommendation.
  ///
  /// In es, this message translates to:
  /// **'Continúa conversando de forma respetuosa y clara.'**
  String get chatNeutralRecommendation;

  /// No description provided for @chatStatusHealthy.
  ///
  /// In es, this message translates to:
  /// **'Conversación Saludable'**
  String get chatStatusHealthy;

  /// No description provided for @chatHealthyDescription.
  ///
  /// In es, this message translates to:
  /// **'La conversación fluye de manera positiva. Ambos usuarios se están comunicando de forma respetuosa y clara.'**
  String get chatHealthyDescription;

  /// No description provided for @chatHealthyRecommendation.
  ///
  /// In es, this message translates to:
  /// **'¡Sigue así! La transacción tiene buenas probabilidades de éxito.'**
  String get chatHealthyRecommendation;

  /// No description provided for @chatStatusWarning.
  ///
  /// In es, this message translates to:
  /// **'Precaución Recomendada'**
  String get chatStatusWarning;

  /// No description provided for @chatWarningDescription.
  ///
  /// In es, this message translates to:
  /// **'Se han detectado algunos signos de alerta en la conversación. Podría haber malentendidos o tensión.'**
  String get chatWarningDescription;

  /// No description provided for @chatWarningRecommendation.
  ///
  /// In es, this message translates to:
  /// **'Revisa los mensajes anteriores. Intenta ser más claro y empático en tus respuestas.'**
  String get chatWarningRecommendation;

  /// No description provided for @chatStatusDanger.
  ///
  /// In es, this message translates to:
  /// **'Peligro Inminente'**
  String get chatStatusDanger;

  /// No description provided for @chatDangerDescription.
  ///
  /// In es, this message translates to:
  /// **'La conversación muestra signos de conflicto o riesgo. Podría haber mala comunicación o desacuerdos serios.'**
  String get chatDangerDescription;

  /// No description provided for @chatDangerRecommendation.
  ///
  /// In es, this message translates to:
  /// **'Detente y evalúa la situación. Considera contactar a soporte si es necesario.'**
  String get chatDangerRecommendation;

  /// No description provided for @chatCancelMeetingQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Cancelar el encuentro?'**
  String get chatCancelMeetingQuestion;

  /// No description provided for @chatRecordingRejectionWarning.
  ///
  /// In es, this message translates to:
  /// **'Si rechazás la grabación de voz por seguridad, el encuentro se cancela para AMBOS usuarios y el chat queda cerrado.\n\nEsta acción no se puede deshacer.'**
  String get chatRecordingRejectionWarning;

  /// No description provided for @chatGoBack.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get chatGoBack;

  /// No description provided for @chatYesCancelMeeting.
  ///
  /// In es, this message translates to:
  /// **'Sí, cancelar el encuentro'**
  String get chatYesCancelMeeting;

  /// No description provided for @chatSecurityVoiceRecording.
  ///
  /// In es, this message translates to:
  /// **'Grabación de voz por seguridad'**
  String get chatSecurityVoiceRecording;

  /// No description provided for @chatSecurityRecordingConsentBody.
  ///
  /// In es, this message translates to:
  /// **'A partir de este momento, la app GRABARÁ el audio que se emita en esta conversación desde AMBOS dispositivos, con el único fin de proteger a los usuarios.\n\n• Los fragmentos de audio se guardan cada 10 segundos.\n• Esa grabación puede ser compartida con un tercero (autoridad o perito de seguridad) si hay una denuncia o incidente.\n• Nadie más puede escuchar los audios sin tu permiso o una orden legal.\n\n⚠️ IMPORTANTE: La grabación por seguridad es OBLIGATORIA para poder realizar el encuentro.\n\nSi RECHAZÁS la grabación, el encuentro se CANCELA automáticamente para ambos usuarios y el chat queda cerrado. No se podrá continuar con el encuentro presencial a través de la app.'**
  String get chatSecurityRecordingConsentBody;

  /// No description provided for @chatRejectAndCancel.
  ///
  /// In es, this message translates to:
  /// **'Rechazar y cancelar'**
  String get chatRejectAndCancel;

  /// No description provided for @chatAcceptAndContinue.
  ///
  /// In es, this message translates to:
  /// **'Aceptar y continuar'**
  String get chatAcceptAndContinue;

  /// No description provided for @chatProposeMeeting.
  ///
  /// In es, this message translates to:
  /// **'Proponer encuentro'**
  String get chatProposeMeeting;

  /// No description provided for @chatChooseSafePlace.
  ///
  /// In es, this message translates to:
  /// **'Elegí un lugar seguro de la lista.'**
  String get chatChooseSafePlace;

  /// No description provided for @chatProposalNumber.
  ///
  /// In es, this message translates to:
  /// **'Propuesta {number} de 3'**
  String chatProposalNumber(int number);

  /// No description provided for @chatChoosePlaceOnMap.
  ///
  /// In es, this message translates to:
  /// **'Elegir lugar en el mapa'**
  String get chatChoosePlaceOnMap;

  /// No description provided for @chatPlaceSelected.
  ///
  /// In es, this message translates to:
  /// **'Lugar seleccionado'**
  String get chatPlaceSelected;

  /// No description provided for @chatTapToOpenMap.
  ///
  /// In es, this message translates to:
  /// **'Tocá para abrir el mapa'**
  String get chatTapToOpenMap;

  /// No description provided for @chatChooseTime.
  ///
  /// In es, this message translates to:
  /// **'Elegí una hora (7:00 AM – 6:00 PM)'**
  String get chatChooseTime;

  /// No description provided for @chatSelectDateTime.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar fecha y hora'**
  String get chatSelectDateTime;

  /// No description provided for @chatSelectPlaceAndDate.
  ///
  /// In es, this message translates to:
  /// **'⚠️ Elegí un lugar en el mapa y una fecha'**
  String get chatSelectPlaceAndDate;

  /// No description provided for @chatTimeSlotOccupiedChooseAnother.
  ///
  /// In es, this message translates to:
  /// **'⛔ Ese día y hora ya está ocupado. Elegí otro horario.'**
  String get chatTimeSlotOccupiedChooseAnother;

  /// No description provided for @chatAddProposal.
  ///
  /// In es, this message translates to:
  /// **'Agregar propuesta'**
  String get chatAddProposal;

  /// No description provided for @chatAddAndViewSummary.
  ///
  /// In es, this message translates to:
  /// **'Agregar y ver resumen'**
  String get chatAddAndViewSummary;

  /// No description provided for @chatViewSummaryCount.
  ///
  /// In es, this message translates to:
  /// **'Ver resumen ({count})'**
  String chatViewSummaryCount(int count);

  /// No description provided for @chatProposalsSummary.
  ///
  /// In es, this message translates to:
  /// **'Resumen de propuestas'**
  String get chatProposalsSummary;

  /// No description provided for @chatProposalsAddedCount.
  ///
  /// In es, this message translates to:
  /// **'{count} de 3 propuestas agregadas'**
  String chatProposalsAddedCount(int count);

  /// No description provided for @chatMaxThreeProposals.
  ///
  /// In es, this message translates to:
  /// **'Máximo 3 propuestas'**
  String get chatMaxThreeProposals;

  /// No description provided for @chatAddAnotherProposal.
  ///
  /// In es, this message translates to:
  /// **'Agregar otra propuesta'**
  String get chatAddAnotherProposal;

  /// No description provided for @chatProposalCancelled.
  ///
  /// In es, this message translates to:
  /// **'ANULADA'**
  String get chatProposalCancelled;

  /// No description provided for @chatProposalAccepted.
  ///
  /// In es, this message translates to:
  /// **'ACEPTADA'**
  String get chatProposalAccepted;

  /// No description provided for @chatProposalPending.
  ///
  /// In es, this message translates to:
  /// **'PENDIENTE'**
  String get chatProposalPending;

  /// No description provided for @chatMeetingDetails.
  ///
  /// In es, this message translates to:
  /// **'Detalle del encuentro'**
  String get chatMeetingDetails;

  /// No description provided for @chatDistrict.
  ///
  /// In es, this message translates to:
  /// **'Distrito'**
  String get chatDistrict;

  /// No description provided for @chatPlace.
  ///
  /// In es, this message translates to:
  /// **'Lugar'**
  String get chatPlace;

  /// No description provided for @chatDateAndTime.
  ///
  /// In es, this message translates to:
  /// **'Fecha y hora'**
  String get chatDateAndTime;

  /// No description provided for @chatMeetingStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get chatMeetingStatus;

  /// No description provided for @chatAcceptProposalQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Aceptas esta propuesta?'**
  String get chatAcceptProposalQuestion;

  /// No description provided for @chatWaitingOtherResponse.
  ///
  /// In es, this message translates to:
  /// **'Esperando respuesta del otro usuario...'**
  String get chatWaitingOtherResponse;

  /// No description provided for @chatMeetingConfirmationNotice.
  ///
  /// In es, this message translates to:
  /// **'Una vez confirmado, no podrán escribir por chat hasta que se vean en persona.\n\n• No llegues tarde\n• Se pedirá reconocimiento facial\n• Se activará el GPS el día del encuentro'**
  String get chatMeetingConfirmationNotice;

  /// No description provided for @chatCancelDealQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Cancelar el trato?'**
  String get chatCancelDealQuestion;

  /// No description provided for @chatMeetingLabel.
  ///
  /// In es, this message translates to:
  /// **'ENCUENTRO'**
  String get chatMeetingLabel;

  /// No description provided for @chatCancellationRule.
  ///
  /// In es, this message translates to:
  /// **'Regla de cancelación'**
  String get chatCancellationRule;

  /// No description provided for @chatCancellationNotification.
  ///
  /// In es, this message translates to:
  /// **'Al cancelar, el encuentro se anula para los dos y el chat vuelve a abrirse. El otro usuario recibirá una notificación.'**
  String get chatCancellationNotification;

  /// No description provided for @chatOtherConfirmedCannotCancel.
  ///
  /// In es, this message translates to:
  /// **'El otro usuario confirmó asistencia. Ya no podés cancelar este encuentro.'**
  String get chatOtherConfirmedCannotCancel;

  /// No description provided for @chatCannotCancelWithinHour.
  ///
  /// In es, this message translates to:
  /// **'Ya no podés cancelar este encuentro porque falta menos de 1 hora. Deben presentarse en el lugar acordado.'**
  String get chatCannotCancelWithinHour;

  /// No description provided for @chatBothConfirmedCannotCancel.
  ///
  /// In es, this message translates to:
  /// **'Ambos ya confirmaron asistencia. El encuentro no se puede cancelar.'**
  String get chatBothConfirmedCannotCancel;

  /// No description provided for @chatOnlyOtherCanCancel.
  ///
  /// In es, this message translates to:
  /// **'El otro usuario confirmó asistencia. Solo él puede cancelar hasta 10 minutos antes.'**
  String get chatOnlyOtherCanCancel;

  /// No description provided for @chatYouCanCancelUntilTenMinutes.
  ///
  /// In es, this message translates to:
  /// **'Confirmaste asistencia. Podés cancelar hasta 10 minutos antes del encuentro.'**
  String get chatYouCanCancelUntilTenMinutes;

  /// No description provided for @chatCancellationDeadlineRule.
  ///
  /// In es, this message translates to:
  /// **'Solo podés cancelar el trato hasta 1 hora antes del encuentro. Si falta menos de 1 hora, ya no se permite cancelar y deben presentarse en el lugar acordado.'**
  String get chatCancellationDeadlineRule;

  /// No description provided for @chatBack.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get chatBack;

  /// No description provided for @chatYesCancel.
  ///
  /// In es, this message translates to:
  /// **'Sí, cancelar'**
  String get chatYesCancel;

  /// No description provided for @chatMeetingCancelError.
  ///
  /// In es, this message translates to:
  /// **'Error: {error}'**
  String chatMeetingCancelError(String error);

  /// No description provided for @chatDealClosedTitle.
  ///
  /// In es, this message translates to:
  /// **'🤝 Trato cerrado'**
  String get chatDealClosedTitle;

  /// No description provided for @chatDealClosedDescription.
  ///
  /// In es, this message translates to:
  /// **'El chat quedó bloqueado. Nos vemos en el encuentro.'**
  String get chatDealClosedDescription;

  /// No description provided for @chatViewChatMessages.
  ///
  /// In es, this message translates to:
  /// **'Ver mensajes del chat'**
  String get chatViewChatMessages;

  /// No description provided for @chatReviewAlertsStep.
  ///
  /// In es, this message translates to:
  /// **'1. Revisá tus alertas'**
  String get chatReviewAlertsStep;

  /// No description provided for @chatReviewAlertsDescription.
  ///
  /// In es, this message translates to:
  /// **'Entrá a la sección de Alertas para ver la fecha, hora y lugar del encuentro confirmado.'**
  String get chatReviewAlertsDescription;

  /// No description provided for @chatFacialRecognitionStep.
  ///
  /// In es, this message translates to:
  /// **'2. Reconocimiento facial'**
  String get chatFacialRecognitionStep;

  /// No description provided for @chatFacialRecognitionStepDescription.
  ///
  /// In es, this message translates to:
  /// **'El día del encuentro, la app te va a pedir una selfie para verificar tu identidad antes de salir.'**
  String get chatFacialRecognitionStepDescription;

  /// No description provided for @chatEnableGpsStep.
  ///
  /// In es, this message translates to:
  /// **'3. Activá el GPS'**
  String get chatEnableGpsStep;

  /// No description provided for @chatEnableGpsStepDescription.
  ///
  /// In es, this message translates to:
  /// **'Al llegar al lugar, activá la ubicación. La app confirma que estás en el punto seguro.'**
  String get chatEnableGpsStepDescription;

  /// No description provided for @chatUnlockChatStep.
  ///
  /// In es, this message translates to:
  /// **'4. Se desbloquea el chat'**
  String get chatUnlockChatStep;

  /// No description provided for @chatUnlockChatStepDescription.
  ///
  /// In es, this message translates to:
  /// **'Cuando ambos estén presentes y verificados, el chat vuelve a abrirse.'**
  String get chatUnlockChatStepDescription;

  /// No description provided for @chatArriveEarlyWarning.
  ///
  /// In es, this message translates to:
  /// **'Llegá 10 minutos antes. Si no llegás, el encuentro se marca como \"no presentado\" y el chat queda cerrado.'**
  String get chatArriveEarlyWarning;

  /// No description provided for @chatShieldAlreadyActive.
  ///
  /// In es, this message translates to:
  /// **'🛡️ El Escudo ya está activo y no se puede desactivar'**
  String get chatShieldAlreadyActive;

  /// No description provided for @chatShieldAnalyzingMessages.
  ///
  /// In es, this message translates to:
  /// **'🛡️ Escudo activado. Analizando mensajes...'**
  String get chatShieldAnalyzingMessages;

  /// No description provided for @chatActivateShieldToViewAnalysis.
  ///
  /// In es, this message translates to:
  /// **'🛡️ Activa el Escudo para ver el análisis de la conversación'**
  String get chatActivateShieldToViewAnalysis;

  /// No description provided for @chatDealInfo.
  ///
  /// In es, this message translates to:
  /// **'Info del trato'**
  String get chatDealInfo;

  /// No description provided for @chatProposePlaceBeforeClosingDeal.
  ///
  /// In es, this message translates to:
  /// **'📍 Primero proponé un lugar y una fecha para el encuentro.\nCuando el otro acepte, vas a poder cerrar el trato.'**
  String get chatProposePlaceBeforeClosingDeal;

  /// No description provided for @chatDealClosedWaitingMeeting.
  ///
  /// In es, this message translates to:
  /// **'✅ Trato cerrado. Esperando el encuentro.'**
  String get chatDealClosedWaitingMeeting;

  /// No description provided for @chatWaitingDealConfirmation.
  ///
  /// In es, this message translates to:
  /// **'⏳ Esperando que el otro usuario confirme...'**
  String get chatWaitingDealConfirmation;

  /// No description provided for @chatConfirmDeal.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get chatConfirmDeal;

  /// No description provided for @chatMoreQuestions.
  ///
  /// In es, this message translates to:
  /// **'Tengo más preguntas'**
  String get chatMoreQuestions;

  /// No description provided for @chatNoMessagesYet.
  ///
  /// In es, this message translates to:
  /// **'No hay mensajes aún'**
  String get chatNoMessagesYet;

  /// No description provided for @chatItemSold.
  ///
  /// In es, this message translates to:
  /// **'ARTÍCULO VENDIDO'**
  String get chatItemSold;

  /// No description provided for @chatMeetingHasBeenAccepted.
  ///
  /// In es, this message translates to:
  /// **'El encuentro ha sido aceptado'**
  String get chatMeetingHasBeenAccepted;

  /// No description provided for @chatDealClosedBothConfirmed.
  ///
  /// In es, this message translates to:
  /// **'✅ Trato cerrado. Ambos confirmaron. ¡Nos vemos el día del encuentro!'**
  String get chatDealClosedBothConfirmed;

  /// No description provided for @chatBothContinueTalking.
  ///
  /// In es, this message translates to:
  /// **'✅ Ambos decidieron seguir conversando'**
  String get chatBothContinueTalking;

  /// No description provided for @chatUserWantsToContinueTalking.
  ///
  /// In es, this message translates to:
  /// **'El usuario quiere seguir conversando'**
  String get chatUserWantsToContinueTalking;

  /// No description provided for @chatRatingThankYou.
  ///
  /// In es, this message translates to:
  /// **'✅ Has calificado. ¡Gracias por tu opinión!'**
  String get chatRatingThankYou;

  /// No description provided for @chatRatingVisibleAfterWeek.
  ///
  /// In es, this message translates to:
  /// **'Tu calificación se reflejará en el perfil de {userName} una semana después de enviarla.'**
  String chatRatingVisibleAfterWeek(String userName);

  /// No description provided for @chatYouSharedLocation.
  ///
  /// In es, this message translates to:
  /// **'Compartiste tu ubicación'**
  String get chatYouSharedLocation;

  /// No description provided for @chatLocationShared.
  ///
  /// In es, this message translates to:
  /// **'Ubicación compartida'**
  String get chatLocationShared;

  /// No description provided for @chatTapToOpenMaps.
  ///
  /// In es, this message translates to:
  /// **'Toca para abrir en mapas'**
  String get chatTapToOpenMaps;

  /// No description provided for @chatMeetingCouldNotTakePlace.
  ///
  /// In es, this message translates to:
  /// **'El encuentro no se pudo realizar'**
  String get chatMeetingCouldNotTakePlace;

  /// No description provided for @chatMeetingCancelledChatReopened.
  ///
  /// In es, this message translates to:
  /// **'❌ El encuentro fue cancelado. El chat volvió a abrirse.'**
  String get chatMeetingCancelledChatReopened;

  /// No description provided for @chatConfirmedDealWaitingResponse.
  ///
  /// In es, this message translates to:
  /// **'⏳ Confirmaste cerrar el trato. Esperando la respuesta del otro usuario...'**
  String get chatConfirmedDealWaitingResponse;

  /// No description provided for @chatWaitingOtherDecision.
  ///
  /// In es, this message translates to:
  /// **'⏳ Esperando que el otro usuario decida...'**
  String get chatWaitingOtherDecision;

  /// No description provided for @chatMeetingProposalPendingWrite.
  ///
  /// In es, this message translates to:
  /// **'Propuesta de encuentro pendiente. Esperá a que se resuelva para escribir.'**
  String get chatMeetingProposalPendingWrite;

  /// No description provided for @chatRecordingSlideToCancel.
  ///
  /// In es, this message translates to:
  /// **'🎤 Grabando... desliza para cancelar'**
  String get chatRecordingSlideToCancel;

  /// No description provided for @chatReleaseToCancel.
  ///
  /// In es, this message translates to:
  /// **'Suelta para cancelar'**
  String get chatReleaseToCancel;

  /// No description provided for @chatRecordingRejectedMeetingCancelled.
  ///
  /// In es, this message translates to:
  /// **'❌ Rechazaste la grabación. El encuentro se canceló para ambos y el chat quedó cerrado.'**
  String get chatRecordingRejectedMeetingCancelled;

  /// No description provided for @chatRecordingEnabledBothAccepted.
  ///
  /// In es, this message translates to:
  /// **'🎙️ Grabación habilitada. Ambos aceptaron.'**
  String get chatRecordingEnabledBothAccepted;

  /// No description provided for @chatRecordingAcceptedWaitingOther.
  ///
  /// In es, this message translates to:
  /// **'🎙️ Aceptaste. Esperando que el otro usuario acepte.'**
  String get chatRecordingAcceptedWaitingOther;

  /// No description provided for @chatRecordingMeetingCancelledTitle.
  ///
  /// In es, this message translates to:
  /// **'🚫 Encuentro cancelado'**
  String get chatRecordingMeetingCancelledTitle;

  /// No description provided for @chatRecordingMeetingCancelledReason.
  ///
  /// In es, this message translates to:
  /// **'El encuentro se canceló porque una de las partes rechazó la grabación de voz por seguridad.'**
  String get chatRecordingMeetingCancelledReason;

  /// No description provided for @chatRecordingMandatoryExplanation.
  ///
  /// In es, this message translates to:
  /// **'La grabación por seguridad es obligatoria para realizar encuentros presenciales a través de la app. Esta medida protege a ambos usuarios.'**
  String get chatRecordingMandatoryExplanation;

  /// No description provided for @chatReportSuspiciousProduct.
  ///
  /// In es, this message translates to:
  /// **'Producto sospechoso'**
  String get chatReportSuspiciousProduct;

  /// No description provided for @chatReportProhibitedProducts.
  ///
  /// In es, this message translates to:
  /// **'Publicación de productos prohibidos'**
  String get chatReportProhibitedProducts;

  /// No description provided for @chatReportFraud.
  ///
  /// In es, this message translates to:
  /// **'Estafa o fraude'**
  String get chatReportFraud;

  /// No description provided for @chatReportHarassment.
  ///
  /// In es, this message translates to:
  /// **'Acoso o maltrato'**
  String get chatReportHarassment;

  /// No description provided for @chatReportMisleadingInfo.
  ///
  /// In es, this message translates to:
  /// **'Información falsa o engañosa'**
  String get chatReportMisleadingInfo;

  /// No description provided for @chatReportOtherReason.
  ///
  /// In es, this message translates to:
  /// **'Otro motivo'**
  String get chatReportOtherReason;

  /// No description provided for @chatLocation.
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
  String get chatLocation;

  /// No description provided for @chatClosedShieldRejected.
  ///
  /// In es, this message translates to:
  /// **'Chat cerrado. Uno de los participantes no aceptó el Escudo de Seguridad.'**
  String get chatClosedShieldRejected;

  /// No description provided for @chatLockedForMeeting.
  ///
  /// In es, this message translates to:
  /// **'Chat bloqueado. Se verán en persona. No llegues tarde.'**
  String get chatLockedForMeeting;

  /// No description provided for @chatSendProposals.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Enviar 1 propuesta} other{Enviar {count} propuestas}}'**
  String chatSendProposals(int count);

  /// No description provided for @chatMapCoordinates.
  ///
  /// In es, this message translates to:
  /// **'Lat: {latitude}, Lng: {longitude}'**
  String chatMapCoordinates(String latitude, String longitude);

  /// No description provided for @chatAnalyzingConversation.
  ///
  /// In es, this message translates to:
  /// **'Analizando conversación...'**
  String get chatAnalyzingConversation;

  /// No description provided for @chatAnalysisNotAvailable.
  ///
  /// In es, this message translates to:
  /// **'No hay análisis disponible aún.'**
  String get chatAnalysisNotAvailable;

  /// No description provided for @chatMeetingTimeOccupied.
  ///
  /// In es, this message translates to:
  /// **'Ese día y hora ya está ocupado.'**
  String get chatMeetingTimeOccupied;

  /// No description provided for @chatYourPortfolio.
  ///
  /// In es, this message translates to:
  /// **'Tu portafolio'**
  String get chatYourPortfolio;

  /// No description provided for @chatHideProducts.
  ///
  /// In es, this message translates to:
  /// **'Ocultar productos'**
  String get chatHideProducts;

  /// No description provided for @chatViewProducts.
  ///
  /// In es, this message translates to:
  /// **'Ver productos'**
  String get chatViewProducts;

  /// No description provided for @chatViewProduct.
  ///
  /// In es, this message translates to:
  /// **'Ver producto'**
  String get chatViewProduct;

  /// No description provided for @chatSelectMessagePart.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar parte del mensaje para copiar'**
  String get chatSelectMessagePart;

  /// No description provided for @chatMeetingProposalTitle.
  ///
  /// In es, this message translates to:
  /// **'Propuesta de encuentro'**
  String get chatMeetingProposalTitle;

  /// No description provided for @chatWaitingProposalResponse.
  ///
  /// In es, this message translates to:
  /// **'Esperando respuesta...'**
  String get chatWaitingProposalResponse;

  /// No description provided for @chatTapProposalDetails.
  ///
  /// In es, this message translates to:
  /// **'Toca para ver detalles y responder'**
  String get chatTapProposalDetails;

  /// No description provided for @chatProposalAcceptedNotice.
  ///
  /// In es, this message translates to:
  /// **'✅ Propuesta aceptada'**
  String get chatProposalAcceptedNotice;

  /// No description provided for @chatProposalRejected.
  ///
  /// In es, this message translates to:
  /// **'❌ Propuesta rechazada'**
  String get chatProposalRejected;

  /// No description provided for @chatOtherUserMeetingReady.
  ///
  /// In es, this message translates to:
  /// **'{userName} desea saber si ya todo está listo para el encuentro'**
  String chatOtherUserMeetingReady(String userName);

  /// No description provided for @chatMeetingEverythingReady.
  ///
  /// In es, this message translates to:
  /// **'¿Ya está todo listo para el encuentro?'**
  String get chatMeetingEverythingReady;

  /// No description provided for @chatMeetingBothConfirmLock.
  ///
  /// In es, this message translates to:
  /// **'Si ambos confirman, el chat se bloquea hasta que se vean en persona.'**
  String get chatMeetingBothConfirmLock;

  /// No description provided for @chatConversationAgreement.
  ///
  /// In es, this message translates to:
  /// **'La conversación parece haber llegado a un acuerdo.'**
  String get chatConversationAgreement;

  /// No description provided for @chatCancelMeetingBoth.
  ///
  /// In es, this message translates to:
  /// **'Esta acción anula el encuentro para ambos.'**
  String get chatCancelMeetingBoth;

  /// No description provided for @chatMeetingNotCompletedExplanation.
  ///
  /// In es, this message translates to:
  /// **'Lamentamos las molestias. No todos los encuentros se pueden concretar, y eso está bien: lo importante es cuidarnos entre todos.\n\nEl chat quedó cerrado. Eliminá este chat y volvé a abrirlo para seguir conversando.'**
  String get chatMeetingNotCompletedExplanation;
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
