# Low-level FFI bindings for podofo 1.0.x

when defined(windows):
  {.passL: "-lpodofo".}
elif defined(macosx):
  {.passL: "-lpodofo".}
else:
  # Linux
  {.passL: "-lpodofo".}

{.push header: "<podofo/podofo.h>".}

# PoDoFo Exception handling
type
  PdfErrorCode* {.importcpp: "PoDoFo::PdfErrorCode".} = enum
    Unknown = 0
    InvalidHandle = 1
    FileNotFound = 2
    InvalidDeviceOperation = 3
    UnexpectedEOF = 4
    OutOfMemory = 5
    ValueOutOfRange = 6
    InternalLogic = 7
    InvalidEnumValue = 8
    BrokenFile = 9
    PageNotFound = 10
    NoPdfFile = 11
    NoXRef = 12
    NoTrailer = 13
    NoNumber = 14
    NoObject = 15
    NoEOFToken = 16
    InvalidTrailerSize = 17
    InvalidLinearization = 18
    InvalidDataType = 19
    InvalidXRef = 20
    InvalidXRefStream = 21
    InvalidXRefType = 22
    InvalidPredictor = 23
    InvalidStrokeStyle = 24
    InvalidHexString = 25
    InvalidStream = 26
    InvalidStreamLength = 27
    InvalidKey = 28
    InvalidName = 29
    InvalidEncryptionDict = 30
    InvalidPassword = 31
    InvalidFontData = 32
    InvalidContentStream = 33
    UnsupportedFilter = 34
    UnsupportedFontFormat = 35
    ActionAlreadyPresent = 36
    WrongDestinationType = 37
    MissingEndStream = 38
    Date = 39
    Flate = 40
    FreeType = 41
    SignatureError = 42
    UnsupportedImageFormat = 43
    CannotConvertColor = 44
    NotImplemented = 45
    DestinationAlreadyPresent = 46
    ChangeOnImmutable = 47
    NotCompiled = 48
    OutlineItemAlreadyPresent = 49
    NotLoadedForUpdate = 50
    CannotEncryptedForUpdate = 51
    XmpMetadata = 52

  PdfErrorObj* {.importcpp: "PoDoFo::PdfError".} = object

proc getCode*(err: PdfErrorObj): PdfErrorCode {.importcpp: "#.GetCode()".}
proc what*(err: PdfErrorObj): cstring {.importcpp: "#.what()".}

# Error message helper - gets full error description
proc pdfErrorMessage*(
  code: PdfErrorCode
): cstring {.importcpp: "PoDoFo::PdfError::ErrorMessage(@)".}

type
  # Auxiliary types
  PodofoRect* {.importcpp: "PoDoFo::Rect", bycopy.} = object
    X*: cdouble
    Y*: cdouble
    Width*: cdouble
    Height*: cdouble

  Matrix* {.importcpp: "PoDoFo::Matrix", bycopy.} = object

  # Forward declarations for main types
  PdfMemDocumentObj* {.importcpp: "PoDoFo::PdfMemDocument", inheritable.} = object
  PdfPageObj* {.importcpp: "PoDoFo::PdfPage".} = object
  PdfPainterObj* {.importcpp: "PoDoFo::PdfPainter".} = object
  PdfPainterPathObj* {.importcpp: "PoDoFo::PdfPainterPath".} = object
  PdfFontObj* {.importcpp: "PoDoFo::PdfFont".} = object
  PdfImageObj* {.importcpp: "PoDoFo::PdfImage".} = object
  PdfXObjectObj* {.importcpp: "PoDoFo::PdfXObject".} = object
  PdfXObjectFormObj* {.importcpp: "PoDoFo::PdfXObjectForm".} = object
  PdfPageCollectionObj* {.importcpp: "PoDoFo::PdfPageCollection".} = object
  PdfFontManagerObj* {.importcpp: "PoDoFo::PdfFontManager".} = object
  PdfGraphicsStateWrapperObj* {.importcpp: "PoDoFo::PdfGraphicsStateWrapper".} = object
  PdfTextStateWrapperObj* {.importcpp: "PoDoFo::PdfTextStateWrapper".} = object
  PdfTextStateObj* {.importcpp: "PoDoFo::PdfTextState", bycopy.} = object
    Font*: ptr PdfFontObj
    FontSize*: cdouble
    FontScale*: cdouble
    CharSpacing*: cdouble
    WordSpacing*: cdouble

  PdfColorObj* {.importcpp: "PoDoFo::PdfColor".} = object
  PdfCanvasObj* {.importcpp: "PoDoFo::PdfCanvas".} = object
  PdfMetadataObj* {.importcpp: "PoDoFo::PdfMetadata".} = object
  PdfFileSpecObj* {.importcpp: "PoDoFo::PdfFileSpec".} = object
  PdfDateObj* {.importcpp: "PoDoFo::PdfDate".} = object
  PdfStringObj* {.importcpp: "PoDoFo::PdfString".} = object
  PdfNameObj* {.importcpp: "PoDoFo::PdfName".} = object
  PdfExtGStateObj* {.importcpp: "PoDoFo::PdfExtGState".} = object
  PdfOutlinesObj* {.importcpp: "PoDoFo::PdfOutlines".} = object
  PdfOutlineItemObj* {.importcpp: "PoDoFo::PdfOutlineItem".} = object
  PdfDestinationObj* {.importcpp: "PoDoFo::PdfDestination".} = object
  PdfAcroFormObj* {.importcpp: "PoDoFo::PdfAcroForm".} = object
  PdfAnnotationObj* {.importcpp: "PoDoFo::PdfAnnotation".} = object
  PdfAnnotationLinkObj* {.importcpp: "PoDoFo::PdfAnnotationLink".} = object
  PdfAnnotationTextObj* {.importcpp: "PoDoFo::PdfAnnotationText".} = object
  PdfAnnotationWidgetObj* {.importcpp: "PoDoFo::PdfAnnotationWidget".} = object
  PdfFieldObj* {.importcpp: "PoDoFo::PdfField".} = object
  PdfTextBoxObj* {.importcpp: "PoDoFo::PdfTextBox".} = object
  PdfCheckBoxObj* {.importcpp: "PoDoFo::PdfCheckBox".} = object
  PdfPushButtonObj* {.importcpp: "PoDoFo::PdfPushButton".} = object
  PdfRadioButtonObj* {.importcpp: "PoDoFo::PdfRadioButton".} = object
  PdfComboBoxObj* {.importcpp: "PoDoFo::PdfComboBox".} = object
  PdfListBoxObj* {.importcpp: "PoDoFo::PdfListBox".} = object
  PdfSignatureObj* {.importcpp: "PoDoFo::PdfSignature".} = object
  PdfActionObj* {.importcpp: "PoDoFo::PdfAction".} = object
  PdfAnnotationCollectionObj* {.importcpp: "PoDoFo::PdfAnnotationCollection".} = object
  NullablePdfStringRef* {.importcpp: "PoDoFo::nullable<const PoDoFo::PdfString&>".} = object
    # For setters that take nullable ref

  NullablePdfString* {.importcpp: "PoDoFo::nullable<PoDoFo::PdfString>".} = object
    # For metadata getters returning by value

  NullablePdfDate* {.importcpp: "PoDoFo::nullable<PoDoFo::PdfDate>".} = object

  NullablePdfDestinationRef* {.
    importcpp: "PoDoFo::nullable<const PoDoFo::PdfDestination&>"
  .} = object
  PdfIndirectObjectListObj* {.importcpp: "PoDoFo::PdfIndirectObjectList".} = object
  PdfCatalogObj* {.importcpp: "PoDoFo::PdfCatalog".} = object
  PdfObjectObj* {.importcpp: "PoDoFo::PdfObject".} = object
  PdfDictionaryObj* {.importcpp: "PoDoFo::PdfDictionary".} = object
  PdfArrayObj* {.importcpp: "PoDoFo::PdfArray".} = object
  PdfObjectStreamObj* {.importcpp: "PoDoFo::PdfObjectStream".} = object
  PdfReferenceObj* {.importcpp: "PoDoFo::PdfReference".} = object
  PdfNameTreesObj* {.importcpp: "PoDoFo::PdfNameTrees".} = object
  PdfEmbeddedFilesObj* {.importcpp: "PoDoFo::PdfEmbeddedFiles".} = object

  # Smart pointers and utility types for PoDoFo 1.0.x
  UniquePtrPdfFileSpec* {.
    importcpp: "std::unique_ptr<PoDoFo::PdfFileSpec>", header: "<memory>"
  .} = object

  SharedPtrPdfFileSpec* {.
    importcpp: "std::shared_ptr<PoDoFo::PdfFileSpec>", header: "<memory>"
  .} = object

  UniquePtrPdfImage* {.
    importcpp: "std::unique_ptr<PoDoFo::PdfImage>", header: "<memory>"
  .} = object

  UniquePtrPdfXObjectForm* {.
    importcpp: "std::unique_ptr<PoDoFo::PdfXObjectForm>", header: "<memory>"
  .} = object
  charbuff* {.importcpp: "PoDoFo::charbuff".} = object
  NullableCharbuffRef* {.importcpp: "PoDoFo::nullable<const PoDoFo::charbuff&>".} = object
  NullablePdfStringRefConst* {.importcpp: "PoDoFo::nullable<const PoDoFo::PdfString&>".} = object

  # Enums
  PdfPageSize* {.importcpp: "PoDoFo::PdfPageSize".} = enum
    A0 = 0
    A1 = 1
    A2 = 2
    A3 = 3
    A4 = 4
    A5 = 5
    A6 = 6
    Letter = 7
    Legal = 8
    Tabloid = 9

  PdfPathDrawMode* {.importcpp: "PoDoFo::PdfPathDrawMode".} = enum
    Stroke = 1
    Fill = 2
    StrokeFill = 3
    FillEvenOdd = 4
    StrokeFillEvenOdd = 5

  PdfPainterFlags* {.importcpp: "PoDoFo::PdfPainterFlags".} = enum
    None = 0
    Prepend = 1
    NoSaveRestorePrior = 2
    NoSaveRestore = 4
    RawCoordinates = 8

  PdfSaveOptions* {.importcpp: "PoDoFo::PdfSaveOptions".} = enum
    None = 0
    Clean = 1
    NoFlateCompress = 2
    NoCollectGarbage = 4
    NoModifyDateUpdate = 8

  PdfLineCapStyle* {.importcpp: "PoDoFo::PdfLineCapStyle".} = enum
    Butt = 0
    Round = 1
    Square = 2

  PdfLineJoinStyle* {.importcpp: "PoDoFo::PdfLineJoinStyle".} = enum
    Miter = 0
    Round = 1
    Bevel = 2

  PdfHorizontalAlignment* {.importcpp: "PoDoFo::PdfHorizontalAlignment".} = enum
    Left = 0
    Center = 1
    Right = 2

  PdfVerticalAlignment* {.importcpp: "PoDoFo::PdfVerticalAlignment".} = enum
    Top = 0
    Center = 1
    Bottom = 2

  PdfColorSpaceType* {.importcpp: "PoDoFo::PdfColorSpaceType".} = enum
    Unknown = 0
    DeviceGray = 1
    DeviceRGB = 2
    DeviceCMYK = 3
    CalGray = 4
    CalRGB = 5
    Lab = 6
    ICCBased = 7
    Indexed = 8
    Pattern = 9
    Separation = 10
    DeviceN = 11

  PdfStandard14FontType* {.importcpp: "PoDoFo::PdfStandard14FontType".} = enum
    Unknown = 0
    TimesRoman = 1
    TimesItalic = 2
    TimesBold = 3
    TimesBoldItalic = 4
    Helvetica = 5
    HelveticaOblique = 6
    HelveticaBold = 7
    HelveticaBoldOblique = 8
    Courier = 9
    CourierOblique = 10
    CourierBold = 11
    CourierBoldOblique = 12
    Symbol = 13
    ZapfDingbats = 14

  PdfTextRenderingMode* {.importcpp: "PoDoFo::PdfTextRenderingMode".} = enum
    Fill = 0
    Stroke = 1
    FillAndStroke = 2
    Invisible = 3
    FillToClipPath = 4
    StrokeToClipPath = 5
    FillAndStrokeToClipPath = 6
    ToClipPath = 7

  PdfStrokeStyle* {.importcpp: "PoDoFo::PdfStrokeStyle".} = enum
    Solid = 0
    Dash = 1
    Dot = 2
    DashDot = 3
    DashDotDot = 4

  PdfBlendMode* {.importcpp: "PoDoFo::PdfBlendMode".} = enum
    Normal = 0
    Multiply = 1
    Screen = 2
    Overlay = 3
    Darken = 4
    Lighten = 5
    ColorDodge = 6
    ColorBurn = 7
    HardLight = 8
    SoftLight = 9
    Difference = 10
    Exclusion = 11
    Hue = 12
    Saturation = 13
    Color = 14
    Luminosity = 15

  PdfDestinationFit* {.importcpp: "PoDoFo::PdfDestinationFit".} = enum
    Fit = 0
    FitH = 1
    FitV = 2
    FitB = 3
    FitBH = 4
    FitBV = 5

  PdfAnnotationType* {.importcpp: "PoDoFo::PdfAnnotationType".} = enum
    Unknown = 0
    Text = 1
    Link = 2
    FreeText = 3
    Line = 4
    Square = 5
    Circle = 6
    Polygon = 7
    PolyLine = 8
    Highlight = 9
    Underline = 10
    Squiggly = 11
    StrikeOut = 12
    Stamp = 13
    Caret = 14
    Ink = 15
    Popup = 16
    FileAttachment = 17
    Sound = 18
    Movie = 19
    Widget = 20
    Screen = 21
    PrinterMark = 22
    TrapNet = 23
    Watermark = 24
    Model3D = 25
    RichMedia = 26
    WebMedia = 27
    Redact = 28
    Projection = 29

  PdfAcroFormDefaulAppearance* {.importcpp: "PoDoFo::PdfAcroFormDefaulAppearance".} = enum
    None = 0
    BlackText12pt = 1

  PdfFieldType* {.importcpp: "PoDoFo::PdfFieldType".} = enum
    Unknown = 0
    PushButton = 1
    CheckBox = 2
    RadioButton = 3
    TextBox = 4
    ComboBox = 5
    ListBox = 6
    Signature = 7

  PdfActionType* {.importcpp: "PoDoFo::PdfActionType".} = enum
    Unknown = 0
    GoTo = 1
    GoToR = 2
    GoToE = 3
    Launch = 4
    Thread = 5
    URI = 6
    Sound = 7
    Movie = 8
    Hide = 9
    Named = 10
    SubmitForm = 11
    ResetForm = 12
    ImportData = 13
    JavaScript = 14
    SetOCGState = 15
    Rendition = 16
    Trans = 17
    GoTo3DView = 18
    RichMediaExecute = 19

  PdfAnnotationFlags* {.importcpp: "PoDoFo::PdfAnnotationFlags".} = enum
    None = 0x0000
    Invisible = 0x0001
    Hidden = 0x0002
    Print = 0x0004
    NoZoom = 0x0008
    NoRotate = 0x0010
    NoView = 0x0020
    ReadOnly = 0x0040
    Locked = 0x0080
    ToggleNoView = 0x0100
    LockedContents = 0x0200

  PdfAppearanceType* {.importcpp: "PoDoFo::PdfAppearanceType".} = enum
    Normal = 0
    Rollover = 1
    Down = 2

  PdfCertPermission* {.importcpp: "PoDoFo::PdfCertPermission".} = enum
    NoPerms = 1
    FormFill = 2
    Annotations = 3

  PdfVersion* {.importcpp: "PoDoFo::PdfVersion".} = enum
    V1_0 = 0
    V1_1 = 1
    V1_2 = 2
    V1_3 = 3
    V1_4 = 4
    V1_5 = 5
    V1_6 = 6
    V1_7 = 7
    V2_0 = 8

  PdfALevel* {.importcpp: "PoDoFo::PdfALevel".} = enum
    Unknown = 0
    L1A = 1
    L1B = 2
    L2A = 3
    L2B = 4
    L2U = 5
    L3A = 6
    L3B = 7
    L3U = 8
    L4 = 9
    L4E = 10
    L4F = 11

