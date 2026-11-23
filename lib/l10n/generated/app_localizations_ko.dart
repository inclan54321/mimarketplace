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
  String errorGenericoAlerta(String error) {
    return '오류: $error';
  }

  @override
  String get errorDesconocido => '알 수 없음';

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
  String get catAutomoviles => '자동차';

  @override
  String get catHerramientas => '도구';

  @override
  String get catRopaYCalzado => '의류 및 신발';

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
  String errorCompra(String detalle) {
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
  String get porFavorEscribeUnMensaje => '메시지를 입력해주세요';

  @override
  String get porFavorEscribeUnAsunto => '제목을 입력해주세요';

  @override
  String get mensajeEnviadoExito => '✅ 메시지가 전송되었습니다. 곧 답변드리겠습니다.';

  @override
  String get necesitasAyuda => '도움이 필요하신가요?';

  @override
  String get cuentanosTuProblema => '문제를 알려주시면 해결을 도와드리겠습니다.';

  @override
  String get tipoDeConsulta => '문의 유형';

  @override
  String get asunto => '제목';

  @override
  String get ejemploProblemaCuenta => '예: 계정 문제';

  @override
  String get mensaje => '메시지';

  @override
  String get describeTuProblema => '문제를 최대한 자세히 설명해주세요...';

  @override
  String get enviarMensaje => '메시지 보내기';

  @override
  String get tiempoRespuestaEstimado => '예상 응답 시간: 24-48시간';

  @override
  String get mensajeEnviado => '메시지가 전송되었습니다!';

  @override
  String get hemosRecibidoTuConsulta => '문의가 접수되었습니다. 지원팀이 24-48시간 이내에 답변드립니다.';

  @override
  String get enviarOtroMensaje => '다른 메시지 보내기';

  @override
  String get volver => '돌아가기';

  @override
  String get categoria => '카테고리';

  @override
  String get direccion => '주소';

  @override
  String get nombreDelProducto => '상품명';

  @override
  String get ejemploNombreProducto => '예: iPhone 13, 노트북 등';

  @override
  String get ingresaNombreProducto => '상품명을 입력해주세요';

  @override
  String get nombreMinimoCaracteres => '이름은 최소 3자 이상이어야 합니다';

  @override
  String get precio => '가격 (₡)';

  @override
  String get ingresePrecioProducto => '상품 가격을 입력해주세요';

  @override
  String get ingresaPrecio => '가격을 입력해주세요';

  @override
  String get ingresaPrecioValido => '유효한 가격을 입력해주세요';

  @override
  String get precioMayorCero => '가격은 0보다 커야 합니다';

  @override
  String get descripcion => '설명';

  @override
  String get escribeDescripcionDetallada => '상품에 대한 자세한 설명을 작성해주세요...';

  @override
  String get ingresaDescripcion => '설명을 입력해주세요';

  @override
  String get publicarProducto => '상품 등록';

  @override
  String get compartaProductoComunidad => '커뮤니티와 상품을 공유하세요';

  @override
  String get anuncioCompletado => '✅ 광고가 완료되었습니다. 상품 등록 중...';

  @override
  String get debesVerAnuncioParaPublicar => '❌ 등록하려면 광고를 끝까지 시청해야 합니다';

  @override
  String get productoEnviadoRevision =>
      '📝 상품이 검토를 위해 전송되었습니다. 승인되면 알림을 받게 됩니다.';

  @override
  String errorAlPublicar(String error) {
    return '등록 오류: $error';
  }

  @override
  String get paraPublicarNecesitasVerAnuncio => '상품을 등록하려면 짧은 광고를 시청해야 합니다.';

  @override
  String get verAnuncio => '광고 보기';

  @override
  String get agregarImagenes => '이미지 추가';

  @override
  String get imagenDestacada => '대표 이미지';

  @override
  String get estaImagenApareceraPortada => '이 이미지는 상품 커버와 추천 섹션에 표시됩니다.';

  @override
  String get soloImagenesCalidadEstudio =>
      '스튜디오 품질의 사진(좋은 조명, 선명한 초점, 깨끗한 배경)만 허용됩니다.';

  @override
  String get tocaParaSeleccionarImagen => '탭하여 이미지 선택';

  @override
  String get formatosImagenPermitidos => 'JPG, PNG 또는 WEBP · 최대 10MB';

  @override
  String get enRevisionPuntos => '🔍 검토 중...';

  @override
  String get enviadoARevision => '🔄 검토를 위해 전송됨';

  @override
  String get enviarARevision => '🛡️ 검토를 위해 전송';

  @override
  String get imagenRevisadaIA => '이미지는 AI에 의해 검토됩니다. 승인되면 알림을 받게 됩니다.';

  @override
  String get imagenesRealesProducto => '상품 실제 이미지';

  @override
  String get subeHasta4Fotos => '상품의 실제 사진을 최대 4장 업로드하세요 (필수)';

  @override
  String get agregar => '추가';

  @override
  String get maximo4ImagenesReales => '⚠️ 실제 이미지는 최대 4장까지만 업로드할 수 있습니다';

  @override
  String get escribeDescripcionMejorarImagen => '이미지를 개선할 설명을 작성하세요';

  @override
  String get primeroSeleccionaImagen => '먼저 이미지를 선택하세요';

  @override
  String get imagenMejoradaCorrectamente => '✅ 이미지가 성공적으로 개선되었습니다';

  @override
  String get errorGenerarImagen => '이미지 생성 오류';

  @override
  String get imagenEnviadaRevision =>
      '🔄 이미지가 검토를 위해 전송되었습니다. 승인되면 알림을 받게 됩니다.';

  @override
  String errorEnviarImagen(String codigo) {
    return '이미지 전송 오류: $codigo';
  }

  @override
  String get revisionDeImagen => '🛡️ 이미지 검토';

  @override
  String get tuImagenSeraEnviadaModeracion =>
      '이미지는 검토를 위해 검토 팀으로 전송됩니다. 계속하려면 짧은 광고를 시청해야 합니다.';

  @override
  String get revisionPuedeTomar24Horas => '검토에는 최대 24시간이 소요될 수 있습니다.';

  @override
  String get verAnuncioConEmoji => '광고 보기 🎬';

  @override
  String get anuncioCompletadoEnviandoImagen =>
      '✅ 광고가 완료되었습니다. 이미지를 검토로 전송 중...';

  @override
  String get debesVerAnuncioParaEnviarImagen => '❌ 이미지를 전송하려면 광고를 끝까지 시청해야 합니다';

  @override
  String get seleccionaAlMenos1Imagen => '실제 이미지를 최소 1장 선택하세요';

  @override
  String get siguienteConFlecha => '다음 →';

  @override
  String get recoleccionDeDatos => '데이터 수집';

  @override
  String get tuPrivacidadImportante =>
      '귀하의 개인정보는 중요합니다. 맞춤형 상품 추천을 받기 위해 브라우징 데이터 및 환경설정 수집을 허용할지 선택할 수 있습니다.';

  @override
  String get aceptoRecoleccionDatos =>
      '맞춤형 상품 추천을 받기 위해 브라우징 데이터 및 환경설정 수집에 동의합니다.';

  @override
  String get guardarPreferencias => '환경설정 저장';

  @override
  String get preferenciasGuardadas => '✅ 환경설정이 저장되었습니다';

  @override
  String get errorAlGuardar => '저장 오류';

  @override
  String get historialDePagos => '결제 내역';

  @override
  String get consultaTodosLosPagos =>
      '앱 내에서 한 모든 결제를 확인하세요: 게시물 홍보, 갱신, 광고 제거 및 기타 서비스.';

  @override
  String get verHistorialDePagos => '결제 내역 보기';

  @override
  String get todosTusPagosTransacciones => '모든 결제 및 거래';

  @override
  String get estadoDeCuenta => '계정 상태';

  @override
  String get revisaTusAdvertencias => '플랫폼에서 경고 및 활성 정지를 확인하세요.';

  @override
  String get advertencias => '경고';

  @override
  String get suspensionesTemporales => '임시 정지';

  @override
  String get asistenciaAEncuentros => '약속 참석';

  @override
  String get llegadasTardias => '지각';

  @override
  String get noVerificaste5Min => '5분 이내에 확인하지 않았습니다. 3회 = 경고 1회';

  @override
  String get ausencias => '결석';

  @override
  String get noLlegasteEncuentro => '약속에 오지 않았습니다. 1회 = 경고 1회';

  @override
  String minutosTardeAcumulados(int cantidad) {
    return '⏱️ 누적 지각 시간: $cantidad분';
  }

  @override
  String get informacion => '정보';

  @override
  String get comoFunciona => '어떻게 작동하나요?';

  @override
  String get comoFuncionaEstadoCuenta =>
      '귀하의 계정은 커뮤니티 규칙 위반으로 경고와 임시 정지가 누적됩니다.\n\n약속 참석:\n• 지각 3회 (0/3) = 경고 1회.\n• 결석 1회 = 경고 1회.\n\n에스컬레이션:\n• 경고 3회 = 임시 정지 1회 (7일).\n• 정지 3회 = 영구 차단.\n\n회복:\n• 매월 지각 2회가 차감됩니다.\n• 3개월마다 경고 1회가 차감됩니다.';

  @override
  String get advertenciasInfo =>
      '경고 (최대 3회): 부적절한 언어, 오해의 소지가 있는 게시물, 경미한 규칙 위반 등의 가벼운 신고로 발생합니다. 계정을 차단하지 않습니다.';

  @override
  String get suspensionesInfo =>
      '임시 정지 (최대 3회): 사기, 괴롭힘, 신원 도용 또는 경고 반복 등의 더 심각한 위반에 적용됩니다. 각 정지는 일정 기간 동안 계정을 차단합니다.';

  @override
  String get baneoInfo => '정지 3회에 도달하면 계정이 영구 차단되며 해당 이메일로 재가입할 수 없습니다.';

  @override
  String get entendido => '확인';

  @override
  String get guardar => '저장';

  @override
  String get guardarCambios => '변경사항 저장';

  @override
  String get nombreCompleto => '전체 이름';

  @override
  String get telefono => '전화번호';

  @override
  String get usuarioNoAutenticado => '사용자가 인증되지 않았습니다';

  @override
  String get errorAlCargarDatos => '데이터 로드 오류';

  @override
  String get nombreNoPuedeEstarVacio => '이름은 비워둘 수 없습니다';

  @override
  String get perfilActualizadoCorrectamente => '✅ 프로필이 성공적으로 업데이트되었습니다';

  @override
  String get errorAlGuardarEnServidor => '서버 저장 오류';

  @override
  String get volverAlPerfil => 'Volver al perfil';

  @override
  String get chatShieldAccepted => '🛡️ 보호 기능을 수락했습니다';

  @override
  String get chatShieldRejected => '🚫 보호 기능이 거부되어 채팅이 종료되었습니다.';

  @override
  String get chatRatingSent => '평가가 제출되었습니다! 의견 감사합니다.';

  @override
  String get chatMessageBlocked => '메시지가 차단되었습니다';

  @override
  String get chatPhoneBlocked =>
      '보안 보호 기능이 이 메시지를 차단했습니다.\n\n사유: 전화번호는 허용되지 않습니다.';

  @override
  String get chatUnderstood => '알겠습니다';

  @override
  String get chatMeetingNotHeld =>
      '만남이 이루어지지 않았습니다. 대화를 계속하려면 이 채팅을 삭제하고 다시 여세요.';

  @override
  String get chatGallery => '갤러리';

  @override
  String get chatCamera => '카메라';

  @override
  String get chatShareLocation => '위치 공유';

  @override
  String get chatSharePortfolio => '포트폴리오 공유';

  @override
  String get chatEnableGps => '위치를 공유하려면 휴대전화의 GPS를 켜세요';

  @override
  String get chatLocationPermission => '위치 권한이 필요합니다';

  @override
  String get chatGettingLocation => '📍 위치를 확인하는 중...';

  @override
  String get chatCannotOpenApp => '앱을 열 수 없습니다';

  @override
  String get chatOpenLocationWith => '위치를 열 앱...';

  @override
  String get chatPortfolioShared => '📤 포트폴리오를 공유했습니다';

  @override
  String get chatDontShowAgain => '다시 표시하지 않기';

  @override
  String get chatCancel => '취소';

  @override
  String get chatContinue => '계속';

  @override
  String get chatOtherUser => '상대 사용자';

  @override
  String chatGenericError(String error) {
    return '오류: $error';
  }

  @override
  String chatLocationSendError(String statusCode) {
    return '위치를 전송할 수 없습니다 ($statusCode)';
  }

  @override
  String chatLocationGetError(String error) {
    return '위치 정보를 가져오는 중 오류가 발생했습니다: $error';
  }

  @override
  String chatImageSendError(String error) {
    return '이미지 전송 중 오류가 발생했습니다: $error';
  }

  @override
  String get chatAudioPermissionRequired => '오디오를 녹음하려면 마이크 권한이 필요합니다';

  @override
  String get chatRecordingTapToStop => '🎤 녹음 중... 다시 탭하면 중지됩니다';

  @override
  String chatRecordingError(String error) {
    return '녹음 중 오류가 발생했습니다: $error';
  }

  @override
  String get chatVerifyingAudio => '🛡️ 오디오 확인 중...';

  @override
  String get chatAudioSent => '🎤 오디오를 전송했습니다';

  @override
  String chatAudioSendError(String error) {
    return '오디오 전송 중 오류가 발생했습니다: $error';
  }

  @override
  String get chatRecordingLimitReached => '⏱️ 25초 녹음 제한에 도달했습니다';

  @override
  String get chatRecordingCancelled => '🗑️ 녹음이 취소되었습니다';

  @override
  String get chatSendingAudio => '📤 오디오 전송 중...';

  @override
  String chatStopRecordingError(String error) {
    return '녹음 중지 중 오류가 발생했습니다: $error';
  }

  @override
  String chatAudioPlaybackError(String error) {
    return '오디오 재생 중 오류가 발생했습니다: $error';
  }

  @override
  String get chatSellerBlocked => '판매자를 차단했습니다';

  @override
  String get chatSellerBlockError => '판매자 차단 중 오류가 발생했습니다';

  @override
  String get chatSellerUnblocked => '판매자 차단을 해제했습니다';

  @override
  String get chatSellerUnblockError => '판매자 차단 해제 중 오류가 발생했습니다';

  @override
  String get chatReportSeller => '판매자 신고';

  @override
  String get chatReport => '신고하기';

  @override
  String get chatReportLoginRequired => '신고하려면 로그인해야 합니다';

  @override
  String get chatReportSent => '신고가 접수되었습니다. 운영팀에서 검토할 예정입니다.';

  @override
  String chatReportSendError(String error) {
    return '신고 전송 중 오류가 발생했습니다: $error';
  }

  @override
  String get chatInternetSearchComingSoon => '\"인터넷 검색\" 기능은 개발 중입니다';

  @override
  String get chatSelectText => '텍스트 선택';

  @override
  String get chatSelectTextToCopy => '복사할 텍스트를 선택하세요:';

  @override
  String get chatClose => '닫기';

  @override
  String get chatAccept => '수락';

  @override
  String get chatReject => '거절';

  @override
  String get chatConfirmMeetingQuestion => '만남을 확정하시겠습니까?';

  @override
  String get chatConfirm => '확인';

  @override
  String get chatMeetingConfirmed => '만남이 확정되었습니다';

  @override
  String get chatMeetingNotFound => '예정된 만남을 찾을 수 없습니다';

  @override
  String get chatMeetingCancelledReopened => '만남이 취소되었습니다. 채팅이 다시 열렸습니다.';

  @override
  String get chatCannotCancelMeeting => '취소할 수 없습니다';

  @override
  String get chatRecordingNotActive => '녹음이 활성화되어 있지 않습니다';

  @override
  String get chatRecordingStopped => '녹음이 중지되었습니다';

  @override
  String get chatWriteMessage => '메시지를 입력하세요...';

  @override
  String chatSellerBlockException(String error) {
    return '차단 중 오류가 발생했습니다: $error';
  }

  @override
  String chatSellerUnblockException(String error) {
    return '차단 해제 중 오류가 발생했습니다: $error';
  }

  @override
  String get chatSelectReportReason => '신고 사유를 선택하세요:';

  @override
  String get chatReportModerationNotice => '이 신고는 운영팀에서 검토합니다.';

  @override
  String get chatSellerOptions => '판매자 옵션';

  @override
  String get chatUnblock => '차단 해제';

  @override
  String get chatBlock => '차단';

  @override
  String chatUnblockUser(String userName) {
    return '$userName 차단 해제';
  }

  @override
  String chatBlockUser(String userName) {
    return '$userName 차단';
  }

  @override
  String get chatViewProfileInfo => '프로필 정보 보기';

  @override
  String chatViewUserDetails(String userName) {
    return '$userName의 상세 정보 보기';
  }

  @override
  String get chatViewPortfolio => '포트폴리오 보기';

  @override
  String chatViewUserProducts(String userName) {
    return '$userName의 모든 상품 보기';
  }

  @override
  String chatReportUserRules(String userName) {
    return '규칙 위반으로 $userName 신고';
  }

  @override
  String get chatStrikeMessage => '메시지 취소선 표시';

  @override
  String get chatStrikeMessageDescription => '해결된 메시지임을 표시하기 위해 취소선을 적용합니다';

  @override
  String get chatMessageStruck => '메시지에 취소선이 적용되었습니다';

  @override
  String get chatStrikeRemoved => '취소선이 제거되었습니다';

  @override
  String get chatSearchInternet => '인터넷 검색';

  @override
  String get chatSearchMessageGoogle => 'Google에서 이 메시지 검색';

  @override
  String get chatOnline => '온라인';

  @override
  String get chatLastSeen => '마지막 접속';

  @override
  String get chatLastSeenToday => '오늘 마지막 접속';

  @override
  String get chatLastSeenYesterday => '어제 마지막 접속';

  @override
  String chatLastSeenOn(String date) {
    return '마지막 접속: $date';
  }

  @override
  String get chatPortfolioSharedByYou => '내 포트폴리오를 공유했습니다';

  @override
  String chatPortfolioOfUser(String userName) {
    return '$userName의 포트폴리오';
  }

  @override
  String get chatTapToViewProducts => '탭하여 상품 보기';

  @override
  String get chatView => '보기';

  @override
  String get chatYou => '나';

  @override
  String get chatShieldAudioTitle => '보안 실드를 통한 오디오 보호';

  @override
  String get chatShieldImageTitle => '보안 실드를 통한 이미지 보호';

  @override
  String chatShieldAudioInstructions(String productName) {
    return '• 최대 25초까지 녹음할 수 있습니다.\n• 오디오는 AI가 검토하며 \"$productName\"에 관한 내용만 포함해야 합니다.\n• 전화번호, 소셜 미디어, 앱 외부 결제, 욕설 및 관련 없는 주제는 허용되지 않습니다.\n\n이 창을 닫은 후 마이크를 길게 눌러 녹음하세요.';
  }

  @override
  String chatShieldImageInstructions(String productName) {
    return '• 이 채팅에서는 이미지를 1장만 전송할 수 있습니다.\n• 이미지는 AI가 검토하며 \"$productName\" 상품이 표시되어야 합니다.\n• 전화번호, QR 코드, 소셜 미디어, 앱 외부 결제, 성적·폭력적·모욕적인 콘텐츠는 허용되지 않습니다.';
  }

  @override
  String get chatImageLimitTitle => '이미지 전송 제한';

  @override
  String get chatImageLimitBody =>
      '보안 실드가 활성화된 상태에서는 이 채팅에 이미지를 1장만 전송할 수 있습니다.';

  @override
  String get chatCropImage => '이미지 자르기';

  @override
  String get chatDone => '완료';

  @override
  String get chatImageRejected => '이미지가 거부되었습니다';

  @override
  String get chatAudioRejected => '오디오가 거부되었습니다';

  @override
  String get chatStatusNeutral => '중립 상태';

  @override
  String get chatNeutralDescription =>
      '대화가 진행 중입니다. 아직 거래 상태를 판단하기에 충분한 정보가 없습니다.';

  @override
  String get chatNeutralRecommendation => '상대방을 존중하며 명확하게 대화를 이어가세요.';

  @override
  String get chatStatusHealthy => '건전한 대화';

  @override
  String get chatHealthyDescription =>
      '대화가 긍정적으로 진행되고 있습니다. 양측 사용자가 서로 존중하며 명확하게 소통하고 있습니다.';

  @override
  String get chatHealthyRecommendation => '좋습니다! 거래가 성공적으로 이루어질 가능성이 높습니다.';

  @override
  String get chatStatusWarning => '주의 권장';

  @override
  String get chatWarningDescription =>
      '대화에서 몇 가지 경고 신호가 감지되었습니다. 오해나 긴장이 발생했을 수 있습니다.';

  @override
  String get chatWarningRecommendation =>
      '이전 메시지를 검토하세요. 더 명확하고 공감하는 태도로 답변해 보세요.';

  @override
  String get chatStatusDanger => '임박한 위험';

  @override
  String get chatDangerDescription =>
      '대화에서 갈등이나 위험의 징후가 나타납니다. 의사소통 문제나 심각한 의견 충돌이 있을 수 있습니다.';

  @override
  String get chatDangerRecommendation =>
      '잠시 멈추고 상황을 평가하세요. 필요한 경우 고객지원팀에 문의하세요.';

  @override
  String get chatCancelMeetingQuestion => '만남을 취소하시겠습니까?';

  @override
  String get chatRecordingRejectionWarning =>
      '보안을 위한 음성 녹음을 거부하면 양측 사용자의 만남이 취소되고 채팅이 종료됩니다.\n\n이 작업은 되돌릴 수 없습니다.';

  @override
  String get chatGoBack => '돌아가기';

  @override
  String get chatYesCancelMeeting => '예, 만남 취소';

  @override
  String get chatSecurityVoiceRecording => '보안을 위한 음성 녹음';

  @override
  String get chatSecurityRecordingConsentBody =>
      '지금부터 앱은 사용자 보호만을 목적으로 양측 기기에서 이 대화의 음성을 녹음합니다.\n\n• 음성은 10초마다 저장됩니다.\n• 신고나 사건이 발생한 경우 녹음 내용은 제3자(당국 또는 보안 전문가)에게 제공될 수 있습니다.\n• 귀하의 허가 또는 법적 명령 없이는 다른 사람이 녹음 내용을 들을 수 없습니다.\n\n⚠️ 중요: 만남을 진행하려면 보안 녹음에 반드시 동의해야 합니다.\n\n녹음을 거부하면 양측 사용자의 만남이 자동으로 취소되고 채팅이 종료됩니다. 앱을 통한 대면 만남을 계속 진행할 수 없습니다.';

  @override
  String get chatRejectAndCancel => '거부하고 취소';

  @override
  String get chatAcceptAndContinue => '동의하고 계속';

  @override
  String get chatProposeMeeting => '만남 제안하기';

  @override
  String get chatChooseSafePlace => '목록에서 안전한 장소를 선택하세요.';

  @override
  String chatProposalNumber(int number) {
    return '제안 $number/3';
  }

  @override
  String get chatChoosePlaceOnMap => '지도에서 장소 선택';

  @override
  String get chatPlaceSelected => '장소 선택됨';

  @override
  String get chatTapToOpenMap => '탭하여 지도 열기';

  @override
  String get chatChooseTime => '시간 선택(오전 7시~오후 6시)';

  @override
  String get chatSelectDateTime => '날짜와 시간 선택';

  @override
  String get chatSelectPlaceAndDate => '⚠️ 지도에서 장소와 날짜를 선택하세요';

  @override
  String get chatTimeSlotOccupiedChooseAnother =>
      '⛔ 해당 날짜와 시간은 이미 예약되어 있습니다. 다른 시간을 선택하세요.';

  @override
  String get chatAddProposal => '제안 추가';

  @override
  String get chatAddAndViewSummary => '추가하고 요약 보기';

  @override
  String chatViewSummaryCount(int count) {
    return '요약 보기 ($count)';
  }

  @override
  String get chatProposalsSummary => '제안 요약';

  @override
  String chatProposalsAddedCount(int count) {
    return '3개 중 $count개 제안 추가됨';
  }

  @override
  String get chatMaxThreeProposals => '최대 3개까지 제안 가능';

  @override
  String get chatAddAnotherProposal => '다른 제안 추가';

  @override
  String get chatProposalCancelled => '취소됨';

  @override
  String get chatProposalAccepted => '수락됨';

  @override
  String get chatProposalPending => '대기 중';

  @override
  String get chatMeetingDetails => '만남 상세 정보';

  @override
  String get chatDistrict => '지역';

  @override
  String get chatPlace => '장소';

  @override
  String get chatDateAndTime => '날짜 및 시간';

  @override
  String get chatMeetingStatus => '상태';

  @override
  String get chatAcceptProposalQuestion => '이 제안을 수락하시겠습니까?';

  @override
  String get chatWaitingOtherResponse => '상대방의 응답을 기다리는 중...';

  @override
  String get chatMeetingConfirmationNotice =>
      '확정 후에는 직접 만날 때까지 채팅으로 메시지를 보낼 수 없습니다.\n\n• 늦지 마세요\n• 얼굴 인식이 필요합니다\n• 만남 당일 GPS가 활성화됩니다';

  @override
  String get chatCancelDealQuestion => '거래를 취소하시겠습니까?';

  @override
  String get chatMeetingLabel => '만남';

  @override
  String get chatCancellationRule => '취소 규정';

  @override
  String get chatCancellationNotification =>
      '취소하면 양쪽 모두의 만남이 취소되고 채팅이 다시 열립니다. 상대방에게 알림이 전송됩니다.';

  @override
  String get chatOtherConfirmedCannotCancel =>
      '상대방이 참석을 확인했습니다. 더 이상 이 만남을 취소할 수 없습니다.';

  @override
  String get chatCannotCancelWithinHour =>
      '만남까지 1시간도 남지 않아 취소할 수 없습니다. 양쪽 모두 약속된 장소에 참석해야 합니다.';

  @override
  String get chatBothConfirmedCannotCancel =>
      '양쪽 모두 참석을 확인했습니다. 만남을 취소할 수 없습니다.';

  @override
  String get chatOnlyOtherCanCancel =>
      '상대방이 참석을 확인했습니다. 상대방만 만남 10분 전까지 취소할 수 있습니다.';

  @override
  String get chatYouCanCancelUntilTenMinutes =>
      '참석을 확인했습니다. 만남 10분 전까지 취소할 수 있습니다.';

  @override
  String get chatCancellationDeadlineRule =>
      '거래는 만남 1시간 전까지만 취소할 수 있습니다. 1시간 미만으로 남으면 취소할 수 없으며 양쪽 모두 약속된 장소에 참석해야 합니다.';

  @override
  String get chatBack => '뒤로';

  @override
  String get chatYesCancel => '예, 취소합니다';

  @override
  String chatMeetingCancelError(String error) {
    return '오류: $error';
  }

  @override
  String get chatDealClosedTitle => '🤝 거래 성사';

  @override
  String get chatDealClosedDescription => '채팅이 잠겼습니다. 만남 장소에서 뵙겠습니다.';

  @override
  String get chatViewChatMessages => '채팅 메시지 보기';

  @override
  String get chatReviewAlertsStep => '1. 알림 확인';

  @override
  String get chatReviewAlertsDescription =>
      '알림 메뉴에서 확정된 만남의 날짜, 시간 및 장소를 확인하세요.';

  @override
  String get chatFacialRecognitionStep => '2. 얼굴 인식';

  @override
  String get chatFacialRecognitionStepDescription =>
      '만남 당일 출발하기 전에 앱에서 본인 확인을 위한 셀카 촬영을 요청합니다.';

  @override
  String get chatEnableGpsStep => '3. GPS 활성화';

  @override
  String get chatEnableGpsStepDescription =>
      '도착하면 위치 서비스를 활성화하세요. 앱에서 안전한 만남 장소에 있는지 확인합니다.';

  @override
  String get chatUnlockChatStep => '4. 채팅 잠금 해제';

  @override
  String get chatUnlockChatStepDescription =>
      '양쪽 모두 도착하고 본인 확인을 마치면 채팅이 다시 열립니다.';

  @override
  String get chatArriveEarlyWarning =>
      '10분 일찍 도착하세요. 나타나지 않으면 만남이 \"불참\"으로 표시되고 채팅은 닫힌 상태로 유지됩니다.';

  @override
  String get chatShieldAlreadyActive => '🛡️ 보호막이 이미 활성화되어 있으며 비활성화할 수 없습니다';

  @override
  String get chatShieldAnalyzingMessages => '🛡️ 보호막이 활성화되었습니다. 메시지 분석 중...';

  @override
  String get chatActivateShieldToViewAnalysis => '🛡️ 대화 분석을 보려면 보호막을 활성화하세요';

  @override
  String get chatDealInfo => '거래 정보';

  @override
  String get chatProposePlaceBeforeClosingDeal =>
      '📍 먼저 만남 장소와 날짜를 제안하세요.\n상대방이 수락하면 거래를 확정할 수 있습니다.';

  @override
  String get chatDealClosedWaitingMeeting => '✅ 거래가 성사되었습니다. 만남을 기다리는 중입니다.';

  @override
  String get chatWaitingDealConfirmation => '⏳ 상대방의 확인을 기다리는 중...';

  @override
  String get chatConfirmDeal => '확인';

  @override
  String get chatMoreQuestions => '질문이 더 있어요';

  @override
  String get chatNoMessagesYet => '아직 메시지가 없습니다';

  @override
  String get chatItemSold => '상품 판매 완료';

  @override
  String get chatMeetingHasBeenAccepted => '만남이 수락되었습니다';

  @override
  String get chatDealClosedBothConfirmed =>
      '✅ 거래 성사. 양쪽 모두 확인했습니다. 만남 당일에 뵙겠습니다!';

  @override
  String get chatBothContinueTalking => '✅ 양쪽 모두 대화를 계속하기로 했습니다';

  @override
  String get chatUserWantsToContinueTalking => '상대방이 대화를 계속하고 싶어 합니다';

  @override
  String get chatRatingThankYou => '✅ 평가를 제출했습니다. 의견을 보내주셔서 감사합니다!';

  @override
  String chatRatingVisibleAfterWeek(String userName) {
    return '평가를 제출한 지 일주일 후 $userName님의 프로필에 반영됩니다.';
  }

  @override
  String get chatYouSharedLocation => '위치를 공유했습니다';

  @override
  String get chatLocationShared => '위치가 공유되었습니다';

  @override
  String get chatTapToOpenMaps => '탭하여 지도에서 열기';

  @override
  String get chatMeetingCouldNotTakePlace => '만남이 이루어지지 못했습니다';

  @override
  String get chatMeetingCancelledChatReopened => '❌ 만남이 취소되었습니다. 채팅이 다시 열렸습니다.';

  @override
  String get chatConfirmedDealWaitingResponse =>
      '⏳ 거래 성사를 확인했습니다. 상대방의 응답을 기다리는 중...';

  @override
  String get chatWaitingOtherDecision => '⏳ 상대방의 결정을 기다리는 중...';

  @override
  String get chatMeetingProposalPendingWrite =>
      '만남 제안이 대기 중입니다. 결정될 때까지 메시지를 보낼 수 없습니다.';

  @override
  String get chatRecordingSlideToCancel => '🎤 녹음 중... 밀어서 취소';

  @override
  String get chatReleaseToCancel => '놓으면 취소';

  @override
  String get chatRecordingRejectedMeetingCancelled =>
      '❌ 녹음을 거부했습니다. 양측의 만남이 취소되고 채팅이 종료되었습니다.';

  @override
  String get chatRecordingEnabledBothAccepted =>
      '🎙️ 녹음이 활성화되었습니다. 양측 모두 동의했습니다.';

  @override
  String get chatRecordingAcceptedWaitingOther =>
      '🎙️ 동의했습니다. 상대방의 동의를 기다리는 중입니다.';

  @override
  String get chatRecordingMeetingCancelledTitle => '🚫 만남 취소됨';

  @override
  String get chatRecordingMeetingCancelledReason =>
      '참여자 중 한 명이 안전을 위한 음성 녹음을 거부하여 만남이 취소되었습니다.';

  @override
  String get chatRecordingMandatoryExplanation =>
      '앱을 통한 대면 만남에는 안전을 위한 음성 녹음이 필수입니다. 이 조치는 양측 모두를 보호합니다.';

  @override
  String get chatReportSuspiciousProduct => '의심스러운 상품';

  @override
  String get chatReportProhibitedProducts => '금지 상품 게시';

  @override
  String get chatReportFraud => '사기 또는 부정행위';

  @override
  String get chatReportHarassment => '괴롭힘 또는 학대';

  @override
  String get chatReportMisleadingInfo => '허위 또는 오해의 소지가 있는 정보';

  @override
  String get chatReportOtherReason => '기타 사유';

  @override
  String get chatLocation => '위치';

  @override
  String get chatClosedShieldRejected =>
      '채팅이 종료되었습니다. 참여자 중 한 명이 보안 실드를 수락하지 않았습니다.';

  @override
  String get chatLockedForMeeting => '채팅이 잠겼습니다. 직접 만날 예정입니다. 늦지 마세요.';

  @override
  String chatSendProposals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '제안 $count개 보내기',
    );
    return '$_temp0';
  }

  @override
  String chatMapCoordinates(String latitude, String longitude) {
    return '위도: $latitude, 경도: $longitude';
  }

  @override
  String get chatAnalyzingConversation => '대화를 분석하는 중...';

  @override
  String get chatAnalysisNotAvailable => '아직 분석 결과가 없습니다.';

  @override
  String get chatMeetingTimeOccupied => '해당 날짜와 시간은 이미 예약되어 있습니다.';

  @override
  String get chatYourPortfolio => '내 포트폴리오';

  @override
  String get chatHideProducts => '상품 숨기기';

  @override
  String get chatViewProducts => '상품 보기';

  @override
  String get chatViewProduct => '상품 보기';

  @override
  String get chatSelectMessagePart => '복사할 메시지 부분 선택';

  @override
  String get chatMeetingProposalTitle => '만남 제안';

  @override
  String get chatWaitingProposalResponse => '응답을 기다리는 중...';

  @override
  String get chatTapProposalDetails => '탭하여 세부 정보를 확인하고 응답하기';

  @override
  String get chatProposalAcceptedNotice => '✅ 제안 수락됨';

  @override
  String get chatProposalRejected => '❌ 제안 거절됨';

  @override
  String chatOtherUserMeetingReady(String userName) {
    return '$userName님이 만남 준비가 모두 완료되었는지 확인하고 싶어 합니다';
  }

  @override
  String get chatMeetingEverythingReady => '만남 준비가 모두 완료되었나요?';

  @override
  String get chatMeetingBothConfirmLock => '양측 모두 확인하면 직접 만날 때까지 채팅이 잠깁니다.';

  @override
  String get chatConversationAgreement => '대화에서 합의에 도달한 것 같습니다.';

  @override
  String get chatCancelMeetingBoth => '이 작업은 양측의 만남을 취소합니다.';

  @override
  String get chatMeetingNotCompletedExplanation =>
      '불편을 드려 죄송합니다. 모든 만남이 성사되는 것은 아니며, 가장 중요한 것은 서로의 안전을 지키는 것입니다.\n\n채팅이 종료되었습니다. 대화를 계속하려면 이 채팅을 삭제한 후 다시 열어 주세요.';
}
