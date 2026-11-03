// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Mi Marketplace';

  @override
  String bienvenido(String nombre) {
    return 'Bienvenido, $nombre';
  }

  @override
  String get categorias => 'Categorías';

  @override
  String get productosDestacados => 'Productos Destacados';

  @override
  String get verTodas => 'Ver todas';

  @override
  String get buscarProductos => 'Buscar productos...';

  @override
  String get noHayResultados => 'No hay resultados';

  @override
  String get noHayProductosDestacados => 'No hay productos destacados';

  @override
  String get noHayProductosConFiltros => 'No hay productos con esos filtros';

  @override
  String get quitarFiltros => 'Quitar filtros';

  @override
  String get filtrarProductos => 'Filtrar productos';

  @override
  String get canton => '📍 Cantón';

  @override
  String get rangoPrecio => '💰 Rango de precio (₡)';

  @override
  String get limpiar => 'Limpiar';

  @override
  String get aplicarFiltros => 'Aplicar filtros';

  @override
  String get filtrosAplicados => '✅ Filtros aplicados';

  @override
  String get sinFiltrosAplicados => 'Sin filtros aplicados';

  @override
  String get todos => 'Todos';

  @override
  String get iniciarSesion => 'Iniciar Sesión';

  @override
  String get correoElectronico => 'Correo electrónico';

  @override
  String get contrasena => 'Contraseña';

  @override
  String get continuarConGoogle => 'Continuar con Google';

  @override
  String get noTienesCuenta => '¿No tienes cuenta? Regístrate';

  @override
  String get inicio => 'Inicio';

  @override
  String get avisos => 'Avisos';

  @override
  String get vender => 'Vender';

  @override
  String get mensajes => 'Mensajes';

  @override
  String get perfil => 'Perfil';

  @override
  String get editarPerfil => 'Editar Perfil';

  @override
  String get impulsar => 'Impulsar';

  @override
  String get eliminarPublicidad => 'Eliminar publicidad';

  @override
  String get cerrarSesion => 'Cerrar Sesión';

  @override
  String get privacidadYSeguridad => 'Privacidad y Seguridad';

  @override
  String get soporte => 'Soporte';

  @override
  String get terminosDeServicio => 'Términos de Servicio';

  @override
  String get misArticulos => 'Mis artículos';

  @override
  String get masVistos => 'Más vistos';

  @override
  String get favoritos => 'Favoritos';

  @override
  String get noHasPublicadoNingunArticulo => 'No has publicado ningún artículo';

  @override
  String get noTienesProductosFavoritos => 'No tienes productos favoritos';

  @override
  String get reintentar => 'Reintentar';

  @override
  String get noHayCalificacionesAun => 'No hay calificaciones aún';

  @override
  String get sinComentario => 'Sin comentario';

  @override
  String get usuario => 'Usuario';

  @override
  String get cerrarSesionExitoso => 'Sesión cerrada';

  @override
  String get estiloVisualDelPerfil => '🎨 Estilo visual del perfil';

  @override
  String get eligeElFondoQueMasTeGuste => 'Elige el fondo que más te guste';

  @override
  String get atardecer => 'Atardecer';

  @override
  String get galaxia => 'Galaxia';

  @override
  String get oceano => 'Océano';

  @override
  String get volcan => 'Volcán';

  @override
  String get cancelar => 'Cancelar';

  @override
  String get eliminar => 'Eliminar';

  @override
  String get confirmar => 'Confirmar';

  @override
  String get yaSeVendio => '¿Ya se vendió?';

  @override
  String get calificacion => 'calificación';

  @override
  String get calificaciones => 'calificaciones';

  @override
  String get queVasAVender => '¿Qué vas a vender?';

  @override
  String get seleccionaCategoria =>
      'Selecciona la categoría que mejor describe tu artículo';

  @override
  String get buscarCategoria => 'Buscar categoría...';

  @override
  String get noSeEncontraronCategorias => 'No se encontraron categorías';

  @override
  String get todasLasCategorias => 'Todas las categorías';

  @override
  String get seleccionar => 'Seleccionar';

  @override
  String get chateaConCompradoresVendedores =>
      'Chatea con compradores y vendedores';

  @override
  String get tabChats => 'CHATS';

  @override
  String get tabAgenda => 'AGENDA';

  @override
  String get tabEncuentros => 'ENCUENTROS';

  @override
  String get noTienesConversaciones => 'No tienes conversaciones';

  @override
  String get encuentroAceptado => 'ENCUENTRO ACEPTADO';

  @override
  String get articuloVendido => 'ARTÍCULO VENDIDO';

  @override
  String get nuevoMensaje => 'NUEVO MENSAJE';

  @override
  String get fijarChat => 'Fijar chat';

  @override
  String get desfijarChat => 'Desfijar chat';

  @override
  String get quitarDeLaParteSuperior => 'Quitar de la parte superior';

  @override
  String get mantenerEnLaParteSuperior => 'Mantener en la parte superior';

  @override
  String get chatFijado => '📌 Chat fijado';

  @override
  String get chatDesfijado => '📌 Chat desfijado';

  @override
  String errorAlFijar(String codigo) {
    return 'Error al fijar: $codigo';
  }

  @override
  String get eliminarChat => 'Eliminar chat';

  @override
  String confirmarEliminarChat(String nombre) {
    return '¿Estás seguro de borrar la conversación con $nombre?';
  }

  @override
  String get chatEliminado => '🗑️ Chat eliminado';

  @override
  String guardadoConProductos(int cantidad) {
    return '✅ Guardado ($cantidad productos)';
  }

  @override
  String get eliminado => '🗑️ Eliminado';

  @override
  String get buscarContactosProductos => 'Buscar contactos o productos...';

  @override
  String get noHayContactosGuardados => 'No hay contactos guardados';

  @override
  String noHayResultadosPara(String busqueda) {
    return 'No hay resultados para \"$busqueda\"';
  }

  @override
  String get tocaBotonParaGuardarContacto =>
      'Toca el botón en un chat para guardar el contacto en tu agenda';

  @override
  String get producto => 'Producto';

  @override
  String get sinMensajes => 'Sin mensajes';

  @override
  String get fechaDesconocida => 'Fecha desconocida';

  @override
  String haceDias(int cantidad) {
    return 'hace $cantidad días';
  }

  @override
  String haceHoras(int cantidad) {
    return 'hace $cantidad horas';
  }

  @override
  String haceMinutos(int cantidad) {
    return 'hace $cantidad minutos';
  }

  @override
  String get haceUnosSegundos => 'hace unos segundos';

  @override
  String get lun => 'Lun';

  @override
  String get mar => 'Mar';

  @override
  String get mie => 'Mié';

  @override
  String get jue => 'Jue';

  @override
  String get vie => 'Vie';

  @override
  String get sab => 'Sáb';

  @override
  String errorGenerico(String error) {
    return 'Error: $error';
  }

  @override
  String get catElectronicos => 'Electrónicos';

  @override
  String get catDeportes => 'Deportes';

  @override
  String get catHogar => 'Hogar';

  @override
  String get catMusica => 'Música';

  @override
  String get catCocina => 'Cocina';

  @override
  String get catPeliculas => 'Películas';

  @override
  String get catFotografia => 'Fotografía';

  @override
  String get catVideojuegos => 'Videojuegos';

  @override
  String get catJuegosDeMesa => 'Juegos de Mesa';

  @override
  String get catJuguetes => 'Juguetes';

  @override
  String get catFiguras => 'Figuras';

  @override
  String get subElectronicos => 'Móviles, Laptops, Audio';

  @override
  String get subDeportes => 'Fútbol, Tenis, Running';

  @override
  String get subHogar => 'Muebles, Decoración, Cocina';

  @override
  String get subMusica => 'Guitarras, Pianos, Audio';

  @override
  String get subCocina => 'Ollas, Utensilios, Vajilla';

  @override
  String get subPeliculas => 'Acción, Comedia, Drama';

  @override
  String get subFotografia => 'Cámaras, Lentes, Accesorios';

  @override
  String get subVideojuegos => 'Consolas, Juegos, Controles';

  @override
  String get subJuegosDeMesa => 'Cartas, Tableros, Estrategia';

  @override
  String get subJuguetes => 'Peluches, Bloques, Carros';

  @override
  String get subFiguras => 'Acción, Coleccionables, Anime';

  @override
  String get alertasTitulo => 'Alertas';

  @override
  String get recargar => 'Recargar';

  @override
  String get limpiarTodasLasAlertas => 'Limpiar todas las alertas';

  @override
  String get noTienesAlertas => 'No tienes alertas';

  @override
  String get aquiApareceranAvisos => 'Aquí aparecerán tus avisos y encuentros.';

  @override
  String get noHayAlertasParaLimpiar => 'No hay alertas para limpiar';

  @override
  String get limpiarAlertas => '🗑️ Limpiar alertas';

  @override
  String get confirmarLimpiarAlertas =>
      '¿Estás seguro de que quieres eliminar todas las alertas?';

  @override
  String get eliminarTodo => 'Eliminar todo';

  @override
  String get todasLasAlertasEliminadas =>
      '✅ Todas las alertas han sido eliminadas';

  @override
  String errorAlLimpiarAlertas(String error) {
    return 'Error al limpiar alertas: $error';
  }

  @override
  String get cargandoAnuncio => '⏳ Cargando anuncio... espera un momento';

  @override
  String get noSePudoCargarAnuncio =>
      '❌ No se pudo cargar el anuncio. Intentá de nuevo.';

  @override
  String get productoRenovado => '✅ Producto renovado por 30 días más';

  @override
  String errorAlRenovar(String error) {
    return 'Error al renovar: $error';
  }

  @override
  String get debesVerAnuncioCompleto =>
      '❌ Debes ver el anuncio completo para renovar';

  @override
  String get renovarPor30Dias => 'Renovar por 30 días';

  @override
  String get ambosConfirmaron => 'Ambos confirmaron';

  @override
  String get esperandoAlOtro => 'Esperando al otro';

  @override
  String get confirmarEncuentro => 'Confirmar encuentro';

  @override
  String get verificarIdentidad => 'Verificar identidad';

  @override
  String get verificarIdentidadDelOtro => 'Verificar identidad del otro';

  @override
  String get identidadRechazada => 'Identidad rechazada';

  @override
  String get revisarComparacion => 'Revisar comparación';

  @override
  String get ambosConfirmaronExito => '✅ Ambos confirmaron. ¡Nos vemos!';

  @override
  String get confirmasteAsistencia =>
      '✅ Confirmaste tu asistencia. Esperando al otro.';

  @override
  String errorGenericoAlerta(String error) {
    return 'Error: $error';
  }

  @override
  String get eliminarPublicidadTitulo => 'Eliminar publicidad';

  @override
  String get eliminaLosAnuncios => 'Eliminá los anuncios';

  @override
  String get descripcionEliminarPublicidad =>
      'Pagá un plan y navegá sin publicidad en toda la app. Sin anuncios, sin interrupciones.';

  @override
  String get beneficioSinAnuncios => 'Sin anuncios en toda la app';

  @override
  String get beneficioNavegacionRapida => 'Navegación más rápida';

  @override
  String get beneficioSinInterrupciones => 'Experiencia sin interrupciones';

  @override
  String get elegiTuPlan => 'Elegí tu plan';

  @override
  String get plan1Mes => '1 mes';

  @override
  String get plan6Meses => '6 meses';

  @override
  String get sinAnunciosPor30Dias => 'Sin anuncios por 30 días';

  @override
  String get sinAnunciosPor180Dias => 'Sin anuncios por 180 días';

  @override
  String ahorrasMonto(String monto) {
    return 'Ahorrás $monto';
  }

  @override
  String get elegiUnPlan => 'Elegí un plan';

  @override
  String pagarMonto(String monto) {
    return 'Pagar $monto';
  }

  @override
  String get pagoSeguro => 'El pago se procesa de forma segura';

  @override
  String get confirmarCompra => 'Confirmar compra';

  @override
  String confirmarCompraPregunta(String precio, String duracion) {
    return '¿Querés pagar $precio por $duracion sin anuncios?';
  }

  @override
  String get pagar => 'Pagar';

  @override
  String get integracionPagoEnDesarrollo =>
      '🚧 Integración de pago en desarrollo';
}