# C++ std::string_view helper
type StdStringView* {.importcpp: "std::string_view", header: "<string_view>".} = object

proc initStdStringView*(
  s: cstring
): StdStringView {.importcpp: "std::string_view(@)", header: "<string_view>".}

proc initStdStringView*(
  s: cstring, len: csize_t
): StdStringView {.importcpp: "std::string_view(@)", header: "<string_view>".}

# C++ std::unique_ptr helper
type UniquePtr*[T] {.importcpp: "std::unique_ptr<'0>", header: "<memory>".} = object

proc get*[T](p: UniquePtr[T]): ptr T {.importcpp: "#.get()".}

# C++ std::shared_ptr helper
type SharedPtrDestination* {.
  importcpp: "std::shared_ptr<PoDoFo::PdfDestination>", header: "<memory>"
.} = object

proc makeSharedDestination*(
  p: ptr PdfDestinationObj
): SharedPtrDestination {.importcpp: "std::shared_ptr<PoDoFo::PdfDestination>(#)".}

# Rect

proc initRect*(): PodofoRect {.importcpp: "PoDoFo::Rect()".}
proc initRect*(
  x, y, width, height: cdouble
): PodofoRect {.importcpp: "PoDoFo::Rect(@)".}

proc getLeft*(r: PodofoRect): cdouble {.importcpp: "#.GetLeft()".}
proc getBottom*(r: PodofoRect): cdouble {.importcpp: "#.GetBottom()".}
proc getRight*(r: PodofoRect): cdouble {.importcpp: "#.GetRight()".}
proc getTop*(r: PodofoRect): cdouble {.importcpp: "#.GetTop()".}
proc getWidth*(r: PodofoRect): cdouble {.importcpp: "#.Width".}
proc getHeight*(r: PodofoRect): cdouble {.importcpp: "#.Height".}

proc createStandardPageSize*(
  pageSize: PdfPageSize, landscape: bool = false
): PodofoRect {.importcpp: "PoDoFo::PdfPage::CreateStandardPageSize(@)".}

# Matrix

proc initMatrix*(): Matrix {.importcpp: "PoDoFo::Matrix()".}
proc initMatrix*(a, b, c, d, e, f: cdouble): Matrix {.importcpp: "PoDoFo::Matrix(@)".}

proc createRotation*(
  radians: cdouble
): Matrix {.importcpp: "PoDoFo::Matrix::CreateRotation(@)".}

# PdfColor

proc initPdfColorGray*(gray: cdouble): PdfColorObj {.importcpp: "PoDoFo::PdfColor(@)".}
proc initPdfColorRGB*(
  r, g, b: cdouble
): PdfColorObj {.importcpp: "PoDoFo::PdfColor(@)".}

proc initPdfColorCMYK*(
  c, m, y, k: cdouble
): PdfColorObj {.importcpp: "PoDoFo::PdfColor(@)".}

proc initPdfColorTransparent*(): PdfColorObj {.
  importcpp: "PoDoFo::PdfColor::CreateTransparent()"
.}

proc isGrayScale*(c: PdfColorObj): bool {.importcpp: "#.IsGrayScale()".}
proc isRGB*(c: PdfColorObj): bool {.importcpp: "#.IsRGB()".}
proc isCMYK*(c: PdfColorObj): bool {.importcpp: "#.IsCMYK()".}
proc isTransparent*(c: PdfColorObj): bool {.importcpp: "#.IsTransparent()".}

proc getGrayScale*(c: PdfColorObj): cdouble {.importcpp: "#.GetGrayScale()".}
proc getRed*(c: PdfColorObj): cdouble {.importcpp: "#.GetRed()".}
proc getGreen*(c: PdfColorObj): cdouble {.importcpp: "#.GetGreen()".}
proc getBlue*(c: PdfColorObj): cdouble {.importcpp: "#.GetBlue()".}
proc getCyan*(c: PdfColorObj): cdouble {.importcpp: "#.GetCyan()".}
proc getMagenta*(c: PdfColorObj): cdouble {.importcpp: "#.GetMagenta()".}
proc getYellow*(c: PdfColorObj): cdouble {.importcpp: "#.GetYellow()".}
proc getBlack*(c: PdfColorObj): cdouble {.importcpp: "#.GetBlack()".}

proc convertToGrayScale*(
  c: PdfColorObj
): PdfColorObj {.importcpp: "#.ConvertToGrayScale()".}

proc convertToRGB*(c: PdfColorObj): PdfColorObj {.importcpp: "#.ConvertToRGB()".}
proc convertToCMYK*(c: PdfColorObj): PdfColorObj {.importcpp: "#.ConvertToCMYK()".}

# PdfMemDocument

proc newPdfMemDocument*(): ptr PdfMemDocumentObj {.
  importcpp: "new PoDoFo::PdfMemDocument()"
.}

proc deletePdfMemDocument*(doc: ptr PdfMemDocumentObj) {.importcpp: "delete #".}

proc load*(
  doc: ptr PdfMemDocumentObj,
  filename: StdStringView,
  password: StdStringView = initStdStringView(""),
) {.importcpp: "#->Load(@)".}

