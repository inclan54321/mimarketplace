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
}
