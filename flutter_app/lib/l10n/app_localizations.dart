import 'package:flutter/material.dart';

/// Hand-maintained translations. Keeping these in one place avoids a
/// code-generation step for a small, stable set of strings.
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [
    Locale('en'),
    Locale('es'),
    Locale('zh', 'CN'),
  ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const _delegate = _AppLocalizationsDelegate();

  static const LocalizationsDelegate<AppLocalizations> delegate = _delegate;

  String _t(String key) =>
      _values[locale.languageCode]?[key] ?? _en[key] ?? key;

  String get appName => _t('appName');
  String get top => _t('top');
  String get newest => _t('newest');
  String get best => _t('best');
  String get ask => _t('ask');
  String get show => _t('show');
  String get jobs => _t('jobs');
  String get popular => _t('popular');
  String get lastDay => _t('lastDay');
  String get lastWeek => _t('lastWeek');
  String get lastMonth => _t('lastMonth');
  String get lastYear => _t('lastYear');
  String get favorites => _t('favorites');
  String get search => _t('search');
  String get submit => _t('submit');
  String get settings => _t('settings');
  String get login => _t('login');
  String get logout => _t('logout');
  String get profile => _t('profile');
  String get comments => _t('comments');
  String get noComments => _t('noComments');
  String get retry => _t('retry');
  String get error => _t('error');
  String get noResults => _t('noResults');
  String get searchHint => _t('searchHint');
  String get by => _t('by');
  String get points => _t('points');
  String get ago => _t('ago');
  String get justNow => _t('justNow');
  String get minutesAgo => _t('minutesAgo');
  String get hoursAgo => _t('hoursAgo');
  String get daysAgo => _t('daysAgo');
  String get addFavorite => _t('addFavorite');
  String get removeFavorite => _t('removeFavorite');
  String get favorite => _t('favorite');
  String get share => _t('share');
  String get openBrowser => _t('openBrowser');
  String get openComments => _t('openComments');
  String get reply => _t('reply');
  String get upvote => _t('upvote');
  String get loginRequired => _t('loginRequired');
  String get username => _t('username');
  String get password => _t('password');
  String get signIn => _t('signIn');
  String get createAccount => _t('createAccount');
  String get cancel => _t('cancel');
  String get save => _t('save');
  String get theme => _t('theme');
  String get textSize => _t('textSize');
  String get font => _t('font');
  String get launchScreen => _t('launchScreen');
  String get reading => _t('reading');
  String get externalBrowser => _t('externalBrowser');
  String get colorCode => _t('colorCode');
  String get threadIndicator => _t('threadIndicator');
  String get swipeActions => _t('swipeActions');
  String get autoMarkRead => _t('autoMarkRead');
  String get lazyLoad => _t('lazyLoad');
  String get exportFavorites => _t('exportFavorites');
  String get clearFavorites => _t('clearFavorites');
  String get clearReadHistory => _t('clearReadHistory');
  String get clearSearchHistory => _t('clearSearchHistory');
  String get searchHistory => _t('searchHistory');
  String get delete => _t('delete');
  String get title => _t('title');
  String get url => _t('url');
  String get text => _t('text');
  String get post => _t('post');
  String get more => _t('more');
  String get read => _t('read');
  String get unread => _t('unread');
  String get loading => _t('loading');
  String get about => _t('about');
  String get account => _t('account');
  String get signOutConfirm => _t('signOutConfirm');
  String get invalidUrl => _t('invalidUrl');
  String get emptyFavorites => _t('emptyFavorites');
  String get emptyHistory => _t('emptyHistory');
  String get submitStory => _t('submitStory');
  String get story => _t('story');
  String get unknown => _t('unknown');
  String get content => _t('content');
  String get original => _t('original');
  String get saved => _t('saved');
  String get removed => _t('removed');
  String get markAllRead => _t('markAllRead');
  String get fontDefault => _t('fontDefault');
  String get fontSerif => _t('fontSerif');
  String get fontSlab => _t('fontSlab');
  String get fontBaskerville => _t('fontBaskerville');
  String get appearance => _t('appearance');
  String get behavior => _t('behavior');
  String get data => _t('data');
  String get general => _t('general');
  String get dark => _t('dark');
  String get light => _t('light');
  String get black => _t('black');
  String get sepia => _t('sepia');
  String get green => _t('green');
  String get solarized => _t('solarized');
  String get solarizedDark => _t('solarizedDark');
  String get system => _t('system');
  String get extraSmall => _t('extraSmall');
  String get small => _t('small');
  String get normal => _t('normal');
  String get large => _t('large');
  String get extraLarge => _t('extraLarge');
  String get version => _t('version');
  String get sourceCode => _t('sourceCode');
  String get noConnection => _t('noConnection');
  String get commentHint => _t('commentHint');
  String get submitted => _t('submitted');
  String get karma => _t('karma');
  String get joined => _t('joined');
  String get sortRecent => _t('sortRecent');
  String get sortRelevant => _t('sortRelevant');
  String get collapse => _t('collapse');
  String get expand => _t('expand');
  String get openInReader => _t('openInReader');
  String get cannotOpen => _t('cannotOpen');
  String get credentialsInvalid => _t('credentialsInvalid');
  String get postingFailed => _t('postingFailed');
  String get commentPosted => _t('commentPosted');
  String get storySubmitted => _t('storySubmitted');
  String get favoriteAdded => _t('favoriteAdded');
  String get favoriteRemoved => _t('favoriteRemoved');
  String get email => _t('email');
  String get optional => _t('optional');
  String get hnNote => _t('hnNote');
  String get lastScreen => _t('lastScreen');

  static const Map<String, Map<String, String>> _values = {
    'en': _en,
    'es': _es,
    'zh': _zh,
  };

  static const Map<String, String> _en = {
    'appName': 'Materialistic',
    'top': 'Top',
    'newest': 'New',
    'best': 'Best',
    'ask': 'Ask',
    'show': 'Show',
    'jobs': 'Jobs',
    'popular': 'Popular',
    'lastDay': 'Last 24 hours',
    'lastWeek': 'Last week',
    'lastMonth': 'Last month',
    'lastYear': 'Last year',
    'favorites': 'Favorites',
    'search': 'Search',
    'submit': 'Submit',
    'settings': 'Settings',
    'login': 'Log in',
    'logout': 'Log out',
    'profile': 'Profile',
    'comments': 'comments',
    'noComments': 'No comments yet',
    'retry': 'Retry',
    'error': 'Something went wrong',
    'noResults': 'No results',
    'searchHint': 'Search Hacker News',
    'by': 'by',
    'points': 'points',
    'ago': 'ago',
    'justNow': 'just now',
    'minutesAgo': 'm ago',
    'hoursAgo': 'h ago',
    'daysAgo': 'd ago',
    'addFavorite': 'Add to favorites',
    'removeFavorite': 'Remove from favorites',
    'favorite': 'Favorite',
    'share': 'Share',
    'openBrowser': 'Open in browser',
    'openComments': 'Open comments',
    'reply': 'Reply',
    'upvote': 'Upvote',
    'loginRequired': 'Log in to continue',
    'username': 'Username',
    'password': 'Password',
    'signIn': 'Sign in',
    'createAccount': 'Create account',
    'cancel': 'Cancel',
    'save': 'Save',
    'theme': 'Theme',
    'textSize': 'Text size',
    'font': 'Font',
    'launchScreen': 'Launch screen',
    'reading': 'Reading',
    'externalBrowser': 'External browser',
    'colorCode': 'Color-code usernames',
    'threadIndicator': 'Thread indicators',
    'swipeActions': 'Swipe actions',
    'autoMarkRead': 'Auto-mark as read',
    'lazyLoad': 'Lazy load comments',
    'exportFavorites': 'Export favorites',
    'clearFavorites': 'Clear favorites',
    'clearReadHistory': 'Clear read history',
    'clearSearchHistory': 'Clear search history',
    'searchHistory': 'Search history',
    'delete': 'Delete',
    'title': 'Title',
    'url': 'URL',
    'text': 'Text',
    'post': 'Post',
    'more': 'More',
    'read': 'Read',
    'unread': 'Unread',
    'loading': 'Loading…',
    'about': 'About',
    'account': 'Account',
    'signOutConfirm': 'Sign out of Hacker News?',
    'invalidUrl': 'Enter a valid URL',
    'emptyFavorites': 'Stories you save will appear here',
    'emptyHistory': 'Recent searches will appear here',
    'submitStory': 'Submit a story',
    'story': 'Story',
    'unknown': 'Unknown',
    'content': 'Content',
    'original': 'Original',
    'saved': 'Saved',
    'removed': 'Removed',
    'markAllRead': 'Mark all as read',
    'fontDefault': 'Default',
    'fontSerif': 'Serif',
    'fontSlab': 'Slab serif',
    'fontBaskerville': 'Baskerville',
    'appearance': 'Appearance',
    'behavior': 'Behavior',
    'data': 'Data',
    'general': 'General',
    'dark': 'Dark',
    'light': 'Light',
    'black': 'Black',
    'sepia': 'Sepia',
    'green': 'Green',
    'solarized': 'Solarized',
    'solarizedDark': 'Solarized dark',
    'system': 'Follow system',
    'extraSmall': 'Extra small',
    'small': 'Small',
    'normal': 'Normal',
    'large': 'Large',
    'extraLarge': 'Extra large',
    'version': 'Version',
    'sourceCode': 'Source code',
    'noConnection': 'Check your connection and try again',
    'commentHint': 'Write a comment…',
    'submitted': 'Submitted',
    'karma': 'Karma',
    'joined': 'Joined',
    'sortRecent': 'Most recent',
    'sortRelevant': 'Most relevant',
    'collapse': 'Collapse',
    'expand': 'Expand',
    'openInReader': 'Open in reader',
    'cannotOpen': 'Could not open link',
    'credentialsInvalid': 'Invalid username or password',
    'postingFailed': 'Could not post. Please try again.',
    'commentPosted': 'Comment posted',
    'storySubmitted': 'Story submitted',
    'favoriteAdded': 'Added to favorites',
    'favoriteRemoved': 'Removed from favorites',
    'email': 'Email',
    'optional': 'optional',
    'hnNote': 'Hacker News does not display email addresses publicly.',
    'lastScreen': 'Last used screen',
  };

  static const Map<String, String> _es = {
    'appName': 'Materialistic',
    'top': 'Principales',
    'newest': 'Nuevas',
    'best': 'Mejores',
    'ask': 'Preguntas',
    'show': 'Mostrar',
    'jobs': 'Empleos',
    'popular': 'Populares',
    'lastDay': 'Últimas 24 horas',
    'lastWeek': 'Última semana',
    'lastMonth': 'Último mes',
    'lastYear': 'Último año',
    'favorites': 'Favoritos',
    'search': 'Buscar',
    'submit': 'Enviar',
    'settings': 'Ajustes',
    'login': 'Iniciar sesión',
    'logout': 'Cerrar sesión',
    'profile': 'Perfil',
    'comments': 'comentarios',
    'noComments': 'Aún no hay comentarios',
    'retry': 'Reintentar',
    'error': 'Algo salió mal',
    'noResults': 'Sin resultados',
    'searchHint': 'Buscar en Hacker News',
    'by': 'por',
    'points': 'puntos',
    'ago': 'hace',
    'justNow': 'ahora mismo',
    'minutesAgo': 'min',
    'hoursAgo': 'h',
    'daysAgo': 'd',
    'addFavorite': 'Añadir a favoritos',
    'removeFavorite': 'Quitar de favoritos',
    'favorite': 'Favorito',
    'share': 'Compartir',
    'openBrowser': 'Abrir en el navegador',
    'openComments': 'Abrir comentarios',
    'reply': 'Responder',
    'upvote': 'Votar',
    'loginRequired': 'Inicia sesión para continuar',
    'username': 'Usuario',
    'password': 'Contraseña',
    'signIn': 'Entrar',
    'createAccount': 'Crear cuenta',
    'cancel': 'Cancelar',
    'save': 'Guardar',
    'theme': 'Tema',
    'textSize': 'Tamaño del texto',
    'font': 'Fuente',
    'launchScreen': 'Pantalla de inicio',
    'reading': 'Lectura',
    'externalBrowser': 'Navegador externo',
    'colorCode': 'Colorear usuarios',
    'threadIndicator': 'Indicadores de hilo',
    'swipeActions': 'Acciones al deslizar',
    'autoMarkRead': 'Marcar como leído',
    'lazyLoad': 'Cargar comentarios por partes',
    'exportFavorites': 'Exportar favoritos',
    'clearFavorites': 'Borrar favoritos',
    'clearReadHistory': 'Borrar historial de lectura',
    'clearSearchHistory': 'Borrar historial de búsqueda',
    'searchHistory': 'Historial de búsqueda',
    'delete': 'Eliminar',
    'title': 'Título',
    'url': 'URL',
    'text': 'Texto',
    'post': 'Publicar',
    'more': 'Más',
    'read': 'Leído',
    'unread': 'No leído',
    'loading': 'Cargando…',
    'about': 'Acerca de',
    'account': 'Cuenta',
    'signOutConfirm': '¿Cerrar sesión de Hacker News?',
    'invalidUrl': 'Introduce una URL válida',
    'emptyFavorites': 'Las historias guardadas aparecerán aquí',
    'emptyHistory': 'Las búsquedas recientes aparecerán aquí',
    'submitStory': 'Enviar una historia',
    'story': 'Historia',
    'unknown': 'Desconocido',
    'content': 'Contenido',
    'original': 'Original',
    'saved': 'Guardado',
    'removed': 'Eliminado',
    'markAllRead': 'Marcar todo como leído',
    'fontDefault': 'Predeterminada',
    'fontSerif': 'Serif',
    'fontSlab': 'Slab serif',
    'fontBaskerville': 'Baskerville',
    'appearance': 'Apariencia',
    'behavior': 'Comportamiento',
    'data': 'Datos',
    'general': 'General',
    'dark': 'Oscuro',
    'light': 'Claro',
    'black': 'Negro',
    'sepia': 'Sepia',
    'green': 'Verde',
    'solarized': 'Solarizado',
    'solarizedDark': 'Solarizado oscuro',
    'system': 'Seguir al sistema',
    'extraSmall': 'Muy pequeño',
    'small': 'Pequeño',
    'normal': 'Normal',
    'large': 'Grande',
    'extraLarge': 'Muy grande',
    'version': 'Versión',
    'sourceCode': 'Código fuente',
    'noConnection': 'Comprueba tu conexión e inténtalo de nuevo',
    'commentHint': 'Escribe un comentario…',
    'submitted': 'Enviado',
    'karma': 'Karma',
    'joined': 'Se unió',
    'sortRecent': 'Más recientes',
    'sortRelevant': 'Más relevantes',
    'collapse': 'Contraer',
    'expand': 'Expandir',
    'openInReader': 'Abrir en el lector',
    'cannotOpen': 'No se pudo abrir el enlace',
    'credentialsInvalid': 'Usuario o contraseña incorrectos',
    'postingFailed': 'No se pudo publicar. Inténtalo de nuevo.',
    'commentPosted': 'Comentario publicado',
    'storySubmitted': 'Historia enviada',
    'favoriteAdded': 'Añadido a favoritos',
    'favoriteRemoved': 'Eliminado de favoritos',
    'email': 'Correo electrónico',
    'optional': 'opcional',
    'hnNote': 'Hacker News no muestra las direcciones de correo públicamente.',
    'lastScreen': 'Última pantalla usada',
  };

  static const Map<String, String> _zh = {
    'appName': 'Materialistic',
    'top': '头条',
    'newest': '最新',
    'best': '最佳',
    'ask': '问答',
    'show': '展示',
    'jobs': '招聘',
    'popular': '热门',
    'lastDay': '最近 24 小时',
    'lastWeek': '最近一周',
    'lastMonth': '最近一个月',
    'lastYear': '最近一年',
    'favorites': '收藏',
    'search': '搜索',
    'submit': '提交',
    'settings': '设置',
    'login': '登录',
    'logout': '退出登录',
    'profile': '个人资料',
    'comments': '条评论',
    'noComments': '还没有评论',
    'retry': '重试',
    'error': '出了点问题',
    'noResults': '没有结果',
    'searchHint': '搜索 Hacker News',
    'by': '作者',
    'points': '分',
    'ago': '前',
    'justNow': '刚刚',
    'minutesAgo': '分钟前',
    'hoursAgo': '小时前',
    'daysAgo': '天前',
    'addFavorite': '添加到收藏',
    'removeFavorite': '取消收藏',
    'favorite': '收藏',
    'share': '分享',
    'openBrowser': '在浏览器中打开',
    'openComments': '查看评论',
    'reply': '回复',
    'upvote': '点赞',
    'loginRequired': '请先登录',
    'username': '用户名',
    'password': '密码',
    'signIn': '登录',
    'createAccount': '创建账号',
    'cancel': '取消',
    'save': '保存',
    'theme': '主题',
    'textSize': '文字大小',
    'font': '字体',
    'launchScreen': '启动页面',
    'reading': '阅读',
    'externalBrowser': '外部浏览器',
    'colorCode': '用户名着色',
    'threadIndicator': '线程指示线',
    'swipeActions': '滑动操作',
    'autoMarkRead': '自动标记已读',
    'lazyLoad': '分页加载评论',
    'exportFavorites': '导出收藏',
    'clearFavorites': '清空收藏',
    'clearReadHistory': '清除阅读记录',
    'clearSearchHistory': '清除搜索记录',
    'searchHistory': '搜索记录',
    'delete': '删除',
    'title': '标题',
    'url': '网址',
    'text': '正文',
    'post': '发布',
    'more': '更多',
    'read': '已读',
    'unread': '未读',
    'loading': '加载中…',
    'about': '关于',
    'account': '账号',
    'signOutConfirm': '要退出 Hacker News 吗？',
    'invalidUrl': '请输入有效的网址',
    'emptyFavorites': '收藏的故事会显示在这里',
    'emptyHistory': '最近的搜索会显示在这里',
    'submitStory': '提交故事',
    'story': '故事',
    'unknown': '未知',
    'content': '内容',
    'original': '原文',
    'saved': '已保存',
    'removed': '已删除',
    'markAllRead': '全部标为已读',
    'fontDefault': '默认',
    'fontSerif': '衬线',
    'fontSlab': '粗衬线',
    'fontBaskerville': 'Baskerville',
    'appearance': '外观',
    'behavior': '行为',
    'data': '数据',
    'general': '通用',
    'dark': '深色',
    'light': '浅色',
    'black': '纯黑',
    'sepia': '复古',
    'green': '绿色',
    'solarized': 'Solarized',
    'solarizedDark': 'Solarized 深色',
    'system': '跟随系统',
    'extraSmall': '特小',
    'small': '小',
    'normal': '标准',
    'large': '大',
    'extraLarge': '特大',
    'version': '版本',
    'sourceCode': '源代码',
    'noConnection': '请检查网络连接后重试',
    'commentHint': '写下评论…',
    'submitted': '已提交',
    'karma': '声望',
    'joined': '加入于',
    'sortRecent': '最新优先',
    'sortRelevant': '相关度优先',
    'collapse': '折叠',
    'expand': '展开',
    'openInReader': '在阅读模式中打开',
    'cannotOpen': '无法打开链接',
    'credentialsInvalid': '用户名或密码错误',
    'postingFailed': '发布失败，请重试。',
    'commentPosted': '评论已发布',
    'storySubmitted': '故事已提交',
    'favoriteAdded': '已添加到收藏',
    'favoriteRemoved': '已取消收藏',
    'email': '邮箱',
    'optional': '可选',
    'hnNote': 'Hacker News 不会公开显示邮箱地址。',
    'lastScreen': '上次使用的页面',
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any(
    (supported) => supported.languageCode == locale.languageCode,
  );

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}