proc save*(
  doc: ptr PdfMemDocumentObj,
  filename: StdStringView,
  opts: PdfSaveOptions = PdfSaveOptions.None,
) {.importcpp: "#->Save(@)".}

proc getPages*(
  doc: ptr PdfMemDocumentObj
): ptr PdfPageCollectionObj {.importcpp: "(&(#->GetPages()))".}

proc getFonts*(
  doc: ptr PdfMemDocumentObj
): ptr PdfFontManagerObj {.importcpp: "(&(#->GetFonts()))".}

proc getMetadata*(
  doc: ptr PdfMemDocumentObj
): ptr PdfMetadataObj {.importcpp: "(&(#->GetMetadata()))".}

proc createImage*(
  doc: ptr PdfMemDocumentObj
): UniquePtrPdfImage {.importcpp: "#->CreateImage()".}

proc releaseImage*(
  p: var UniquePtrPdfImage
): ptr PdfImageObj {.importcpp: "#.release()".}

proc deletePdfImage*(img: ptr PdfImageObj) {.importcpp: "delete #".}

proc createXObjectForm*(
  doc: ptr PdfMemDocumentObj, rect: PodofoRect
): UniquePtrPdfXObjectForm {.importcpp: "#->CreateXObjectForm(@)".}

proc releaseXObjectForm*(
  p: var UniquePtrPdfXObjectForm
): ptr PdfXObjectFormObj {.importcpp: "#.release()".}

proc deletePdfXObjectForm*(xobj: ptr PdfXObjectFormObj) {.importcpp: "delete #".}

proc isEncrypted*(doc: ptr PdfMemDocumentObj): bool {.importcpp: "#->IsEncrypted()".}
proc collectGarbage*(doc: ptr PdfMemDocumentObj) {.importcpp: "#->CollectGarbage()".}

proc isPrintAllowed*(
  doc: ptr PdfMemDocumentObj
): bool {.importcpp: "#->IsPrintAllowed()".}

proc isEditAllowed*(
  doc: ptr PdfMemDocumentObj
): bool {.importcpp: "#->IsEditAllowed()".}

proc isCopyAllowed*(
  doc: ptr PdfMemDocumentObj
): bool {.importcpp: "#->IsCopyAllowed()".}

proc isEditNotesAllowed*(
  doc: ptr PdfMemDocumentObj
): bool {.importcpp: "#->IsEditNotesAllowed()".}

proc isFillAndSignAllowed*(
  doc: ptr PdfMemDocumentObj
): bool {.importcpp: "#->IsFillAndSignAllowed()".}

proc isHighPrintAllowed*(
  doc: ptr PdfMemDocumentObj
): bool {.importcpp: "#->IsHighPrintAllowed()".}

proc getOrCreateOutlines*(
  doc: ptr PdfMemDocumentObj
): ptr PdfOutlinesObj {.importcpp: "(&(#->GetOrCreateOutlines()))".}

proc getOrCreateAcroForm*(
  doc: ptr PdfMemDocumentObj,
  defaultAppearance: PdfAcroFormDefaulAppearance =
    PdfAcroFormDefaulAppearance.BlackText12pt,
): ptr PdfAcroFormObj {.importcpp: "(&(#->GetOrCreateAcroForm(@)))".}

# PoDoFo 1.0.x: AttachFile and GetAttachment removed
# Use GetNames()->GetOrCreateTree<PdfEmbeddedFiles>().AddValue() instead

# PdfNameTrees - Name tree access (PoDoFo 1.0.x)
proc getNames*(
  doc: ptr PdfMemDocumentObj
): ptr PdfNameTreesObj {.importcpp: "#->GetNames()".}

proc mustGetNames*(
  doc: ptr PdfMemDocumentObj
): ptr PdfNameTreesObj {.importcpp: "(&(#->MustGetNames()))".}

proc getOrCreateNames*(
  doc: ptr PdfMemDocumentObj
): ptr PdfNameTreesObj {.importcpp: "(&(#->GetOrCreateNames()))".}

# PdfEmbeddedFiles - Embedded files name tree
proc getOrCreateEmbeddedFiles*(
  names: ptr PdfNameTreesObj
): ptr PdfEmbeddedFilesObj {.
  importcpp: "(&(#->GetOrCreateTree<PoDoFo::PdfEmbeddedFiles>()))"
.}

proc getEmbeddedFiles*(
  names: ptr PdfNameTreesObj
): ptr PdfEmbeddedFilesObj {.importcpp: "#->GetTree<PoDoFo::PdfEmbeddedFiles>()".}

proc addValueToEmbeddedFiles*(
  tree: ptr PdfEmbeddedFilesObj, key: PdfStringObj, value: SharedPtrPdfFileSpec
) {.importcpp: "#->AddValue(@)".}

proc hasKeyInEmbeddedFiles*(
  tree: ptr PdfEmbeddedFilesObj, key: StdStringView
): bool {.importcpp: "#->HasKey(@)".}

proc getValueFromEmbeddedFiles*(
  tree: ptr PdfEmbeddedFilesObj, key: StdStringView
): ptr PdfFileSpecObj {.importcpp: "#->GetValue(@).get()".}

proc appendDocumentPages*(
  doc: ptr PdfMemDocumentObj, srcDoc: ptr PdfMemDocumentObj
) {.importcpp: "#->GetPages().AppendDocumentPages(*#)".}

# PdfPageCollection

proc getCount*(pages: ptr PdfPageCollectionObj): cuint {.importcpp: "#->GetCount()".}
proc getPageAt*(
  pages: ptr PdfPageCollectionObj, index: cuint
): ptr PdfPageObj {.importcpp: "&(#->GetPageAt(@))".}

proc createPage*(
  pages: ptr PdfPageCollectionObj, size: PodofoRect
): ptr PdfPageObj {.importcpp: "&(#->CreatePage(@))".}

proc createPageAt*(
  pages: ptr PdfPageCollectionObj, index: cuint, size: PodofoRect
): ptr PdfPageObj {.importcpp: "&(#->CreatePageAt(@))".}

proc removePageAt*(
  pages: ptr PdfPageCollectionObj, index: cuint
) {.importcpp: "#->RemovePageAt(@)".}

proc flattenStructure*(
  pages: ptr PdfPageCollectionObj
) {.importcpp: "#->FlattenStructure()".}

# PdfPage

proc getRect*(page: ptr PdfPageObj): PodofoRect {.importcpp: "#->GetRect()".}
proc setRect*(page: ptr PdfPageObj, rect: PodofoRect) {.importcpp: "#->SetRect(@)".}
proc getPageNumber*(page: ptr PdfPageObj): cuint {.importcpp: "#->GetPageNumber()".}
proc getIndex*(page: ptr PdfPageObj): cuint {.importcpp: "#->GetIndex()".}
proc getRotationRaw*(page: ptr PdfPageObj): cint {.importcpp: "#->GetRotationRaw()".}
proc setRotationRaw*(
  page: ptr PdfPageObj, rotation: cint
) {.importcpp: "#->SetRotationRaw(@)".}

proc moveAt*(page: ptr PdfPageObj, index: cuint) {.importcpp: "#->MoveAt(@)".}
proc flattenStructure*(page: ptr PdfPageObj) {.importcpp: "#->FlattenStructure()".}

# Page boxes
proc getMediaBox*(
  page: ptr PdfPageObj, raw: bool = false
): PodofoRect {.importcpp: "#->GetMediaBox(@)".}

proc setMediaBox*(
  page: ptr PdfPageObj, rect: PodofoRect, raw: bool = false
) {.importcpp: "#->SetMediaBox(@)".}

proc getCropBox*(
  page: ptr PdfPageObj, raw: bool = false
): PodofoRect {.importcpp: "#->GetCropBox(@)".}

proc setCropBox*(
  page: ptr PdfPageObj, rect: PodofoRect, raw: bool = false
) {.importcpp: "#->SetCropBox(@)".}

proc getTrimBox*(
  page: ptr PdfPageObj, raw: bool = false
): PodofoRect {.importcpp: "#->GetTrimBox(@)".}

proc setTrimBox*(
  page: ptr PdfPageObj, rect: PodofoRect, raw: bool = false
) {.importcpp: "#->SetTrimBox(@)".}

proc getBleedBox*(
  page: ptr PdfPageObj, raw: bool = false
): PodofoRect {.importcpp: "#->GetBleedBox(@)".}

proc setBleedBox*(
  page: ptr PdfPageObj, rect: PodofoRect, raw: bool = false
) {.importcpp: "#->SetBleedBox(@)".}

proc getArtBox*(
  page: ptr PdfPageObj, raw: bool = false
): PodofoRect {.importcpp: "#->GetArtBox(@)".}

proc setArtBox*(
  page: ptr PdfPageObj, rect: PodofoRect, raw: bool = false
) {.importcpp: "#->SetArtBox(@)".}

# PdfFontManager

proc searchFont*(
  fontMgr: ptr PdfFontManagerObj, fontPattern: StdStringView
): ptr PdfFontObj {.importcpp: "#->SearchFont(@)".}

proc getOrCreateFont*(
  fontMgr: ptr PdfFontManagerObj, fontPath: StdStringView
): ptr PdfFontObj {.importcpp: "&(#->GetOrCreateFont(@))".}

proc getStandard14Font*(
  fontMgr: ptr PdfFontManagerObj, stdFont: PdfStandard14FontType
): ptr PdfFontObj {.importcpp: "&(#->GetStandard14Font(@))".}

proc embedFonts*(fontMgr: ptr PdfFontManagerObj) {.importcpp: "#->EmbedFonts()".}

# PdfFont

proc getName*(font: ptr PdfFontObj): cstring {.importcpp: "#->GetName().c_str()".}
proc isStandard14Font*(
  font: ptr PdfFontObj
): bool {.importcpp: "#->IsStandard14Font()".}

proc isCIDKeyed*(font: ptr PdfFontObj): bool {.importcpp: "#->IsCIDKeyed()".}

proc getStringLength*(
  font: ptr PdfFontObj, str: StdStringView, state: PdfTextStateObj
): cdouble {.importcpp: "#->GetStringLength(@)".}

proc getLineSpacing*(
  font: ptr PdfFontObj, state: PdfTextStateObj
): cdouble {.importcpp: "#->GetLineSpacing(@)".}

proc getUnderlineThickness*(
  font: ptr PdfFontObj, state: PdfTextStateObj
): cdouble {.importcpp: "#->GetUnderlineThickness(@)".}

proc getUnderlinePosition*(
  font: ptr PdfFontObj, state: PdfTextStateObj
): cdouble {.importcpp: "#->GetUnderlinePosition(@)".}

proc getStrikeThroughPosition*(
  font: ptr PdfFontObj, state: PdfTextStateObj
): cdouble {.importcpp: "#->GetStrikeThroughPosition(@)".}

