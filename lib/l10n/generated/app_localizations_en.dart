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
}
