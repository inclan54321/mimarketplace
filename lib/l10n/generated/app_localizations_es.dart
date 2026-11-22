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
  String get miPerfil => 'Mi Perfil';

  @override
  String get verPortafolio => 'Ver Portafolio';

  @override
  String get verTodosMisProductos => 'Ver todos mis productos publicados';

  @override
  String get opcionesDelVendedor => 'Opciones del Vendedor';

  @override
  String get desbloquear => 'Desbloquear';

  @override
  String get bloquear => 'Bloquear';

  @override
  String desbloquearA(String nombre) {
    return 'Desbloquear a $nombre';
  }

  @override
  String bloquearA(String nombre) {
    return 'Bloquear a $nombre';
  }

  @override
  String get verInformacionDePerfil => 'Ver información de perfil';

  @override
  String verDetallesDe(String nombre) {
    return 'Ver detalles de $nombre';
  }

  @override
  String verTodosLosProductosDe(String nombre) {
    return 'Ver todos los productos de $nombre';
  }

  @override
  String get denunciarVendedor => 'Denunciar vendedor';

  @override
  String reportarA(String nombre) {
    return 'Reportar a $nombre por incumplir las reglas';
  }

  @override
  String get vendedorBloqueadoCorrectamente =>
      'Vendedor bloqueado correctamente. Reiniciando...';

  @override
  String get vendedorDesbloqueadoCorrectamente =>
      'Vendedor desbloqueado correctamente. Reiniciando...';

  @override
  String get errorAlBloquear => 'Error al bloquear';

  @override
  String get errorAlDesbloquear => 'Error al desbloquear';

  @override
  String get errorAlBloquearUsuario => 'Error al bloquear usuario';

  @override
  String get errorAlDesbloquearUsuario => 'Error al desbloquear usuario';

  @override
  String get denunciarVendedorTitulo => '⚠️ Denunciar vendedor';

  @override
  String get seleccionaMotivoDenuncia => 'Selecciona el motivo de la denuncia:';

  @override
  String get denunciaRevisadaPorEquipo =>
      'Esta denuncia será revisada por nuestro equipo de moderación.';

  @override
  String get denunciar => 'Denunciar';

  @override
  String get debesIniciarSesionParaDenunciar =>
      'Debes iniciar sesión para denunciar';

  @override
  String get denunciaEnviada =>
      '✅ Denuncia enviada. Será revisada por moderación.';

  @override
  String errorAlEnviarDenuncia(String error) {
    return 'Error al enviar denuncia: $error';
  }

  @override
  String get motivoProductoSospechoso => 'Producto sospechoso';

  @override
  String get motivoProductosProhibidos => 'Publicación de productos prohibidos';

  @override
  String get motivoEstafaFraude => 'Estafa o fraude';

  @override
  String get motivoAcosoMaltrato => 'Acoso o maltrato';

  @override
  String get motivoInformacionFalsa => 'Información falsa o engañosa';

  @override
  String get motivoOtro => 'Otro motivo';

  @override
  String get vendedor => 'Vendedor';

  @override
  String get esteVendedor => 'este vendedor';

  @override
  String get miPortafolio => 'Mi Portafolio';

  @override
  String get debesIniciarSesion => 'Debes iniciar sesión';

  @override
  String get editarProducto => 'Editar Producto';

  @override
  String get contactarVendedor => 'Contactar Vendedor';

  @override
  String compartirProductoMensaje(String enlace) {
    return '📱 Mira este producto en MiMarketplace:\n\n$enlace';
  }

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
  String errorGenericoAlerta(String error) {
    return 'Error: $error';
  }

  @override
  String get errorDesconocido => 'Error desconocido';

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
  String get catAutomoviles => 'Automóviles';

  @override
  String get catHerramientas => 'Herramientas';

  @override
  String get catRopaYCalzado => 'Ropa y Calzado';

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

  @override
  String get encuentroCaducado => 'Encuentro caducado';

  @override
  String get esperandoVerificacionDelOtro =>
      'Esperando que el otro verifique tu selfie';

  @override
  String get verificacionCompleta => 'Verificación completa';

  @override
  String get premiumActivoTitulo => '¡Ya sos premium!';

  @override
  String get premiumActivoDescripcion => 'Los anuncios están eliminados';

  @override
  String get planUnaSemana => '1 Semana';

  @override
  String get sinAnunciosPor7Dias => 'Sin anuncios por 7 días';

  @override
  String get yaTenesAnunciosEliminados => 'Ya tenés los anuncios eliminados';

  @override
  String get productoNoDisponible => 'Producto no disponible';

  @override
  String errorCompra(String detalle) {
    return 'Error: $detalle';
  }

  @override
  String get desconocido => 'Desconocido';

  @override
  String get usuarioNoLogueado => 'No hay usuario logueado';

  @override
  String get errorVerificarCompra => 'Error al verificar compra';

  @override
  String get compraExitosaAnunciosEliminados =>
      '✅ ¡Listo! Los anuncios fueron eliminados.';

  @override
  String get configurarImpulso => 'Configurar impulso';

  @override
  String get impulsarTitulo => 'Impulsar';

  @override
  String get impulsarPublicacion => 'Impulsar publicación';

  @override
  String get poneTuProductoPrimero => 'Poné tu producto primero';

  @override
  String get impulsarPunto1Titulo => 'Subí al primer lugar';

  @override
  String get impulsarPunto1Desc =>
      'Tu producto aparece primero en la lista de Productos Destacados del Home.';

  @override
  String get impulsarPunto2Titulo => 'Más visibilidad';

  @override
  String get impulsarPunto2Desc =>
      'Al estar primero, más personas lo ven y tenés más chances de venderlo rápido.';

  @override
  String get impulsarPunto3Titulo => 'Duración limitada';

  @override
  String get impulsarPunto3Desc =>
      'El impulso dura hasta que otro vendedor pague por subir. Ahí bajás un lugar.';

  @override
  String get seleccionarArticulo => 'Seleccionar artículo';

  @override
  String get proximamenteDisponiblePagos =>
      'Próximamente disponible. Estamos habilitando los pagos.';

  @override
  String get articuloAImpulsar => 'Artículo a impulsar';

  @override
  String get comoFuncionaImpulso => '¿Cómo funciona?';

  @override
  String get explicacionImpulso =>
      'Al impulsar, tu producto sube al primer lugar del Home. Si otro vendedor impulsa su producto, vos bajás un lugar. El que pagó más recientemente siempre está primero.';

  @override
  String get procesando => 'Procesando...';

  @override
  String get cargando => 'Cargando...';

  @override
  String get impulsarAhora => 'Impulsar ahora';

  @override
  String get cambiarProducto => 'Cambiar producto';

  @override
  String get noTenesProductosPublicados => 'No tenés productos publicados';

  @override
  String get elegiUnArticulo => 'Elegí un artículo';

  @override
  String get elQueElijasApareceraPrimero =>
      'El que elijas aparecerá primero en el Home';

  @override
  String get primeroElegiUnArticulo => 'Primero elegí un artículo';

  @override
  String get productoImpulsoNoDisponible =>
      'Producto de impulso no disponible. Revisá tu conexión.';

  @override
  String productoEstaPrimeroEnHome(String nombre) {
    return '✅ \"$nombre\" está primero en el Home';
  }

  @override
  String get pagoNoVerificado =>
      'El pago no se pudo verificar. Contactá a soporte.';

  @override
  String get compraPendiente => 'La compra quedó pendiente. Intentá de nuevo.';

  @override
  String get errorAlImpulsar => 'Error al impulsar';

  @override
  String escudoActivoPor(String nombre) {
    return '$nombre activó el Escudo de Seguridad';
  }

  @override
  String get escudoPaso0Titulo => '¿Qué es el Escudo de Seguridad?';

  @override
  String get escudoPaso0Desc =>
      'Es un conjunto de medidas de protección que se activan cuando ambos usuarios de un trato lo aceptan. Su objetivo es prevenir fraudes y garantizar que el encuentro sea seguro.\n\n¿Quién debe activarlo?\nAmbos usuarios del trato deben aceptar el Escudo. Si uno lo activa, el otro recibirá una notificación para aceptarlo o rechazarlo. Si el segundo usuario lo rechaza, el chat se cerrará para ambos.';

  @override
  String get escudoPaso1Titulo => '¿Qué ocurre cuando el Escudo está activo?';

  @override
  String get escudoPaso1Desc =>
      '3.1. Bloqueo de enlaces y teléfonos: La app detecta y bloquea automáticamente números de teléfono y enlaces externos en los mensajes. Esto evita compartir datos de contacto fuera de la plataforma y reduce el riesgo de estafas.';

  @override
  String get escudoPaso2Titulo => 'Cómo cerrar el trato';

  @override
  String get escudoPaso2Desc =>
      'Para cerrar el trato, primero proponé un encuentro: tocá el escudo en la barra superior del chat y elegí \"Proponer encuentro\". Ahí seleccionás provincia, cantón, distrito, un lugar seguro y la fecha con hora. Enviás la propuesta y el otro usuario la recibe como tarjeta en el chat. Cuando la acepta, el encuentro queda agendado pero el chat sigue abierto: pueden seguir hablando. Para cerrar el trato, tocá el escudo otra vez y elegí \"Cerrar trato\". Se abre un cartel para confirmar. Cuando ambos confirman, el chat se bloquea y las protecciones se activan.';

  @override
  String get escudoPaso3Titulo => 'Confirmación de asistencia';

  @override
  String get escudoPaso3Desc =>
      'Una hora antes del encuentro, ambos usuarios recibirán una notificación para confirmar su asistencia. Si alguno de los dos no confirma dentro de los 15 minutos posteriores a la notificación, el otro usuario podrá cancelar el encuentro hasta 15 minutos antes de la hora pactada.';

  @override
  String get escudoPaso4Titulo => 'Seguimiento GPS';

  @override
  String get escudoPaso4Desc =>
      '3.3. Seguimiento GPS el día del encuentro: El día acordado, 15 minutos antes de la hora del encuentro, ambos usuarios deben estar en el lugar y activar el GPS para verificar su ubicación. Si faltando 5 minutos para la hora acordada el usuario no activó el GPS y no verificó su identidad, se considerará que llegó tarde. Si 15 minutos después de la hora acordada el usuario no lo hizo, se considerará que no llegó. En ambos casos, queda registrado y puede ser sancionado según las normas de MiMarketplace.';

  @override
  String get escudoPaso5Titulo => 'Verificación facial';

  @override
  String get escudoPaso5Desc =>
      '3.4. Verificación de identidad antes del chat: Para liberar el chat del encuentro, ambos usuarios deben confirmar que son quienes dicen ser. Esto se habilita 15 minutos antes de la hora acordada y es un requisito obligatorio para poder abrir el chat. El sistema le pedirá a cada uno que se tome una foto en el momento. Luego, el otro usuario deberá comparar esa foto con la foto de perfil para confirmar que coinciden. Es importante estar atento, porque la verificación se habilita cuando el otro usuario la activa, y hay que seguir las instrucciones que aparecen en pantalla. Así se evita que alguien más use la cuenta.';

  @override
  String get escudoPaso6Titulo => 'Consideraciones adicionales';

  @override
  String get escudoPaso6Desc =>
      '4.1. Cancelación voluntaria: Cualquier usuario puede cancelar su asistencia al encuentro siempre y cuando falte más de una hora para la hora acordada. Una vez que falte menos de una hora, la cancelación ya no estará disponible.\n\n¿Cómo cancelar? Entrá al chat del artículo, tocá el botón del escudo en la barra superior y elegí \"Cancelar trato\". Se va a abrir un cartel que te muestra la fecha del encuentro y te indica si todavía podés cancelar o si ya falta menos de una hora. Si se puede, confirmás y el encuentro se anula para los dos.\n\nRevisá siempre la sección de Alertas. Ahí llegan los recordatorios del encuentro, la confirmación de asistencia, la verificación de identidad y cualquier cambio de estado. Tenés que revisarlas seguido para no perderte nada importante.';

  @override
  String get noAceptar => 'No aceptar';

  @override
  String get aceptar => 'Aceptar';

  @override
  String get cerrar => 'Cerrar';

  @override
  String get siguiente => 'Siguiente';

  @override
  String get iniciar => 'Iniciar';

  @override
  String get verVideo => 'Ver video';

  @override
  String errorGenericoImpulsar(String error) {
    return 'Error: $error';
  }

  @override
  String get ubicacionDelEncuentro => 'Ubicación del encuentro';

  @override
  String get verificarCuenta => 'Verificar cuenta';

  @override
  String get verificaTuCuenta => 'Verificá tu cuenta';

  @override
  String get obteneLaInsigniaDeVerificado =>
      'Obtené la insignia de verificado en tu perfil';

  @override
  String get paso1EnviaSinpe => 'Paso 1: Enviá el SINPE Móvil';

  @override
  String realizaSinpeDeMontoANumero(String monto) {
    return 'Realizá un SINPE Móvil de $monto al número:';
  }

  @override
  String get paso2IngresaTuNumero => 'Paso 2: Ingresá tu número';

  @override
  String get ingresaNumeroDesdeElQueEnviaste =>
      'Ingresá el número de teléfono desde el que enviaste el SINPE:';

  @override
  String get ejemploTelefono => 'Ej: 88888888';

  @override
  String get confirmarPago => 'Confirmar pago';

  @override
  String get enviando => 'Enviando...';

  @override
  String get porFavorIngresaTuTelefono =>
      'Por favor, ingresá tu número de teléfono';

  @override
  String get solicitudEnviada => '¡Solicitud enviada!';

  @override
  String get estamosVerificandoTuPago =>
      'Estamos verificando tu pago. En breve recibirás la insignia de verificado en tu perfil.';

  @override
  String get porFavorEscribeUnMensaje => 'Por favor, escribe un mensaje';

  @override
  String get porFavorEscribeUnAsunto => 'Por favor, escribe un asunto';

  @override
  String get mensajeEnviadoExito =>
      '✅ Mensaje enviado. Te responderemos pronto.';

  @override
  String get necesitasAyuda => '¿Necesitas ayuda?';

  @override
  String get cuentanosTuProblema =>
      'Cuéntanos tu problema y te ayudaremos a resolverlo.';

  @override
  String get tipoDeConsulta => 'Tipo de consulta';

  @override
  String get asunto => 'Asunto';

  @override
  String get ejemploProblemaCuenta => 'Ej: Problema con mi cuenta';

  @override
  String get mensaje => 'Mensaje';

  @override
  String get describeTuProblema =>
      'Describe tu problema con el mayor detalle posible...';

  @override
  String get enviarMensaje => 'Enviar mensaje';

  @override
  String get tiempoRespuestaEstimado =>
      'Tiempo de respuesta estimado: 24-48 horas';

  @override
  String get mensajeEnviado => '¡Mensaje enviado!';

  @override
  String get hemosRecibidoTuConsulta =>
      'Hemos recibido tu consulta. Nuestro equipo de soporte te responderá en las próximas 24-48 horas.';

  @override
  String get enviarOtroMensaje => 'Enviar otro mensaje';

  @override
  String get volver => 'Volver';

  @override
  String get categoria => 'Categoría';

  @override
  String get direccion => 'Dirección';

  @override
  String get nombreDelProducto => 'Nombre del producto';

  @override
  String get ejemploNombreProducto => 'Ej. iPhone 13, Laptop, etc.';

  @override
  String get ingresaNombreProducto => 'Ingresa el nombre del producto';

  @override
  String get nombreMinimoCaracteres =>
      'El nombre debe tener al menos 3 caracteres';

  @override
  String get precio => 'Precio (₡)';

  @override
  String get ingresePrecioProducto => 'Ingrese el precio del producto';

  @override
  String get ingresaPrecio => 'Ingresa el precio';

  @override
  String get ingresaPrecioValido => 'Ingresa un precio válido';

  @override
  String get precioMayorCero => 'El precio debe ser mayor a 0';

  @override
  String get descripcion => 'Descripción';

  @override
  String get escribeDescripcionDetallada =>
      'Escriba una descripción detallada del producto...';

  @override
  String get ingresaDescripcion => 'Ingresa una descripción';

  @override
  String get publicarProducto => 'Publicar Producto';

  @override
  String get compartaProductoComunidad =>
      'Comparta su producto con la comunidad';

  @override
  String get anuncioCompletado =>
      '✅ Anuncio completado. Publicando producto...';

  @override
  String get debesVerAnuncioParaPublicar =>
      '❌ Debes ver el anuncio completo para publicar';

  @override
  String get productoEnviadoRevision =>
      '📝 Producto enviado para revisión. Recibirás notificación al aprobarse.';

  @override
  String errorAlPublicar(String error) {
    return 'Error al publicar: $error';
  }

  @override
  String get paraPublicarNecesitasVerAnuncio =>
      'Para publicar tu producto, necesitas ver un breve anuncio.';

  @override
  String get verAnuncio => 'Ver anuncio';

  @override
  String get agregarImagenes => 'Agregar imágenes';

  @override
  String get imagenDestacada => 'Imagen Destacada';

  @override
  String get estaImagenApareceraPortada =>
      'Esta imagen aparecerá en la portada del producto y en la sección de destacados.';

  @override
  String get soloImagenesCalidadEstudio =>
      'Solo se aceptan imágenes con calidad de estudio fotográfico (buena iluminación, enfoque nítido, fondo limpio).';

  @override
  String get tocaParaSeleccionarImagen => 'Toca para seleccionar una imagen';

  @override
  String get formatosImagenPermitidos => 'JPG, PNG o WEBP · Máx. 10 MB';

  @override
  String get enRevisionPuntos => '🔍 En revisión...';

  @override
  String get enviadoARevision => '🔄 Enviado a revisión';

  @override
  String get enviarARevision => '🛡️ Enviar a revisión';

  @override
  String get imagenRevisadaIA =>
      'La imagen será revisada por IA. Recibirás una notificación cuando sea aprobada.';

  @override
  String get imagenesRealesProducto => 'Imágenes Reales del Producto';

  @override
  String get subeHasta4Fotos =>
      'Sube hasta 4 fotos reales del producto (obligatorio)';

  @override
  String get agregar => 'Agregar';

  @override
  String get maximo4ImagenesReales =>
      '⚠️ Solo puedes subir máximo 4 imágenes reales';

  @override
  String get escribeDescripcionMejorarImagen =>
      'Escribe una descripción para mejorar la imagen';

  @override
  String get primeroSeleccionaImagen => 'Primero selecciona una imagen';

  @override
  String get imagenMejoradaCorrectamente => '✅ Imagen mejorada correctamente';

  @override
  String get errorGenerarImagen => 'Error al generar imagen';

  @override
  String get imagenEnviadaRevision =>
      '🔄 Imagen enviada a revisión. Recibirás una notificación cuando sea aprobada.';

  @override
  String errorEnviarImagen(String codigo) {
    return 'Error al enviar imagen: $codigo';
  }

  @override
  String get revisionDeImagen => '🛡️ Revisión de imagen';

  @override
  String get tuImagenSeraEnviadaModeracion =>
      'Tu imagen será enviada a nuestro equipo de moderación para su revisión. Para continuar, necesitas ver un breve anuncio.';

  @override
  String get revisionPuedeTomar24Horas =>
      'La revisión puede tomar hasta 24 horas.';

  @override
  String get verAnuncioConEmoji => 'Ver anuncio 🎬';

  @override
  String get anuncioCompletadoEnviandoImagen =>
      '✅ Anuncio completado. Enviando imagen a revisión...';

  @override
  String get debesVerAnuncioParaEnviarImagen =>
      '❌ Debes ver el anuncio completo para enviar la imagen';

  @override
  String get seleccionaAlMenos1Imagen => 'Selecciona al menos 1 imagen real';

  @override
  String get siguienteConFlecha => 'Siguiente →';

  @override
  String get recoleccionDeDatos => 'Recolección de datos';

  @override
  String get tuPrivacidadImportante =>
      'Tu privacidad es importante para nosotros. Puedes elegir si permites que tus datos de navegación y preferencias sean recolectados para recibir sugerencias de productos personalizados.';

  @override
  String get aceptoRecoleccionDatos =>
      'Acepto que mis datos de navegación y preferencias sean recolectados para recibir sugerencias de productos personalizados.';

  @override
  String get guardarPreferencias => 'Guardar preferencias';

  @override
  String get preferenciasGuardadas => '✅ Preferencias guardadas';

  @override
  String get errorAlGuardar => 'Error al guardar';

  @override
  String get historialDePagos => 'Historial de pagos';

  @override
  String get consultaTodosLosPagos =>
      'Consultá todos los pagos que hiciste dentro de la app: impulsos de publicaciones, renovaciones, eliminación de publicidad y otros servicios.';

  @override
  String get verHistorialDePagos => 'Ver historial de pagos';

  @override
  String get todosTusPagosTransacciones => 'Todos tus pagos y transacciones';

  @override
  String get estadoDeCuenta => 'Estado de cuenta';

  @override
  String get revisaTusAdvertencias =>
      'Revisá tus advertencias y suspensiones activas en la plataforma.';

  @override
  String get advertencias => 'Advertencias';

  @override
  String get suspensionesTemporales => 'Suspensiones temporales';

  @override
  String get asistenciaAEncuentros => 'Asistencia a encuentros';

  @override
  String get llegadasTardias => 'Llegadas tardías';

  @override
  String get noVerificaste5Min =>
      'No verificaste a 5 min o menos. 3 = 1 advertencia';

  @override
  String get ausencias => 'Ausencias';

  @override
  String get noLlegasteEncuentro =>
      'No llegaste al encuentro. 1 = 1 advertencia';

  @override
  String minutosTardeAcumulados(int cantidad) {
    return '⏱️ Minutos tarde acumulados: $cantidad';
  }

  @override
  String get informacion => 'Información';

  @override
  String get comoFunciona => '¿Cómo funciona?';

  @override
  String get comoFuncionaEstadoCuenta =>
      'Tu cuenta acumula advertencias y suspensiones temporales por incumplir las normas de la comunidad.\n\nAsistencia a encuentros:\n• 3 llegadas tardías (0/3) = 1 advertencia.\n• 1 ausencia = 1 advertencia.\n\nEscalado:\n• 3 advertencias = 1 suspensión temporal (7 días).\n• 3 suspensiones = baneo permanente.\n\nRecuperación:\n• Cada mes se descuentan 2 llegadas tardías.\n• Cada 3 meses se descuenta 1 advertencia.';

  @override
  String get advertenciasInfo =>
      'Advertencias (máx. 3): se generan por reportes leves como lenguaje inapropiado, publicaciones con información engañosa o incumplimiento menor de las reglas. No bloquean tu cuenta.';

  @override
  String get suspensionesInfo =>
      'Suspensiones temporales (máx. 3): se aplican por faltas más graves como estafas, acoso, suplantación de identidad o reincidencia en advertencias. Cada suspensión bloquea tu cuenta por un período.';

  @override
  String get baneoInfo =>
      'Si llegás a 3 suspensiones, tu cuenta será baneada de forma permanente y su correo no podrá volver a registrarse.';

  @override
  String get entendido => 'Entendido';

  @override
  String get guardar => 'Guardar';

  @override
  String get guardarCambios => 'Guardar Cambios';

  @override
  String get nombreCompleto => 'Nombre completo';

  @override
  String get telefono => 'Teléfono';

  @override
  String get usuarioNoAutenticado => 'Usuario no autenticado';

  @override
  String get errorAlCargarDatos => 'Error al cargar datos';

  @override
  String get nombreNoPuedeEstarVacio => 'El nombre no puede estar vacío';

  @override
  String get perfilActualizadoCorrectamente =>
      '✅ Perfil actualizado correctamente';

  @override
  String get errorAlGuardarEnServidor => 'Error al guardar en el servidor';

  @override
  String get volverAlPerfil => 'Volver al perfil';
}