proc getStrikeThroughThickness*(
  font: ptr PdfFontObj, state: PdfTextStateObj
): cdouble {.importcpp: "#->GetStrikeThroughThickness(@)".}

proc getAscent*(
  font: ptr PdfFontObj, state: PdfTextStateObj
): cdouble {.importcpp: "#->GetAscent(@)".}

proc getDescent*(
  font: ptr PdfFontObj, state: PdfTextStateObj
): cdouble {.importcpp: "#->GetDescent(@)".}

# PdfPainter

proc createPdfPainter*(): ptr PdfPainterObj {.importcpp: "new PoDoFo::PdfPainter()".}

proc deletePdfPainter*(painter: ptr PdfPainterObj) {.importcpp: "delete #".}

proc setCanvas*(
  painter: ptr PdfPainterObj, page: ptr PdfPageObj
) {.importcpp: "#->SetCanvas(*#)".}

proc setCanvasXObject*(
  painter: ptr PdfPainterObj, xobj: ptr PdfXObjectFormObj
) {.importcpp: "#->SetCanvas(*#)".}

proc finishDrawing*(painter: ptr PdfPainterObj) {.importcpp: "#->FinishDrawing()".}

proc save*(painter: ptr PdfPainterObj) {.importcpp: "#->Save()".}
proc restore*(painter: ptr PdfPainterObj) {.importcpp: "#->Restore()".}

proc setPrecision*(
  painter: ptr PdfPainterObj, precision: cushort
) {.importcpp: "#->SetPrecision(@)".}

# Color operations (PoDoFo 1.0.x - via GraphicsState wrapper)
proc setNonStrokingColor*(
  painter: ptr PdfPainterObj, color: PdfColorObj
) {.importcpp: "#->GraphicsState.SetNonStrokingColor(@)".}

proc setStrokingColor*(
  painter: ptr PdfPainterObj, color: PdfColorObj
) {.importcpp: "#->GraphicsState.SetStrokingColor(@)".}

proc setExtGState*(
  painter: ptr PdfPainterObj, gs: ptr PdfExtGStateObj
) {.importcpp: "#->GraphicsState.SetExtGState(*#)".}

# Drawing operations
proc drawLine*(
  painter: ptr PdfPainterObj, x1, y1, x2, y2: cdouble
) {.importcpp: "#->DrawLine(@)".}

proc drawCubicBezier*(
  painter: ptr PdfPainterObj, x1, y1, x2, y2, x3, y3, x4, y4: cdouble
) {.importcpp: "#->DrawCubicBezier(@)".}

proc drawArc*(
  painter: ptr PdfPainterObj,
  x, y, radius, startAngle, endAngle: cdouble,
  clockwise: bool = false,
) {.importcpp: "#->DrawArc(@)".}

proc drawCircle*(
  painter: ptr PdfPainterObj,
  x, y, radius: cdouble,
  mode: PdfPathDrawMode = PdfPathDrawMode.Stroke,
) {.importcpp: "#->DrawCircle(@)".}

proc drawEllipse*(
  painter: ptr PdfPainterObj,
  x, y, width, height: cdouble,
  mode: PdfPathDrawMode = PdfPathDrawMode.Stroke,
) {.importcpp: "#->DrawEllipse(@)".}

proc drawRectangle*(
  painter: ptr PdfPainterObj,
  x, y, width, height: cdouble,
  mode: PdfPathDrawMode = PdfPathDrawMode.Stroke,
  roundX: cdouble = 0.0,
  roundY: cdouble = 0.0,
) {.importcpp: "#->DrawRectangle(@)".}

proc drawText*(
  painter: ptr PdfPainterObj, str: StdStringView, x, y: cdouble
) {.importcpp: "#->DrawText(@)".}

proc drawTextMultiLine*(
  painter: ptr PdfPainterObj,
  str: StdStringView,
  x, y, width, height: cdouble,
  hAlignment: PdfHorizontalAlignment = PdfHorizontalAlignment.Left,
  vAlignment: PdfVerticalAlignment = PdfVerticalAlignment.Top,
) {.importcpp: "#->DrawTextMultiLine(@)".}

proc drawTextAligned*(
  painter: ptr PdfPainterObj,
  str: StdStringView,
  x, y, width: cdouble,
  hAlignment: PdfHorizontalAlignment,
) {.importcpp: "#->DrawTextAligned(@)".}

proc drawImage*(
  painter: ptr PdfPainterObj,
  img: ptr PdfImageObj,
  x, y: cdouble,
  scaleX: cdouble = 1.0,
  scaleY: cdouble = 1.0,
) {.importcpp: "#->DrawImage(*#, @)".}

proc drawXObject*(
  painter: ptr PdfPainterObj,
  xobj: ptr PdfXObjectObj,
  x, y: cdouble,
  scaleX: cdouble = 1.0,
  scaleY: cdouble = 1.0,
) {.importcpp: "#->DrawXObject(*#, @)".}

proc drawPath*(
  painter: ptr PdfPainterObj,
  path: ptr PdfPainterPathObj,
  mode: PdfPathDrawMode = PdfPathDrawMode.Stroke,
) {.importcpp: "#->DrawPath(*#, @)".}

proc clipPath*(
  painter: ptr PdfPainterObj, path: ptr PdfPainterPathObj, useEvenOddRule: bool = false
) {.importcpp: "#->ClipPath(*#, @)".}

proc setClipRect*(
  painter: ptr PdfPainterObj, x, y, width, height: cdouble
) {.importcpp: "#->SetClipRect(@)".}

proc setClipRectR*(
  painter: ptr PdfPainterObj, rect: PodofoRect
) {.importcpp: "#->SetClipRect(@)".}

# Marked content
proc beginMarkedContent*(
  painter: ptr PdfPainterObj, tag: StdStringView
) {.importcpp: "#->BeginMarkedContent(@)".}

proc endMarkedContent*(
  painter: ptr PdfPainterObj
) {.importcpp: "#->EndMarkedContent()".}

# Text object mode
proc beginText*(painter: ptr PdfPainterObj) {.importcpp: "#->BeginText()".}
proc endText*(painter: ptr PdfPainterObj) {.importcpp: "#->EndText()".}
proc textMoveTo*(
  painter: ptr PdfPainterObj, x, y: cdouble
) {.importcpp: "#->TextMoveTo(@)".}

proc addText*(
  painter: ptr PdfPainterObj, str: StdStringView
) {.importcpp: "#->AddText(@)".}

# GraphicsState access
proc getGraphicsState*(
  painter: ptr PdfPainterObj
): ptr PdfGraphicsStateWrapperObj {.importcpp: "(&(#->GraphicsState))".}

proc getTextState*(
  painter: ptr PdfPainterObj
): ptr PdfTextStateWrapperObj {.importcpp: "(&(#->TextState))".}

# PdfPainterPath

proc createPdfPainterPath*(): ptr PdfPainterPathObj {.
  importcpp: "new PoDoFo::PdfPainterPath()"
.}

proc deletePdfPainterPath*(path: ptr PdfPainterPathObj) {.importcpp: "delete #".}

proc moveTo*(path: ptr PdfPainterPathObj, x, y: cdouble) {.importcpp: "#->MoveTo(@)".}
proc lineTo*(
  path: ptr PdfPainterPathObj, x, y: cdouble
) {.importcpp: "#->AddLineTo(@)".}

proc cubicBezierTo*(
  path: ptr PdfPainterPathObj, x1, y1, x2, y2, x3, y3: cdouble
) {.importcpp: "#->AddCubicBezierTo(@)".}

proc addArc*(
  path: ptr PdfPainterPathObj,
  x, y, radius, startAngle, endAngle: cdouble,
  clockwise: bool = false,
) {.importcpp: "#->AddArc(@)".}

proc addArcTo*(
  path: ptr PdfPainterPathObj, x1, y1, x2, y2, radius: cdouble
) {.importcpp: "#->AddArcTo(@)".}

proc addCircle*(
  path: ptr PdfPainterPathObj, x, y, radius: cdouble
) {.importcpp: "#->AddCircle(@)".}

proc addEllipse*(
  path: ptr PdfPainterPathObj, x, y, width, height: cdouble
) {.importcpp: "#->AddEllipse(@)".}

proc addRectangle*(
  path: ptr PdfPainterPathObj,
  x, y, width, height: cdouble,
  roundX: cdouble = 0.0,
  roundY: cdouble = 0.0,
) {.importcpp: "#->AddRectangle(@)".}

proc closePath*(path: ptr PdfPainterPathObj) {.importcpp: "#->Close()".}
proc reset*(path: ptr PdfPainterPathObj) {.importcpp: "#->Reset()".}

# PdfGraphicsStateWrapper

proc setLineWidth*(
  gs: ptr PdfGraphicsStateWrapperObj, width: cdouble
) {.importcpp: "#->SetLineWidth(@)".}

proc setMiterLimit*(
  gs: ptr PdfGraphicsStateWrapperObj, limit: cdouble
) {.importcpp: "#->SetMiterLimit(@)".}

proc setLineCapStyle*(
  gs: ptr PdfGraphicsStateWrapperObj, style: PdfLineCapStyle
) {.importcpp: "#->SetLineCapStyle(@)".}

proc setLineJoinStyle*(
  gs: ptr PdfGraphicsStateWrapperObj, style: PdfLineJoinStyle
) {.importcpp: "#->SetLineJoinStyle(@)".}

# SetFillColor/SetStrokeColor removed from GraphicsStateWrapper in 1.0.x
# Use painter.setNonStrokingColor/setStrokingColor instead
proc setRenderingIntent*(
  gs: ptr PdfGraphicsStateWrapperObj, intent: StdStringView
) {.importcpp: "#->SetRenderingIntent(@)".}

proc setTransformationMatrix*(
  gs: ptr PdfGraphicsStateWrapperObj, matrix: Matrix
) {.importcpp: "#->SetTransformationMatrix(@)".}

proc getLineWidth*(
  gs: ptr PdfGraphicsStateWrapperObj
): cdouble {.importcpp: "#->GetLineWidth()".}

proc getMiterLimit*(
  gs: ptr PdfGraphicsStateWrapperObj
): cdouble {.importcpp: "#->GetMiterLevel()".}

# PdfTextStateWrapper

proc setFont*(
  ts: ptr PdfTextStateWrapperObj, font: ptr PdfFontObj, fontSize: cdouble
) {.importcpp: "#->SetFont(*#, @)".}

proc setFontScale*(
  ts: ptr PdfTextStateWrapperObj, scale: cdouble
) {.importcpp: "#->SetFontScale(@)".}

proc setCharSpacing*(
  ts: ptr PdfTextStateWrapperObj, spacing: cdouble
) {.importcpp: "#->SetCharSpacing(@)".}

