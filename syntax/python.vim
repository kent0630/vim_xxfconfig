" Vim syntax file
" Language:	Python
" Maintainer:	Neil Schemenauer <nas@python.ca>
" Last Change:	2010 Sep 21
" Credits:	Zvezdan Petkovic <zpetkovic@acm.org>
"		Neil Schemenauer <nas@python.ca>
"		Dmitry Vasiliev
"
"		This version is a major rewrite by Zvezdan Petkovic.
"
"		- introduced highlighting of doctests
"		- updated keywords, built-ins, and exceptions
"		- corrected regular expressions for
"
"		  * functions
"		  * decorators
"		  * strings
"		  * escapes
"		  * numbers
"		  * space error
"
"		- corrected synchronization
"		- more highlighting is ON by default, except
"		- space error highlighting is OFF by default
"
" Optional highlighting can be controlled using these variables.
"
"   let python_no_builtin_highlight = 1
"   let python_no_doctest_code_highlight = 1
"   let python_no_doctest_highlight = 1
"   let python_no_exception_highlight = 1
"   let python_no_number_highlight = 1
"   let python_space_error_highlight = 1
"
" All the options above can be switched on together.
"
"   let python_highlight_all = 1
"

" For version 5.x: Clear all syntax items.
" For version 6.x: Quit when a syntax file was already loaded.
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" We need nocompatible mode in order to continue lines with backslashes.
" Original setting will be restored.
let s:cpo_save = &cpo
set cpo&vim

" Keep Python keywords in alphabetical order inside groups for easy
" comparison with the table in the 'Python Language Reference'
" http://docs.python.org/reference/lexical_analysis.html#keywords.
" Groups are in the order presented in NAMING CONVENTIONS in syntax.txt.
" Exceptions come last at the end of each group (class and def below).
"
" Keywords 'with' and 'as' are new in Python 2.6
" (use 'from __future__ import with_statement' in Python 2.5).
"
" Some compromises had to be made to support both Python 3.0 and 2.6.
" We include Python 3.0 features, but when a definition is duplicated,
" the last definition takes precedence.
"
" - 'False', 'None', and 'True' are keywords in Python 3.0 but they are
"   built-ins in 2.6 and will be highlighted as built-ins below.
" - 'exec' is a built-in in Python 3.0 and will be highlighted as
"   built-in below.
" - 'nonlocal' is a keyword in Python 3.0 and will be highlighted.
" - 'print' is a built-in in Python 3.0 and will be highlighted as
"   built-in below (use 'from __future__ import print_function' in 2.6)
"
syn keyword pythonStatement	False, None, True
syn keyword pythonStatement	as assert break continue del exec global
syn keyword pythonStatement	lambda nonlocal pass print return with yield
syn keyword pythonStatement	class def self nextgroup=pythonFunction skipwhite
syn keyword pythonConditional	elif else if
syn keyword pythonRepeat	for while
syn keyword pythonOperator	and in is not or
syn keyword pythonException	except finally raise try
syn keyword pythonInclude	from import

" Decorators (new in Python 2.4)
syn match   pythonDecorator	"@" display nextgroup=pythonFunction skipwhite
" The zero-length non-grouping match before the function name is
" extremely important in pythonFunction.  Without it, everything is
" interpreted as a function inside the contained environment of
" doctests.
" A dot must be allowed because of @MyClass.myfunc decorators.
syn match   pythonFunction
      \ "\%(\%(def\s\|class\s\|@\)\s*\)\@<=\h\%(\w\|\.\)*" contained

syn match   pythonComment	"#.*$" contains=pythonTodo,@Spell
syn keyword pythonTodo		FIXME NOTE NOTES TODO XXX contained

