// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '마이 마켓플레이스';

  @override
  String bienvenido(String nombre) {
    return '환영합니다, $nombre님';
  }

  @override
  String get categorias => '카테고리';

  @override
  String get productosDestacados => '추천 상품';

  @override
  String get verTodas => '전체 보기';

  @override
  String get buscarProductos => '상품 검색...';

  @override
  String get noHayResultados => '검색 결과가 없습니다';

  @override
  String get noHayProductosDestacados => '추천 상품이 없습니다';

  @override
  String get noHayProductosConFiltros => '해당 필터에 맞는 상품이 없습니다';

  @override
  String get quitarFiltros => '필터 초기화';

  @override
  String get filtrarProductos => '상품 필터링';

  @override
  String get canton => '📍 지역';

  @override
  String get rangoPrecio => '💰 가격대 (₡)';

  @override
  String get limpiar => '지우기';

  @override
  String get aplicarFiltros => '필터 적용';

  @override
  String get filtrosAplicados => '✅ 필터 적용됨';

  @override
  String get sinFiltrosAplicados => '적용된 필터 없음';

  @override
  String get todos => '전체';

  @override
  String get iniciarSesion => '로그인';

  @override
  String get correoElectronico => '이메일';

  @override
  String get contrasena => '비밀번호';

  @override
  String get continuarConGoogle => 'Google로 계속하기';

  @override
  String get noTienesCuenta => '계정이 없으신가요? 회원가입';

  @override
  String get inicio => '홈';

  @override
  String get avisos => '알림';

  @override
  String get vender => '판매하기';

  @override
  String get mensajes => '메시지';

  @override
  String get perfil => '프로필';

  @override
  String get editarPerfil => '프로필 수정';

  @override
  String get impulsar => '홍보하기';

  @override
  String get eliminarPublicidad => '광고 제거';

  @override
  String get cerrarSesion => '로그아웃';

  @override
  String get privacidadYSeguridad => '개인정보 보호 및 보안';

  @override
  String get soporte => '고객지원';

  @override
  String get terminosDeServicio => '서비스 이용약관';

  @override
  String get misArticulos => '내 판매 상품';

  @override
  String get masVistos => '인기 상품';

  @override
  String get favoritos => '관심 목록';

  @override
  String get miPerfil => '내 프로필';

  @override
  String get verPortafolio => '포트폴리오 보기';

  @override
  String get verTodosMisProductos => '내가 게시한 모든 상품 보기';

  @override
  String get opcionesDelVendedor => '판매자 옵션';

  @override
  String get desbloquear => '차단 해제';

  @override
  String get bloquear => '차단';

  @override
  String desbloquearA(String nombre) {
    return '$nombre 차단 해제';
  }

  @override
  String bloquearA(String nombre) {
    return '$nombre 차단';
  }

  @override
  String get verInformacionDePerfil => '프로필 정보 보기';

  @override
  String verDetallesDe(String nombre) {
    return '$nombre의 세부 정보 보기';
  }

  @override
  String verTodosLosProductosDe(String nombre) {
    return '$nombre의 모든 상품 보기';
  }

  @override
  String get denunciarVendedor => '판매자 신고';

  @override
  String reportarA(String nombre) {
    return '규칙 위반으로 $nombre 신고';
  }

  @override
  String get vendedorBloqueadoCorrectamente => '판매자가 성공적으로 차단되었습니다. 재시작 중...';

  @override
  String get vendedorDesbloqueadoCorrectamente =>
      '판매자가 성공적으로 차단 해제되었습니다. 재시작 중...';

  @override
  String get errorAlBloquear => '차단 중 오류';

  @override
  String get errorAlDesbloquear => '차단 해제 중 오류';

  @override
  String get errorAlBloquearUsuario => '사용자 차단 중 오류';

  @override
  String get errorAlDesbloquearUsuario => '사용자 차단 해제 중 오류';

  @override
  String get denunciarVendedorTitulo => '⚠️ 판매자 신고';

  @override
  String get seleccionaMotivoDenuncia => '신고 이유를 선택하세요:';

  @override
  String get denunciaRevisadaPorEquipo => '이 신고는 검토 팀에 의해 검토됩니다.';

  @override
  String get denunciar => '신고';

  @override
  String get debesIniciarSesionParaDenunciar => '신고하려면 로그인해야 합니다';

  @override
  String get denunciaEnviada => '✅ 신고가 전송되었습니다. 검토 팀이 검토합니다.';

  @override
  String errorAlEnviarDenuncia(String error) {
    return '신고 전송 중 오류: $error';
  }

  @override
  String get motivoProductoSospechoso => '의심스러운 상품';

  @override
  String get motivoProductosProhibidos => '금지된 상품 게시';

  @override
  String get motivoEstafaFraude => '사기 또는 사기 행위';

  @override
  String get motivoAcosoMaltrato => '괴롭힘 또는 학대';

  @override
  String get motivoInformacionFalsa => '거짓 또는 오해의 소지가 있는 정보';

  @override
  String get motivoOtro => '기타 이유';

  @override
  String get vendedor => '판매자';

  @override
  String get esteVendedor => '이 판매자';

  @override
  String get miPortafolio => '내 포트폴리오';

  @override
  String get debesIniciarSesion => '로그인해야 합니다';

  @override
  String get editarProducto => '상품 편집';

  @override
  String get contactarVendedor => '판매자에게 연락';

  @override
  String compartirProductoMensaje(String enlace) {
    return '📱 MiMarketplace에서 이 상품을 확인하세요:\n\n$enlace';
  }

  @override
  String get noHasPublicadoNingunArticulo => '등록한 상품이 없습니다';

  @override
  String get noTienesProductosFavoritos => '관심 등록한 상품이 없습니다';

  @override
  String get reintentar => '다시 시도';

  @override
  String get noHayCalificacionesAun => '아직 리뷰가 없습니다';

  @override
  String get sinComentario => '의견 없음';

  @override
  String get usuario => '사용자';

  @override
  String get cerrarSesionExitoso => '로그아웃되었습니다';

  @override
  String get estiloVisualDelPerfil => '🎨 프로필 테마 스타일';

  @override
  String get eligeElFondoQueMasTeGuste => '마음에 드는 배경을 선택하세요';

  @override
  String get atardecer => '노을';

  @override
  String get galaxia => '은하수';

  @override
  String get oceano => '바다';

  @override
  String get volcan => '화산';

  @override
  String get cancelar => '취소';

  @override
  String get eliminar => '삭제';

  @override
  String get confirmar => '확인';

  @override
  String get yaSeVendio => '판매가 완료되었나요?';

  @override
  String get calificacion => '평점';

  @override
  String get calificaciones => '리뷰';

  @override
  String get queVasAVender => '무엇을 판매하시겠어요?';

  @override
  String get seleccionaCategoria => '상품을 가장 잘 설명하는 카테고리를 선택하세요';

  @override
  String get buscarCategoria => '카테고리 검색...';

  @override
  String get noSeEncontraronCategorias => '카테고리를 찾을 수 없습니다';

  @override
  String get todasLasCategorias => '전체 카테고리';

  @override
  String get seleccionar => '선택하기';

  @override
  String get chateaConCompradoresVendedores => '구매자 및 판매자와 채팅하세요';

  @override
  String get tabChats => '채팅';

  @override
  String get tabAgenda => '주소록';

  @override
  String get tabEncuentros => '약속';

  @override
  String get noTienesConversaciones => '대화 내역이 없습니다';

  @override
  String get encuentroAceptado => '약속 수락됨';

  @override
  String get articuloVendido => '상품 판매 완료';

  @override
  String get nuevoMensaje => '새 메시지';

  @override
  String get fijarChat => '채팅 고정';

  @override
  String get desfijarChat => '채팅 고정 해제';

  @override
  String get quitarDeLaParteSuperior => '상단 고정 해제';

  @override
  String get mantenerEnLaParteSuperior => '상단에 고정';

  @override
  String get chatFijado => '📌 채팅이 고정되었습니다';

  @override
  String get chatDesfijado => '📌 채팅 고정이 해제되었습니다';

  @override
  String errorAlFijar(String codigo) {
    return '고정 오류: $codigo';
  }

  @override
  String get eliminarChat => '채팅 삭제';

  @override
  String confirmarEliminarChat(String nombre) {
    return '$nombre님과의 대화를 정말 삭제하시겠습니까?';
  }

  @override
  String get chatEliminado => '🗑️ 채팅이 삭제되었습니다';

  @override
  String guardadoConProductos(int cantidad) {
    return '✅ 저장됨 ($cantidad개 상품)';
  }

  @override
  String get eliminado => '🗑️ 삭제됨';

  @override
  String get buscarContactosProductos => '연락처 또는 상품 검색...';

  @override
  String get noHayContactosGuardados => '저장된 연락처가 없습니다';

  @override
  String noHayResultadosPara(String busqueda) {
    return '\"$busqueda\"에 대한 검색 결과가 없습니다';
  }

  @override
  String get tocaBotonParaGuardarContacto => '채팅창의 버튼을 눌러 연락처를 주소록에 저장하세요';

  @override
  String get producto => '상품';

  @override
  String get sinMensajes => '메시지 없음';

  @override
  String get fechaDesconocida => '알 수 없는 날짜';

  @override
  String haceDias(int cantidad) {
    return '$cantidad일 전';
  }

  @override
  String haceHoras(int cantidad) {
    return '$cantidad시간 전';
  }

  @override
  String haceMinutos(int cantidad) {
    return '$cantidad분 전';
  }

  @override
  String get haceUnosSegundos => '방금 전';

  @override
  String get lun => '월';

  @override
  String get mar => '화';

  @override
  String get mie => '수';

  @override
  String get jue => '목';

  @override
  String get vie => '금';

  @override
  String get sab => '토';

  @override
  String errorGenerico(String error) {
    return '오류: $error';
  }

  @override
  String get catElectronicos => '전자기기';

  @override
  String get catDeportes => '스포츠';

  @override
  String get catHogar => '가전/가구';

  @override
  String get catMusica => '악기/음악';

  @override
  String get catCocina => '주방용품';

  @override
  String get catPeliculas => '영화';

  @override
  String get catFotografia => '카메라/사진';

  @override
  String get catVideojuegos => '비디오 게임';

  @override
  String get catJuegosDeMesa => '보드게임';

  @override
  String get catJuguetes => '장난감';

  @override
  String get catFiguras => '피규어';

  @override
  String get subElectronicos => '스마트폰, 노트북, 음향기기';

  @override
  String get subDeportes => '축구, 테니스, 러닝';

  @override
  String get subHogar => '가구, 인테리어, 주방';

  @override
  String get subMusica => '기타, 피아노, 오디오';

  @override
  String get subCocina => '냄비, 조리도구, 식기';

  @override
  String get subPeliculas => '액션, 코미디, 드라마';

  @override
  String get subFotografia => '카메라, 렌즈, 악세서리';

  @override
  String get subVideojuegos => '콘솔, 타이틀, 컨트롤러';

  @override
  String get subJuegosDeMesa => '카드 게임, 보드판, 전략 게임';

  @override
  String get subJuguetes => '인형, 블록, 미니카';

  @override
  String get subFiguras => '액션 피규어, 수집품, 애니메이션';

  @override
  String get alertasTitulo => '알림';

  @override
  String get recargar => '새로고침';

  @override
  String get limpiarTodasLasAlertas => '모든 알림 삭제';

  @override
  String get noTienesAlertas => '알림이 없습니다';

  @override
  String get aquiApareceranAvisos => '여기에 공지 사항과 약속 알림이 표시됩니다.';

  @override
  String get noHayAlertasParaLimpiar => '삭제할 알림이 없습니다';

  @override
  String get limpiarAlertas => '🗑️ 알림 지우기';

  @override
  String get confirmarLimpiarAlertas => '모든 알림을 삭제하시겠습니까?';

  @override
  String get eliminarTodo => '전체 삭제';

  @override
  String get todasLasAlertasEliminadas => '✅ 모든 알림이 삭제되었습니다';

  @override
  String errorAlLimpiarAlertas(String error) {
    return '삭제 실패: $error';
  }

  @override
  String get cargandoAnuncio => '⏳ 광고를 불러오는 중입니다... 잠시만 기다려주세요';

  @override
  String get noSePudoCargarAnuncio => '❌ 광고를 불러올 수 없습니다. 다시 시도해주세요.';

  @override
  String get productoRenovado => '✅ 상품 게시 기간이 30일 연장되었습니다';

  @override
  String errorAlRenovar(String error) {
    return '연장 오류: $error';
  }

  @override
  String get debesVerAnuncioCompleto => '❌ 게시 기간을 연장하려면 광고를 끝까지 시청해야 합니다';

  @override
  String get renovarPor30Dias => '30일 연장하기';

  @override
  String get ambosConfirmaron => '양측 확정 완료';

  @override
  String get esperandoAlOtro => '상대방 확인 대기 중';

  @override
  String get confirmarEncuentro => '약속 확정하기';

  @override
  String get verificarIdentidad => '본인 인증';

  @override
  String get verificarIdentidadDelOtro => '상대방 신원 확인';

  @override
  String get identidadRechazada => '신원 확인 거절됨';

  @override
  String get revisarComparacion => '비교 검토';

  @override
  String get ambosConfirmaronExito => '✅ 양측 모두 확정되었습니다. 곧 만나요!';

  @override
  String get confirmasteAsistencia => '✅ 참석을 확정했습니다. 상대방의 확인을 기다리는 중입니다.';

  @override
  String errorGenericoAlerta(String error) {
    return '오류: $error';
  }

  @override
  String get eliminarPublicidadTitulo => '광고 제거';

  @override
  String get eliminaLosAnuncios => '광고 없이 사용하세요';

  @override
  String get descripcionEliminarPublicidad =>
      '플랜을 구독하고 앱 전체에서 광고 없이 쾌적하게 이용해보세요. 간섭 없는 깔끔한 환경을 제공합니다.';

  @override
  String get beneficioSinAnuncios => '앱 전체 광고 제거';

  @override
  String get beneficioNavegacionRapida => '더 빠른 로딩 및 이동';

  @override
  String get beneficioSinInterrupciones => '방해 없는 이용 경험';

  @override
  String get elegiTuPlan => '플랜을 선택하세요';

  @override
  String get plan1Mes => '1개월';

  @override
  String get plan6Meses => '6개월';

  @override
  String get sinAnunciosPor30Dias => '30일간 광고 없음';

  @override
  String get sinAnunciosPor180Dias => '180일간 광고 없음';

  @override
  String ahorrasMonto(String monto) {
    return '$monto 절약';
  }

  @override
  String get elegiUnPlan => '플랜 선택';

  @override
  String pagarMonto(String monto) {
    return '$monto 결제하기';
  }

  @override
  String get pagoSeguro => '결제는 안전하게 처리됩니다';

  @override
  String get confirmarCompra => '구매 확정';

  @override
  String confirmarCompraPregunta(String precio, String duracion) {
    return '$duracion동안 광고 없이 이용하기 위해 $precio을(를) 결제하시겠습니까?';
  }

  @override
  String get pagar => '결제하기';

  @override
  String get integracionPagoEnDesarrollo => '🚧 결제 시스템 개발 중';

  @override
  String get encuentroCaducado => '약속 만료됨';

  @override
  String get esperandoVerificacionDelOtro => '상대방이 셀카 사진을 검토할 때까지 기다리는 중입니다';

  @override
  String get verificacionCompleta => '인증 완료';

  @override
  String get premiumActivoTitulo => '프리미엄 회원입니다!';

  @override
  String get premiumActivoDescripcion => '모든 광고가 제거되었습니다';

  @override
  String get planUnaSemana => '1주';

  @override
  String get sinAnunciosPor7Dias => '7일간 광고 없음';

  @override
  String get yaTenesAnunciosEliminados => '이미 광고가 제거된 상태입니다';

  @override
  String get productoNoDisponible => '구매할 수 없는 상품입니다';

  @override
  String errorCompra(Object detalle) {
    return '오류: $detalle';
  }

  @override
  String get desconocido => '알 수 없음';

  @override
  String get usuarioNoLogueado => '로그인된 사용자가 없습니다';

  @override
  String get errorVerificarCompra => '구매 확인 중 오류가 발생했습니다';

  @override
  String get compraExitosaAnunciosEliminados => '✅ 완료되었습니다! 광고가 제거되었습니다.';

  @override
  String get configurarImpulso => '홍보 설정';

  @override
  String get impulsarTitulo => '홍보하기';

  @override
  String get impulsarPublicacion => '게시물 홍보하기';

  @override
  String get poneTuProductoPrimero => '상품을 최상단에 노출하세요';

  @override
  String get impulsarPunto1Titulo => '1위로 올라가기';

  @override
  String get impulsarPunto1Desc => '홈 화면의 추천 상품 목록 최상단에 상품이 노출됩니다.';

  @override
  String get impulsarPunto2Titulo => '더 많은 노출';

  @override
  String get impulsarPunto2Desc =>
      '최상단에 노출되므로 더 많은 사람들이 상품을 보고 빠르게 판매할 확률이 높아집니다.';

  @override
  String get impulsarPunto3Titulo => '제한된 기간';

  @override
  String get impulsarPunto3Desc => '다른 판매자가 홍보 비용을 지불하고 올라오면 한 단계씩 내려갑니다.';

  @override
  String get seleccionarArticulo => '상품 선택';

  @override
  String get proximamenteDisponiblePagos => '곧 출시 예정입니다. 현재 결제 시스템을 준비 중입니다.';

  @override
  String get articuloAImpulsar => '홍보할 상품';

  @override
  String get comoFuncionaImpulso => '어떻게 작동하나요?';

  @override
  String get explicacionImpulso =>
      '홍보를 하면 상품이 홈 화면 최상단으로 올라갑니다. 다른 판매자가 자신의 상품을 홍보하면 한 단계씩 내려갑니다. 가장 최근에 결제한 판매자의 상품이 항상 첫 번째에 위치합니다.';

  @override
  String get procesando => '처리 중...';

  @override
  String get cargando => '로딩 중...';

  @override
  String get impulsarAhora => '지금 홍보하기';

  @override
  String get cambiarProducto => '상품 변경';

  @override
  String get noTenesProductosPublicados => '게시한 상품이 없습니다';

  @override
  String get elegiUnArticulo => '상품을 선택하세요';

  @override
  String get elQueElijasApareceraPrimero => '선택한 상품이 홈 화면 최상단에 표시됩니다';

  @override
  String get primeroElegiUnArticulo => '먼저 상품을 선택하세요';

  @override
  String get productoImpulsoNoDisponible =>
      '홍보 상품을 이용할 수 없습니다. 인터넷 연결을 확인해주세요.';

  @override
  String get errorDesconocido => '알 수 없음';

  @override
  String productoEstaPrimeroEnHome(String nombre) {
    return '✅ \"$nombre\" 상품이 홈 화면 최상단에 노출됩니다';
  }

  @override
  String get pagoNoVerificado => '결제를 확인할 수 없습니다. 고객센터에 문의해주세요.';

  @override
  String get compraPendiente => '결제가 보류 중입니다. 다시 시도해주세요.';

  @override
  String get errorAlImpulsar => '홍보 중 오류 발생';

  @override
  String escudoActivoPor(String nombre) {
    return '$nombre님이 보안 쉴드를 활성화했습니다';
  }

  @override
  String get escudoPaso0Titulo => '보안 쉴드란 무엇인가요?';

  @override
  String get escudoPaso0Desc =>
      '거래 당사자双方 모두 동의할 때 활성화되는 보호 조치입니다. 사기를 예방하고 안전한 만남을 보장하는 것이 목적입니다.\n\n누가 활성화해야 하나요?\n거래 당사자双方 모두 쉴드를 수락해야 합니다. 한 명이 활성화하면 다른 한 명에게 수락 또는 거절 알림이 전송됩니다. 상대방이 거절하면 채팅이 양측 모두 종료됩니다.';

  @override
  String get escudoPaso1Titulo => '쉴드가 활성화되면 어떻게 되나요?';

  @override
  String get escudoPaso1Desc =>
      '3.1. 링크 및 전화번호 차단: 앱이 메시지 내의 전화번호와 외부 링크를 자동으로 감지하고 차단합니다. 이를 통해 플랫폼 외부로 연락처가 유출되는 것을 방지하고 사기 위험을 줄입니다.';

  @override
  String get escudoPaso2Titulo => '거래를 완료하는 방법';

  @override
  String get escudoPaso2Desc =>
      '거래를 완료하려면 먼저 만남을 제안하세요: 채팅 상단 바의 쉴드를 눌러 \"만남 제안\"을 선택합니다. 여기서 지역, 구역, 안전한 장소, 날짜와 시간을 선택합니다. 제안을 보내면 상대방이 채팅에서 카드 형태로 받습니다. 수락하면 만남이 예약되지만 채팅은 계속 열려 있습니다. 대화를 계속할 수 있습니다. 거래를 완료하려면 다시 쉴드를 눌러 \"거래 완료\"를 선택합니다. 확인 창이 열립니다. 양측이 확인하면 채팅이 차단되고 보호 기능이 활성화됩니다.';

  @override
  String get escudoPaso3Titulo => '참석 확인';

  @override
  String get escudoPaso3Desc =>
      '만남 1시간 전에 양측 사용자에게 참석 확인 알림이 전송됩니다. 알림 후 15분 이내에 확인하지 않으면 상대방은 약속 시간 15분 전까지 만남을 취소할 수 있습니다.';

  @override
  String get escudoPaso4Titulo => 'GPS 추적';

  @override
  String get escudoPaso4Desc =>
      '3.3. 만남 당일 GPS 추적: 약속 당일, 만남 15분 전에 양측 사용자는 해당 장소에 있어야 하며 위치 확인을 위해 GPS를 활성화해야 합니다. 약속 시간 5분 전까지 GPS를 활성화하지 않고 신원을 확인하지 않으면 지각으로 간주됩니다. 약속 시간 15분 후에도 확인하지 않으면 불참으로 간주됩니다. 두 경우 모두 기록되며 MiMarketplace 규정에 따라 제재를 받을 수 있습니다.';

  @override
  String get escudoPaso5Titulo => '얼굴 인증';

  @override
  String get escudoPaso5Desc =>
      '3.4. 채팅 전 신원 확인: 만남 채팅을 열려면 양측 사용자가 자신이 주장하는 사람임을 확인해야 합니다. 이는 약속 시간 15분 전에 활성화되며 채팅을 열기 위한 필수 요건입니다. 시스템은 각 사용자에게 그 자리에서 사진을 찍도록 요청합니다. 그런 다음 상대방은 해당 사진을 프로필 사진과 비교하여 일치하는지 확인해야 합니다. 상대방이 인증을 활성화하면 인증이 시작되므로 주의를 기울이고 화면에 표시되는 지침을 따라야 합니다. 이를 통해 다른 사람이 계정을 사용하는 것을 방지합니다.';

  @override
  String get escudoPaso6Titulo => '추가 고려 사항';

  @override
  String get escudoPaso6Desc =>
      '4.1. 자발적 취소: 모든 사용자는 약속 시간 1시간 전까지 만남 참석을 취소할 수 있습니다. 1시간 미만 남으면 취소가 불가능합니다.\n\n취소 방법: 상품 채팅에 들어가 상단 바의 쉴드 버튼을 눌러 \"거래 취소\"를 선택합니다. 만남 날짜를 보여주고 취소 가능 여부 또는 1시간 미만 남았는지 알려주는 창이 열립니다. 가능하면 확인하면 양측 모두 약속이 취소됩니다.\n\n항상 알림 섹션을 확인하세요. 만남 알림, 참석 확인, 신원 확인 및 상태 변경 사항이 여기에 도착합니다. 중요한 내용을 놓치지 않도록 자주 확인해야 합니다.';

  @override
  String get noAceptar => '거절';

  @override
  String get aceptar => '수락';

  @override
  String get cerrar => '닫기';

  @override
  String get siguiente => '다음';

  @override
  String get iniciar => '시작';

  @override
  String get verVideo => '동영상 보기';

  @override
  String errorGenericoImpulsar(String error) {
    return '오류: $error';
  }

  @override
  String get ubicacionDelEncuentro => '만남 장소';
}