proc setWordSpacing*(
  ts: ptr PdfTextStateWrapperObj, spacing: cdouble
) {.importcpp: "#->SetWordSpacing(@)".}

proc setRenderingMode*(
  ts: ptr PdfTextStateWrapperObj, mode: PdfTextRenderingMode
) {.importcpp: "#->SetRenderingMode(@)".}

proc getFontSize*(
  ts: ptr PdfTextStateWrapperObj
): cdouble {.importcpp: "#->GetFontSize()".}

# PdfImage

proc load*(
  img: ptr PdfImageObj, filename: StdStringView, imageIndex: cuint = 0
) {.importcpp: "#->Load(@)".}

proc loadFromBuffer*(
  img: ptr PdfImageObj, data: cstring, size: csize_t, imageIndex: cuint = 0
) {.importcpp: "#->LoadFromBuffer(PoDoFo::bufferview((const char*)#, @))".}

proc getWidth*(img: ptr PdfImageObj): cuint {.importcpp: "#->GetWidth()".}
proc getHeight*(img: ptr PdfImageObj): cuint {.importcpp: "#->GetHeight()".}
proc setInterpolate*(
  img: ptr PdfImageObj, value: bool
) {.importcpp: "#->SetInterpolate(@)".}

proc setChromaKeyMask*(
  img: ptr PdfImageObj, r, g, b, threshold: int64
) {.importcpp: "#->SetChromaKeyMask(@)".}

# PdfMetadata

# String metadata - PoDoFo 1.0.x: getters/setters use nullable<const PdfString&>
proc getAuthor*(
  meta: ptr PdfMetadataObj
): NullablePdfStringRef {.importcpp: "#->GetAuthor()".}

proc setAuthor*(
  meta: ptr PdfMetadataObj, author: NullablePdfStringRef
) {.importcpp: "#->SetAuthor(@)".}

proc getCreator*(
  meta: ptr PdfMetadataObj
): NullablePdfStringRef {.importcpp: "#->GetCreator()".}

proc setCreator*(
  meta: ptr PdfMetadataObj, creator: NullablePdfStringRef
) {.importcpp: "#->SetCreator(@)".}

proc getKeywordsRaw*(
  meta: ptr PdfMetadataObj
): NullablePdfStringRef {.importcpp: "#->GetKeywordsRaw()".}

proc getSubject*(
  meta: ptr PdfMetadataObj
): NullablePdfStringRef {.importcpp: "#->GetSubject()".}

proc setSubject*(
  meta: ptr PdfMetadataObj, subject: NullablePdfStringRef
) {.importcpp: "#->SetSubject(@)".}

proc getTitle*(
  meta: ptr PdfMetadataObj
): NullablePdfStringRef {.importcpp: "#->GetTitle()".}

proc setTitle*(
  meta: ptr PdfMetadataObj, title: NullablePdfStringRef
) {.importcpp: "#->SetTitle(@)".}

proc getProducer*(
  meta: ptr PdfMetadataObj
): NullablePdfStringRef {.importcpp: "#->GetProducer()".}

proc setProducer*(
  meta: ptr PdfMetadataObj, producer: NullablePdfStringRef
) {.importcpp: "#->SetProducer(@)".}

# Date metadata - PoDoFo 1.0.x: setters take nullable<PdfDate>
proc getCreationDate*(
  meta: ptr PdfMetadataObj
): NullablePdfDate {.importcpp: "#->GetCreationDate()".}

proc setCreationDate*(
  meta: ptr PdfMetadataObj, date: NullablePdfDate
) {.importcpp: "#->SetCreationDate(@)".}

proc getModifyDate*(
  meta: ptr PdfMetadataObj
): NullablePdfDate {.importcpp: "#->GetModifyDate()".}

proc setModifyDate*(
  meta: ptr PdfMetadataObj, date: NullablePdfDate
) {.importcpp: "#->SetModifyDate(@)".}

proc initNullablePdfDate*(
  date: PdfDateObj
): NullablePdfDate {.importcpp: "PoDoFo::nullable<PoDoFo::PdfDate>(@)".}

proc getTrapped*(
  meta: ptr PdfMetadataObj
): cstring {.importcpp: "#->GetTrapped().c_str()".}

proc ensureXMPMetadata*(
  meta: ptr PdfMetadataObj
) {.importcpp: "#->EnsureXMPMetadata()".}

# PdfString helpers

proc initPdfString*(
  s: StdStringView
): PdfStringObj {.importcpp: "PoDoFo::PdfString(@)".}

proc getString*(
  s: PdfStringObj
): cstring {.importcpp: "std::string(#.GetString()).c_str()".}

proc isNull*(s: PdfStringObj): bool {.importcpp: "#.IsNull()".}

# PdfName helpers

proc initPdfName*(s: StdStringView): PdfNameObj {.importcpp: "PoDoFo::PdfName(@)".}
proc getNameString*(
  n: PdfNameObj
): cstring {.importcpp: "std::string(#.GetString()).c_str()".}

# nullable helpers

proc hasValue*(n: NullablePdfString): bool {.importcpp: "#.has_value()".}
proc getValue*(n: NullablePdfString): PdfStringObj {.importcpp: "*#".}
proc getStringCstr*(
  n: NullablePdfString
): cstring {.importcpp: "std::string((*#).GetString()).c_str()".}

proc hasValue*(n: NullablePdfStringRef): bool {.importcpp: "#.has_value()".}
proc getValue*(n: NullablePdfStringRef): PdfStringObj {.importcpp: "*#".}
# Note: getStringCstr returns pointer to temporary - caller must copy immediately
proc getStringCstr*(
  n: NullablePdfStringRef
): cstring {.importcpp: "std::string((*#).GetString()).c_str()".}

proc initNullablePdfStringRef*(
  s: PdfStringObj
): NullablePdfStringRef {.importcpp: "PoDoFo::nullable<const PoDoFo::PdfString&>(@)".}

# Helper to get string with proper lifetime - returns std::string by value
type StdString* {.importcpp: "std::string", header: "<string>".} = object
proc initStdString*(): StdString {.constructor, importcpp: "std::string()".}
proc initStdString*(
  sv: StdStringView
): StdString {.constructor, importcpp: "std::string(@)".}

proc cStr*(s: StdString): cstring {.importcpp: "#.c_str()".}
proc len*(s: StdString): csize_t {.importcpp: "#.length()".}

# Safe string extraction from nullable - creates an owned std::string
proc getStringOwned*(
  n: NullablePdfStringRef
): StdString {.importcpp: "std::string((*#).GetString())".}

proc hasValue*(n: NullablePdfDate): bool {.importcpp: "#.has_value()".}
proc getValue*(n: NullablePdfDate): PdfDateObj {.importcpp: "*#".}

# PdfDate

proc initPdfDate*(): PdfDateObj {.importcpp: "PoDoFo::PdfDate()".}
proc initPdfDateNow*(): PdfDateObj {.importcpp: "PoDoFo::PdfDate::LocalNow()".}
proc toStringRaw*(d: PdfDateObj): cstring {.importcpp: "#.ToString().c_str()".}

# PdfFileSpec - PoDoFo 1.0.x API (constructors are private, use CreateFileSpec)

proc createFileSpec*(
  doc: ptr PdfMemDocumentObj
): UniquePtrPdfFileSpec {.importcpp: "#->CreateFileSpec()".}

proc deletePdfFileSpec*(fs: ptr PdfFileSpecObj) {.importcpp: "delete #".}

# unique_ptr operations
proc getFileSpecPtr*(
  p: UniquePtrPdfFileSpec
): ptr PdfFileSpecObj {.importcpp: "#.get()".}

proc releaseFileSpec*(
  p: var UniquePtrPdfFileSpec
): ptr PdfFileSpecObj {.importcpp: "#.release()".}

# shared_ptr operations
proc makeSharedFileSpec*(
  p: ptr PdfFileSpecObj
): SharedPtrPdfFileSpec {.importcpp: "std::shared_ptr<PoDoFo::PdfFileSpec>(#)".}

proc getSharedFileSpecPtr*(
  p: SharedPtrPdfFileSpec
): ptr PdfFileSpecObj {.importcpp: "#.get()".}

# FileSpec methods
proc getFilename*(
  fileSpec: ptr PdfFileSpecObj
): cstring {.importcpp: "std::string(#->GetFilename().value().GetString()).c_str()".}

proc hasFilename*(
  fileSpec: ptr PdfFileSpecObj
): bool {.importcpp: "#->GetFilename().has_value()".}

proc setFilename*(
  fileSpec: ptr PdfFileSpecObj, filename: NullablePdfStringRefConst
) {.importcpp: "#->SetFilename(@)".}

proc setFilenameStr*(
  fileSpec: ptr PdfFileSpecObj, filename: PdfStringObj
) {.importcpp: "#->SetFilename(@)".}

# charbuff helpers for embedded data
proc initCharbuff*(): charbuff {.importcpp: "PoDoFo::charbuff()".}
proc initCharbuffFromData*(
  data: cstring, size: csize_t
): charbuff {.importcpp: "PoDoFo::charbuff(std::string_view(@))".}

# nullable<const charbuff&> helpers
proc initNullableCharbuff*(
  buf: charbuff
): NullableCharbuffRef {.importcpp: "PoDoFo::nullable<const PoDoFo::charbuff&>(@)".}

proc initNullableCharbuffNull*(): NullableCharbuffRef {.
  importcpp: "PoDoFo::nullable<const PoDoFo::charbuff&>()"
.}

proc setEmbeddedData*(
  fileSpec: ptr PdfFileSpecObj, data: NullableCharbuffRef
) {.importcpp: "#->SetEmbeddedData(@)".}

proc setEmbeddedDataFromFile*(
  fileSpec: ptr PdfFileSpecObj, filepath: StdStringView
) {.importcpp: "#->SetEmbeddedDataFromFile(@)".}

# PdfExtGState - Extended Graphics State (PoDoFo 1.0.x)
# New API: Create definition, then call doc.CreateExtGState(definition)

type
  PdfExtGStateDefinitionObj* {.
    importcpp: "PoDoFo::PdfExtGStateDefinition", header: "<podofo/podofo.h>"
  .} = object

  PdfExtGStateDefinitionPtr* {.
    importcpp: "std::shared_ptr<const PoDoFo::PdfExtGStateDefinition>"
  .} = object
  UniquePtrPdfExtGState* {.importcpp: "std::unique_ptr<PoDoFo::PdfExtGState>".} = object

proc initExtGStateDefinition*(): PdfExtGStateDefinitionObj {.
  importcpp: "PoDoFo::PdfExtGStateDefinition()"
.}