" Triple-quoted strings can contain doctests.
syn region  pythonString
      \ start=+[uU]\=\z(['"]\)+ end="\z1" skip="\\\\\|\\\z1"
      \ contains=pythonEscape,@Spell
syn region  pythonString
      \ start=+[uU]\=\z('''\|"""\)+ end="\z1" keepend
      \ contains=pythonEscape,pythonSpaceError,pythonDoctest,@Spell
syn region  pythonRawString
      \ start=+[uU]\=[rR]\z(['"]\)+ end="\z1" skip="\\\\\|\\\z1"
      \ contains=@Spell
syn region  pythonRawString
      \ start=+[uU]\=[rR]\z('''\|"""\)+ end="\z1" keepend
      \ contains=pythonSpaceError,pythonDoctest,@Spell

syn match   pythonEscape	+\\[abfnrtv'"\\]+ contained
syn match   pythonEscape	"\\\o\{1,3}" contained
syn match   pythonEscape	"\\x\x\{2}" contained
syn match   pythonEscape	"\%(\\u\x\{4}\|\\U\x\{8}\)" contained
" Python allows case-insensitive Unicode IDs: http://www.unicode.org/charts/
syn match   pythonEscape	"\\N{\a\+\%(\s\a\+\)*}" contained
syn match   pythonEscape	"\\$"

if exists("python_highlight_all")
  if exists("python_no_builtin_highlight")
    unlet python_no_builtin_highlight
  endif
  if exists("python_no_doctest_code_highlight")
    unlet python_no_doctest_code_highlight
  endif
  if exists("python_no_doctest_highlight")
    unlet python_no_doctest_highlight
  endif
  if exists("python_no_exception_highlight")
    unlet python_no_exception_highlight
  endif
  if exists("python_no_number_highlight")
    unlet python_no_number_highlight
  endif
  let python_space_error_highlight = 1
endif

" It is very important to understand all details before changing the
" regular expressions below or their order.
" The word boundaries are *not* the floating-point number boundaries
" because of a possible leading or trailing decimal point.
" The expressions below ensure that all valid number literals are
" highlighted, and invalid number literals are not.  For example,
"
" - a decimal point in '4.' at the end of a line is highlighted,
" - a second dot in 1.0.0 is not highlighted,
" - 08 is not highlighted,
" - 08e0 or 08j are highlighted,
"
" and so on, as specified in the 'Python Language Reference'.
" http://docs.python.org/reference/lexical_analysis.html#numeric-literals
if !exists("python_no_number_highlight")
  " numbers (including longs and complex)
  syn match   pythonNumber	"\<0[oO]\=\o\+[Ll]\=\>"
  syn match   pythonNumber	"\<0[xX]\x\+[Ll]\=\>"
  syn match   pythonNumber	"\<0[bB][01]\+[Ll]\=\>"
  syn match   pythonNumber	"\<\%([1-9]\d*\|0\)[Ll]\=\>"
  syn match   pythonNumber	"\<\d\+[jJ]\>"
  syn match   pythonNumber	"\<\d\+[eE][+-]\=\d\+[jJ]\=\>"
  syn match   pythonNumber
	\ "\<\d\+\.\%([eE][+-]\=\d\+\)\=[jJ]\=\%(\W\|$\)\@="
  syn match   pythonNumber
	\ "\%(^\|\W\)\@<=\d*\.\d\+\%([eE][+-]\=\d\+\)\=[jJ]\=\>"
endif

" Group the built-ins in the order in the 'Python Library Reference' for
" easier comparison.
" http://docs.python.org/library/constants.html
" http://docs.python.org/library/functions.html
" http://docs.python.org/library/functions.html#non-essential-built-in-functions
" Python built-in functions are in alphabetical order.
if !exists("python_no_builtin_highlight")
  " built-in constants
  " 'False', 'True', and 'None' are also reserved words in Python 3.0
  syn keyword pythonBuiltin	False True None
  syn keyword pythonBuiltin	NotImplemented Ellipsis __debug__
  " built-in functions
  syn keyword pythonBuiltin	abs all any bin bool chr classmethod
  syn keyword pythonBuiltin	compile complex delattr dict dir divmod
  syn keyword pythonBuiltin	enumerate eval filter float format
  syn keyword pythonBuiltin	frozenset getattr globals hasattr hash
  syn keyword pythonBuiltin	help hex id input int isinstance
  syn keyword pythonBuiltin	issubclass iter len list locals map max
  syn keyword pythonBuiltin	min next object oct open ord pow print
  syn keyword pythonBuiltin	property range repr reversed round set
  syn keyword pythonBuiltin	setattr slice sorted staticmethod str
  syn keyword pythonBuiltin	sum super tuple type vars zip __import__
  " Python 2.6 only
  syn keyword pythonBuiltin	basestring callable cmp execfile file
  syn keyword pythonBuiltin	long raw_input reduce reload unichr
  syn keyword pythonBuiltin	unicode xrange
  " Python 3.0 only
  syn keyword pythonBuiltin	ascii bytearray bytes exec memoryview
  " non-essential built-in functions; Python 2.6 only
  syn keyword pythonBuiltin	apply buffer coerce intern
endif

" From the 'Python Library Reference' class hierarchy at the bottom.
" http://docs.python.org/library/exceptions.html
if !exists("python_no_exception_highlight")
  " builtin base exceptions (only used as base classes for other exceptions)
  syn keyword pythonExceptions	BaseException Exception
  syn keyword pythonExceptions	ArithmeticError EnvironmentError
  syn keyword pythonExceptions	LookupError
  " builtin base exception removed in Python 3.0
  syn keyword pythonExceptions	StandardError
  " builtin exceptions (actually raised)
  syn keyword pythonExceptions	AssertionError AttributeError BufferError
  syn keyword pythonExceptions	EOFError FloatingPointError GeneratorExit
  syn keyword pythonExceptions	IOError ImportError IndentationError
  syn keyword pythonExceptions	IndexError KeyError KeyboardInterrupt
  syn keyword pythonExceptions	MemoryError NameError NotImplementedError
  syn keyword pythonExceptions	OSError OverflowError ReferenceError
  syn keyword pythonExceptions	RuntimeError StopIteration SyntaxError
  syn keyword pythonExceptions	SystemError SystemExit TabError TypeError
  syn keyword pythonExceptions	UnboundLocalError UnicodeError
  syn keyword pythonExceptions	UnicodeDecodeError UnicodeEncodeError
  syn keyword pythonExceptions	UnicodeTranslateError ValueError VMSError
  syn keyword pythonExceptions	WindowsError ZeroDivisionError
  " builtin warnings
  syn keyword pythonExceptions	BytesWarning DeprecationWarning FutureWarning
  syn keyword pythonExceptions	ImportWarning PendingDeprecationWarning
  syn keyword pythonExceptions	RuntimeWarning SyntaxWarning UnicodeWarning
  syn keyword pythonExceptions	UserWarning Warning
endif
" QT
syn keyword qtRepeat		foreach forever
syn keyword qtAccess		signals slots SIGNAL SLOT 
syn keyword qtStatement		emit

syn keyword qtType		qint8 qint16 qint32 qint64 qlonglong qptrdiff qreal quint8
syn keyword qtType		quint16 quint32 quint64 quintptr qulonglong uchar uint ulong
syn keyword qtType		ushort

syn keyword qtMacros		QT_POINTER_SIZE QT_REQUIRE_VERSION QT_TRANSLATE_NOOP3 QT_TRANSLATE_NOOP
syn keyword qtMacros		QT_TRAP_THROWING QT_TRID_NOOP QT_TRYCATCH_ERROR QT_TRYCATCH_LEAVING
syn keyword qtMacros		QT_TR_NOOP QT_VERSION QT_VERSION_CHECK QT_VERSION_STR Q_ASSERT Q_ASSERT_X
syn keyword qtMacros		Q_BIG_ENDIAN Q_BYTE_ORDER Q_CC_BOR Q_CC_CDS Q_CC_COMEAU Q_CC_DEC Q_CC_EDG
syn keyword qtMacros		Q_CC_GHS Q_CC_GNU Q_CC_HIGHC Q_CC_HPACC Q_CC_INTEL Q_CC_KAI Q_CC_MIPS
syn keyword qtMacros		Q_CC_MSVC Q_CC_MWERKS Q_CC_OC Q_CC_PGI Q_CC_SUN Q_CC_SYM Q_CC_USLC
syn keyword qtMacros		Q_CC_WAT Q_CHECK_PTR Q_DECLARE_TYPEINFO Q_DECL_EXPORT Q_DECL_IMPORT
syn keyword qtMacros		Q_FOREACH Q_FOREVER Q_FUNC_INFO Q_INT64_C Q_LITTLE_ENDIAN
syn keyword qtMacros		Q_OS_AIX Q_OS_BSD4 Q_OS_BSDI Q_OS_CYGWIN Q_OS_DARWIN Q_OS_DGUX Q_OS_DYNIX
syn keyword qtMacros		Q_OS_FREEBSD Q_OS_HPUX Q_OS_HURD Q_OS_IRIX Q_OS_LINUX Q_OS_LYNX Q_OS_MAC
syn keyword qtMacros		Q_OS_MSDOS Q_OS_NETBSD Q_OS_OS2 Q_OS_OPENBSD Q_OS_OS2EMX Q_OS_OSF Q_OS_QNX
syn keyword qtMacros		Q_OS_RELIANT Q_OS_SCO Q_OS_SOLARIS Q_OS_SYMBIAN Q_OS_ULTRIX Q_OS_UNIX
syn keyword qtMacros		Q_OS_UNIXWARE Q_OS_WIN32 Q_OS_WINCE
syn keyword qtMacros		Q_UINT64_C Q_UNUSED Q_WS_S60 Q_WS_X11 Q_WS_MAC Q_WS_QWS Q_WS_WIN

syn keyword qtClass		QAbstractAnimation
syn keyword qtClass		QAbstractButton
syn keyword qtClass		QAbstractEventDispatcher
syn keyword qtClass		QAbstractExtensionFactory
syn keyword qtClass		QAbstractExtensionManager
syn keyword qtClass		QAbstractFileEngine
syn keyword qtClass		QAbstractFileEngineHandler
syn keyword qtClass		QAbstractFileEngineIterator
syn keyword qtClass		QAbstractFontEngine
syn keyword qtClass		QAbstractFormBuilder
syn keyword qtClass		QAbstractGraphicsShapeItem
syn keyword qtClass		QAbstractItemDelegate
syn keyword qtClass		QAbstractItemModel
syn keyword qtClass		QAbstractItemView
syn keyword qtClass		QAbstractListModel
syn keyword qtClass		QAbstractMessageHandler
syn keyword qtClass		QAbstractNetworkCache
syn keyword qtClass		QAbstractPrintDialog
syn keyword qtClass		QAbstractProxyModel
syn keyword qtClass		QAbstractScrollArea
syn keyword qtClass		QBasicTimer QBitArray
syn keyword qtClass		QCache QCalendarWidget QCDEStyle QChar QCheckBox QChildEvent QCleanlooksStyle
syn keyword qtClass		QDataStream QDataWidgetMapper QDate QDateEdit QDateTime QDateTimeEdit QDBusAbstractAdaptor
syn keyword qtClass		QDBusAbstractInterface QDBusArgument QDBusConnection QDBusConnectionInterface QDBusContext
syn keyword qtClass		QDBusError QDBusInterface QDBusMessage QDBusObjectPath QDBusPendingCall QDBusPendingCallWatcher
syn keyword qtClass		QDBusPendingReply QDBusReply QDBusServiceWatcher QDBusSignature QDBusVariant QDebug
syn keyword qtClass		QDeclarativeComponent QDeclarativeContext QDeclarativeEngine QDeclarativeError QDeclarativeExpression
syn keyword qtClass		QDeclarativeExtensionPlugin QDeclarativeImageProvider
syn keyword qtClass		QEasingCurve
syn keyword qtClass		QFile QFileDialog QFileIconProvider QFileInfo QFileOpenEvent QFileSystemModel QFileSystemWatcher
syn keyword qtClass		QFinalState QFlag
syn keyword qtClass		QGenericArgument QGenericMatrix QGenericReturnArgument QGesture QGestureEvent QGestureRecognizer
syn keyword qtClass		QGLBuffer QGLColormap QGLContext QGLFormat QGLFramebufferObject QGLFramebufferObjectFormat
syn keyword qtClass		QGLPixelBuffer QGLShader QGLShaderProgram QGLWidget QGradient QGraphicsAnchor QGraphicsAnchorLayout	
syn keyword qtClass		QHash QHashIterator QHBoxLayout QHeaderView QHelpContentItem QHelpContentModel 
syn keyword qtClass		QIcon QIconDragEvent QIconEngine QIconEnginePlugin QIconEnginePluginV2 QIconEngineV2 QImage QImageIOHandler
syn keyword qtClass		QKbdDriverFactory
syn keyword qtClass		QLabel QLatin1Char QLatin1String QLayout QLayoutItem QLCDNumber
syn keyword qtClass		QMacCocoaViewContainer QMacNativeWidget QMacPasteboardMime QMacStyle QMainWindow QMap QMapIterator
syn keyword qtClass		QMargins QMatrix4x4 QMdiArea QMdiSubWindow MediaController MediaNode Effect EffectParameter
syn keyword qtClass		QNetworkAccessManager QNetworkAddressEntry QNetworkCacheMetaData QNetworkConfiguration
syn keyword qtClass		QPageSetupDialog QPaintDevice QPaintEngine QPaintEngineState QPainter QPainterPath QPainterPathStroker
syn keyword qtClass		QPaintEvent QPair QPalette QPanGesture QParallelAnimationGroup Path QPauseAnimation
syn keyword qtClass		QRadialGradient QRadioButton QRasterPaintEngine QReadLocker
syn keyword qtClass		QS60MainApplication QS60MainAppUi QS60MainDocument QS60Style QScopedArrayPointer QScopedPointer
syn keyword qtClass		QScreen QScreenCursor QScreenDriverFactory QScreenDriverPlugin QScriptable QScriptClass
syn keyword qtClass		QScriptClassPropertyIterator QScriptContext QScriptContextInfo QScriptEngine QScriptEngineAgent
syn keyword qtClass		QScriptEngineDebugger QScriptExtensionPlugin QScriptProgram QScriptString QScriptSyntaxCheckResult
syn keyword qtClass		QScriptValue QScriptValueIterator QScrollArea QScrollBar SeekSlider QSemaphore QSequentialAnimationGroup
syn keyword qtClass		QSessionManager QSet QSetIterator QSettings QSharedData QSharedDataPointer QSharedMemory QSharedPointer
syn keyword qtClass		QShortcut QShortcutEvent QShowEvent QSignalMapper QSignalSpy QSignalTransition QSimpleXmlNodeModel
syn keyword qtClass		QSize QSizeF QSizeGrip QSizePolicy QSlider QSocketNotifier
syn keyword qtClass		QTabBar QTabletEvent QTableView QTableWidget QTableWidgetItem QTableWidgetSelectionRange QTabWidget
syn keyword qtClass		QTapAndHoldGesture QTapGesture QTcpServer QTcpSocket QTemporaryFile QTestEventList QTextBlock
syn keyword qtClass		QTextBlockFormat QTextBlockGroup QTextBlockUserData QTextBoundaryFinder QTextBrowser QTextCharFormat
syn keyword qtClass		QTextCodec QTextCodecPlugin
syn keyword qtClass		QUdpSocket QUiLoader QUndoCommand QUndoGroup QUndoStack QUndoView UnhandledException QUrl QUrlInfo QUuid
syn keyword qtClass		QValidator QVariant QVariantAnimation QVarLengthArray QVBoxLayout QVector QVector2D QVector3D QVector4D
syn keyword qtClass		QVectorIterator QVideoFrame VideoPlayer (Phonon) QVideoSurfaceFormat VideoWidget
syn keyword qtClass		VideoWidgetInterface44 VolumeSlider
syn keyword qtClass		QWaitCondition QWeakPointer QWebDatabase QWebElement QWebElementCollection QWebFrame QWebHistory QWebHistoryInterface
syn keyword qtClass		QWebHistoryItem QWebHitTestResult QWebInspector QWebPage QWebPluginFactory QWebSecurityOrigin
syn keyword qtClass		QWebSettings QWebView QWhatsThis QWhatsThisClickedEvent QWheelEvent QWidget QWidgetAction QWidgetItem
syn keyword qtClass		QWindowsMime QWindowsStyle QWindowStateChangeEvent QWindowsVistaStyle QWindowsXPStyle QWizard QWizardPage
syn keyword qtClass		QWriteLocker QWSCalibratedMouseHandler QWSClient QWSEmbedWidget QWSEvent QWSGLWindowSurface QWSInputMethod
syn keyword qtClass		QWSKeyboardHandler QWSMouseHandler QWSPointerCalibrationData QWSScreenSaver QWSServer QWSWindow 
syn keyword qtClass		QX11EmbedContainer QX11EmbedWidget QX11Info QXmlAttributes QXmlContentHandler QXmlDeclHandler QXmlDefaultHandler
syn keyword qtClass		QXmlDTDHandler QXmlEntityResolver QXmlErrorHandler QXmlFormatter QXmlInputSource QXmlItem QXmlLexicalHandler
syn keyword qtClass		QXmlLocator QXmlName QXmlNamePool QXmlNamespaceSupport QXmlNodeModelIndex QXmlParseException QXmlQuery
syn keyword qtClass		QXmlReader QXmlResultItems QXmlSchema QXmlSchemaValidator QXmlSerializer QXmlSimpleReader QXmlStreamAttribute
syn keyword qtClass		QXmlStreamAttributes QXmlStreamEntityDeclaration QXmlStreamEntityResolver QXmlStreamNamespaceDeclaration
syn keyword qtClass		QXmlStreamNotationDeclaration QXmlStreamReader QXmlStreamWriter	
syn keyword qtClass		QTextCursor QTextDecoder QTextDocument QTextDocumentFragment QTextDocumentWriter QTextEdit QTextEncoder QTextFormat
syn keyword qtClass		QTextFragment QTextFrame QTextFrameFormat QTextImageFormat QTextInlineObject QTextItem QTextLayout
syn keyword qtClass		QTextLength QTextLine QTextList QTextListFormat QTextObject QTextObjectInterface QTextOption QTextStream
syn keyword qtClass		QTextTable QTextTableCell QTextTableCellFormat QTextTableFormat QThread QThreadPool QThreadStorage QTileRules
syn keyword qtClass		QTime QTimeEdit QTimeLine QTimer QTimerEvent QToolBar QToolBox QToolButton QToolTip QTouchEvent QTransform
syn keyword qtClass		QTranslator QTreeView QTreeWidget QTreeWidgetItem QTreeWidgetItemIteratorX
syn keyword qtClass		QSortFilterProxyModel QSound QSourceLocation QSpacerItem QSpinBox QSplashScreen QSplitter QSplitterHandle
syn keyword qtClass		QSqlDatabase QSqlDriver QSqlDriverCreator QSqlDriverCreatorBase QSqlDriverPlugin QSqlError QSqlField QSqlIndex
syn keyword qtClass		QSqlQuery QSqlQueryModel QSqlRecord QSqlRelation QSqlRelationalDelegate QSqlRelationalTableModel QSqlResult
syn keyword qtClass		QSqlTableModel QSslCertificate QSslCipher QSslConfiguration QSslError QSslKey QSslSocket QStack QStackedLayout
syn keyword qtClass		QStackedWidget QStandardItem QStandardItemEditorCreator QStandardItemModel QState QStateMachine QStaticText QStatusBar
syn keyword qtClass		QStatusTipEvent QString QStringList QStringListModel QStringMatcher QStringRef QStyle QStyledItemDelegate
syn keyword qtClass		QStyleFactory QStyleHintReturn QStyleHintReturnMask QStyleHintReturnVariant QStyleOption QStyleOptionButton
syn keyword qtClass		QStyleOptionComboBox QStyleOptionComplex QStyleOptionDockWidget QStyleOptionFocusRect QStyleOptionFrame QStyleOptionFrameV2
syn keyword qtClass		QStyleOptionFrameV3 QStyleOptionGraphicsItem QStyleOptionGroupBox QStyleOptionHeader QStyleOptionMenuItem
syn keyword qtClass		QStyleOptionProgressBar QStyleOptionProgressBarV2 QStyleOptionQ3DockWindow QStyleOptionQ3ListView QStyleOptionQ3ListViewItem
syn keyword qtClass		QStyleOptionRubberBand QStyleOptionSizeGrip QStyleOptionSlider QStyleOptionSpinBox QStyleOptionTab QStyleOptionTabBarBase
syn keyword qtClass		QStyleOptionTabBarBaseV2 QStyleOptionTabV2 QStyleOptionTabV3 QStyleOptionTabWidgetFrame QStyleOptionTabWidgetFrameV2
syn keyword qtClass		QStyleOptionTitleBar QStyleOptionToolBar QStyleOptionToolBox QStyleOptionToolBoxV2 QStyleOptionToolButton QStyleOptionViewItem
syn keyword qtClass		QStyleOptionViewItemV2 QStyleOptionViewItemV3 QStyleOptionViewItemV4 QStylePainter QStylePlugin QSvgGenerator
syn keyword qtClass		QSvgRenderer QSvgWidget QSwipeGesture QSymbianEvent QSyntaxHighlighter QSysInfo QSystemLocale QSystemSemaphore QSystemTrayIcon	
syn keyword qtClass		QReadWriteLock QRect QRectF QRegExp QRegExpValidator QRegion QResizeEvent QResource QRubberBand QRunnable 
syn keyword qtClass		QTouchEventSequence QQuaternion QQueue
syn keyword qtClass		QPen QPersistentModelIndex QPicture QPinchGesture QPixmap QPixmapCache QPlainTextDocumentLayout QPlainTextEdit QPlastiqueStyle
syn keyword qtClass		QPluginLoader QPoint QPointer QPointF QPolygon QPolygonF QPrintDialog QPrintEngine QPrinter QPrinterInfo QPrintPreviewDialog
syn keyword qtClass		QPrintPreviewWidget QProcess QProcessEnvironment QProgressBar QProgressDialog QPropertyAnimation QProxyScreen
syn keyword qtClass		QProxyScreenCursor QProxyStyle QPushButton
syn keyword qtClass		QObject QObjectCleanupHandler ObjectDescription
syn keyword qtClass		QNetworkConfigurationManager QNetworkCookie QNetworkCookieJar QNetworkDiskCache QNetworkInterface QNetworkProxy
syn keyword qtClass		QNetworkProxyFactory QNetworkProxyQuery QNetworkReply QNetworkRequest QNetworkSession Notifier 
syn keyword qtClass		MediaObject MediaSource QMenu QMenuBar QMessageBox QMetaClassInfo QMetaEnum QMetaMethod QMetaObject QMetaProperty
syn keyword qtClass		QMetaType QMimeData QModelIndex QMotifStyle QMouseDriverFactory QMouseDriverPlugin QMouseEvent QMouseEventTransition
syn keyword qtClass		QMoveEvent QMovie QMultiHash QMultiMap QMutableHashIterator QMutableLinkedListIterator QMutableListIterator
syn keyword qtClass		QMutableMapIterator QMutableSetIterator QMutableVectorIterator QMutex QMutexLocker
syn keyword qtClass		QLibrary QLibraryInfo QLine QLinearGradient QLineEdit QLineF QLinkedList QLinkedListIterator QList QListIterator
syn keyword qtClass		QListView QListWidget QListWidgetItem QLocale QLocalServer QLocalSocket	
syn keyword qtClass		QKbdDriverPlugin QKeyEvent QKeyEventTransition QKeySequence
syn keyword qtClass		QImageIOPlugin QImageReader QImageWriter QInputContext QInputContextFactory QInputContextPlugin
syn keyword qtClass		QInputDialog QInputEvent QInputMethodEvent QIntValidator QIODevice QItemDelegate QItemEditorCreator
syn keyword qtClass		QItemEditorCreatorBase QItemEditorFactory QItemSelection QItemSelectionModel QItemSelectionRange
syn keyword qtClass		QHelpContentWidget QHelpEngine QHelpEngineCore QHelpEvent QHelpIndexModel QHelpIndexWidget
syn keyword qtClass		QHelpSearchEngine QHelpSearchQuery QHelpSearchQueryWidget QHelpSearchResultWidget QHideEvent
syn keyword qtClass		QHistoryState QHostAddress QHostInfo QHoverEvent
syn keyword qtClass		QGraphicsBlurEffect QGraphicsColorizeEffect QGraphicsDropShadowEffect QGraphicsEffect QGraphicsEllipseItem
syn keyword qtClass		QGraphicsGridLayout QGraphicsItem QGraphicsItemAnimation QGraphicsItemGroup QGraphicsLayout QGraphicsLayoutItem
syn keyword qtClass		QGraphicsLinearLayout QGraphicsLineItem QGraphicsObject QGraphicsOpacityEffect QGraphicsPathItem QGraphicsPixmapItem
syn keyword qtClass		QGraphicsPolygonItem QGraphicsProxyWidget QGraphicsRectItem QGraphicsRotation QGraphicsScale QGraphicsScene
syn keyword qtClass		QGraphicsSceneContextMenuEvent QGraphicsSceneDragDropEvent QGraphicsSceneEvent QGraphicsSceneHelpEvent
syn keyword qtClass		QGraphicsSceneHoverEvent QGraphicsSceneMouseEvent QGraphicsSceneMoveEvent QGraphicsSceneResizeEvent
syn keyword qtClass		QGraphicsSceneWheelEvent QGraphicsSimpleTextItem QGraphicsSvgItem QGraphicsTextItem QGraphicsTransform
syn keyword qtClass		QGraphicsView QGraphicsWebView QGraphicsWidget QGridLayout QGroupBox QGtkStyle
syn keyword qtClass		QFlags QFocusEvent QFocusFrame QFont QFontComboBox QFontDatabase QFontDialog QFontEngineInfo QFontEnginePlugin
syn keyword qtClass		QFontInfo QFontMetrics QFontMetricsF QFormBuilder QFormLayout QFrame QFSFileEngine QFtp QFuture
syn keyword qtClass		QFutureIterator QFutureSynchronizer QFutureWatcher	
syn keyword qtClass		EffectWidget QElapsedTimer QErrorMessage QEvent QEventLoop QEventTransition Exception QExplicitlySharedDataPointer
syn keyword qtClass		QExtensionFactory QExtensionManager
syn keyword qtClass		QDeclarativeItem QDeclarativeListProperty QDeclarativeListReference QDeclarativeNetworkAccessManagerFactory
syn keyword qtClass		QDeclarativeParserStatus QDeclarativeProperty QDeclarativePropertyMap QDeclarativePropertyValueSource
syn keyword qtClass		QDeclarativeScriptString QDeclarativeTypeLoader QDeclarativeView QDecoration QDecorationDefault QDecorationFactory
syn keyword qtClass		QDecorationPlugin QDesignerActionEditorInterface QDesignerContainerExtension QDesignerCustomWidgetCollectionInterface
syn keyword qtClass		QDesignerCustomWidgetInterface QDesignerDynamicPropertySheetExtension QDesignerFormEditorInterface
syn keyword qtClass		QDesignerFormWindowCursorInterface QDesignerFormWindowInterface QDesignerFormWindowManagerInterface QDesignerMemberSheetExtension
syn keyword qtClass		QDesignerObjectInspectorInterface QDesignerPropertyEditorInterface QDesignerPropertySheetExtension QDesignerTaskMenuExtension
syn keyword qtClass		QDesignerWidgetBoxInterface QDesktopServices QDesktopWidget QDial QDialog QDialogButtonBox QDir QDirectPainter
syn keyword qtClass		QDirIterator QDockWidget QDomAttr QDomCDATASection QDomCharacterData QDomComment QDomDocument QDomDocumentFragment QDomDocumentType
syn keyword qtClass		QDomElement QDomEntity QDomEntityReference QDomImplementation QDomNamedNodeMap QDomNode QDomNodeList QDomNotation
syn keyword qtClass		QDomProcessingInstruction QDomText QDoubleSpinBox QDoubleValidator QDrag QDragEnterEvent QDragLeaveEvent
syn keyword qtClass		QDragMoveEvent QDropEvent QDynamicPropertyChangeEvent	
syn keyword qtClass		QClipboard QCloseEvent QColor QColorDialog QColormap QColumnView QComboBox QCommandLinkButton QCommonStyle QCompleter
syn keyword qtClass		QConicalGradient QContextMenuEvent QContiguousCache QCopChannel QCoreApplication QCryptographicHash QCursor QCustomRasterPaintDevice
syn keyword qtClass		QBitmap	QBoxLayout QBrush QBuffer QButtonGroup QByteArray QByteArrayMatcher
syn keyword qtClass		QAbstractSlider QAbstractSocket QAbstractSpinBox QAbstractState QAbstractTableModel QAbstractTextDocumentLayout
syn keyword qtClass		QAbstractTransition QAbstractUriResolver QAbstractVideoBuffer QAbstractVideoSurface QAbstractXmlNodeModel QAbstractXmlReceiver
syn keyword qtClass		QAccessible QAccessibleBridge QAccessibleBridgePlugin QAccessibleEvent QAccessibleInterface QAccessibleObject
syn keyword qtClass		QAccessiblePlugin QAccessibleWidget QAction QActionEvent QActionGroup QAnimationGroup QApplication QAtomicInt
syn keyword qtClass		QAtomicPointer AudioDataOutput QAudioDeviceInfo QAudioFormat QAudioInput QAudioOutput QAuthenticator
syn keyword qtClass		QAxAggregated QAxBase QAxBindable QAxFactory QAxObject QAxScript QAxScriptEngine QAxScriptManager QAxWidget
syn keyword qtClass             QtGui QtCore

if exists("python_space_error_highlight")
  " trailing whitespace
  syn match   pythonSpaceError	display excludenl "\s\+$"
  " mixed tabs and spaces
  syn match   pythonSpaceError	display " \+\t"
  syn match   pythonSpaceError	display "\t\+ "
endif

" Do not spell doctests inside strings.
" Notice that the end of a string, either ''', or """, will end the contained
" doctest too.  Thus, we do *not* need to have it as an end pattern.
if !exists("python_no_doctest_highlight")
  if !exists("python_no_doctest_code_higlight")
    syn region pythonDoctest
	  \ start="^\s*>>>\s" end="^\s*$"
	  \ contained contains=ALLBUT,pythonDoctest,@Spell
    syn region pythonDoctestValue
	  \ start=+^\s*\%(>>>\s\|\.\.\.\s\|"""\|'''\)\@!\S\++ end="$"
	  \ contained
  else
    syn region pythonDoctest
	  \ start="^\s*>>>" end="^\s*$"
	  \ contained contains=@NoSpell
  endif
endif

" Sync at the beginning of class, function, or method definition.
syn sync match pythonSync grouphere NONE "^\s*\%(def\|class\)\s\+\h\w*\s*("

if version >= 508 || !exists("did_python_syn_inits")
  if version <= 508
    let did_python_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  " The default highlight links.  Can be overridden later.
  HiLink pythonStatement	Statement
  HiLink pythonConditional	Conditional
  HiLink pythonRepeat		Repeat
  HiLink pythonOperator		Operator
  HiLink pythonException	Exception
  HiLink pythonInclude		Include
  HiLink pythonDecorator	Define
  HiLink pythonFunction		Function
  HiLink pythonComment		Comment
  HiLink pythonTodo		Todo
  HiLink pythonString		String
  HiLink pythonRawString	String
  HiLink pythonEscape		Special
  HiLink qtClass		Define	
  HiLink qtMacros		Constant 
  HiLink qtRepeat		Conditional
  HiLink qtAccess		Statement
  HiLink qtStatement		Statement
  HiLink qtType			Type
  if !exists("python_no_number_highlight")
    HiLink pythonNumber		Number
  endif
  if !exists("python_no_builtin_highlight")
    HiLink pythonBuiltin	Function
  endif
  if !exists("python_no_exception_highlight")
    HiLink pythonExceptions	Structure
  endif
  if exists("python_space_error_highlight")
    HiLink pythonSpaceError	Error
  endif
  if !exists("python_no_doctest_highlight")
    HiLink pythonDoctest	Special
    HiLink pythonDoctestValue	Define
  endif

  delcommand HiLink
endif

let b:current_syntax = "python"

let &cpo = s:cpo_save
unlet s:cpo_save

" vim:set sw=2 sts=2 ts=8 noet:
