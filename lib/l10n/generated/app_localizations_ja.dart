// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'マイマーケットプレイス';

  @override
  String bienvenido(String nombre) {
    return 'ようこそ、$nombreさん';
  }

  @override
  String get categorias => 'カテゴリー';

  @override
  String get productosDestacados => 'おすすめ商品';

  @override
  String get verTodas => 'すべて見る';

  @override
  String get buscarProductos => '商品を検索...';

  @override
  String get noHayResultados => '検索結果がありません';

  @override
  String get noHayProductosDestacados => 'おすすめ商品はありません';

  @override
  String get noHayProductosConFiltros => '条件に一致する商品がありません';

  @override
  String get quitarFiltros => 'フィルターを解除';

  @override
  String get filtrarProductos => '商品を絞り込む';

  @override
  String get canton => '📍 地域';

  @override
  String get rangoPrecio => '💰 価格帯 (₡)';

  @override
  String get limpiar => 'クリア';

  @override
  String get aplicarFiltros => 'フィルターを適用';

  @override
  String get filtrosAplicados => '✅ フィルター適用中';

  @override
  String get sinFiltrosAplicados => '適用中のフィルターはありません';

  @override
  String get todos => 'すべて';

  @override
  String get iniciarSesion => 'ログイン';

  @override
  String get correoElectronico => 'メールアドレス';

  @override
  String get contrasena => 'パスワード';

  @override
  String get continuarConGoogle => 'Googleで継続';

  @override
  String get noTienesCuenta => 'アカウントをお持ちでないですか？ 新規登録';

  @override
  String get inicio => 'ホーム';

  @override
  String get avisos => 'お知らせ';

  @override
  String get vender => '出品する';

  @override
  String get mensajes => 'メッセージ';

  @override
  String get perfil => 'プロフィール';

  @override
  String get editarPerfil => 'プロフィールを編集';

  @override
  String get impulsar => 'PR・宣伝する';

  @override
  String get eliminarPublicidad => '広告を非表示';

  @override
  String get cerrarSesion => 'ログアウト';

  @override
  String get privacidadYSeguridad => 'プライバシーとセキュリティ';

  @override
  String get soporte => 'サポート';

  @override
  String get terminosDeServicio => '利用規約';

  @override
  String get misArticulos => '出品した商品';

  @override
  String get masVistos => '閲覧数の多い商品';

  @override
  String get favoritos => 'お気に入り';

  @override
  String get miPerfil => 'マイプロフィール';

  @override
  String get verPortafolio => 'ポートフォリオを見る';

  @override
  String get verTodosMisProductos => '出品したすべての商品を見る';

  @override
  String get opcionesDelVendedor => '出品者オプション';

  @override
  String get desbloquear => 'ブロック解除';

  @override
  String get bloquear => 'ブロック';

  @override
  String desbloquearA(String nombre) {
    return '$nombre のブロックを解除';
  }

  @override
  String bloquearA(String nombre) {
    return '$nombre をブロック';
  }

  @override
  String get verInformacionDePerfil => 'プロフィール情報を見る';

  @override
  String verDetallesDe(String nombre) {
    return '$nombre の詳細を見る';
  }

  @override
  String verTodosLosProductosDe(String nombre) {
    return '$nombre のすべての商品を見る';
  }

  @override
  String get denunciarVendedor => '出品者を報告';

  @override
  String reportarA(String nombre) {
    return '規約違反で $nombre を報告';
  }

  @override
  String get vendedorBloqueadoCorrectamente => '出品者をブロックしました。再起動中...';

  @override
  String get vendedorDesbloqueadoCorrectamente => '出品者のブロックを解除しました。再起動中...';

  @override
  String get errorAlBloquear => 'ブロック中のエラー';

  @override
  String get errorAlDesbloquear => 'ブロック解除中のエラー';

  @override
  String get errorAlBloquearUsuario => 'ユーザーのブロック中のエラー';

  @override
  String get errorAlDesbloquearUsuario => 'ユーザーのブロック解除中のエラー';

  @override
  String get denunciarVendedorTitulo => '⚠️ 出品者を報告';

  @override
  String get seleccionaMotivoDenuncia => '報告理由を選択してください：';

  @override
  String get denunciaRevisadaPorEquipo => 'この報告はモデレーションチームによって審査されます。';

  @override
  String get denunciar => '報告する';

  @override
  String get debesIniciarSesionParaDenunciar => '報告するにはログインが必要です';

  @override
  String get denunciaEnviada => '✅ 報告を送信しました。モデレーションが確認します。';

  @override
  String errorAlEnviarDenuncia(String error) {
    return '報告の送信中にエラー: $error';
  }

  @override
  String get motivoProductoSospechoso => '不審な商品';

  @override
  String get motivoProductosProhibidos => '禁止商品の出品';

  @override
  String get motivoEstafaFraude => '詐欺・不正行為';

  @override
  String get motivoAcosoMaltrato => '嫌がらせ・虐待';

  @override
  String get motivoInformacionFalsa => '虚偽・誤解を招く情報';

  @override
  String get motivoOtro => 'その他の理由';

  @override
  String get vendedor => '出品者';

  @override
  String get esteVendedor => 'この出品者';

  @override
  String get miPortafolio => 'マイポートフォリオ';

  @override
  String get debesIniciarSesion => 'ログインしてください';

  @override
  String get editarProducto => '商品を編集';

  @override
  String get contactarVendedor => '出品者に連絡';

  @override
  String compartirProductoMensaje(String enlace) {
    return '📱 MiMarketplaceでこの商品をチェック:\n\n$enlace';
  }

  @override
  String get noHasPublicadoNingunArticulo => 'まだ出品した商品はありません';

  @override
  String get noTienesProductosFavoritos => 'お気に入り商品はありません';

  @override
  String get reintentar => '再試行';

  @override
  String get noHayCalificacionesAun => '評価はまだありません';

  @override
  String get sinComentario => 'コメントなし';

  @override
  String get usuario => 'ユーザー';

  @override
  String get cerrarSesionExitoso => 'ログアウトしました';

  @override
  String get estiloVisualDelPerfil => '🎨 プロフィールのデザインテーマ';

  @override
  String get eligeElFondoQueMasTeGuste => 'お好みの背景を選択してください';

  @override
  String get atardecer => '夕焼け';

  @override
  String get galaxia => '銀河';

  @override
  String get oceano => 'オーシャン';

  @override
  String get volcan => '火山';

  @override
  String get cancelar => 'キャンセル';

  @override
  String get eliminar => '削除';

  @override
  String get confirmar => '確認';

  @override
  String get yaSeVendio => '売却済みですか？';

  @override
  String get calificacion => '評価';

  @override
  String get calificaciones => '評価一覧';

  @override
  String get queVasAVender => '何を出品しますか？';

  @override
  String get seleccionaCategoria => '商品に最適なカテゴリーを選択してください';

  @override
  String get buscarCategoria => 'カテゴリーを検索...';

  @override
  String get noSeEncontraronCategorias => 'カテゴリーが見つかりませんでした';

  @override
  String get todasLasCategorias => 'すべてのカテゴリー';

  @override
  String get seleccionar => '選択する';

  @override
  String get chateaConCompradoresVendedores => '購入者・出品者とチャットする';

  @override
  String get tabChats => 'チャット';

  @override
  String get tabAgenda => '連絡先';

  @override
  String get tabEncuentros => '待ち合わせ';

  @override
  String get noTienesConversaciones => 'メッセージはありません';

  @override
  String get encuentroAceptado => '待ち合わせ承認済み';

  @override
  String get articuloVendido => '商品売却済み';

  @override
  String get nuevoMensaje => '新着メッセージ';

  @override
  String get fijarChat => 'チャットをピン留め';

  @override
  String get desfijarChat => 'ピン留めを解除';

  @override
  String get quitarDeLaParteSuperior => '上部固定を解除';

  @override
  String get mantenerEnLaParteSuperior => '上部に固定';

  @override
  String get chatFijado => '📌 チャットをピン留めしました';

  @override
  String get chatDesfijado => '📌 ピン留めを解除しました';

  @override
  String errorAlFijar(String codigo) {
    return 'ピン留めエラー: $codigo';
  }

  @override
  String get eliminarChat => 'チャットを削除';

  @override
  String confirmarEliminarChat(String nombre) {
    return '$nombreさんとの会話を削除してもよろしいですか？';
  }

  @override
  String get chatEliminado => '🗑️ チャットを削除しました';

  @override
  String guardadoConProductos(int cantidad) {
    return '✅ 保存済み ($cantidad個の商品)';
  }

  @override
  String get eliminado => '🗑️ 削除済み';

  @override
  String get buscarContactosProductos => '連絡先または商品を検索...';

  @override
  String get noHayContactosGuardados => '保存された連絡先はありません';

  @override
  String noHayResultadosPara(String busqueda) {
    return '「$busqueda」の検索結果はありません';
  }

  @override
  String get tocaBotonParaGuardarContacto => 'チャット内のボタンをタップして連絡先を保存できます';

  @override
  String get producto => '商品';

  @override
  String get sinMensajes => 'メッセージなし';

  @override
  String get fechaDesconocida => '日付不明';

  @override
  String haceDias(int cantidad) {
    return '$cantidad日前';
  }

  @override
  String haceHoras(int cantidad) {
    return '$cantidad時間前';
  }

  @override
  String haceMinutos(int cantidad) {
    return '$cantidad分前';
  }

  @override
  String get haceUnosSegundos => 'たった今';

  @override
  String get lun => '月';

  @override
  String get mar => '火';

  @override
  String get mie => '水';

  @override
  String get jue => '木';

  @override
  String get vie => '金';

  @override
  String get sab => '土';

  @override
  String errorGenerico(String error) {
    return 'エラー: $error';
  }

  @override
  String errorGenericoAlerta(String error) {
    return 'エラー: $error';
  }

  @override
  String get errorDesconocido => '不明';

  @override
  String get catElectronicos => '家電・スマホ・カメラ';

  @override
  String get catDeportes => 'スポーツ・レジャー';

  @override
  String get catHogar => '家具・インテリア';

  @override
  String get catMusica => '楽器・音楽';

  @override
  String get catCocina => 'キッチン用品';

  @override
  String get catPeliculas => '映画・DVD';

  @override
  String get catFotografia => 'カメラ・写真';

  @override
  String get catVideojuegos => 'ゲーム';

  @override
  String get catJuegosDeMesa => 'ボードゲーム';

  @override
  String get catJuguetes => 'おもちゃ';

  @override
  String get catFiguras => 'フィギュア';

  @override
  String get catAutomoviles => '自動車';

  @override
  String get catHerramientas => '工具';

  @override
  String get catRopaYCalzado => '衣類・靴';

  @override
  String get subElectronicos => 'スマホ、ノートPC、オーディオ';

  @override
  String get subDeportes => 'サッカー、テニス、ランニング';

  @override
  String get subHogar => '家具、インテリア、キッチン';

  @override
  String get subMusica => 'ギター、ピアノ、オーディオ機器';

  @override
  String get subCocina => '鍋、調理器具、食器';

  @override
  String get subPeliculas => 'アクション、コメディ、ドラマ';

  @override
  String get subFotografia => 'カメラ、レンズ、アクセサリ';

  @override
  String get subVideojuegos => 'ゲーム機、ソフト、コントローラー';

  @override
  String get subJuegosDeMesa => 'カード、ボード、戦略ゲーム';

  @override
  String get subJuguetes => 'ぬいぐるみ、ブロック、ミニカー';

  @override
  String get subFiguras => 'アクション、コレクター品、アニメ';

  @override
  String get alertasTitulo => 'お知らせ';

  @override
  String get recargar => '再読み込み';

  @override
  String get limpiarTodasLasAlertas => 'すべてのお知らせを削除';

  @override
  String get noTienesAlertas => 'お知らせはありません';

  @override
  String get aquiApareceranAvisos => 'ここにお知らせや待ち合わせの通知が表示されます。';

  @override
  String get noHayAlertasParaLimpiar => '削除するお知らせはありません';

  @override
  String get limpiarAlertas => '🗑️ お知らせを削除';

  @override
  String get confirmarLimpiarAlertas => 'すべてのお知らせを削除してもよろしいですか？';

  @override
  String get eliminarTodo => 'すべて削除';

  @override
  String get todasLasAlertasEliminadas => '✅ すべてのお知らせを削除しました';

  @override
  String errorAlLimpiarAlertas(String error) {
    return '削除エラー: $error';
  }

  @override
  String get cargandoAnuncio => '⏳ 広告を読み込み中... しばらくお待ちください';

  @override
  String get noSePudoCargarAnuncio => '❌ 広告を読み込めませんでした。再試行してください。';

  @override
  String get productoRenovado => '✅ 商品の掲載期間を30日間延長しました';

  @override
  String errorAlRenovar(String error) {
    return '延長エラー: $error';
  }

  @override
  String get debesVerAnuncioCompleto => '❌ 掲載を延長するには広告を最後まで視聴する必要があります';

  @override
  String get renovarPor30Dias => '30日間延長する';

  @override
  String get ambosConfirmaron => '双方確認済み';

  @override
  String get esperandoAlOtro => '相手の確認待ち';

  @override
  String get confirmarEncuentro => '待ち合わせを確認';

  @override
  String get verificarIdentidad => '本人確認';

  @override
  String get verificarIdentidadDelOtro => '相手の本人確認';

  @override
  String get identidadRechazada => '本人確認が拒否されました';

  @override
  String get revisarComparacion => '照合を確認';

  @override
  String get ambosConfirmaronExito => '✅ 双方の確認が完了しました。また後ほど！';

  @override
  String get confirmasteAsistencia => '✅ 参加を確認しました。相手の確認を待っています。';

  @override
  String get eliminarPublicidadTitulo => '広告を非表示';

  @override
  String get eliminaLosAnuncios => '広告なしで快適に';

  @override
  String get descripcionEliminarPublicidad =>
      'プランを購入すると、アプリ全体で広告なしで閲覧できます。中断のない快適な体験をお楽しみください。';

  @override
  String get beneficioSinAnuncios => 'アプリ全体の広告を非表示';

  @override
  String get beneficioNavegacionRapida => 'より高速なページ移動';

  @override
  String get beneficioSinInterrupciones => '中断のないストレスフリー体験';

  @override
  String get elegiTuPlan => 'プランを選択';

  @override
  String get plan1Mes => '1ヶ月';

  @override
  String get plan6Meses => '6ヶ月';

  @override
  String get sinAnunciosPor30Dias => '30日間 広告非表示';

  @override
  String get sinAnunciosPor180Dias => '180日間 広告非表示';

  @override
  String ahorrasMonto(String monto) {
    return '$monto お得';
  }

  @override
  String get elegiUnPlan => 'プランを選択してください';

  @override
  String pagarMonto(String monto) {
    return '$monto を支払う';
  }

  @override
  String get pagoSeguro => 'お支払いは安全に処理されます';

  @override
  String get confirmarCompra => '購入を確定';

  @override
  String confirmarCompraPregunta(String precio, String duracion) {
    return '$duracion間、広告非表示のために $precio を支払いますか？';
  }

  @override
  String get pagar => '支払う';

  @override
  String get integracionPagoEnDesarrollo => '🚧 決済機能は現在開発中です';

  @override
  String get encuentroCaducado => '待ち合わせの期限が切れました';

  @override
  String get esperandoVerificacionDelOtro => '相手が自撮り写真を確認するのを待っています';

  @override
  String get verificacionCompleta => '確認完了';

  @override
  String get premiumActivoTitulo => 'プレミアム会員です！';

  @override
  String get premiumActivoDescripcion => '広告が非表示になりました';

  @override
  String get planUnaSemana => '1週間';

  @override
  String get sinAnunciosPor7Dias => '7日間 広告非表示';

  @override
  String get yaTenesAnunciosEliminados => '既に広告は非表示になっています';

  @override
  String get productoNoDisponible => '利用できない商品です';

  @override
  String errorCompra(String detalle) {
    return 'エラー: $detalle';
  }

  @override
  String get desconocido => '不明';

  @override
  String get usuarioNoLogueado => 'ログインしているユーザーがいません';

  @override
  String get errorVerificarCompra => '購入の確認中にエラーが発生しました';

  @override
  String get compraExitosaAnunciosEliminados => '✅ 完了しました！広告が非表示になりました。';

  @override
  String get configurarImpulso => 'PR設定';

  @override
  String get impulsarTitulo => 'PR・宣伝する';

  @override
  String get impulsarPublicacion => '出品商品をPRする';

  @override
  String get poneTuProductoPrimero => '商品を一番上に表示しましょう';

  @override
  String get impulsarPunto1Titulo => '1番上に表示';

  @override
  String get impulsarPunto1Desc => 'ホーム画面のおすすめ商品リストの最上部に商品が表示されます。';

  @override
  String get impulsarPunto2Titulo => 'より多くの露出';

  @override
  String get impulsarPunto2Desc => '一番上に表示されるため、より多くの人に見てもらい、早く売れる可能性が高まります。';

  @override
  String get impulsarPunto3Titulo => '期間限定';

  @override
  String get impulsarPunto3Desc => '他の出品者がPR料を支払って上がってくると、1つ下に下がります。';

  @override
  String get seleccionarArticulo => '商品を選択';

  @override
  String get proximamenteDisponiblePagos => '近日公開予定。現在決済システムを準備中です。';

  @override
  String get articuloAImpulsar => 'PRする商品';

  @override
  String get comoFuncionaImpulso => '仕組みは？';

  @override
  String get explicacionImpulso =>
      'PRすると商品がホーム画面の最上部に上がります。他の出品者が自分の商品をPRすると1つ下に下がります。最も最近支払った出品者の商品が常に最初に表示されます。';

  @override
  String get procesando => '処理中...';

  @override
  String get cargando => '読み込み中...';

  @override
  String get impulsarAhora => '今すぐPRする';

  @override
  String get cambiarProducto => '商品を変更';

  @override
  String get noTenesProductosPublicados => '出品した商品がありません';

  @override
  String get elegiUnArticulo => '商品を選択してください';

  @override
  String get elQueElijasApareceraPrimero => '選択した商品がホーム画面の最上部に表示されます';

  @override
  String get primeroElegiUnArticulo => 'まず商品を選択してください';

  @override
  String get productoImpulsoNoDisponible => 'PR商品が利用できません。接続を確認してください。';

  @override
  String productoEstaPrimeroEnHome(String nombre) {
    return '✅ \"$nombre\" がホーム画面の最上部に表示されています';
  }

  @override
  String get pagoNoVerificado => '支払いを確認できませんでした。サポートにお問い合わせください。';

  @override
  String get compraPendiente => '購入が保留中です。もう一度お試しください。';

  @override
  String get errorAlImpulsar => 'PR中のエラー';

  @override
  String escudoActivoPor(String nombre) {
    return '$nombre がセキュリティシールドを有効にしました';
  }

  @override
  String get escudoPaso0Titulo => 'セキュリティシールドとは？';

  @override
  String get escudoPaso0Desc =>
      '取引当事者双方が同意したときに有効になる保護措置のセットです。詐欺を防ぎ、安全な待ち合わせを保証することを目的としています。\n\n誰が有効にすべきですか？\n取引当事者双方がシールドを承認する必要があります。一方が有効にすると、もう一方に承認または拒否の通知が届きます。相手が拒否した場合、チャットは双方とも閉鎖されます。';

  @override
  String get escudoPaso1Titulo => 'シールドが有効になるとどうなりますか？';

  @override
  String get escudoPaso1Desc =>
      '3.1. リンクと電話番号のブロック：アプリがメッセージ内の電話番号と外部リンクを自動的に検出してブロックします。これにより、プラットフォーム外への連絡先の共有を防ぎ、詐欺のリスクを減らします。';

  @override
  String get escudoPaso2Titulo => '取引を完了する方法';

  @override
  String get escudoPaso2Desc =>
      '取引を完了するには、まず待ち合わせを提案します：チャット上部バーのシールドをタップして「待ち合わせを提案」を選択します。そこで地域、市区町村、安全な場所、日時を選択します。提案を送信すると、相手がチャットでカードとして受け取ります。承認すると待ち合わせが予約されますが、チャットは開いたままです。会話を続けることができます。取引を完了するには、もう一度シールドをタップして「取引を完了」を選択します。確認ダイアログが開きます。双方が確認すると、チャットがブロックされ、保護機能が有効になります。';

  @override
  String get escudoPaso3Titulo => '出席確認';

  @override
  String get escudoPaso3Desc =>
      '待ち合わせの1時間前に、双方のユーザーに出席確認の通知が届きます。通知後15分以内に確認しない場合、相手は約束時間の15分前まで待ち合わせをキャンセルできます。';

  @override
  String get escudoPaso4Titulo => 'GPS追跡';

  @override
  String get escudoPaso4Desc =>
      '3.3. 待ち合わせ当日のGPS追跡：約束当日、待ち合わせの15分前に双方のユーザーはその場所にいて、位置確認のためにGPSを有効にする必要があります。約束時間の5分前までにGPSを有効にせず本人確認もしない場合、遅刻とみなされます。約束時間の15分後にも確認しない場合、不参加とみなされます。いずれの場合も記録され、MiMarketplaceの規約に従って制裁を受ける可能性があります。';

  @override
  String get escudoPaso5Titulo => '顔認証';

  @override
  String get escudoPaso5Desc =>
      '3.4. チャット前の本人確認：待ち合わせチャットを開くには、双方のユーザーが本人であることを確認する必要があります。これは約束時間の15分前に有効になり、チャットを開くための必須要件です。システムは各ユーザーにその場で写真を撮るよう求めます。その後、相手はその写真をプロフィール写真と比較して一致するか確認する必要があります。相手が認証を有効にすると認証が始まるので、注意して画面に表示される指示に従ってください。これにより、他の人がアカウントを使用するのを防ぎます。';

  @override
  String get escudoPaso6Titulo => '追加の考慮事項';

  @override
  String get escudoPaso6Desc =>
      '4.1. 自主的なキャンセル：すべてのユーザーは約束時間の1時間前まで待ち合わせへの参加をキャンセルできます。1時間を切るとキャンセルはできなくなります。\n\nキャンセル方法：商品チャットに入り、上部バーのシールドボタンをタップして「取引をキャンセル」を選択します。待ち合わせの日付が表示され、キャンセル可能かどうか、または1時間を切っているかが示されます。可能な場合は確認すると、双方の待ち合わせがキャンセルされます。\n\n常にお知らせセクションを確認してください。待ち合わせのリマインダー、出席確認、本人確認、ステータス変更がここに届きます。重要な情報を見逃さないように頻繁に確認してください。';

  @override
  String get noAceptar => '承認しない';

  @override
  String get aceptar => '承認する';

  @override
  String get cerrar => '閉じる';

  @override
  String get siguiente => '次へ';

  @override
  String get iniciar => '開始';

  @override
  String get verVideo => '動画を見る';

  @override
  String errorGenericoImpulsar(String error) {
    return 'エラー: $error';
  }

  @override
  String get ubicacionDelEncuentro => '待ち合わせ場所';

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
  String get porFavorEscribeUnMensaje => 'メッセージを入力してください';

  @override
  String get porFavorEscribeUnAsunto => '件名を入力してください';

  @override
  String get mensajeEnviadoExito => '✅ メッセージを送信しました。すぐにご返信します。';

  @override
  String get necesitasAyuda => 'お困りですか？';

  @override
  String get cuentanosTuProblema => '問題を教えてください。解決をお手伝いします。';

  @override
  String get tipoDeConsulta => 'お問い合わせの種類';

  @override
  String get asunto => '件名';

  @override
  String get ejemploProblemaCuenta => '例：アカウントの問題';

  @override
  String get mensaje => 'メッセージ';

  @override
  String get describeTuProblema => '問題をできるだけ詳しく説明してください...';

  @override
  String get enviarMensaje => 'メッセージを送信';

  @override
  String get tiempoRespuestaEstimado => '返信予定時間：24〜48時間';

  @override
  String get mensajeEnviado => 'メッセージを送信しました！';

  @override
  String get hemosRecibidoTuConsulta =>
      'お問い合わせを受け付けました。サポートチームが24〜48時間以内にご返信します。';

  @override
  String get enviarOtroMensaje => '別のメッセージを送信';

  @override
  String get volver => '戻る';

  @override
  String get categoria => 'カテゴリー';

  @override
  String get direccion => '住所';

  @override
  String get nombreDelProducto => '商品名';

  @override
  String get ejemploNombreProducto => '例：iPhone 13、ノートPCなど';

  @override
  String get ingresaNombreProducto => '商品名を入力してください';

  @override
  String get nombreMinimoCaracteres => '名前は3文字以上である必要があります';

  @override
  String get precio => '価格 (₡)';

  @override
  String get ingresePrecioProducto => '商品の価格を入力してください';

  @override
  String get ingresaPrecio => '価格を入力してください';

  @override
  String get ingresaPrecioValido => '有効な価格を入力してください';

  @override
  String get precioMayorCero => '価格は0より大きい必要があります';

  @override
  String get descripcion => '説明';

  @override
  String get escribeDescripcionDetallada => '商品の詳細な説明を書いてください...';

  @override
  String get ingresaDescripcion => '説明を入力してください';

  @override
  String get publicarProducto => '商品を出品';

  @override
  String get compartaProductoComunidad => '商品をコミュニティと共有しましょう';

  @override
  String get anuncioCompletado => '✅ 広告が完了しました。商品を出品中...';

  @override
  String get debesVerAnuncioParaPublicar => '❌ 出品するには広告を最後まで視聴する必要があります';

  @override
  String get productoEnviadoRevision => '📝 商品が審査に送信されました。承認されると通知が届きます。';

  @override
  String errorAlPublicar(String error) {
    return '出品エラー: $error';
  }

  @override
  String get paraPublicarNecesitasVerAnuncio => '商品を出品するには、短い広告を視聴する必要があります。';

  @override
  String get verAnuncio => '広告を見る';

  @override
  String get agregarImagenes => '画像を追加';

  @override
  String get imagenDestacada => 'メイン画像';

  @override
  String get estaImagenApareceraPortada => 'この画像は商品のカバーとおすすめセクションに表示されます。';

  @override
  String get soloImagenesCalidadEstudio =>
      'スタジオ品質の写真（良好な照明、シャープなピント、きれいな背景）のみ受け付けます。';

  @override
  String get tocaParaSeleccionarImagen => 'タップして画像を選択';

  @override
  String get formatosImagenPermitidos => 'JPG、PNG、WEBP · 最大10MB';

  @override
  String get enRevisionPuntos => '🔍 審査中...';

  @override
  String get enviadoARevision => '🔄 審査に送信済み';

  @override
  String get enviarARevision => '🛡️ 審査に送信';

  @override
  String get imagenRevisadaIA => '画像はAIによって審査されます。承認されると通知が届きます。';

  @override
  String get imagenesRealesProducto => '商品の実物画像';

  @override
  String get subeHasta4Fotos => '商品の実物写真を最大4枚アップロードしてください（必須）';

  @override
  String get agregar => '追加';

  @override
  String get maximo4ImagenesReales => '⚠️ 実物画像は最大4枚までアップロードできます';

  @override
  String get escribeDescripcionMejorarImagen => '画像を改善するための説明を書いてください';

  @override
  String get primeroSeleccionaImagen => 'まず画像を選択してください';

  @override
  String get imagenMejoradaCorrectamente => '✅ 画像が正常に改善されました';

  @override
  String get errorGenerarImagen => '画像生成エラー';

  @override
  String get imagenEnviadaRevision => '🔄 画像が審査に送信されました。承認されると通知が届きます。';

  @override
  String errorEnviarImagen(String codigo) {
    return '画像送信エラー: $codigo';
  }

  @override
  String get revisionDeImagen => '🛡️ 画像審査';

  @override
  String get tuImagenSeraEnviadaModeracion =>
      'あなたの画像は審査のためにモデレーションチームに送信されます。続行するには短い広告を視聴する必要があります。';

  @override
  String get revisionPuedeTomar24Horas => '審査には最大24時間かかる場合があります。';

  @override
  String get verAnuncioConEmoji => '広告を見る 🎬';

  @override
  String get anuncioCompletadoEnviandoImagen => '✅ 広告が完了しました。画像を審査に送信中...';

  @override
  String get debesVerAnuncioParaEnviarImagen => '❌ 画像を送信するには広告を最後まで視聴する必要があります';

  @override
  String get seleccionaAlMenos1Imagen => '少なくとも1枚の実物画像を選択してください';

  @override
  String get siguienteConFlecha => '次へ →';

  @override
  String get recoleccionDeDatos => 'データ収集';

  @override
  String get tuPrivacidadImportante =>
      'あなたのプライバシーは私たちにとって重要です。パーソナライズされた商品提案を受け取るために、閲覧データと設定の収集を許可するかどうかを選択できます。';

  @override
  String get aceptoRecoleccionDatos =>
      'パーソナライズされた商品提案を受け取るために、閲覧データと設定の収集に同意します。';

  @override
  String get guardarPreferencias => '設定を保存';

  @override
  String get preferenciasGuardadas => '✅ 設定を保存しました';

  @override
  String get errorAlGuardar => '保存エラー';

  @override
  String get historialDePagos => '支払い履歴';

  @override
  String get consultaTodosLosPagos =>
      'アプリ内で行ったすべての支払いを確認できます：出品のPR、更新、広告非表示、その他のサービス。';

  @override
  String get verHistorialDePagos => '支払い履歴を見る';

  @override
  String get todosTusPagosTransacciones => 'すべての支払いと取引';

  @override
  String get estadoDeCuenta => 'アカウント状態';

  @override
  String get revisaTusAdvertencias => 'プラットフォーム上の警告と有効な停止を確認してください。';

  @override
  String get advertencias => '警告';

  @override
  String get suspensionesTemporales => '一時停止';

  @override
  String get asistenciaAEncuentros => '待ち合わせの出席';

  @override
  String get llegadasTardias => '遅刻';

  @override
  String get noVerificaste5Min => '5分以内に確認しませんでした。3回 = 警告1回';

  @override
  String get ausencias => '欠席';

  @override
  String get noLlegasteEncuentro => '待ち合わせに来ませんでした。1回 = 警告1回';

  @override
  String minutosTardeAcumulados(int cantidad) {
    return '⏱️ 累積遅刻時間: $cantidad分';
  }

  @override
  String get informacion => '情報';

  @override
  String get comoFunciona => '仕組みは？';

  @override
  String get comoFuncionaEstadoCuenta =>
      'あなたのアカウントはコミュニティルール違反により警告と一時停止を蓄積します。\n\n待ち合わせの出席：\n• 遅刻3回（0/3）= 警告1回。\n• 欠席1回 = 警告1回。\n\nエスカレーション：\n• 警告3回 = 一時停止1回（7日間）。\n• 停止3回 = 永久BAN。\n\n回復：\n• 毎月遅刻2回が差し引かれます。\n• 3ヶ月ごとに警告1回が差し引かれます。';

  @override
  String get advertenciasInfo =>
      '警告（最大3回）：不適切な言葉、誤解を招く出品、軽微なルール違反などの軽い報告で発生します。アカウントはブロックされません。';

  @override
  String get suspensionesInfo =>
      '一時停止（最大3回）：詐欺、嫌がらせ、なりすまし、警告の繰り返しなど、より重大な違反に適用されます。各停止はアカウントを一定期間ブロックします。';

  @override
  String get baneoInfo => '停止3回に達すると、アカウントは永久にBANされ、そのメールアドレスは再登録できなくなります。';

  @override
  String get entendido => '了解';

  @override
  String get guardar => '保存';

  @override
  String get guardarCambios => '変更を保存';

  @override
  String get nombreCompleto => '氏名';

  @override
  String get telefono => '電話番号';

  @override
  String get usuarioNoAutenticado => 'ユーザーが認証されていません';

  @override
  String get errorAlCargarDatos => 'データの読み込みエラー';

  @override
  String get nombreNoPuedeEstarVacio => '名前は空にできません';

  @override
  String get perfilActualizadoCorrectamente => '✅ プロフィールが正常に更新されました';

  @override
  String get errorAlGuardarEnServidor => 'サーバーへの保存エラー';

  @override
  String get volverAlPerfil => 'Volver al perfil';
}