proc makeSharedExtGStateDefinition*(
  def: PdfExtGStateDefinitionObj
): PdfExtGStateDefinitionPtr {.
  importcpp: "std::make_shared<const PoDoFo::PdfExtGStateDefinition>(@)"
.}

# Set nullable doubles on definition
proc setStrokingAlpha*(
  def: var PdfExtGStateDefinitionObj, alpha: cdouble
) {.importcpp: "#.StrokingAlpha = @".}

proc setNonStrokingAlpha*(
  def: var PdfExtGStateDefinitionObj, alpha: cdouble
) {.importcpp: "#.NonStrokingAlpha = @".}

proc setBlendModeOnDef*(
  def: var PdfExtGStateDefinitionObj, mode: PdfBlendMode
) {.importcpp: "#.BlendMode = @".}

proc setNonZeroOverprintMode*(
  def: var PdfExtGStateDefinitionObj, enable: bool
) {.importcpp: "#.NonZeroOverprintMode = @".}

proc createExtGState*(
  doc: ptr PdfMemDocumentObj, def: PdfExtGStateDefinitionPtr
): UniquePtrPdfExtGState {.importcpp: "#->CreateExtGState(@)".}

proc releaseExtGState*(
  uptr: var UniquePtrPdfExtGState
): ptr PdfExtGStateObj {.importcpp: "#.release()".}

proc deleteExtGState*(gs: ptr PdfExtGStateObj) {.importcpp: "delete #".}

# PdfOutlines - Bookmarks

# PoDoFo 1.0.x: CreateRoot/CreateChild/CreateNext return references, not pointers
proc createRoot*(
  outlines: ptr PdfOutlinesObj, title: StdStringView
): ptr PdfOutlineItemObj {.importcpp: "(&(#->CreateRoot(PoDoFo::PdfString(@))))".}

# Note: CreateChild/CreateNext no longer take destination in PoDoFo 1.0.x
proc createChild*(
  item: ptr PdfOutlineItemObj, title: StdStringView
): ptr PdfOutlineItemObj {.importcpp: "(&(#->CreateChild(PoDoFo::PdfString(@))))".}

proc createNext*(
  item: ptr PdfOutlineItemObj, title: StdStringView
): ptr PdfOutlineItemObj {.importcpp: "(&(#->CreateNext(PoDoFo::PdfString(@))))".}

# PoDoFo 1.0.x: SetDestination uses nullable<const PdfDestination&>
proc setDestination*(
  item: ptr PdfOutlineItemObj, dest: NullablePdfDestinationRef
) {.importcpp: "#->SetDestination(@)".}

proc setTextFormat*(
  item: ptr PdfOutlineItemObj, italic, bold: bool
) {.
  importcpp:
    "#->SetTextFormat(static_cast<PoDoFo::PdfOutlineFormat>((# ? 1 : 0) | (# ? 2 : 0)))"
.}

# PoDoFo 1.0.x: SetTextColor takes PdfColor, not (r,g,b)
proc setTextColor*(
  item: ptr PdfOutlineItemObj, color: PdfColorObj
) {.importcpp: "#->SetTextColor(@)".}

proc getTitle*(
  item: ptr PdfOutlineItemObj
): cstring {.importcpp: "std::string(#->GetTitle().GetString()).c_str()".}

# PdfDestination - PoDoFo 1.0.x API

# unique_ptr for destination
type UniquePtrPdfDestination* {.
  importcpp: "std::unique_ptr<PoDoFo::PdfDestination>", header: "<memory>"
.} = object

proc createDestination*(
  doc: ptr PdfMemDocumentObj
): UniquePtrPdfDestination {.importcpp: "#->CreateDestination()".}

proc getDestinationPtr*(
  p: UniquePtrPdfDestination
): ptr PdfDestinationObj {.importcpp: "#.get()".}

proc releaseDestination*(
  p: var UniquePtrPdfDestination
): ptr PdfDestinationObj {.importcpp: "#.release()".}

# SetDestination methods
proc setDestination*(
  dest: ptr PdfDestinationObj,
  page: ptr PdfPageObj,
  fit: PdfDestinationFit = PdfDestinationFit.Fit,
) {.importcpp: "#->SetDestination(*#, @)".}

proc setDestinationXYZ*(
  dest: ptr PdfDestinationObj, page: ptr PdfPageObj, left, top, zoom: cdouble
) {.importcpp: "#->SetDestination(*#, @)".}

proc deleteDestination*(dest: ptr PdfDestinationObj) {.importcpp: "delete #".}

# PdfTextState (struct for font metrics)

proc initPdfTextState*(
  font: ptr PdfFontObj, fontSize: cdouble
): PdfTextStateObj {.importcpp: "PoDoFo::PdfTextState{#, @}".}

# PdfAcroForm - Interactive Forms

proc setNeedAppearances*(
  form: ptr PdfAcroFormObj, need: bool
) {.importcpp: "#->SetNeedAppearances(@)".}

proc getNeedAppearances*(
  form: ptr PdfAcroFormObj
): bool {.importcpp: "#->GetNeedAppearances()".}

proc getFieldCount*(form: ptr PdfAcroFormObj): cuint {.importcpp: "#->GetFieldCount()".}
proc getFieldAt*(
  form: ptr PdfAcroFormObj, index: cuint
): ptr PdfFieldObj {.importcpp: "(&(#->GetFieldAt(@)))".}

proc removeFieldAt*(
  form: ptr PdfAcroFormObj, index: cuint
) {.importcpp: "#->RemoveFieldAt(@)".}

proc createFieldTextBox*(
  form: ptr PdfAcroFormObj, name: StdStringView
): ptr PdfTextBoxObj {.importcpp: "(&(#->CreateField<PoDoFo::PdfTextBox>(@)))".}

proc createFieldCheckBox*(
  form: ptr PdfAcroFormObj, name: StdStringView
): ptr PdfCheckBoxObj {.importcpp: "(&(#->CreateField<PoDoFo::PdfCheckBox>(@)))".}

proc createFieldPushButton*(
  form: ptr PdfAcroFormObj, name: StdStringView
): ptr PdfPushButtonObj {.importcpp: "(&(#->CreateField<PoDoFo::PdfPushButton>(@)))".}

proc createFieldSignature*(
  form: ptr PdfAcroFormObj, name: StdStringView
): ptr PdfSignatureObj {.importcpp: "(&(#->CreateField<PoDoFo::PdfSignature>(@)))".}

proc createFieldComboBox*(
  form: ptr PdfAcroFormObj, name: StdStringView
): ptr PdfComboBoxObj {.importcpp: "(&(#->CreateField<PoDoFo::PdfComboBox>(@)))".}

proc createFieldListBox*(
  form: ptr PdfAcroFormObj, name: StdStringView
): ptr PdfListBoxObj {.importcpp: "(&(#->CreateField<PoDoFo::PdfListBox>(@)))".}

# PdfField - Base field class

proc getFieldType*(field: ptr PdfFieldObj): PdfFieldType {.importcpp: "#->GetType()".}
proc getFieldName*(
  field: ptr PdfFieldObj
): cstring {.importcpp: "#->GetFullName().c_str()".}

proc setFieldName*(
  field: ptr PdfFieldObj, name: StdStringView
) {.importcpp: "#->SetName(@)".}

proc getAlternateName*(
  field: ptr PdfFieldObj
): cstring {.importcpp: "#->GetAlternateName().c_str()".}

proc setAlternateName*(
  field: ptr PdfFieldObj, name: StdStringView
) {.importcpp: "#->SetAlternateName(PoDoFo::PdfString(@))".}

proc getMappingName*(
  field: ptr PdfFieldObj
): cstring {.importcpp: "#->GetMappingName().c_str()".}

proc setMappingName*(
  field: ptr PdfFieldObj, name: StdStringView
) {.importcpp: "#->SetMappingName(PoDoFo::PdfString(@))".}

proc isReadOnly*(field: ptr PdfFieldObj): bool {.importcpp: "#->IsReadOnly()".}
proc setReadOnly*(
  field: ptr PdfFieldObj, readOnly: bool
) {.importcpp: "#->SetReadOnly(@)".}

proc isRequired*(field: ptr PdfFieldObj): bool {.importcpp: "#->IsRequired()".}
proc setRequired*(
  field: ptr PdfFieldObj, required: bool
) {.importcpp: "#->SetRequired(@)".}

proc isNoExport*(field: ptr PdfFieldObj): bool {.importcpp: "#->IsNoExport()".}
proc setNoExport*(
  field: ptr PdfFieldObj, noExport: bool
) {.importcpp: "#->SetNoExport(@)".}

# PdfTextBox - Text input field

proc getText*(
  textBox: ptr PdfTextBoxObj
): NullablePdfStringRef {.importcpp: "#->GetText()".}

proc setText*(
  textBox: ptr PdfTextBoxObj, text: PdfStringObj
) {.importcpp: "#->SetText(@)".}

proc getMaxLen*(textBox: ptr PdfTextBoxObj): int64 {.importcpp: "#->GetMaxLen()".}
proc setMaxLen*(
  textBox: ptr PdfTextBoxObj, maxLen: int64
) {.importcpp: "#->SetMaxLen(@)".}

proc isMultiLine*(textBox: ptr PdfTextBoxObj): bool {.importcpp: "#->IsMultiLine()".}
proc setMultiLine*(
  textBox: ptr PdfTextBoxObj, multiLine: bool
) {.importcpp: "#->SetMultiLine(@)".}

proc isPasswordField*(
  textBox: ptr PdfTextBoxObj
): bool {.importcpp: "#->IsPasswordField()".}

proc setPasswordField*(
  textBox: ptr PdfTextBoxObj, password: bool
) {.importcpp: "#->SetPasswordField(@)".}

proc isFileField*(textBox: ptr PdfTextBoxObj): bool {.importcpp: "#->IsFileField()".}
proc setFileField*(
  textBox: ptr PdfTextBoxObj, file: bool
) {.importcpp: "#->SetFileField(@)".}

proc isSpellcheckingEnabled*(
  textBox: ptr PdfTextBoxObj
): bool {.importcpp: "#->IsSpellcheckingEnabled()".}

proc setSpellcheckingEnabled*(
  textBox: ptr PdfTextBoxObj, spellcheck: bool
) {.importcpp: "#->SetSpellcheckingEnabled(@)".}

proc isScrollBarsEnabled*(
  textBox: ptr PdfTextBoxObj
): bool {.importcpp: "#->IsScrollBarsEnabled()".}

proc setScrollBarsEnabled*(
  textBox: ptr PdfTextBoxObj, scroll: bool
) {.importcpp: "#->SetScrollBarsEnabled(@)".}

