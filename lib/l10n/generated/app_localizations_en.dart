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
  String errorGenericoAlerta(String error) {
    return 'Error: $error';
  }

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
  String errorCompra(Object detalle) {
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
  String get errorDesconocido => 'Unknown';

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
}
