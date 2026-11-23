// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'My Marketplace';

  @override
  String bienvenido(String nombre) {
    return 'Welcome, $nombre';
  }

  @override
  String get categorias => 'Categories';

  @override
  String get productosDestacados => 'Featured Products';

  @override
  String get verTodas => 'See all';

  @override
  String get buscarProductos => 'Search products...';

  @override
  String get noHayResultados => 'No results';

  @override
  String get noHayProductosDestacados => 'No featured products';

  @override
  String get noHayProductosConFiltros => 'No products with those filters';

  @override
  String get quitarFiltros => 'Clear filters';

  @override
  String get filtrarProductos => 'Filter products';

  @override
  String get canton => '📍 Canton';

  @override
  String get rangoPrecio => '💰 Price range (₡)';

  @override
  String get limpiar => 'Clear';

  @override
  String get aplicarFiltros => 'Apply filters';

  @override
  String get filtrosAplicados => '✅ Filters applied';

  @override
  String get sinFiltrosAplicados => 'No filters applied';

  @override
  String get todos => 'All';

  @override
  String get iniciarSesion => 'Sign In';

  @override
  String get correoElectronico => 'Email';

  @override
  String get contrasena => 'Password';

  @override
  String get continuarConGoogle => 'Continue with Google';

  @override
  String get noTienesCuenta => 'Don\'t have an account? Sign up';

  @override
  String get inicio => 'Home';

  @override
  String get avisos => 'Alerts';

  @override
  String get vender => 'Sell';

  @override
  String get mensajes => 'Messages';

  @override
  String get perfil => 'Profile';

  @override
  String get editarPerfil => 'Edit Profile';

  @override
  String get impulsar => 'Boost';

  @override
  String get eliminarPublicidad => 'Remove ads';

  @override
  String get cerrarSesion => 'Sign Out';

  @override
  String get privacidadYSeguridad => 'Privacy & Security';

  @override
  String get soporte => 'Support';

  @override
  String get terminosDeServicio => 'Terms of Service';

  @override
  String get misArticulos => 'My items';

  @override
  String get masVistos => 'Most viewed';

  @override
  String get favoritos => 'Favorites';

  @override
  String get miPerfil => 'My Profile';

  @override
  String get verPortafolio => 'View Portfolio';

  @override
  String get verTodosMisProductos => 'View all my published products';

  @override
  String get opcionesDelVendedor => 'Seller Options';

  @override
  String get desbloquear => 'Unblock';

  @override
  String get bloquear => 'Block';

  @override
  String desbloquearA(String nombre) {
    return 'Unblock $nombre';
  }

  @override
  String bloquearA(String nombre) {
    return 'Block $nombre';
  }

  @override
  String get verInformacionDePerfil => 'View profile information';

  @override
  String verDetallesDe(String nombre) {
    return 'View details of $nombre';
  }

  @override
  String verTodosLosProductosDe(String nombre) {
    return 'View all products from $nombre';
  }

  @override
  String get denunciarVendedor => 'Report seller';

  @override
  String reportarA(String nombre) {
    return 'Report $nombre for breaking the rules';
  }

  @override
  String get vendedorBloqueadoCorrectamente =>
      'Seller blocked successfully. Restarting...';

  @override
  String get vendedorDesbloqueadoCorrectamente =>
      'Seller unblocked successfully. Restarting...';

  @override
  String get errorAlBloquear => 'Error blocking';

  @override
  String get errorAlDesbloquear => 'Error unblocking';

  @override
  String get errorAlBloquearUsuario => 'Error blocking user';

  @override
  String get errorAlDesbloquearUsuario => 'Error unblocking user';

  @override
  String get denunciarVendedorTitulo => '⚠️ Report seller';

  @override
  String get seleccionaMotivoDenuncia => 'Select the reason for the report:';

  @override
  String get denunciaRevisadaPorEquipo =>
      'This report will be reviewed by our moderation team.';

  @override
  String get denunciar => 'Report';

  @override
  String get debesIniciarSesionParaDenunciar => 'You must log in to report';

  @override
  String get denunciaEnviada =>
      '✅ Report sent. It will be reviewed by moderation.';

  @override
  String errorAlEnviarDenuncia(String error) {
    return 'Error sending report: $error';
  }

  @override
  String get motivoProductoSospechoso => 'Suspicious product';

  @override
  String get motivoProductosProhibidos => 'Publishing prohibited products';

  @override
  String get motivoEstafaFraude => 'Scam or fraud';

  @override
  String get motivoAcosoMaltrato => 'Harassment or abuse';

  @override
  String get motivoInformacionFalsa => 'False or misleading information';

  @override
  String get motivoOtro => 'Other reason';

  @override
  String get vendedor => 'Seller';

  @override
  String get esteVendedor => 'this seller';

  @override
  String get miPortafolio => 'My Portfolio';

  @override
  String get debesIniciarSesion => 'You must log in';

  @override
  String get editarProducto => 'Edit Product';

  @override
  String get contactarVendedor => 'Contact Seller';

  @override
  String compartirProductoMensaje(String enlace) {
    return '📱 Check out this product on MiMarketplace:\n\n$enlace';
  }

  @override
  String get noHasPublicadoNingunArticulo => 'You haven\'t published any items';

  @override
  String get noTienesProductosFavoritos => 'You don\'t have favorite products';

  @override
  String get reintentar => 'Retry';

  @override
  String get noHayCalificacionesAun => 'No ratings yet';

  @override
  String get sinComentario => 'No comment';

  @override
  String get usuario => 'User';

  @override
  String get cerrarSesionExitoso => 'Signed out';

  @override
  String get estiloVisualDelPerfil => '🎨 Profile visual style';

  @override
  String get eligeElFondoQueMasTeGuste => 'Choose the background you like best';

  @override
  String get atardecer => 'Sunset';

  @override
  String get galaxia => 'Galaxy';

  @override
  String get oceano => 'Ocean';

  @override
  String get volcan => 'Volcano';

  @override
  String get cancelar => 'Cancel';

  @override
  String get eliminar => 'Delete';

  @override
  String get confirmar => 'Confirm';

  @override
  String get yaSeVendio => 'Already sold?';

  @override
  String get calificacion => 'rating';

  @override
  String get calificaciones => 'ratings';

  @override
  String get queVasAVender => 'What are you selling?';

  @override
  String get seleccionaCategoria =>
      'Select the category that best describes your item';

  @override
  String get buscarCategoria => 'Search category...';

  @override
  String get noSeEncontraronCategorias => 'No categories found';

  @override
  String get todasLasCategorias => 'All categories';

  @override
  String get seleccionar => 'Select';

  @override
  String get chateaConCompradoresVendedores => 'Chat with buyers and sellers';

  @override
  String get tabChats => 'CHATS';

  @override
  String get tabAgenda => 'AGENDA';

  @override
  String get tabEncuentros => 'MEETINGS';

  @override
  String get noTienesConversaciones => 'You have no conversations';

  @override
  String get encuentroAceptado => 'MEETING ACCEPTED';

  @override
  String get articuloVendido => 'ITEM SOLD';

  @override
  String get nuevoMensaje => 'NEW MESSAGE';

  @override
  String get fijarChat => 'Pin chat';

  @override
  String get desfijarChat => 'Unpin chat';

  @override
  String get quitarDeLaParteSuperior => 'Remove from top';

  @override
  String get mantenerEnLaParteSuperior => 'Keep at the top';

  @override
  String get chatFijado => '📌 Chat pinned';

  @override
  String get chatDesfijado => '📌 Chat unpinned';

  @override
  String errorAlFijar(String codigo) {
    return 'Error pinning: $codigo';
  }

  @override
  String get eliminarChat => 'Delete chat';

  @override
  String confirmarEliminarChat(String nombre) {
    return 'Are you sure you want to delete the conversation with $nombre?';
  }

  @override
  String get chatEliminado => '🗑️ Chat deleted';

  @override
  String guardadoConProductos(int cantidad) {
    return '✅ Saved ($cantidad products)';
  }

  @override
  String get eliminado => '🗑️ Deleted';

  @override
  String get buscarContactosProductos => 'Search contacts or products...';

  @override
  String get noHayContactosGuardados => 'No saved contacts';

  @override
  String noHayResultadosPara(String busqueda) {
    return 'No results for \"$busqueda\"';
  }

  @override
  String get tocaBotonParaGuardarContacto =>
      'Tap the button in a chat to save the contact to your agenda';

  @override
  String get producto => 'Product';

  @override
  String get sinMensajes => 'No messages';

  @override
  String get fechaDesconocida => 'Unknown date';

  @override
  String haceDias(int cantidad) {
    return '$cantidad days ago';
  }

  @override
  String haceHoras(int cantidad) {
    return '$cantidad hours ago';
  }

  @override
  String haceMinutos(int cantidad) {
    return '$cantidad minutes ago';
  }

  @override
  String get haceUnosSegundos => 'a few seconds ago';

  @override
  String get lun => 'Mon';

  @override
  String get mar => 'Tue';

  @override
  String get mie => 'Wed';

  @override
  String get jue => 'Thu';

  @override
  String get vie => 'Fri';

  @override
  String get sab => 'Sat';

  @override
  String errorGenerico(String error) {
    return 'Error: $error';
  }

  @override
  String errorGenericoAlerta(String error) {
    return 'Error: $error';
  }

  @override
  String get errorDesconocido => 'Unknown';

  @override
  String get catElectronicos => 'Electronics';

  @override
  String get catDeportes => 'Sports';

  @override
  String get catHogar => 'Home';

  @override
  String get catMusica => 'Music';

  @override
  String get catCocina => 'Kitchen';

  @override
  String get catPeliculas => 'Movies';

  @override
  String get catFotografia => 'Photography';

  @override
  String get catVideojuegos => 'Video Games';

  @override
  String get catJuegosDeMesa => 'Board Games';

  @override
  String get catJuguetes => 'Toys';

  @override
  String get catFiguras => 'Figures';

  @override
  String get catAutomoviles => 'Cars';

  @override
  String get catHerramientas => 'Tools';

  @override
  String get catRopaYCalzado => 'Clothing & Footwear';

  @override
  String get subElectronicos => 'Phones, Laptops, Audio';

  @override
  String get subDeportes => 'Soccer, Tennis, Running';

  @override
  String get subHogar => 'Furniture, Decor, Kitchen';

  @override
  String get subMusica => 'Guitars, Pianos, Audio';

  @override
  String get subCocina => 'Pots, Utensils, Dishes';

  @override
  String get subPeliculas => 'Action, Comedy, Drama';

  @override
  String get subFotografia => 'Cameras, Lenses, Accessories';

  @override
  String get subVideojuegos => 'Consoles, Games, Controllers';

  @override
  String get subJuegosDeMesa => 'Cards, Boards, Strategy';

  @override
  String get subJuguetes => 'Plush, Blocks, Cars';

  @override
  String get subFiguras => 'Action, Collectibles, Anime';

  @override
  String get alertasTitulo => 'Alerts';

  @override
  String get recargar => 'Reload';

  @override
  String get limpiarTodasLasAlertas => 'Clear all alerts';

  @override
  String get noTienesAlertas => 'You have no alerts';

  @override
  String get aquiApareceranAvisos =>
      'Your notices and meetings will appear here.';

  @override
  String get noHayAlertasParaLimpiar => 'No alerts to clear';

  @override
  String get limpiarAlertas => '🗑️ Clear alerts';

  @override
  String get confirmarLimpiarAlertas =>
      'Are you sure you want to delete all alerts?';

  @override
  String get eliminarTodo => 'Delete all';

  @override
  String get todasLasAlertasEliminadas => '✅ All alerts have been deleted';

  @override
  String errorAlLimpiarAlertas(String error) {
    return 'Error clearing alerts: $error';
  }

  @override
  String get cargandoAnuncio => '⏳ Loading ad... please wait';

  @override
  String get noSePudoCargarAnuncio => '❌ Could not load the ad. Try again.';

  @override
  String get productoRenovado => '✅ Product renewed for 30 more days';

  @override
  String errorAlRenovar(String error) {
    return 'Error renewing: $error';
  }

  @override
  String get debesVerAnuncioCompleto => '❌ You must watch the full ad to renew';

  @override
  String get renovarPor30Dias => 'Renew for 30 days';

  @override
  String get ambosConfirmaron => 'Both confirmed';

  @override
  String get esperandoAlOtro => 'Waiting for the other';

  @override
  String get confirmarEncuentro => 'Confirm meeting';

  @override
  String get verificarIdentidad => 'Verify identity';

  @override
  String get verificarIdentidadDelOtro => 'Verify the other\'s identity';

  @override
  String get identidadRechazada => 'Identity rejected';

  @override
  String get revisarComparacion => 'Review comparison';

  @override
  String get ambosConfirmaronExito => '✅ Both confirmed. See you there!';

  @override
  String get confirmasteAsistencia =>
      '✅ You confirmed your attendance. Waiting for the other.';

  @override
  String get eliminarPublicidadTitulo => 'Remove ads';

  @override
  String get eliminaLosAnuncios => 'Remove the ads';

  @override
  String get descripcionEliminarPublicidad =>
      'Pay for a plan and browse ad-free across the whole app. No ads, no interruptions.';

  @override
  String get beneficioSinAnuncios => 'No ads across the app';

  @override
  String get beneficioNavegacionRapida => 'Faster navigation';

  @override
  String get beneficioSinInterrupciones => 'Uninterrupted experience';

  @override
  String get elegiTuPlan => 'Choose your plan';

  @override
  String get plan1Mes => '1 month';

  @override
  String get plan6Meses => '6 months';

  @override
  String get sinAnunciosPor30Dias => 'No ads for 30 days';

  @override
  String get sinAnunciosPor180Dias => 'No ads for 180 days';

  @override
  String ahorrasMonto(String monto) {
    return 'You save $monto';
  }

  @override
  String get elegiUnPlan => 'Choose a plan';

  @override
  String pagarMonto(String monto) {
    return 'Pay $monto';
  }

  @override
  String get pagoSeguro => 'Payment is processed securely';

  @override
  String get confirmarCompra => 'Confirm purchase';

  @override
  String confirmarCompraPregunta(String precio, String duracion) {
    return 'Do you want to pay $precio for $duracion without ads?';
  }

  @override
  String get pagar => 'Pay';

  @override
  String get integracionPagoEnDesarrollo =>
      '🚧 Payment integration in progress';

  @override
  String get encuentroCaducado => 'Meeting expired';

  @override
  String get esperandoVerificacionDelOtro =>
      'Waiting for the other person to verify your selfie';

  @override
  String get verificacionCompleta => 'Verification complete';

  @override
  String get premiumActivoTitulo => 'You\'re premium!';

  @override
  String get premiumActivoDescripcion => 'Ads have been removed';

  @override
  String get planUnaSemana => '1 Week';

  @override
  String get sinAnunciosPor7Dias => 'Ad-free for 7 days';

  @override
  String get yaTenesAnunciosEliminados => 'Ads have already been removed';

  @override
  String get productoNoDisponible => 'Product unavailable';

  @override
  String errorCompra(String detalle) {
    return 'Error: $detalle';
  }

  @override
  String get desconocido => 'Unknown';

  @override
  String get usuarioNoLogueado => 'No user is logged in';

  @override
  String get errorVerificarCompra => 'Error verifying purchase';

  @override
  String get compraExitosaAnunciosEliminados =>
      '✅ Done! Ads have been removed.';

  @override
  String get configurarImpulso => 'Configure boost';

  @override
  String get impulsarTitulo => 'Boost';

  @override
  String get impulsarPublicacion => 'Boost listing';

  @override
  String get poneTuProductoPrimero => 'Put your product first';

  @override
  String get impulsarPunto1Titulo => 'Go to first place';

  @override
  String get impulsarPunto1Desc =>
      'Your product appears first in the Featured Products list on the Home screen.';

  @override
  String get impulsarPunto2Titulo => 'More visibility';

  @override
  String get impulsarPunto2Desc =>
      'Being first, more people see it and you have a better chance of selling it fast.';

  @override
  String get impulsarPunto3Titulo => 'Limited duration';

  @override
  String get impulsarPunto3Desc =>
      'The boost lasts until another seller pays to move up. Then you go down one place.';

  @override
  String get seleccionarArticulo => 'Select item';

  @override
  String get proximamenteDisponiblePagos =>
      'Coming soon. We\'re enabling payments.';

  @override
  String get articuloAImpulsar => 'Item to boost';

  @override
  String get comoFuncionaImpulso => 'How does it work?';

  @override
  String get explicacionImpulso =>
      'When you boost, your product goes to the top of the Home screen. If another seller boosts their product, you go down one place. Whoever paid most recently is always first.';

  @override
  String get procesando => 'Processing...';

  @override
  String get cargando => 'Loading...';

  @override
  String get impulsarAhora => 'Boost now';

  @override
  String get cambiarProducto => 'Change product';

  @override
  String get noTenesProductosPublicados => 'You have no published products';

  @override
  String get elegiUnArticulo => 'Choose an item';

  @override
  String get elQueElijasApareceraPrimero =>
      'The one you choose will appear first on the Home screen';

  @override
  String get primeroElegiUnArticulo => 'First choose an item';

  @override
  String get productoImpulsoNoDisponible =>
      'Boost product unavailable. Check your connection.';

  @override
  String productoEstaPrimeroEnHome(String nombre) {
    return '✅ \"$nombre\" is first on the Home screen';
  }

  @override
  String get pagoNoVerificado =>
      'Payment could not be verified. Contact support.';

  @override
  String get compraPendiente => 'Purchase is pending. Try again.';

  @override
  String get errorAlImpulsar => 'Error boosting';

  @override
  String escudoActivoPor(String nombre) {
    return '$nombre activated the Security Shield';
  }

  @override
  String get escudoPaso0Titulo => 'What is the Security Shield?';

  @override
  String get escudoPaso0Desc =>
      'It\'s a set of protection measures that activate when both users of a deal accept them. Its goal is to prevent fraud and ensure the meeting is safe.\n\nWho should activate it?\nBoth users of the deal must accept the Shield. If one activates it, the other receives a notification to accept or reject it. If the second user rejects it, the chat will close for both.';

  @override
  String get escudoPaso1Titulo => 'What happens when the Shield is active?';

  @override
  String get escudoPaso1Desc =>
      '3.1. Link and phone blocking: The app automatically detects and blocks phone numbers and external links in messages. This prevents sharing contact info outside the platform and reduces the risk of scams.';

  @override
  String get escudoPaso2Titulo => 'How to close the deal';

  @override
  String get escudoPaso2Desc =>
      'To close the deal, first propose a meeting: tap the shield in the chat\'s top bar and choose \"Propose meeting\". There you select province, canton, district, a safe place and the date with time. Send the proposal and the other user receives it as a card in the chat. When they accept, the meeting is scheduled but the chat stays open: you can keep talking. To close the deal, tap the shield again and choose \"Close deal\". A confirmation dialog opens. When both confirm, the chat is blocked and protections activate.';

  @override
  String get escudoPaso3Titulo => 'Attendance confirmation';

  @override
  String get escudoPaso3Desc =>
      'One hour before the meeting, both users will receive a notification to confirm their attendance. If either doesn\'t confirm within 15 minutes after the notification, the other user can cancel the meeting up to 15 minutes before the agreed time.';

  @override
  String get escudoPaso4Titulo => 'GPS tracking';

  @override
  String get escudoPaso4Desc =>
      '3.3. GPS tracking on the day of the meeting: On the agreed day, 15 minutes before the meeting time, both users must be at the place and activate GPS to verify their location. If 5 minutes before the agreed time the user hasn\'t activated GPS and hasn\'t verified their identity, it will be considered late. If 15 minutes after the agreed time the user hasn\'t done so, it will be considered a no-show. In both cases, it\'s recorded and can be sanctioned according to MiMarketplace rules.';

  @override
  String get escudoPaso5Titulo => 'Facial verification';

  @override
  String get escudoPaso5Desc =>
      '3.4. Identity verification before chat: To unlock the meeting chat, both users must confirm they are who they say they are. This is enabled 15 minutes before the agreed time and is a mandatory requirement to open the chat. The system will ask each one to take a photo on the spot. Then, the other user must compare that photo with the profile photo to confirm they match. It\'s important to pay attention, because verification is enabled when the other user activates it, and you must follow the instructions on screen. This prevents someone else from using the account.';

  @override
  String get escudoPaso6Titulo => 'Additional considerations';

  @override
  String get escudoPaso6Desc =>
      '4.1. Voluntary cancellation: Any user can cancel their attendance to the meeting as long as more than one hour remains before the agreed time. Once less than one hour remains, cancellation is no longer available.\n\nHow to cancel? Enter the item chat, tap the shield button in the top bar and choose \"Cancel deal\". A dialog opens showing the meeting date and telling you if you can still cancel or if less than an hour remains. If possible, confirm and the meeting is canceled for both.\n\nAlways check the Alerts section. Meeting reminders, attendance confirmation, identity verification and any status changes arrive there. You must check them often so you don\'t miss anything important.';

  @override
  String get noAceptar => 'Don\'t accept';

  @override
  String get aceptar => 'Accept';

  @override
  String get cerrar => 'Close';

  @override
  String get siguiente => 'Next';

  @override
  String get iniciar => 'Start';

  @override
  String get verVideo => 'Watch video';

  @override
  String errorGenericoImpulsar(String error) {
    return 'Error: $error';
  }

  @override
  String get ubicacionDelEncuentro => 'Meeting location';

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
  String get porFavorEscribeUnMensaje => 'Please write a message';

  @override
  String get porFavorEscribeUnAsunto => 'Please write a subject';

  @override
  String get mensajeEnviadoExito =>
      '✅ Message sent. We\'ll get back to you soon.';

  @override
  String get necesitasAyuda => 'Need help?';

  @override
  String get cuentanosTuProblema =>
      'Tell us your problem and we\'ll help you solve it.';

  @override
  String get tipoDeConsulta => 'Inquiry type';

  @override
  String get asunto => 'Subject';

  @override
  String get ejemploProblemaCuenta => 'Ex: Problem with my account';

  @override
  String get mensaje => 'Message';

  @override
  String get describeTuProblema =>
      'Describe your problem in as much detail as possible...';

  @override
  String get enviarMensaje => 'Send message';

  @override
  String get tiempoRespuestaEstimado => 'Estimated response time: 24-48 hours';

  @override
  String get mensajeEnviado => 'Message sent!';

  @override
  String get hemosRecibidoTuConsulta =>
      'We have received your inquiry. Our support team will respond within the next 24-48 hours.';

  @override
  String get enviarOtroMensaje => 'Send another message';

  @override
  String get volver => 'Back';

  @override
  String get categoria => 'Category';

  @override
  String get direccion => 'Address';

  @override
  String get nombreDelProducto => 'Product name';

  @override
  String get ejemploNombreProducto => 'Ex. iPhone 13, Laptop, etc.';

  @override
  String get ingresaNombreProducto => 'Enter the product name';

  @override
  String get nombreMinimoCaracteres => 'The name must be at least 3 characters';

  @override
  String get precio => 'Price (₡)';

  @override
  String get ingresePrecioProducto => 'Enter the product price';

  @override
  String get ingresaPrecio => 'Enter the price';

  @override
  String get ingresaPrecioValido => 'Enter a valid price';

  @override
  String get precioMayorCero => 'The price must be greater than 0';

  @override
  String get descripcion => 'Description';

  @override
  String get escribeDescripcionDetallada =>
      'Write a detailed description of the product...';

  @override
  String get ingresaDescripcion => 'Enter a description';

  @override
  String get publicarProducto => 'Publish Product';

  @override
  String get compartaProductoComunidad =>
      'Share your product with the community';

  @override
  String get anuncioCompletado => '✅ Ad completed. Publishing product...';

  @override
  String get debesVerAnuncioParaPublicar =>
      '❌ You must watch the full ad to publish';

  @override
  String get productoEnviadoRevision =>
      '📝 Product sent for review. You\'ll be notified when approved.';

  @override
  String errorAlPublicar(String error) {
    return 'Error publishing: $error';
  }

  @override
  String get paraPublicarNecesitasVerAnuncio =>
      'To publish your product, you need to watch a short ad.';

  @override
  String get verAnuncio => 'Watch ad';

  @override
  String get agregarImagenes => 'Add images';

  @override
  String get imagenDestacada => 'Featured Image';

  @override
  String get estaImagenApareceraPortada =>
      'This image will appear on the product cover and in the featured section.';

  @override
  String get soloImagenesCalidadEstudio =>
      'Only images with studio-quality photography (good lighting, sharp focus, clean background) are accepted.';

  @override
  String get tocaParaSeleccionarImagen => 'Tap to select an image';

  @override
  String get formatosImagenPermitidos => 'JPG, PNG or WEBP · Max. 10 MB';

  @override
  String get enRevisionPuntos => '🔍 Under review...';

  @override
  String get enviadoARevision => '🔄 Sent for review';

  @override
  String get enviarARevision => '🛡️ Send for review';

  @override
  String get imagenRevisadaIA =>
      'The image will be reviewed by AI. You\'ll be notified when approved.';

  @override
  String get imagenesRealesProducto => 'Real Product Images';

  @override
  String get subeHasta4Fotos => 'Upload up to 4 real product photos (required)';

  @override
  String get agregar => 'Add';

  @override
  String get maximo4ImagenesReales =>
      '⚠️ You can only upload up to 4 real images';

  @override
  String get escribeDescripcionMejorarImagen =>
      'Write a description to improve the image';

  @override
  String get primeroSeleccionaImagen => 'First select an image';

  @override
  String get imagenMejoradaCorrectamente => '✅ Image improved successfully';

  @override
  String get errorGenerarImagen => 'Error generating image';

  @override
  String get imagenEnviadaRevision =>
      '🔄 Image sent for review. You\'ll be notified when approved.';

  @override
  String errorEnviarImagen(String codigo) {
    return 'Error sending image: $codigo';
  }

  @override
  String get revisionDeImagen => '🛡️ Image review';

  @override
  String get tuImagenSeraEnviadaModeracion =>
      'Your image will be sent to our moderation team for review. To continue, you need to watch a short ad.';

  @override
  String get revisionPuedeTomar24Horas => 'Review may take up to 24 hours.';

  @override
  String get verAnuncioConEmoji => 'Watch ad 🎬';

  @override
  String get anuncioCompletadoEnviandoImagen =>
      '✅ Ad completed. Sending image for review...';

  @override
  String get debesVerAnuncioParaEnviarImagen =>
      '❌ You must watch the full ad to send the image';

  @override
  String get seleccionaAlMenos1Imagen => 'Select at least 1 real image';

  @override
  String get siguienteConFlecha => 'Next →';

  @override
  String get recoleccionDeDatos => 'Data collection';

  @override
  String get tuPrivacidadImportante =>
      'Your privacy is important to us. You can choose whether to allow your browsing data and preferences to be collected to receive personalized product suggestions.';

  @override
  String get aceptoRecoleccionDatos =>
      'I agree that my browsing data and preferences may be collected to receive personalized product suggestions.';

  @override
  String get guardarPreferencias => 'Save preferences';

  @override
  String get preferenciasGuardadas => '✅ Preferences saved';

  @override
  String get errorAlGuardar => 'Error saving';

  @override
  String get historialDePagos => 'Payment history';

  @override
  String get consultaTodosLosPagos =>
      'Check all the payments you made within the app: listing boosts, renewals, ad removal and other services.';

  @override
  String get verHistorialDePagos => 'View payment history';

  @override
  String get todosTusPagosTransacciones => 'All your payments and transactions';

  @override
  String get estadoDeCuenta => 'Account status';

  @override
  String get revisaTusAdvertencias =>
      'Review your warnings and active suspensions on the platform.';

  @override
  String get advertencias => 'Warnings';

  @override
  String get suspensionesTemporales => 'Temporary suspensions';

  @override
  String get asistenciaAEncuentros => 'Meetup attendance';

  @override
  String get llegadasTardias => 'Late arrivals';

  @override
  String get noVerificaste5Min =>
      'You didn\'t verify within 5 min or less. 3 = 1 warning';

  @override
  String get ausencias => 'Absences';

  @override
  String get noLlegasteEncuentro =>
      'You didn\'t show up to the meetup. 1 = 1 warning';

  @override
  String minutosTardeAcumulados(int cantidad) {
    return '⏱️ Accumulated late minutes: $cantidad';
  }

  @override
  String get informacion => 'Information';

  @override
  String get comoFunciona => 'How does it work?';

  @override
  String get comoFuncionaEstadoCuenta =>
      'Your account accumulates warnings and temporary suspensions for violating community rules.\n\nMeetup attendance:\n• 3 late arrivals (0/3) = 1 warning.\n• 1 absence = 1 warning.\n\nEscalation:\n• 3 warnings = 1 temporary suspension (7 days).\n• 3 suspensions = permanent ban.\n\nRecovery:\n• Each month 2 late arrivals are deducted.\n• Every 3 months 1 warning is deducted.';

  @override
  String get advertenciasInfo =>
      'Warnings (max. 3): generated by minor reports such as inappropriate language, misleading listings or minor rule violations. They don\'t block your account.';

  @override
  String get suspensionesInfo =>
      'Temporary suspensions (max. 3): applied for more serious offenses such as scams, harassment, identity impersonation or repeat warnings. Each suspension blocks your account for a period.';

  @override
  String get baneoInfo =>
      'If you reach 3 suspensions, your account will be permanently banned and its email cannot be registered again.';

  @override
  String get entendido => 'Got it';

  @override
  String get guardar => 'Save';

  @override
  String get guardarCambios => 'Save Changes';

  @override
  String get nombreCompleto => 'Full name';

  @override
  String get telefono => 'Phone';

  @override
  String get usuarioNoAutenticado => 'User not authenticated';

  @override
  String get errorAlCargarDatos => 'Error loading data';

  @override
  String get nombreNoPuedeEstarVacio => 'Name cannot be empty';

  @override
  String get perfilActualizadoCorrectamente => '✅ Profile updated successfully';

  @override
  String get errorAlGuardarEnServidor => 'Error saving to server';

  @override
  String get volverAlPerfil => 'Volver al perfil';

  @override
  String get chatShieldAccepted => '🛡️ Shield accepted';

  @override
  String get chatShieldRejected =>
      '🚫 Shield rejected. The chat has been closed.';

  @override
  String get chatRatingSent => 'Rating submitted! Thanks for your feedback.';

  @override
  String get chatMessageBlocked => 'Message blocked';

  @override
  String get chatPhoneBlocked =>
      'The Safety Shield blocked this message.\n\nReason: Phone numbers are not allowed.';

  @override
  String get chatUnderstood => 'Got it';

  @override
  String get chatMeetingNotHeld =>
      'The meeting did not take place. Delete this chat and reopen it to continue chatting.';

  @override
  String get chatGallery => 'Gallery';

  @override
  String get chatCamera => 'Camera';

  @override
  String get chatShareLocation => 'Share location';

  @override
  String get chatSharePortfolio => 'Share portfolio';

  @override
  String get chatEnableGps =>
      'Turn on your phone\'s GPS to share your location';

  @override
  String get chatLocationPermission => 'Location permission is required';

  @override
  String get chatGettingLocation => '📍 Getting your location...';

  @override
  String get chatCannotOpenApp => 'Could not open the app';

  @override
  String get chatOpenLocationWith => 'Open location with...';

  @override
  String get chatPortfolioShared => '📤 Portfolio shared';

  @override
  String get chatDontShowAgain => 'Don\'t show again';

  @override
  String get chatCancel => 'Cancel';

  @override
  String get chatContinue => 'Continue';

  @override
  String get chatOtherUser => 'The other user';

  @override
  String chatGenericError(String error) {
    return 'Error: $error';
  }

  @override
  String chatLocationSendError(String statusCode) {
    return 'Could not send location ($statusCode)';
  }

  @override
  String chatLocationGetError(String error) {
    return 'Error getting location: $error';
  }

  @override
  String chatImageSendError(String error) {
    return 'Error sending image: $error';
  }

  @override
  String get chatAudioPermissionRequired =>
      'Microphone permission is required to record audio';

  @override
  String get chatRecordingTapToStop => '🎤 Recording... tap again to stop';

  @override
  String chatRecordingError(String error) {
    return 'Recording error: $error';
  }

  @override
  String get chatVerifyingAudio => '🛡️ Verifying audio...';

  @override
  String get chatAudioSent => '🎤 Audio sent';

  @override
  String chatAudioSendError(String error) {
    return 'Error sending audio: $error';
  }

  @override
  String get chatRecordingLimitReached =>
      '⏱️ 25-second recording limit reached';

  @override
  String get chatRecordingCancelled => '🗑️ Recording cancelled';

  @override
  String get chatSendingAudio => '📤 Sending audio...';

  @override
  String chatStopRecordingError(String error) {
    return 'Error stopping recording: $error';
  }

  @override
  String chatAudioPlaybackError(String error) {
    return 'Error playing audio: $error';
  }

  @override
  String get chatSellerBlocked => 'Seller blocked successfully';

  @override
  String get chatSellerBlockError => 'Error blocking seller';

  @override
  String get chatSellerUnblocked => 'Seller unblocked successfully';

  @override
  String get chatSellerUnblockError => 'Error unblocking seller';

  @override
  String get chatReportSeller => 'Report seller';

  @override
  String get chatReport => 'Report';

  @override
  String get chatReportLoginRequired => 'You must sign in to submit a report';

  @override
  String get chatReportSent =>
      'Report submitted. It will be reviewed by our moderation team.';

  @override
  String chatReportSendError(String error) {
    return 'Error submitting report: $error';
  }

  @override
  String get chatInternetSearchComingSoon =>
      'The \"Search the internet\" feature is under development';

  @override
  String get chatSelectText => 'Select text';

  @override
  String get chatSelectTextToCopy => 'Select the text you want to copy:';

  @override
  String get chatClose => 'Close';

  @override
  String get chatAccept => 'Accept';

  @override
  String get chatReject => 'Reject';

  @override
  String get chatConfirmMeetingQuestion => 'Confirm meeting?';

  @override
  String get chatConfirm => 'Confirm';

  @override
  String get chatMeetingConfirmed => 'Meeting confirmed';

  @override
  String get chatMeetingNotFound => 'The scheduled meeting could not be found';

  @override
  String get chatMeetingCancelledReopened =>
      'Meeting cancelled. The chat has been reopened.';

  @override
  String get chatCannotCancelMeeting => 'Could not cancel';

  @override
  String get chatRecordingNotActive => 'Recording is not active';

  @override
  String get chatRecordingStopped => 'Recording stopped';

  @override
  String get chatWriteMessage => 'Type a message...';

  @override
  String chatSellerBlockException(String error) {
    return 'Error blocking seller: $error';
  }

  @override
  String chatSellerUnblockException(String error) {
    return 'Error unblocking seller: $error';
  }

  @override
  String get chatSelectReportReason => 'Select a reason for the report:';

  @override
  String get chatReportModerationNotice =>
      'This report will be reviewed by our moderation team.';

  @override
  String get chatSellerOptions => 'Seller Options';

  @override
  String get chatUnblock => 'Unblock';

  @override
  String get chatBlock => 'Block';

  @override
  String chatUnblockUser(String userName) {
    return 'Unblock $userName';
  }

  @override
  String chatBlockUser(String userName) {
    return 'Block $userName';
  }

  @override
  String get chatViewProfileInfo => 'View profile information';

  @override
  String chatViewUserDetails(String userName) {
    return 'View details for $userName';
  }

  @override
  String get chatViewPortfolio => 'View Portfolio';

  @override
  String chatViewUserProducts(String userName) {
    return 'View all products from $userName';
  }

  @override
  String chatReportUserRules(String userName) {
    return 'Report $userName for violating the rules';
  }

  @override
  String get chatStrikeMessage => 'Strike through message';

  @override
  String get chatStrikeMessageDescription =>
      'Strike through this message to mark it as resolved';

  @override
  String get chatMessageStruck => 'Message struck through';

  @override
  String get chatStrikeRemoved => 'Strikethrough removed';

  @override
  String get chatSearchInternet => 'Search the internet';

  @override
  String get chatSearchMessageGoogle => 'Search for this message on Google';

  @override
  String get chatOnline => 'online';

  @override
  String get chatLastSeen => 'last seen';

  @override
  String get chatLastSeenToday => 'last seen today';

  @override
  String get chatLastSeenYesterday => 'last seen yesterday';

  @override
  String chatLastSeenOn(String date) {
    return 'last seen on $date';
  }

  @override
  String get chatPortfolioSharedByYou => 'You shared your portfolio';

  @override
  String chatPortfolioOfUser(String userName) {
    return '$userName\'s portfolio';
  }

  @override
  String get chatTapToViewProducts => 'Tap to view products';

  @override
  String get chatView => 'View';

  @override
  String get chatYou => 'You';

  @override
  String get chatShieldAudioTitle => 'Audio with the Shield';

  @override
  String get chatShieldImageTitle => 'Images with the Shield';

  @override
  String chatShieldAudioInstructions(String productName) {
    return '• You can record up to 25 seconds.\n• Audio is reviewed by AI and must only discuss \"$productName\".\n• Phone numbers, social media, payments outside the app, insults, and unrelated topics are not allowed.\n\nWhen you close this window, press and hold the microphone to record.';
  }

  @override
  String chatShieldImageInstructions(String productName) {
    return '• You can only send 1 image in this chat.\n• Images are reviewed by AI and must show the product \"$productName\".\n• Phone numbers, QR codes, social media, payments outside the app, and sexual, violent, or offensive content are not allowed.';
  }

  @override
  String get chatImageLimitTitle => 'Image limit';

  @override
  String get chatImageLimitBody =>
      'With the Shield active, you can only send 1 image in this chat.';

  @override
  String get chatCropImage => 'Crop image';

  @override
  String get chatDone => 'Done';

  @override
  String get chatImageRejected => 'Image rejected';

  @override
  String get chatAudioRejected => 'Audio rejected';

  @override
  String get chatStatusNeutral => 'Neutral Status';

  @override
  String get chatNeutralDescription =>
      'The conversation is ongoing. There is not yet enough information to determine the status of the transaction.';

  @override
  String get chatNeutralRecommendation =>
      'Continue communicating respectfully and clearly.';

  @override
  String get chatStatusHealthy => 'Healthy Conversation';

  @override
  String get chatHealthyDescription =>
      'The conversation is progressing positively. Both users are communicating respectfully and clearly.';

  @override
  String get chatHealthyRecommendation =>
      'Keep it up! The transaction has a good chance of success.';

  @override
  String get chatStatusWarning => 'Caution Recommended';

  @override
  String get chatWarningDescription =>
      'Some warning signs have been detected in the conversation. There may be misunderstandings or tension.';

  @override
  String get chatWarningRecommendation =>
      'Review previous messages. Try to be clearer and more empathetic in your responses.';

  @override
  String get chatStatusDanger => 'Imminent Danger';

  @override
  String get chatDangerDescription =>
      'The conversation shows signs of conflict or risk. There may be poor communication or serious disagreements.';

  @override
  String get chatDangerRecommendation =>
      'Stop and assess the situation. Consider contacting support if necessary.';

  @override
  String get chatCancelMeetingQuestion => 'Cancel the meeting?';

  @override
  String get chatRecordingRejectionWarning =>
      'If you reject the security voice recording, the meeting will be canceled for BOTH users and the chat will be closed.\n\nThis action cannot be undone.';

  @override
  String get chatGoBack => 'Go back';

  @override
  String get chatYesCancelMeeting => 'Yes, cancel the meeting';

  @override
  String get chatSecurityVoiceRecording => 'Security Voice Recording';

  @override
  String get chatSecurityRecordingConsentBody =>
      'From this moment on, the app WILL RECORD the audio from this conversation on BOTH devices, solely to protect users.\n\n• Audio segments are saved every 10 seconds.\n• The recording may be shared with a third party (an authority or security expert) if a report or incident occurs.\n• No one else may listen to the recordings without your permission or a legal order.\n\n⚠️ IMPORTANT: Security recording is MANDATORY to proceed with the meeting.\n\nIf you REJECT recording, the meeting will be automatically CANCELED for both users and the chat will be closed. You will not be able to proceed with the in-person meeting through the app.';

  @override
  String get chatRejectAndCancel => 'Reject and cancel';

  @override
  String get chatAcceptAndContinue => 'Accept and continue';

  @override
  String get chatProposeMeeting => 'Propose a meeting';

  @override
  String get chatChooseSafePlace => 'Choose a safe place from the list.';

  @override
  String chatProposalNumber(int number) {
    return 'Proposal $number of 3';
  }

  @override
  String get chatChoosePlaceOnMap => 'Choose a location on the map';

  @override
  String get chatPlaceSelected => 'Location selected';

  @override
  String get chatTapToOpenMap => 'Tap to open the map';

  @override
  String get chatChooseTime => 'Choose a time (7:00 AM – 6:00 PM)';

  @override
  String get chatSelectDateTime => 'Select date and time';

  @override
  String get chatSelectPlaceAndDate =>
      '⚠️ Choose a location on the map and select a date';

  @override
  String get chatTimeSlotOccupiedChooseAnother =>
      '⛔ That date and time are already booked. Choose another time.';

  @override
  String get chatAddProposal => 'Add proposal';

  @override
  String get chatAddAndViewSummary => 'Add and view summary';

  @override
  String chatViewSummaryCount(int count) {
    return 'View summary ($count)';
  }

  @override
  String get chatProposalsSummary => 'Proposal summary';

  @override
  String chatProposalsAddedCount(int count) {
    return '$count of 3 proposals added';
  }

  @override
  String get chatMaxThreeProposals => 'Maximum of 3 proposals';

  @override
  String get chatAddAnotherProposal => 'Add another proposal';

  @override
  String get chatProposalCancelled => 'CANCELLED';

  @override
  String get chatProposalAccepted => 'ACCEPTED';

  @override
  String get chatProposalPending => 'PENDING';

  @override
  String get chatMeetingDetails => 'Meeting details';

  @override
  String get chatDistrict => 'District';

  @override
  String get chatPlace => 'Place';

  @override
  String get chatDateAndTime => 'Date and time';

  @override
  String get chatMeetingStatus => 'Status';

  @override
  String get chatAcceptProposalQuestion => 'Do you accept this proposal?';

  @override
  String get chatWaitingOtherResponse =>
      'Waiting for the other user\'s response...';

  @override
  String get chatMeetingConfirmationNotice =>
      'Once confirmed, you won\'t be able to chat until you meet in person.\n\n• Don\'t be late\n• Facial recognition will be required\n• GPS will be activated on the day of the meeting';

  @override
  String get chatCancelDealQuestion => 'Cancel the deal?';

  @override
  String get chatMeetingLabel => 'MEETING';

  @override
  String get chatCancellationRule => 'Cancellation policy';

  @override
  String get chatCancellationNotification =>
      'Cancelling will void the meeting for both users and reopen the chat. The other user will receive a notification.';

  @override
  String get chatOtherConfirmedCannotCancel =>
      'The other user has confirmed attendance. You can no longer cancel this meeting.';

  @override
  String get chatCannotCancelWithinHour =>
      'You can no longer cancel this meeting because it is less than 1 hour away. Both users must attend at the agreed location.';

  @override
  String get chatBothConfirmedCannotCancel =>
      'Both users have confirmed attendance. The meeting cannot be cancelled.';

  @override
  String get chatOnlyOtherCanCancel =>
      'The other user has confirmed attendance. Only they can cancel up to 10 minutes before the meeting.';

  @override
  String get chatYouCanCancelUntilTenMinutes =>
      'You have confirmed attendance. You can cancel up to 10 minutes before the meeting.';

  @override
  String get chatCancellationDeadlineRule =>
      'You can only cancel the deal up to 1 hour before the meeting. If less than 1 hour remains, cancellation is no longer allowed and both users must attend at the agreed location.';

  @override
  String get chatBack => 'Back';

  @override
  String get chatYesCancel => 'Yes, cancel';

  @override
  String chatMeetingCancelError(String error) {
    return 'Error: $error';
  }

  @override
  String get chatDealClosedTitle => '🤝 Deal closed';

  @override
  String get chatDealClosedDescription =>
      'The chat is locked. See you at the meeting.';

  @override
  String get chatViewChatMessages => 'View chat messages';

  @override
  String get chatReviewAlertsStep => '1. Check your alerts';

  @override
  String get chatReviewAlertsDescription =>
      'Go to Alerts to see the date, time, and location of the confirmed meeting.';

  @override
  String get chatFacialRecognitionStep => '2. Facial recognition';

  @override
  String get chatFacialRecognitionStepDescription =>
      'On the day of the meeting, the app will ask for a selfie to verify your identity before you leave.';

  @override
  String get chatEnableGpsStep => '3. Enable GPS';

  @override
  String get chatEnableGpsStepDescription =>
      'When you arrive, enable your location. The app will confirm that you are at the safe meeting point.';

  @override
  String get chatUnlockChatStep => '4. Chat unlocks';

  @override
  String get chatUnlockChatStepDescription =>
      'Once both users are present and verified, the chat will reopen.';

  @override
  String get chatArriveEarlyWarning =>
      'Arrive 10 minutes early. If you don\'t show up, the meeting will be marked as \"no-show\" and the chat will remain closed.';

  @override
  String get chatShieldAlreadyActive =>
      '🛡️ The Shield is already active and cannot be disabled';

  @override
  String get chatShieldAnalyzingMessages =>
      '🛡️ Shield activated. Analyzing messages...';

  @override
  String get chatActivateShieldToViewAnalysis =>
      '🛡️ Activate the Shield to view the conversation analysis';

  @override
  String get chatDealInfo => 'Deal info';

  @override
  String get chatProposePlaceBeforeClosingDeal =>
      '📍 First propose a meeting place and date.\nOnce the other user accepts, you can close the deal.';

  @override
  String get chatDealClosedWaitingMeeting =>
      '✅ Deal closed. Waiting for the meeting.';

  @override
  String get chatWaitingDealConfirmation =>
      '⏳ Waiting for the other user to confirm...';

  @override
  String get chatConfirmDeal => 'Confirm';

  @override
  String get chatMoreQuestions => 'I have more questions';

  @override
  String get chatNoMessagesYet => 'No messages yet';

  @override
  String get chatItemSold => 'ITEM SOLD';

  @override
  String get chatMeetingHasBeenAccepted => 'The meeting has been accepted';

  @override
  String get chatDealClosedBothConfirmed =>
      '✅ Deal closed. Both users confirmed. See you on the meeting day!';

  @override
  String get chatBothContinueTalking => '✅ Both users decided to keep talking';

  @override
  String get chatUserWantsToContinueTalking => 'The user wants to keep talking';

  @override
  String get chatRatingThankYou =>
      '✅ Rating submitted. Thank you for your feedback!';

  @override
  String chatRatingVisibleAfterWeek(String userName) {
    return 'Your rating will appear on $userName\'s profile one week after submission.';
  }

  @override
  String get chatYouSharedLocation => 'You shared your location';

  @override
  String get chatLocationShared => 'Location shared';

  @override
  String get chatTapToOpenMaps => 'Tap to open in maps';

  @override
  String get chatMeetingCouldNotTakePlace => 'The meeting could not take place';

  @override
  String get chatMeetingCancelledChatReopened =>
      '❌ The meeting was cancelled. The chat has reopened.';

  @override
  String get chatConfirmedDealWaitingResponse =>
      '⏳ You confirmed the deal. Waiting for the other user\'s response...';

  @override
  String get chatWaitingOtherDecision =>
      '⏳ Waiting for the other user to decide...';

  @override
  String get chatMeetingProposalPendingWrite =>
      'Meeting proposal pending. Wait until it is resolved before writing.';

  @override
  String get chatRecordingSlideToCancel => '🎤 Recording... slide to cancel';

  @override
  String get chatReleaseToCancel => 'Release to cancel';

  @override
  String get chatRecordingRejectedMeetingCancelled =>
      '❌ You rejected the recording. The meeting was cancelled for both users and the chat was closed.';

  @override
  String get chatRecordingEnabledBothAccepted =>
      '🎙️ Recording enabled. Both users accepted.';

  @override
  String get chatRecordingAcceptedWaitingOther =>
      '🎙️ You accepted. Waiting for the other user to accept.';

  @override
  String get chatRecordingMeetingCancelledTitle => '🚫 Meeting cancelled';

  @override
  String get chatRecordingMeetingCancelledReason =>
      'The meeting was cancelled because one participant rejected the security voice recording.';

  @override
  String get chatRecordingMandatoryExplanation =>
      'Security voice recording is mandatory for in-person meetings through the app. This measure protects both users.';

  @override
  String get chatReportSuspiciousProduct => 'Suspicious product';

  @override
  String get chatReportProhibitedProducts => 'Listing prohibited products';

  @override
  String get chatReportFraud => 'Scam or fraud';

  @override
  String get chatReportHarassment => 'Harassment or abuse';

  @override
  String get chatReportMisleadingInfo => 'False or misleading information';

  @override
  String get chatReportOtherReason => 'Other reason';

  @override
  String get chatLocation => 'Location';

  @override
  String get chatClosedShieldRejected =>
      'Chat closed. One participant did not accept the Security Shield.';

  @override
  String get chatLockedForMeeting =>
      'Chat locked. You will meet in person. Don\'t be late.';

  @override
  String chatSendProposals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Send $count proposals',
      one: 'Send 1 proposal',
    );
    return '$_temp0';
  }

  @override
  String chatMapCoordinates(String latitude, String longitude) {
    return 'Lat: $latitude, Lng: $longitude';
  }

  @override
  String get chatAnalyzingConversation => 'Analyzing conversation...';

  @override
  String get chatAnalysisNotAvailable => 'No analysis available yet.';

  @override
  String get chatMeetingTimeOccupied => 'That date and time is already taken.';

  @override
  String get chatYourPortfolio => 'Your portfolio';

  @override
  String get chatHideProducts => 'Hide products';

  @override
  String get chatViewProducts => 'View products';

  @override
  String get chatViewProduct => 'View product';

  @override
  String get chatSelectMessagePart => 'Select part of the message to copy';

  @override
  String get chatMeetingProposalTitle => 'Meeting proposal';

  @override
  String get chatWaitingProposalResponse => 'Waiting for a response...';

  @override
  String get chatTapProposalDetails => 'Tap to view details and respond';

  @override
  String get chatProposalAcceptedNotice => '✅ Proposal accepted';

  @override
  String get chatProposalRejected => '❌ Proposal rejected';

  @override
  String chatOtherUserMeetingReady(String userName) {
    return '$userName wants to know if everything is ready for the meeting';
  }

  @override
  String get chatMeetingEverythingReady =>
      'Is everything ready for the meeting?';

  @override
  String get chatMeetingBothConfirmLock =>
      'If both confirm, the chat will be locked until you meet in person.';

  @override
  String get chatConversationAgreement =>
      'The conversation seems to have reached an agreement.';

  @override
  String get chatCancelMeetingBoth =>
      'This action cancels the meeting for both participants.';

  @override
  String get chatMeetingNotCompletedExplanation =>
      'We\'re sorry for the inconvenience. Not every meeting works out, and that\'s okay: what matters is keeping everyone safe.\n\nThe chat has been closed. Delete this chat and open it again to continue talking.';
}