proc isCombs*(textBox: ptr PdfTextBoxObj): bool {.importcpp: "#->IsCombs()".}
proc setCombs*(textBox: ptr PdfTextBoxObj, combs: bool) {.importcpp: "#->SetCombs(@)".}
proc isRichText*(textBox: ptr PdfTextBoxObj): bool {.importcpp: "#->IsRichText()".}
proc setRichText*(
  textBox: ptr PdfTextBoxObj, richText: bool
) {.importcpp: "#->SetRichText(@)".}

# PdfCheckBox - Checkbox field

proc isChecked*(checkBox: ptr PdfCheckBoxObj): bool {.importcpp: "#->IsChecked()".}
proc setChecked*(
  checkBox: ptr PdfCheckBoxObj, checked: bool
) {.importcpp: "#->SetChecked(@)".}

# PdfPushButton - Button field

proc setCaption*(
  button: ptr PdfPushButtonObj, caption: StdStringView
) {.importcpp: "#->SetCaption(PoDoFo::PdfString(@))".}

proc getCaption*(
  button: ptr PdfPushButtonObj
): NullablePdfStringRef {.importcpp: "#->GetCaption()".}

# PdfComboBox - Combobox field

proc getSelectedIndex*(
  comboBox: ptr PdfComboBoxObj
): cint {.importcpp: "#->GetSelectedIndex()".}

proc setSelectedIndex*(
  comboBox: ptr PdfComboBoxObj, index: cint
) {.importcpp: "#->SetSelectedIndex(@)".}

proc isEditable*(comboBox: ptr PdfComboBoxObj): bool {.importcpp: "#->IsEditable()".}
proc setEditable*(
  comboBox: ptr PdfComboBoxObj, editable: bool
) {.importcpp: "#->SetEditable(@)".}

# PdfListBox - List box field

proc getSelectedIndexListBox*(
  listBox: ptr PdfListBoxObj
): cint {.importcpp: "#->GetSelectedIndex()".}

proc setSelectedIndexListBox*(
  listBox: ptr PdfListBoxObj, index: cint
) {.importcpp: "#->SetSelectedIndex(@)".}

proc isMultiSelect*(
  listBox: ptr PdfListBoxObj
): bool {.importcpp: "#->IsMultiSelect()".}

proc setMultiSelect*(
  listBox: ptr PdfListBoxObj, multi: bool
) {.importcpp: "#->SetMultiSelect(@)".}

# PdfSignature - Digital signature field

proc setSignerName*(
  sig: ptr PdfSignatureObj, name: PdfStringObj
) {.importcpp: "#->SetSignerName(@)".}

proc getSignerName*(
  sig: ptr PdfSignatureObj
): NullablePdfStringRef {.importcpp: "#->GetSignerName()".}

proc setSignatureReason*(
  sig: ptr PdfSignatureObj, reason: PdfStringObj
) {.importcpp: "#->SetSignatureReason(@)".}

proc getSignatureReason*(
  sig: ptr PdfSignatureObj
): NullablePdfStringRef {.importcpp: "#->GetSignatureReason()".}

proc setSignatureLocation*(
  sig: ptr PdfSignatureObj, location: PdfStringObj
) {.importcpp: "#->SetSignatureLocation(@)".}

proc getSignatureLocation*(
  sig: ptr PdfSignatureObj
): NullablePdfStringRef {.importcpp: "#->GetSignatureLocation()".}

proc setSignatureCreator*(
  sig: ptr PdfSignatureObj, creator: PdfStringObj
) {.importcpp: "#->SetSignatureCreator(@)".}

proc setSignatureDate*(
  sig: ptr PdfSignatureObj, date: PdfDateObj
) {.importcpp: "#->SetSignatureDate(@)".}

proc getSignatureDate*(
  sig: ptr PdfSignatureObj
): NullablePdfDate {.importcpp: "#->GetSignatureDate()".}

proc addCertificationReference*(
  sig: ptr PdfSignatureObj, perm: PdfCertPermission = PdfCertPermission.NoPerms
) {.importcpp: "#->AddCertificationReference(@)".}

proc ensureValueObject*(
  sig: ptr PdfSignatureObj
) {.importcpp: "#->EnsureValueObject()".}

proc setAppearanceStreamSig*(
  sig: ptr PdfSignatureObj,
  xobj: ptr PdfXObjectFormObj,
  appearance: PdfAppearanceType = PdfAppearanceType.Normal,
) {.importcpp: "#->SetAppearanceStream(*#, @)".}

# PdfAction - PoDoFo 1.0.x API (actions created via PdfDocument::CreateAction)

# Specific action type objects
type
  PdfActionURIObj* {.importcpp: "PoDoFo::PdfActionURI".} = object
  PdfActionJavaScriptObj* {.importcpp: "PoDoFo::PdfActionJavaScript".} = object

  UniquePtrPdfAction* {.
    importcpp: "std::unique_ptr<PoDoFo::PdfAction>", header: "<memory>"
  .} = object

  UniquePtrPdfActionURI* {.
    importcpp: "std::unique_ptr<PoDoFo::PdfActionURI>", header: "<memory>"
  .} = object

  UniquePtrPdfActionJavaScript* {.
    importcpp: "std::unique_ptr<PoDoFo::PdfActionJavaScript>", header: "<memory>"
  .} = object

proc createAction*(
  doc: ptr PdfMemDocumentObj, actionType: PdfActionType
): UniquePtrPdfAction {.importcpp: "#->CreateAction(@)".}

proc createActionURI*(
  doc: ptr PdfMemDocumentObj
): UniquePtrPdfActionURI {.importcpp: "#->CreateAction<PoDoFo::PdfActionURI>()".}

proc createActionJavaScript*(
  doc: ptr PdfMemDocumentObj
): UniquePtrPdfActionJavaScript {.
  importcpp: "#->CreateAction<PoDoFo::PdfActionJavaScript>()"
.}

proc getActionPtr*(p: UniquePtrPdfAction): ptr PdfActionObj {.importcpp: "#.get()".}
proc releaseAction*(
  p: var UniquePtrPdfAction
): ptr PdfActionObj {.importcpp: "#.release()".}

proc getActionURIPtr*(
  p: UniquePtrPdfActionURI
): ptr PdfActionURIObj {.importcpp: "#.get()".}

proc releaseActionURI*(
  p: var UniquePtrPdfActionURI
): ptr PdfActionURIObj {.importcpp: "#.release()".}

proc getActionJavaScriptPtr*(
  p: UniquePtrPdfActionJavaScript
): ptr PdfActionJavaScriptObj {.importcpp: "#.get()".}

proc releaseActionJavaScript*(
  p: var UniquePtrPdfActionJavaScript
): ptr PdfActionJavaScriptObj {.importcpp: "#.release()".}

proc deleteAction*(action: ptr PdfActionObj) {.importcpp: "delete #".}
proc deleteActionURI*(action: ptr PdfActionURIObj) {.importcpp: "delete #".}
proc deleteActionJavaScript*(
  action: ptr PdfActionJavaScriptObj
) {.importcpp: "delete #".}

proc getActionType*(
  action: ptr PdfActionObj
): PdfActionType {.importcpp: "#->GetType()".}

# URI Action methods - PoDoFo 1.0.x uses nullable<const PdfString&>
# Pass PdfString directly - C++ will implicitly convert to nullable<const PdfString&>
proc setURI*(
  action: ptr PdfActionURIObj, uri: PdfStringObj
) {.importcpp: "#->SetURI(@)".}

proc getURINullable*(
  action: ptr PdfActionURIObj
): NullablePdfStringRef {.importcpp: "#->GetURI()".}

# JavaScript Action methods - PoDoFo 1.0.x uses nullable<const PdfString&>
proc setScript*(
  action: ptr PdfActionJavaScriptObj, script: PdfStringObj
) {.importcpp: "#->SetScript(@)".}

proc getScriptNullable*(
  action: ptr PdfActionJavaScriptObj
): NullablePdfStringRef {.importcpp: "#->GetScript()".}

# PdfAnnotation - Annotations on pages

proc getAnnotations*(
  page: ptr PdfPageObj
): ptr PdfAnnotationCollectionObj {.importcpp: "(&(#->GetAnnotations()))".}

proc getAnnotationCount*(
  coll: ptr PdfAnnotationCollectionObj
): cuint {.importcpp: "#->GetCount()".}

proc getAnnotationAt*(
  coll: ptr PdfAnnotationCollectionObj, index: cuint
): ptr PdfAnnotationObj {.importcpp: "(&(#->GetAnnotAt(@)))".}

proc removeAnnotationAt*(
  coll: ptr PdfAnnotationCollectionObj, index: cuint
) {.importcpp: "#->RemoveAnnotAt(@)".}

proc createAnnotationLink*(
  coll: ptr PdfAnnotationCollectionObj, rect: PodofoRect
): ptr PdfAnnotationLinkObj {.
  importcpp: "(&(#->CreateAnnot<PoDoFo::PdfAnnotationLink>(@)))"
.}

proc createAnnotationText*(
  coll: ptr PdfAnnotationCollectionObj, rect: PodofoRect
): ptr PdfAnnotationTextObj {.
  importcpp: "(&(#->CreateAnnot<PoDoFo::PdfAnnotationText>(@)))"
.}

proc createAnnotationWidget*(
  coll: ptr PdfAnnotationCollectionObj, rect: PodofoRect
): ptr PdfAnnotationWidgetObj {.
  importcpp: "(&(#->CreateAnnot<PoDoFo::PdfAnnotationWidget>(@)))"
.}

# Base PdfAnnotation methods
proc getAnnotationType*(
  annot: ptr PdfAnnotationObj
): PdfAnnotationType {.importcpp: "#->GetType()".}

proc getAnnotationRect*(
  annot: ptr PdfAnnotationObj
): PodofoRect {.importcpp: "#->GetRect()".}

proc setAnnotationRect*(
  annot: ptr PdfAnnotationObj, rect: PodofoRect
) {.importcpp: "#->SetRect(@)".}

proc getAnnotationFlags*(
  annot: ptr PdfAnnotationObj
): PdfAnnotationFlags {.importcpp: "#->GetFlags()".}

proc setAnnotationFlags*(
  annot: ptr PdfAnnotationObj, flags: PdfAnnotationFlags
) {.importcpp: "#->SetFlags(@)".}

proc setAnnotationTitle*(
  annot: ptr PdfAnnotationObj, title: PdfStringObj
) {.importcpp: "#->SetTitle(@)".}

proc getAnnotationTitle*(
  annot: ptr PdfAnnotationObj
): NullablePdfStringRef {.importcpp: "#->GetTitle()".}

proc setAnnotationContents*(
  annot: ptr PdfAnnotationObj, contents: PdfStringObj
) {.importcpp: "#->SetContents(@)".}

proc getAnnotationContents*(
  annot: ptr PdfAnnotationObj
): NullablePdfStringRef {.importcpp: "#->GetContents()".}

proc setAnnotationColor*(
  annot: ptr PdfAnnotationObj, color: PdfColorObj
) {.importcpp: "#->SetColor(@)".}

proc getAnnotationColor*(
  annot: ptr PdfAnnotationObj
): PdfColorObj {.importcpp: "#->GetColor()".}

proc setBorderStyle*(
  annot: ptr PdfAnnotationObj, hCorner, vCorner, width: cdouble
) {.importcpp: "#->SetBorderStyle(@)".}

proc setAppearanceStreamAnnot*(
  annot: ptr PdfAnnotationObj,
  xobj: ptr PdfXObjectFormObj,
  appearance: PdfAppearanceType = PdfAppearanceType.Normal,
) {.importcpp: "#->SetAppearanceStream(*#, @)".}

# PdfAnnotationLink specific
# PoDoFo 1.0.x uses nullable<const PdfDestination&> instead of shared_ptr
proc initNullableDestinationRef*(
  dest: ptr PdfDestinationObj
): NullablePdfDestinationRef {.
  importcpp: "PoDoFo::nullable<const PoDoFo::PdfDestination&>(*#)"
.}

proc setDestinationLink*(
  link: ptr PdfAnnotationLinkObj, dest: NullablePdfDestinationRef
) {.importcpp: "#->SetDestination(@)".}

# PdfXObjectForm - Reusable content

proc getXObjectFormRect*(
  xobj: ptr PdfXObjectFormObj
): PodofoRect {.importcpp: "#->GetRect()".}

proc setXObjectFormRect*(
  xobj: ptr PdfXObjectFormObj, rect: PodofoRect
) {.importcpp: "#->SetRect(@)".}

# PdfIndirectObjectList - Object creation and management

proc getObjects*(
  doc: ptr PdfMemDocumentObj
): ptr PdfIndirectObjectListObj {.importcpp: "(&(#->GetObjects()))".}

proc createDictionaryObject*(
  objects: ptr PdfIndirectObjectListObj
): ptr PdfObjectObj {.importcpp: "(&(#->CreateDictionaryObject()))".}

proc createDictionaryObjectWithType*(
  objects: ptr PdfIndirectObjectListObj, typeName: StdStringView
): ptr PdfObjectObj {.importcpp: "(&(#->CreateDictionaryObject(@)))".}

proc createDictionaryObjectWithTypeAndSubtype*(
  objects: ptr PdfIndirectObjectListObj, typeName: StdStringView, subtype: StdStringView
): ptr PdfObjectObj {.importcpp: "(&(#->CreateDictionaryObject(@)))".}

proc createArrayObject*(
  objects: ptr PdfIndirectObjectListObj
): ptr PdfObjectObj {.importcpp: "(&(#->CreateArrayObject()))".}

proc getObjectByRef*(
  objects: ptr PdfIndirectObjectListObj, reference: PdfReferenceObj
): ptr PdfObjectObj {.importcpp: "#->GetObject(@)".}

proc getObjectCount*(
  objects: ptr PdfIndirectObjectListObj
): csize_t {.importcpp: "#->GetObjectCount()".}

# PdfObject - Core PDF object type

proc getDictionary*(
  obj: ptr PdfObjectObj
): ptr PdfDictionaryObj {.importcpp: "(&(#->GetDictionary()))".}

proc getArray*(
  obj: ptr PdfObjectObj
): ptr PdfArrayObj {.importcpp: "(&(#->GetArray()))".}

proc getReference*(
  obj: ptr PdfObjectObj
): PdfReferenceObj {.importcpp: "#->GetIndirectReference()".}

proc hasStream*(obj: ptr PdfObjectObj): bool {.importcpp: "#->HasStream()".}
proc getOrCreateStream*(
  obj: ptr PdfObjectObj
): ptr PdfObjectStreamObj {.importcpp: "(&(#->GetOrCreateStream()))".}

proc mustGetStream*(
  obj: ptr PdfObjectObj
): ptr PdfObjectStreamObj {.importcpp: "(&(#->MustGetStream()))".}

proc isDictionary*(obj: ptr PdfObjectObj): bool {.importcpp: "#->IsDictionary()".}
proc isArray*(obj: ptr PdfObjectObj): bool {.importcpp: "#->IsArray()".}
proc isReference*(obj: ptr PdfObjectObj): bool {.importcpp: "#->IsReference()".}
proc isString*(obj: ptr PdfObjectObj): bool {.importcpp: "#->IsString()".}
proc isName*(obj: ptr PdfObjectObj): bool {.importcpp: "#->IsName()".}
proc isNumber*(obj: ptr PdfObjectObj): bool {.importcpp: "#->IsNumber()".}
proc isReal*(obj: ptr PdfObjectObj): bool {.importcpp: "#->IsRealStrict()".}
proc isBool*(obj: ptr PdfObjectObj): bool {.importcpp: "#->IsBool()".}
proc isNull*(obj: ptr PdfObjectObj): bool {.importcpp: "#->IsNull()".}

# PdfDictionary - Dictionary operations

proc addKey*(
  dict: ptr PdfDictionaryObj, key: PdfNameObj, value: PdfObjectObj
) {.importcpp: "#->AddKey(@)".}

proc addKeyIndirect*(
  dict: ptr PdfDictionaryObj, key: PdfNameObj, value: ptr PdfObjectObj
) {.importcpp: "#->AddKeyIndirect(#, *#)".}

proc hasKey*(
  dict: ptr PdfDictionaryObj, key: PdfNameObj
): bool {.importcpp: "#->HasKey(@)".}

proc getKey*(
  dict: ptr PdfDictionaryObj, key: PdfNameObj
): ptr PdfObjectObj {.importcpp: "#->GetKey(@)".}

proc findKey*(
  dict: ptr PdfDictionaryObj, key: PdfNameObj
): ptr PdfObjectObj {.importcpp: "#->FindKey(@)".}

proc removeKey*(
  dict: ptr PdfDictionaryObj, key: PdfNameObj
) {.importcpp: "#->RemoveKey(@)".}

# PdfDictionary - Type-specific AddKey overloads for Params dictionary
proc addKeyInt*(
  dict: ptr PdfDictionaryObj, key: PdfNameObj, value: int64
) {.importcpp: "#->AddKey(#, PoDoFo::PdfObject(static_cast<int64_t>(#)))".}

proc addKeyDate*(
  dict: ptr PdfDictionaryObj, key: PdfNameObj, value: PdfDateObj
) {.importcpp: "#->AddKey(#, PoDoFo::PdfObject(PoDoFo::PdfString(#.ToString())))".}

proc addKeyString*(
  dict: ptr PdfDictionaryObj, key: PdfNameObj, value: PdfStringObj
) {.importcpp: "#->AddKey(#, PoDoFo::PdfObject(#))".}

proc addKeyName*(
  dict: ptr PdfDictionaryObj, key: PdfNameObj, value: PdfNameObj
) {.importcpp: "#->AddKey(#, PoDoFo::PdfObject(#))".}

proc addKeyRef*(
  dict: ptr PdfDictionaryObj, key: PdfNameObj, value: PdfReferenceObj
) {.importcpp: "#->AddKey(#, PoDoFo::PdfObject(#))".}

proc addKeyDict*(
  dict: ptr PdfDictionaryObj, key: PdfNameObj, value: PdfDictionaryObj
) {.importcpp: "#->AddKey(#, PoDoFo::PdfObject(#))".}

# GetOrAddKey for creating nested dictionaries
proc getOrCreateKeyDict*(
  dict: ptr PdfDictionaryObj, key: PdfNameObj
): ptr PdfDictionaryObj {.importcpp: "(&(#->GetOrAddKey(@).GetDictionary()))".}

# PdfObjectStream - Stream data operations

proc setStreamData*(
  stream: ptr PdfObjectStreamObj, data: cstring, size: csize_t
) {.importcpp: "#->SetData(PoDoFo::bufferview((const char*)#, #))".}

proc setStreamDataRaw*(
  stream: ptr PdfObjectStreamObj, data: cstring, size: csize_t
) {.importcpp: "#->SetData(PoDoFo::bufferview((const char*)#, #), true)".}

proc getStreamLength*(
  stream: ptr PdfObjectStreamObj
): csize_t {.importcpp: "#->GetLength()".}

# PdfReference - Object reference

proc initPdfReference*(
  objNum: cuint, genNum: cushort
): PdfReferenceObj {.importcpp: "PoDoFo::PdfReference(@)".}

proc getObjectNumber*(
  reference: PdfReferenceObj
): cuint {.importcpp: "#.ObjectNumber()".}

proc getGenerationNumber*(
  reference: PdfReferenceObj
): cushort {.importcpp: "#.GenerationNumber()".}

# Catalog access

proc getCatalog*(
  doc: ptr PdfMemDocumentObj
): ptr PdfCatalogObj {.importcpp: "(&(#->GetCatalog()))".}

proc getCatalogObject*(
  catalog: ptr PdfCatalogObj
): ptr PdfObjectObj {.importcpp: "(&(#->GetObject()))".}

proc getCatalogDictionary*(
  catalog: ptr PdfCatalogObj
): ptr PdfDictionaryObj {.importcpp: "(&(#->GetDictionary()))".}

# PdfMemDocument - PDF Version
proc getPdfVersion*(
  doc: ptr PdfMemDocumentObj
): PdfVersion {.importcpp: "#->GetPdfVersion()".}

proc setPdfVersion*(
  doc: ptr PdfMemDocumentObj, version: PdfVersion
) {.importcpp: "#->SetPdfVersion(@)".}

proc getFileSpecObject*(
  fileSpec: ptr PdfFileSpecObj
): ptr PdfObjectObj {.importcpp: "(&(#->GetObject()))".}

proc getFileSpecDictionary*(
  fileSpec: ptr PdfFileSpecObj
): ptr PdfDictionaryObj {.importcpp: "(&(#->GetDictionary()))".}

# PdfMetadata - XMP metadata

proc syncXMPMetadata*(
  meta: ptr PdfMetadataObj, resetXMPPacket: bool = false
) {.importcpp: "#->SyncXMPMetadata(@)".}

proc trySyncXMPMetadata*(
  meta: ptr PdfMetadataObj
) {.importcpp: "#->TrySyncXMPMetadata()".}

# PdfMetadata - PDF/A Level
proc getPdfALevel*(
  meta: ptr PdfMetadataObj
): PdfALevel {.importcpp: "#->GetPdfALevel()".}

proc setPdfALevel*(
  meta: ptr PdfMetadataObj, level: PdfALevel
) {.importcpp: "#->SetPdfALevel(@)".}

{.pop.}
