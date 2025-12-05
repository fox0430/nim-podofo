# Nim bindings for the PoDoFo

import std/os

import lowlevel/raw

export PdfPageSize, PdfPathDrawMode, PdfPainterFlags, PdfSaveOptions
export PdfLineCapStyle, PdfLineJoinStyle, PdfHorizontalAlignment, PdfVerticalAlignment
export PdfColorSpaceType, PdfStandard14FontType, PdfTextRenderingMode, PdfStrokeStyle
export PdfBlendMode, PdfDestinationFit, PdfAnnotationType, PdfAcroFormDefaulAppearance
export
  PdfFieldType, PdfActionType, PdfAnnotationFlags, PdfAppearanceType, PdfCertPermission
export PdfVersion, PdfALevel
export PdfObjectObj, PdfDictionaryObj, PdfArrayObj, PdfObjectStreamObj, PdfReferenceObj
export PdfIndirectObjectListObj
export PdfErrorCode

# PdfError - Exception type for PoDoFo errors

type PdfError* = object of CatchableError
  ## Exception raised when a PoDoFo operation fails
  code*: PdfErrorCode

proc newPdfError*(code: PdfErrorCode, msg: string): ref PdfError =
  ## Create a new PdfError exception
  result = newException(PdfError, msg)
  result.code = code

proc newPdfError*(msg: string): ref PdfError =
  ## Create a new PdfError exception with Unknown code
  result = newException(PdfError, msg)
  result.code = PdfErrorCode.Unknown

# Rect - Rectangle type for page dimensions

type Rect* = object
  x*, y*, width*, height*: float64

proc rect*(x, y, width, height: float64): Rect =
  Rect(x: x, y: y, width: width, height: height)

proc left*(r: Rect): float64 =
  r.x

proc bottom*(r: Rect): float64 =
  r.y

proc right*(r: Rect): float64 =
  r.x + r.width

proc top*(r: Rect): float64 =
  r.y + r.height

proc toPoDoFo(r: Rect): PodofoRect =
  initRect(r.x, r.y, r.width, r.height)

proc fromPoDoFo(r: PodofoRect): Rect =
  rect(r.X, r.Y, r.Width, r.Height)

proc standardPageSize*(size: PdfPageSize, landscape: bool = false): Rect =
  ## Get standard page size dimensions
  fromPoDoFo(createStandardPageSize(size, landscape))

# Color - PDF color representation

type Color* = object
  case kind*: PdfColorSpaceType
  of PdfColorSpaceType.DeviceGray:
    gray*: float64
  of PdfColorSpaceType.DeviceRGB:
    r*, g*, b*: float64
  of PdfColorSpaceType.DeviceCMYK:
    c*, m*, y*, k*: float64
  else:
    discard

proc grayColor*(gray: float64): Color =
  ## Create a grayscale color (0.0 = black, 1.0 = white)
  Color(kind: PdfColorSpaceType.DeviceGray, gray: gray)

proc rgbColor*(r, g, b: float64): Color =
  ## Create an RGB color (values 0.0-1.0)
  Color(kind: PdfColorSpaceType.DeviceRGB, r: r, g: g, b: b)

proc cmykColor*(c, m, y, k: float64): Color =
  ## Create a CMYK color (values 0.0-1.0)
  Color(kind: PdfColorSpaceType.DeviceCMYK, c: c, m: m, y: y, k: k)

proc black*(): Color =
  grayColor(0.0)

proc white*(): Color =
  grayColor(1.0)

proc red*(): Color =
  rgbColor(1.0, 0.0, 0.0)

proc green*(): Color =
  rgbColor(0.0, 1.0, 0.0)

proc blue*(): Color =
  rgbColor(0.0, 0.0, 1.0)

proc yellow*(): Color =
  rgbColor(1.0, 1.0, 0.0)

proc cyan*(): Color =
  rgbColor(0.0, 1.0, 1.0)

proc magenta*(): Color =
  rgbColor(1.0, 0.0, 1.0)

proc toPoDoFo(c: Color): PdfColorObj =
  case c.kind
  of PdfColorSpaceType.DeviceGray:
    initPdfColorGray(c.gray)
  of PdfColorSpaceType.DeviceRGB:
    initPdfColorRGB(c.r, c.g, c.b)
  of PdfColorSpaceType.DeviceCMYK:
    initPdfColorCMYK(c.c, c.m, c.y, c.k)
  else:
    initPdfColorGray(0.0)

proc toGray*(c: Color): Color =
  ## Convert color to grayscale
  let pdfColor = c.toPoDoFo()
  let gray = pdfColor.convertToGrayScale()
  grayColor(gray.getGrayScale())

proc toRGB*(c: Color): Color =
  ## Convert color to RGB
  let pdfColor = c.toPoDoFo()
  let rgb = pdfColor.convertToRGB()
  rgbColor(rgb.getRed(), rgb.getGreen(), rgb.getBlue())

proc toCMYK*(c: Color): Color =
  ## Convert color to CMYK
  let pdfColor = c.toPoDoFo()
  let cmyk = pdfColor.convertToCMYK()
  cmykColor(cmyk.getCyan(), cmyk.getMagenta(), cmyk.getYellow(), cmyk.getBlack())

# PdfDocument - Main document class

type
  PdfDocumentObj = object
    impl: ptr PdfMemDocumentObj

  PdfDocument* = ref PdfDocumentObj

proc `=destroy`(doc: PdfDocumentObj) =
  if doc.impl != nil:
    deletePdfMemDocument(doc.impl)

proc newPdfDocument*(): PdfDocument =
  ## Create a new empty PDF document
  result = PdfDocument()
  result.impl = newPdfMemDocument()

proc loadPdf*(filename: string, password: string = ""): PdfDocument =
  ## Load a PDF document from file
  ## Raises PdfError if file doesn't exist or is not a valid PDF
  if not fileExists(filename):
    raise newPdfError(PdfErrorCode.FileNotFound, "File not found: " & filename)
  result = newPdfDocument()
  try:
    result.impl.load(
      initStdStringView(filename.cstring, filename.len.csize_t),
      initStdStringView(password.cstring, password.len.csize_t),
    )
  except CatchableError as e:
    raise newPdfError("Failed to load PDF: " & e.msg)

proc save*(
    doc: PdfDocument, filename: string, opts: PdfSaveOptions = PdfSaveOptions.None
) =
  ## Save the PDF document to file
  ## Raises PdfError on I/O errors
  if doc.impl == nil:
    raise newPdfError(PdfErrorCode.InvalidHandle, "Document is nil")
  let dir = parentDir(filename)
  if dir.len > 0 and not dirExists(dir):
    raise newPdfError(PdfErrorCode.FileNotFound, "Directory does not exist: " & dir)
  try:
    doc.impl.save(initStdStringView(filename.cstring, filename.len.csize_t), opts)
  except CatchableError as e:
    raise newPdfError("Failed to save PDF: " & e.msg)

proc pageCount*(doc: PdfDocument): int =
  ## Get the number of pages in the document
  doc.impl.getPages().getCount().int

proc isEncrypted*(doc: PdfDocument): bool =
  ## Check if the document is encrypted
  doc.impl.isEncrypted()

proc collectGarbage*(doc: PdfDocument) =
  ## Remove unused objects from the document
  doc.impl.collectGarbage()

proc isPrintAllowed*(doc: PdfDocument): bool =
  doc.impl.isPrintAllowed()

proc isEditAllowed*(doc: PdfDocument): bool =
  doc.impl.isEditAllowed()

proc isCopyAllowed*(doc: PdfDocument): bool =
  doc.impl.isCopyAllowed()

proc isEditNotesAllowed*(doc: PdfDocument): bool =
  doc.impl.isEditNotesAllowed()

proc isFillAndSignAllowed*(doc: PdfDocument): bool =
  doc.impl.isFillAndSignAllowed()

proc isHighPrintAllowed*(doc: PdfDocument): bool =
  doc.impl.isHighPrintAllowed()

proc appendPages*(doc: PdfDocument, srcDoc: PdfDocument) =
  ## Append all pages from another document
  doc.impl.appendDocumentPages(srcDoc.impl)

proc pdfVersion*(doc: PdfDocument): PdfVersion =
  ## Get the PDF version of the document
  doc.impl.getPdfVersion()

proc `pdfVersion=`*(doc: PdfDocument, version: PdfVersion) =
  ## Set the PDF version of the document
  doc.impl.setPdfVersion(version)

# PdfPage - Page manipulation

type PdfPage* = object
  impl: ptr PdfPageObj
  doc: PdfDocument # Keep reference to document

proc getPage*(doc: PdfDocument, index: int): PdfPage =
  ## Get a page by index (0-based)
  ## Raises PdfError if index is out of bounds
  if index < 0 or index >= doc.pageCount:
    raise newPdfError(
      PdfErrorCode.PageNotFound,
      "Page index out of bounds: " & $index & " (document has " & $doc.pageCount &
        " pages)",
    )
  PdfPage(impl: doc.impl.getPages().getPageAt(index.cuint), doc: doc)

proc createPage*(doc: PdfDocument, size: Rect): PdfPage =
  ## Create a new page with the specified size
  PdfPage(impl: doc.impl.getPages().createPage(size.toPoDoFo()), doc: doc)

proc createPage*(
    doc: PdfDocument, size: PdfPageSize, landscape: bool = false
): PdfPage =
  ## Create a new page with a standard page size
  doc.createPage(standardPageSize(size, landscape))

proc createPageAt*(doc: PdfDocument, index: int, size: Rect): PdfPage =
  ## Create a new page at the specified index
  PdfPage(
    impl: doc.impl.getPages().createPageAt(index.cuint, size.toPoDoFo()), doc: doc
  )

proc removePage*(doc: PdfDocument, index: int) =
  ## Remove a page by index
  ## Raises PdfError if index is out of bounds
  if index < 0 or index >= doc.pageCount:
    raise newPdfError(
      PdfErrorCode.PageNotFound,
      "Page index out of bounds: " & $index & " (document has " & $doc.pageCount &
        " pages)",
    )
  doc.impl.getPages().removePageAt(index.cuint)

proc rect*(page: PdfPage): Rect =
  fromPoDoFo(page.impl.getRect())

proc `rect=`*(page: var PdfPage, r: Rect) =
  page.impl.setRect(r.toPoDoFo())

proc pageNumber*(page: PdfPage): int =
  page.impl.getPageNumber().int

proc index*(page: PdfPage): int =
  page.impl.getIndex().int

proc rotation*(page: PdfPage): int =
  page.impl.getRotationRaw()

proc `rotation=`*(page: var PdfPage, rot: int) =
  page.impl.setRotationRaw(rot.cint)

proc moveTo*(page: var PdfPage, index: int) =
  ## Move the page to a different position
  page.impl.moveAt(index.cuint)

# Page boxes
proc mediaBox*(page: PdfPage): Rect =
  fromPoDoFo(page.impl.getMediaBox())

proc `mediaBox=`*(page: var PdfPage, r: Rect) =
  page.impl.setMediaBox(r.toPoDoFo())

proc cropBox*(page: PdfPage): Rect =
  fromPoDoFo(page.impl.getCropBox())

proc `cropBox=`*(page: var PdfPage, r: Rect) =
  page.impl.setCropBox(r.toPoDoFo())

proc trimBox*(page: PdfPage): Rect =
  fromPoDoFo(page.impl.getTrimBox())

proc `trimBox=`*(page: var PdfPage, r: Rect) =
  page.impl.setTrimBox(r.toPoDoFo())

proc bleedBox*(page: PdfPage): Rect =
  fromPoDoFo(page.impl.getBleedBox())

proc `bleedBox=`*(page: var PdfPage, r: Rect) =
  page.impl.setBleedBox(r.toPoDoFo())

proc artBox*(page: PdfPage): Rect =
  fromPoDoFo(page.impl.getArtBox())

proc `artBox=`*(page: var PdfPage, r: Rect) =
  page.impl.setArtBox(r.toPoDoFo())

# PdfFont - Font handling

type PdfFont* = object
  impl: ptr PdfFontObj
  doc: PdfDocument

proc getFont*(doc: PdfDocument, fontPath: string): PdfFont =
  ## Load a font from file
  ## Raises PdfError if font file doesn't exist
  if not fileExists(fontPath):
    raise newPdfError(PdfErrorCode.FileNotFound, "Font file not found: " & fontPath)
  try:
    result = PdfFont(
      impl: doc.impl.getFonts().getOrCreateFont(
          initStdStringView(fontPath.cstring, fontPath.len.csize_t)
        ),
      doc: doc,
    )
  except CatchableError as e:
    raise newPdfError(PdfErrorCode.InvalidFontData, "Failed to load font: " & e.msg)

proc searchFont*(doc: PdfDocument, fontPattern: string): PdfFont =
  ## Search for a font by name pattern
  ## Raises PdfError if no matching font is found
  let fontImpl = doc.impl.getFonts().searchFont(
      initStdStringView(fontPattern.cstring, fontPattern.len.csize_t)
    )
  if fontImpl == nil:
    raise newPdfError(PdfErrorCode.InvalidFontData, "Font not found: " & fontPattern)
  PdfFont(impl: fontImpl, doc: doc)

proc getStandard14Font*(doc: PdfDocument, fontType: PdfStandard14FontType): PdfFont =
  ## Get a standard PDF font by type
  PdfFont(impl: doc.impl.getFonts().getStandard14Font(fontType), doc: doc)

proc helvetica*(doc: PdfDocument): PdfFont =
  doc.getStandard14Font(PdfStandard14FontType.Helvetica)

proc helveticaBold*(doc: PdfDocument): PdfFont =
  doc.getStandard14Font(PdfStandard14FontType.HelveticaBold)

proc helveticaOblique*(doc: PdfDocument): PdfFont =
  doc.getStandard14Font(PdfStandard14FontType.HelveticaOblique)

proc helveticaBoldOblique*(doc: PdfDocument): PdfFont =
  doc.getStandard14Font(PdfStandard14FontType.HelveticaBoldOblique)

proc timesRoman*(doc: PdfDocument): PdfFont =
  doc.getStandard14Font(PdfStandard14FontType.TimesRoman)

proc timesBold*(doc: PdfDocument): PdfFont =
  doc.getStandard14Font(PdfStandard14FontType.TimesBold)

proc timesItalic*(doc: PdfDocument): PdfFont =
  doc.getStandard14Font(PdfStandard14FontType.TimesItalic)

proc timesBoldItalic*(doc: PdfDocument): PdfFont =
  doc.getStandard14Font(PdfStandard14FontType.TimesBoldItalic)

proc courier*(doc: PdfDocument): PdfFont =
  doc.getStandard14Font(PdfStandard14FontType.Courier)

proc courierBold*(doc: PdfDocument): PdfFont =
  doc.getStandard14Font(PdfStandard14FontType.CourierBold)

proc courierOblique*(doc: PdfDocument): PdfFont =
  doc.getStandard14Font(PdfStandard14FontType.CourierOblique)

proc courierBoldOblique*(doc: PdfDocument): PdfFont =
  doc.getStandard14Font(PdfStandard14FontType.CourierBoldOblique)

proc symbol*(doc: PdfDocument): PdfFont =
  doc.getStandard14Font(PdfStandard14FontType.Symbol)

proc zapfDingbats*(doc: PdfDocument): PdfFont =
  doc.getStandard14Font(PdfStandard14FontType.ZapfDingbats)

proc name*(font: PdfFont): string =
  $font.impl.getName()

proc isStandard14*(font: PdfFont): bool =
  font.impl.isStandard14Font()

proc isCIDKeyed*(font: PdfFont): bool =
  font.impl.isCIDKeyed()

proc stringLength*(font: PdfFont, text: string, fontSize: float64): float64 =
  ## Get the width of a string in the given font and size
  let state = initPdfTextState(font.impl, fontSize)
  font.impl.getStringLength(initStdStringView(text.cstring, text.len.csize_t), state)

proc lineSpacing*(font: PdfFont, fontSize: float64): float64 =
  ## Get the line spacing for the font at the given size
  let state = initPdfTextState(font.impl, fontSize)
  font.impl.getLineSpacing(state)

proc ascent*(font: PdfFont, fontSize: float64): float64 =
  ## Get the ascent (height above baseline) for the font
  let state = initPdfTextState(font.impl, fontSize)
  font.impl.getAscent(state)

proc descent*(font: PdfFont, fontSize: float64): float64 =
  ## Get the descent (depth below baseline) for the font
  let state = initPdfTextState(font.impl, fontSize)
  font.impl.getDescent(state)

proc underlineThickness*(font: PdfFont, fontSize: float64): float64 =
  let state = initPdfTextState(font.impl, fontSize)
  font.impl.getUnderlineThickness(state)

proc underlinePosition*(font: PdfFont, fontSize: float64): float64 =
  let state = initPdfTextState(font.impl, fontSize)
  font.impl.getUnderlinePosition(state)

proc strikeThroughThickness*(font: PdfFont, fontSize: float64): float64 =
  let state = initPdfTextState(font.impl, fontSize)
  font.impl.getStrikeThroughThickness(state)

proc strikeThroughPosition*(font: PdfFont, fontSize: float64): float64 =
  let state = initPdfTextState(font.impl, fontSize)
  font.impl.getStrikeThroughPosition(state)

proc embedFonts*(doc: PdfDocument) =
  ## Embed all fonts used in the document
  doc.impl.getFonts().embedFonts()

# PdfImage - Image handling

type
  PdfImageInner = object
    impl: ptr PdfImageObj
    doc: PdfDocument

  PdfImage* = ref PdfImageInner

proc `=destroy`(img: PdfImageInner) =
  if img.impl != nil:
    deletePdfImage(img.impl)

proc createImage*(doc: PdfDocument): PdfImage =
  ## Create a new image object
  result = PdfImage()
  var imgPtr = doc.impl.createImage()
  result.impl = releaseImage(imgPtr)
  result.doc = doc

proc load*(img: PdfImage, filename: string) =
  ## Load an image from file (supports JPEG, PNG, TIFF, etc.)
  ## Raises PdfError if file doesn't exist or has unsupported format
  if img == nil or img.impl == nil:
    raise newPdfError(PdfErrorCode.InvalidHandle, "Image object is nil")
  if not fileExists(filename):
    raise newPdfError(PdfErrorCode.FileNotFound, "Image file not found: " & filename)
  try:
    img.impl.load(initStdStringView(filename.cstring, filename.len.csize_t))
  except CatchableError as e:
    raise
      newPdfError(PdfErrorCode.UnsupportedImageFormat, "Failed to load image: " & e.msg)

proc loadFromBuffer*(img: PdfImage, data: openArray[byte]) =
  ## Load an image from memory buffer
  ## Raises PdfError if image object is nil
  if img == nil or img.impl == nil:
    raise newPdfError(PdfErrorCode.InvalidHandle, "Image object is nil")
  if data.len > 0:
    img.impl.loadFromBuffer(cast[cstring](unsafeAddr data[0]), data.len.csize_t)

proc width*(img: PdfImage): int =
  img.impl.getWidth().int

proc height*(img: PdfImage): int =
  img.impl.getHeight().int

proc setInterpolate*(img: PdfImage, value: bool) =
  ## Enable/disable image interpolation
  img.impl.setInterpolate(value)

proc setChromaKeyMask*(img: PdfImage, r, g, b: int, threshold: int = 0) =
  ## Set a chroma key (transparency) mask
  img.impl.setChromaKeyMask(r.int64, g.int64, b.int64, threshold.int64)

# PdfPainterPath - Vector path for complex shapes

type
  PdfPainterPathInner = object
    impl: ptr PdfPainterPathObj

  PdfPainterPath* = ref PdfPainterPathInner

proc `=destroy`(path: PdfPainterPathInner) =
  if path.impl != nil:
    deletePdfPainterPath(path.impl)

proc newPainterPath*(): PdfPainterPath =
  ## Create a new vector path
  result = PdfPainterPath()
  result.impl = createPdfPainterPath()

proc moveTo*(path: PdfPainterPath, x, y: float64) =
  ## Move to a point without drawing
  path.impl.moveTo(x, y)

proc lineTo*(path: PdfPainterPath, x, y: float64) =
  ## Draw a line to the specified point
  path.impl.lineTo(x, y)

proc cubicBezierTo*(path: PdfPainterPath, x1, y1, x2, y2, x3, y3: float64) =
  ## Draw a cubic Bezier curve
  path.impl.cubicBezierTo(x1, y1, x2, y2, x3, y3)

proc addArc*(
    path: PdfPainterPath,
    x, y, radius, startAngle, endAngle: float64,
    clockwise: bool = false,
) =
  ## Add an arc to the path
  path.impl.addArc(x, y, radius, startAngle, endAngle, clockwise)

proc addArcTo*(path: PdfPainterPath, x1, y1, x2, y2, radius: float64) =
  ## Add an arc connecting two points
  path.impl.addArcTo(x1, y1, x2, y2, radius)

proc addCircle*(path: PdfPainterPath, x, y, radius: float64) =
  ## Add a circle to the path
  path.impl.addCircle(x, y, radius)

proc addEllipse*(path: PdfPainterPath, x, y, width, height: float64) =
  ## Add an ellipse to the path
  path.impl.addEllipse(x, y, width, height)

proc addRectangle*(
    path: PdfPainterPath,
    x, y, width, height: float64,
    roundX: float64 = 0,
    roundY: float64 = 0,
) =
  ## Add a rectangle to the path
  path.impl.addRectangle(x, y, width, height, roundX, roundY)

proc close*(path: PdfPainterPath) =
  ## Close the current subpath
  path.impl.closePath()

proc reset*(path: PdfPainterPath) =
  ## Reset the path
  path.impl.reset()

# PdfExtGState - Extended Graphics State (transparency, blend modes)
# PoDoFo 1.0.x uses an immutable definition-based pattern

type
  PdfExtGStateInner = object
    impl: ptr PdfExtGStateObj

  PdfExtGState* = ref PdfExtGStateInner

  PdfExtGStateBuilder* = object ## Builder for creating extended graphics state objects
    fillOpacity: float64
    strokeOpacity: float64
    blendMode: PdfBlendMode
    hasFillOpacity: bool
    hasStrokeOpacity: bool
    hasBlendMode: bool

proc `=destroy`(gs: PdfExtGStateInner) =
  if gs.impl != nil:
    deleteExtGState(gs.impl)

proc newExtGStateBuilder*(): PdfExtGStateBuilder =
  ## Create a new extended graphics state builder
  result = PdfExtGStateBuilder()

proc `fillOpacity=`*(builder: var PdfExtGStateBuilder, opacity: float64) =
  ## Set fill opacity (0.0-1.0)
  builder.fillOpacity = opacity
  builder.hasFillOpacity = true

proc `strokeOpacity=`*(builder: var PdfExtGStateBuilder, opacity: float64) =
  ## Set stroke opacity (0.0-1.0)
  builder.strokeOpacity = opacity
  builder.hasStrokeOpacity = true

proc `blendMode=`*(builder: var PdfExtGStateBuilder, mode: PdfBlendMode) =
  ## Set blend mode
  builder.blendMode = mode
  builder.hasBlendMode = true

proc build*(builder: PdfExtGStateBuilder, doc: PdfDocument): PdfExtGState =
  ## Build the extended graphics state object
  var def = initExtGStateDefinition()
  if builder.hasFillOpacity:
    def.setNonStrokingAlpha(builder.fillOpacity)
  if builder.hasStrokeOpacity:
    def.setStrokingAlpha(builder.strokeOpacity)
  if builder.hasBlendMode:
    def.setBlendModeOnDef(builder.blendMode)
  let defPtr = makeSharedExtGStateDefinition(def)
  var uptr = createExtGState(doc.impl, defPtr)
  result = PdfExtGState()
  result.impl = releaseExtGState(uptr)

proc newExtGState*(
    doc: PdfDocument,
    fillOpacity: float64 = 1.0,
    strokeOpacity: float64 = 1.0,
    blendMode: PdfBlendMode = PdfBlendMode.Normal,
): PdfExtGState =
  ## Create an extended graphics state object with specified properties
  ## Only properties that differ from PDF defaults (1.0, 1.0, Normal) are applied
  var builder = newExtGStateBuilder()
  if fillOpacity != 1.0:
    builder.fillOpacity = fillOpacity
    builder.hasFillOpacity = true
  if strokeOpacity != 1.0:
    builder.strokeOpacity = strokeOpacity
    builder.hasStrokeOpacity = true
  if blendMode != PdfBlendMode.Normal:
    builder.blendMode = blendMode
    builder.hasBlendMode = true
  result = builder.build(doc)

# PdfPainter - Drawing on pages

type
  PdfPainterInner = object
    impl: ptr PdfPainterObj
    currentFont: PdfFont

  PdfPainter* = ref PdfPainterInner

proc `=destroy`(painter: PdfPainterInner) =
  if painter.impl != nil:
    deletePdfPainter(painter.impl)

proc newPdfPainter*(): PdfPainter =
  ## Create a new painter object
  result = PdfPainter()
  result.impl = createPdfPainter()

proc setCanvas*(painter: PdfPainter, page: PdfPage) =
  ## Set the page to draw on
  painter.impl.setCanvas(page.impl)

proc finishDrawing*(painter: PdfPainter) =
  ## Finish drawing and flush to the page
  painter.impl.finishDrawing()

proc save*(painter: PdfPainter) =
  ## Save the current graphics state
  painter.impl.save()

proc restore*(painter: PdfPainter) =
  ## Restore the previous graphics state
  painter.impl.restore()

template withState*(painter: PdfPainter, body: untyped) =
  ## Execute body with saved/restored graphics state
  painter.save()
  try:
    body
  finally:
    painter.restore()

proc setPrecision*(painter: PdfPainter, precision: int) =
  ## Set the numeric precision for PDF output
  painter.impl.setPrecision(precision.cushort)

# Drawing methods
proc drawLine*(painter: PdfPainter, x1, y1, x2, y2: float64) =
  painter.impl.drawLine(x1, y1, x2, y2)

proc drawCubicBezier*(painter: PdfPainter, x1, y1, x2, y2, x3, y3, x4, y4: float64) =
  painter.impl.drawCubicBezier(x1, y1, x2, y2, x3, y3, x4, y4)

proc drawArc*(
    painter: PdfPainter,
    x, y, radius, startAngle, endAngle: float64,
    clockwise: bool = false,
) =
  painter.impl.drawArc(x, y, radius, startAngle, endAngle, clockwise)

proc drawRectangle*(
    painter: PdfPainter,
    x, y, width, height: float64,
    mode: PdfPathDrawMode = PdfPathDrawMode.Stroke,
    roundX: float64 = 0.0,
    roundY: float64 = 0.0,
) =
  painter.impl.drawRectangle(x, y, width, height, mode, roundX, roundY)

proc drawRectangle*(
    painter: PdfPainter,
    r: Rect,
    mode: PdfPathDrawMode = PdfPathDrawMode.Stroke,
    roundX: float64 = 0.0,
    roundY: float64 = 0.0,
) =
  painter.drawRectangle(r.x, r.y, r.width, r.height, mode, roundX, roundY)

proc drawCircle*(
    painter: PdfPainter,
    x, y, radius: float64,
    mode: PdfPathDrawMode = PdfPathDrawMode.Stroke,
) =
  painter.impl.drawCircle(x, y, radius, mode)

proc drawEllipse*(
    painter: PdfPainter,
    x, y, width, height: float64,
    mode: PdfPathDrawMode = PdfPathDrawMode.Stroke,
) =
  painter.impl.drawEllipse(x, y, width, height, mode)

proc drawText*(painter: PdfPainter, text: string, x, y: float64) =
  painter.impl.drawText(initStdStringView(text.cstring, text.len.csize_t), x, y)

proc drawTextMultiLine*(
    painter: PdfPainter,
    text: string,
    x, y, width, height: float64,
    hAlign: PdfHorizontalAlignment = PdfHorizontalAlignment.Left,
    vAlign: PdfVerticalAlignment = PdfVerticalAlignment.Top,
) =
  ## Draw multi-line text in a box
  painter.impl.drawTextMultiLine(
    initStdStringView(text.cstring, text.len.csize_t),
    x,
    y,
    width,
    height,
    hAlign,
    vAlign,
  )

proc drawTextMultiLine*(
    painter: PdfPainter,
    text: string,
    r: Rect,
    hAlign: PdfHorizontalAlignment = PdfHorizontalAlignment.Left,
    vAlign: PdfVerticalAlignment = PdfVerticalAlignment.Top,
) =
  painter.drawTextMultiLine(text, r.x, r.y, r.width, r.height, hAlign, vAlign)

proc drawTextAligned*(
    painter: PdfPainter,
    text: string,
    x, y, width: float64,
    alignment: PdfHorizontalAlignment,
) =
  painter.impl.drawTextAligned(
    initStdStringView(text.cstring, text.len.csize_t), x, y, width, alignment
  )

proc drawImage*(
    painter: PdfPainter,
    img: PdfImage,
    x, y: float64,
    scaleX: float64 = 1.0,
    scaleY: float64 = 1.0,
) =
  painter.impl.drawImage(img.impl, x, y, scaleX, scaleY)

proc drawPath*(
    painter: PdfPainter,
    path: PdfPainterPath,
    mode: PdfPathDrawMode = PdfPathDrawMode.Stroke,
) =
  ## Draw a vector path
  painter.impl.drawPath(path.impl, mode)

proc clipPath*(
    painter: PdfPainter, path: PdfPainterPath, useEvenOddRule: bool = false
) =
  ## Set clipping path
  painter.impl.clipPath(path.impl, useEvenOddRule)

proc setClipRect*(painter: PdfPainter, x, y, width, height: float64) =
  painter.impl.setClipRect(x, y, width, height)

proc setClipRect*(painter: PdfPainter, r: Rect) =
  painter.setClipRect(r.x, r.y, r.width, r.height)

# Text object mode (for precise text positioning)
proc beginText*(painter: PdfPainter) =
  ## Begin a text object for precise positioning
  painter.impl.beginText()

proc endText*(painter: PdfPainter) =
  ## End the text object
  painter.impl.endText()

proc textMoveTo*(painter: PdfPainter, x, y: float64) =
  ## Move text position
  painter.impl.textMoveTo(x, y)

proc addText*(painter: PdfPainter, text: string) =
  ## Add text at current position (use within beginText/endText)
  painter.impl.addText(initStdStringView(text.cstring, text.len.csize_t))

# Marked content (for PDF/A, accessibility)
proc beginMarkedContent*(painter: PdfPainter, tag: string) =
  painter.impl.beginMarkedContent(initStdStringView(tag.cstring, tag.len.csize_t))

proc endMarkedContent*(painter: PdfPainter) =
  painter.impl.endMarkedContent()

# Extended graphics state
proc setExtGState*(painter: PdfPainter, gs: PdfExtGState) =
  ## Apply extended graphics state (transparency, blend mode)
  painter.impl.setExtGState(gs.impl)

# Graphics state methods
proc setLineWidth*(painter: PdfPainter, width: float64) =
  painter.impl.getGraphicsState().setLineWidth(width)

proc setMiterLimit*(painter: PdfPainter, limit: float64) =
  painter.impl.getGraphicsState().setMiterLimit(limit)

proc setFillColor*(painter: PdfPainter, color: Color) =
  ## Set fill color (non-stroking color in PDF terminology)
  painter.impl.setNonStrokingColor(color.toPoDoFo())

proc setStrokeColor*(painter: PdfPainter, color: Color) =
  ## Set stroke color
  painter.impl.setStrokingColor(color.toPoDoFo())

proc setLineCapStyle*(painter: PdfPainter, style: PdfLineCapStyle) =
  painter.impl.getGraphicsState().setLineCapStyle(style)

proc setLineJoinStyle*(painter: PdfPainter, style: PdfLineJoinStyle) =
  painter.impl.getGraphicsState().setLineJoinStyle(style)

# Text state methods
proc setFont*(painter: PdfPainter, font: PdfFont, size: float64) =
  painter.currentFont = font
  painter.impl.getTextState().setFont(font.impl, size)

proc setFontScale*(painter: PdfPainter, scale: float64) =
  painter.impl.getTextState().setFontScale(scale)

proc setCharSpacing*(painter: PdfPainter, spacing: float64) =
  painter.impl.getTextState().setCharSpacing(spacing)

proc setWordSpacing*(painter: PdfPainter, spacing: float64) =
  painter.impl.getTextState().setWordSpacing(spacing)

proc setRenderingMode*(painter: PdfPainter, mode: PdfTextRenderingMode) =
  painter.impl.getTextState().setRenderingMode(mode)

# Convenient page drawing template
template draw*(page: PdfPage, body: untyped) =
  ## Convenient template to draw on a page
  var painter {.inject.} = newPdfPainter()
  painter.setCanvas(page)
  try:
    body
  finally:
    painter.finishDrawing()

# PdfDestination - Navigation destinations

type
  PdfDestinationInner = object
    impl: ptr PdfDestinationObj
    owned: bool

  PdfDestination* = ref PdfDestinationInner

proc `=destroy`(dest: PdfDestinationInner) =
  if dest.owned and dest.impl != nil:
    deleteDestination(dest.impl)

proc newDestination*(
    page: PdfPage, fit: PdfDestinationFit = PdfDestinationFit.Fit
): PdfDestination =
  ## Create a destination to a page
  result = PdfDestination()
  var uniquePtr = createDestination(page.doc.impl)
  result.impl = releaseDestination(uniquePtr)
  result.owned = true
  result.impl.setDestination(page.impl, fit)

proc newDestinationXYZ*(
    page: PdfPage, left, top: float64, zoom: float64 = 0
): PdfDestination =
  ## Create a destination with specific position and zoom
  result = PdfDestination()
  var uniquePtr = createDestination(page.doc.impl)
  result.impl = releaseDestination(uniquePtr)
  result.owned = true
  result.impl.setDestinationXYZ(page.impl, left, top, zoom)

# PdfOutlines - Bookmarks

type
  PdfOutlineItem* = object
    impl: ptr PdfOutlineItemObj

  PdfOutlines* = object
    impl: ptr PdfOutlinesObj
    doc: PdfDocument

proc outlines*(doc: PdfDocument): PdfOutlines =
  ## Get or create the document outlines (bookmarks)
  PdfOutlines(impl: doc.impl.getOrCreateOutlines(), doc: doc)

proc createRoot*(outlines: PdfOutlines, title: string): PdfOutlineItem =
  ## Create a root bookmark
  PdfOutlineItem(
    impl: outlines.impl.createRoot(initStdStringView(title.cstring, title.len.csize_t))
  )

proc createChild*(
    item: PdfOutlineItem, title: string, dest: PdfDestination
): PdfOutlineItem =
  ## Create a child bookmark with a destination
  ## Note: In PoDoFo 1.0.x, we create the item first then set destination separately
  doAssert item.impl != nil, "PdfOutlineItem.impl is nil"
  doAssert dest != nil, "PdfDestination is required for outline items"
  let sv = initStdStringView(title.cstring, title.len.csize_t)
  result = PdfOutlineItem(impl: item.impl.createChild(sv))
  result.impl.setDestination(initNullableDestinationRef(dest.impl))

proc createNext*(
    item: PdfOutlineItem, title: string, dest: PdfDestination
): PdfOutlineItem =
  ## Create a sibling bookmark with a destination
  ## Note: In PoDoFo 1.0.x, we create the item first then set destination separately
  doAssert dest != nil, "PdfDestination is required for outline items"
  let sv = initStdStringView(title.cstring, title.len.csize_t)
  result = PdfOutlineItem(impl: item.impl.createNext(sv))
  result.impl.setDestination(initNullableDestinationRef(dest.impl))

proc title*(item: PdfOutlineItem): string =
  $item.impl.getTitle()

proc setTextFormat*(item: PdfOutlineItem, italic: bool = false, bold: bool = false) =
  ## Set text formatting for the bookmark
  item.impl.setTextFormat(italic, bold)

proc setTextColor*(item: PdfOutlineItem, r, g, b: float64) =
  ## Set text color for the bookmark (using RGB color)
  item.impl.setTextColor(initPdfColorRGB(r, g, b))

proc setDestination*(item: PdfOutlineItem, dest: PdfDestination) =
  ## Set the destination for a bookmark
  item.impl.setDestination(initNullableDestinationRef(dest.impl))

# PdfMetadata - Document metadata handling

type PdfMetadata* = object
  impl: ptr PdfMetadataObj
  doc: PdfDocument

proc metadata*(doc: PdfDocument): PdfMetadata =
  ## Get the document metadata object
  PdfMetadata(impl: doc.impl.getMetadata(), doc: doc)

proc author*(meta: PdfMetadata): string =
  let nullable = meta.impl.getAuthor()
  if nullable.hasValue():
    result = $nullable.getStringOwned()
  else:
    result = ""

proc `author=`*(meta: PdfMetadata, author: string) =
  let str = initPdfString(initStdStringView(author.cstring, author.len.csize_t))
  meta.impl.setAuthor(initNullablePdfStringRef(str))

proc title*(meta: PdfMetadata): string =
  let nullable = meta.impl.getTitle()
  if nullable.hasValue():
    result = $nullable.getStringOwned()
  else:
    result = ""

proc `title=`*(meta: PdfMetadata, title: string) =
  let str = initPdfString(initStdStringView(title.cstring, title.len.csize_t))
  meta.impl.setTitle(initNullablePdfStringRef(str))

proc subject*(meta: PdfMetadata): string =
  let nullable = meta.impl.getSubject()
  if nullable.hasValue():
    result = $nullable.getStringOwned()
  else:
    result = ""

proc `subject=`*(meta: PdfMetadata, subject: string) =
  let str = initPdfString(initStdStringView(subject.cstring, subject.len.csize_t))
  meta.impl.setSubject(initNullablePdfStringRef(str))

proc keywordsRaw*(meta: PdfMetadata): string =
  let nullable = meta.impl.getKeywordsRaw()
  if nullable.hasValue():
    result = $nullable.getStringOwned()
  else:
    result = ""

proc creator*(meta: PdfMetadata): string =
  let nullable = meta.impl.getCreator()
  if nullable.hasValue():
    result = $nullable.getStringOwned()
  else:
    result = ""

proc `creator=`*(meta: PdfMetadata, creator: string) =
  let str = initPdfString(initStdStringView(creator.cstring, creator.len.csize_t))
  meta.impl.setCreator(initNullablePdfStringRef(str))

proc producer*(meta: PdfMetadata): string =
  let nullable = meta.impl.getProducer()
  if nullable.hasValue():
    result = $nullable.getStringOwned()
  else:
    result = ""

proc `producer=`*(meta: PdfMetadata, producer: string) =
  let str = initPdfString(initStdStringView(producer.cstring, producer.len.csize_t))
  meta.impl.setProducer(initNullablePdfStringRef(str))

proc setCreationDateNow*(meta: PdfMetadata) =
  meta.impl.setCreationDate(initNullablePdfDate(initPdfDateNow()))

proc setModifyDateNow*(meta: PdfMetadata) =
  meta.impl.setModifyDate(initNullablePdfDate(initPdfDateNow()))

proc ensureXMPMetadata*(meta: PdfMetadata) =
  ## Ensure XMP metadata is created for PDF/A compliance
  meta.impl.ensureXMPMetadata()

proc pdfALevel*(meta: PdfMetadata): PdfALevel =
  ## Get the PDF/A conformance level
  meta.impl.getPdfALevel()

proc `pdfALevel=`*(meta: PdfMetadata, level: PdfALevel) =
  ## Set the PDF/A conformance level
  meta.impl.setPdfALevel(level)

# Embedded Files - File attachment handling (PoDoFo 1.0.x API)

type
  PdfFileSpecInner = object
    impl: ptr PdfFileSpecObj
    owned: bool

  PdfFileSpec* = ref PdfFileSpecInner

proc `=destroy`(fs: PdfFileSpecInner) =
  if fs.owned and fs.impl != nil:
    deletePdfFileSpec(fs.impl)

proc embedFile*(doc: PdfDocument, name: string, filePath: string): PdfFileSpec =
  ## Embed a file from disk into the PDF with a custom name
  ## Uses PoDoFo 1.0.x API: CreateFileSpec + SetFilename + SetEmbeddedDataFromFile
  result = PdfFileSpec()

  # Create FileSpec using new API
  var uniquePtr = doc.impl.createFileSpec()
  result.impl = releaseFileSpec(uniquePtr)
  result.owned = true

  # Set filename using PdfString
  let filenameStr = initPdfString(initStdStringView(name.cstring, name.len.csize_t))
  result.impl.setFilenameStr(filenameStr)

  # Set embedded data from file
  result.impl.setEmbeddedDataFromFile(
    initStdStringView(filePath.cstring, filePath.len.csize_t)
  )

  # Add to embedded files name tree
  let names = doc.impl.getOrCreateNames()
  let embeddedFiles = names.getOrCreateEmbeddedFiles()
  let keyStr = initPdfString(initStdStringView(name.cstring, name.len.csize_t))
  let sharedPtr = makeSharedFileSpec(result.impl)
  embeddedFiles.addValueToEmbeddedFiles(keyStr, sharedPtr)

  # FileSpec is now owned by the document through shared_ptr
  result.owned = false

proc embedData*(doc: PdfDocument, name: string, data: openArray[byte]): PdfFileSpec =
  ## Embed raw data as a file attachment
  ## Uses PoDoFo 1.0.x API: CreateFileSpec + SetFilename + SetEmbeddedData
  result = PdfFileSpec()

  # Create FileSpec using new API
  var uniquePtr = doc.impl.createFileSpec()
  result.impl = releaseFileSpec(uniquePtr)
  result.owned = true

  # Set filename using PdfString
  let filenameStr = initPdfString(initStdStringView(name.cstring, name.len.csize_t))
  result.impl.setFilenameStr(filenameStr)

  # Set embedded data
  if data.len > 0:
    let buf = initCharbuffFromData(cast[cstring](unsafeAddr data[0]), data.len.csize_t)
    let nullableBuf = initNullableCharbuff(buf)
    result.impl.setEmbeddedData(nullableBuf)
  else:
    let nullBuf = initNullableCharbuffNull()
    result.impl.setEmbeddedData(nullBuf)

  # Add to embedded files name tree
  let names = doc.impl.getOrCreateNames()
  let embeddedFiles = names.getOrCreateEmbeddedFiles()
  let keyStr = initPdfString(initStdStringView(name.cstring, name.len.csize_t))
  let sharedPtr = makeSharedFileSpec(result.impl)
  embeddedFiles.addValueToEmbeddedFiles(keyStr, sharedPtr)

  # FileSpec is now owned by the document through shared_ptr
  result.owned = false

proc embedString*(doc: PdfDocument, name: string, content: string): PdfFileSpec =
  ## Embed a string as a text file attachment
  doc.embedData(name, content.toOpenArrayByte(0, content.len - 1))

proc getAttachment*(doc: PdfDocument, name: string): PdfFileSpec =
  ## Get an embedded file by name
  ## Uses PoDoFo 1.0.x API: GetNames()->GetTree<PdfEmbeddedFiles>()->GetValue()
  let names = doc.impl.getNames()
  if names == nil:
    return nil
  let embeddedFiles = names.getEmbeddedFiles()
  if embeddedFiles == nil:
    return nil

  let keyView = initStdStringView(name.cstring, name.len.csize_t)
  if not embeddedFiles.hasKeyInEmbeddedFiles(keyView):
    return nil

  let impl = embeddedFiles.getValueFromEmbeddedFiles(keyView)
  if impl == nil:
    return nil
  result = PdfFileSpec()
  result.impl = impl
  result.owned = false

proc filename*(fileSpec: PdfFileSpec): string =
  if fileSpec == nil or fileSpec.impl == nil:
    return ""
  if not fileSpec.impl.hasFilename():
    return ""
  $fileSpec.impl.getFilename()

proc getEmbeddedFile*(
    doc: PdfDocument, name: string
): PdfFileSpec {.deprecated: "Use getAttachment instead".} =
  doc.getAttachment(name)

# PDF/A-3 compliant Params dictionary helpers
# Note: PoDoFo 0.10.x automatically sets Size in Params, but ModDate/CreationDate are marked as TODO in PoDoFo source.
# These helpers allow manual setting of additional Params entries for PDF/A-3 compliance.

proc getEmbeddedFileStreamDict*(fileSpec: PdfFileSpec): ptr PdfDictionaryObj =
  ## Get the embedded file stream's dictionary (EF/F entry)
  ## Returns nil if no embedded file stream exists
  if fileSpec == nil or fileSpec.impl == nil:
    return nil
  let fsDict = fileSpec.impl.getFileSpecDictionary()
  let efKey = initPdfName(initStdStringView("EF", 2))
  if not fsDict.hasKey(efKey):
    return nil
  let efObj = fsDict.findKey(efKey)
  if efObj == nil or not efObj.isDictionary():
    return nil
  let efDict = efObj.getDictionary()
  let fKey = initPdfName(initStdStringView("F", 1))
  if not efDict.hasKey(fKey):
    return nil
  let streamObj = efDict.findKey(fKey)
  if streamObj == nil:
    return nil
  return streamObj.getDictionary()

proc setEmbeddedFileParams*(
    fileSpec: PdfFileSpec,
    modDate: string = "",
    creationDate: string = "",
    checkSum: string = "",
) =
  ## Set additional Params dictionary entries for PDF/A-3 compliance
  ## modDate/creationDate should be in PDF date format: D:YYYYMMDDHHmmSSOHH'mm'
  ## checkSum should be the MD5 hash of the file content (optional)
  ##
  ## Note: Size is automatically set by PoDoFo when embedding data.
  let streamDict = fileSpec.getEmbeddedFileStreamDict()
  if streamDict == nil:
    return

  let paramsKey = initPdfName(initStdStringView("Params", 6))
  let paramsDict = streamDict.getOrCreateKeyDict(paramsKey)

  if modDate.len > 0:
    let modDateKey = initPdfName(initStdStringView("ModDate", 7))
    let modDateStr =
      initPdfString(initStdStringView(modDate.cstring, modDate.len.csize_t))
    paramsDict.addKeyString(modDateKey, modDateStr)

  if creationDate.len > 0:
    let creationDateKey = initPdfName(initStdStringView("CreationDate", 12))
    let creationDateStr =
      initPdfString(initStdStringView(creationDate.cstring, creationDate.len.csize_t))
    paramsDict.addKeyString(creationDateKey, creationDateStr)

  if checkSum.len > 0:
    let checkSumKey = initPdfName(initStdStringView("CheckSum", 8))
    let checkSumStr =
      initPdfString(initStdStringView(checkSum.cstring, checkSum.len.csize_t))
    paramsDict.addKeyString(checkSumKey, checkSumStr)

proc setEmbeddedFileModDate*(fileSpec: PdfFileSpec) =
  ## Set ModDate to current time for PDF/A-3 compliance
  ## Uses PoDoFo's PdfDate::LocalNow() for proper PDF date format
  let streamDict = fileSpec.getEmbeddedFileStreamDict()
  if streamDict == nil:
    return

  let paramsKey = initPdfName(initStdStringView("Params", 6))
  let paramsDict = streamDict.getOrCreateKeyDict(paramsKey)

  let modDateKey = initPdfName(initStdStringView("ModDate", 7))
  let nowDate = initPdfDateNow()
  paramsDict.addKeyDate(modDateKey, nowDate)

# Iteration support

iterator pages*(doc: PdfDocument): PdfPage =
  ## Iterate over all pages in the document
  for i in 0 ..< doc.pageCount:
    yield doc.getPage(i)

# PdfAcroForm - Interactive Forms

type PdfAcroForm* = object
  impl: ptr PdfAcroFormObj
  doc: PdfDocument

proc acroForm*(
    doc: PdfDocument,
    defaultAppearance: PdfAcroFormDefaulAppearance =
      PdfAcroFormDefaulAppearance.BlackText12pt,
): PdfAcroForm =
  ## Get or create the document's interactive form
  PdfAcroForm(impl: doc.impl.getOrCreateAcroForm(defaultAppearance), doc: doc)

proc needAppearances*(form: PdfAcroForm): bool =
  form.impl.getNeedAppearances()

proc `needAppearances=`*(form: PdfAcroForm, need: bool) =
  form.impl.setNeedAppearances(need)

proc fieldCount*(form: PdfAcroForm): int =
  form.impl.getFieldCount().int

# PdfField - Base field type

type PdfField* = object
  impl: ptr PdfFieldObj
  doc: PdfDocument

proc getFieldAt*(form: PdfAcroForm, index: int): PdfField =
  ## Get a field by index (0-based)
  ## Raises PdfError if index is out of bounds
  if index < 0 or index >= form.fieldCount:
    raise newPdfError(
      PdfErrorCode.ValueOutOfRange,
      "Field index out of bounds: " & $index & " (form has " & $form.fieldCount &
        " fields)",
    )
  PdfField(impl: form.impl.getFieldAt(index.cuint), doc: form.doc)

proc removeFieldAt*(form: PdfAcroForm, index: int) =
  ## Remove a field by index (0-based)
  ## Raises PdfError if index is out of bounds
  if index < 0 or index >= form.fieldCount:
    raise newPdfError(
      PdfErrorCode.ValueOutOfRange,
      "Field index out of bounds: " & $index & " (form has " & $form.fieldCount &
        " fields)",
    )
  form.impl.removeFieldAt(index.cuint)

proc fieldType*(field: PdfField): PdfFieldType =
  field.impl.getFieldType()

proc name*(field: PdfField): string =
  $field.impl.getFieldName()

proc `name=`*(field: PdfField, name: string) =
  field.impl.setFieldName(initStdStringView(name.cstring, name.len.csize_t))

proc alternateName*(field: PdfField): string =
  $field.impl.getAlternateName()

proc `alternateName=`*(field: PdfField, name: string) =
  field.impl.setAlternateName(initStdStringView(name.cstring, name.len.csize_t))

proc mappingName*(field: PdfField): string =
  $field.impl.getMappingName()

proc `mappingName=`*(field: PdfField, name: string) =
  field.impl.setMappingName(initStdStringView(name.cstring, name.len.csize_t))

proc isReadOnly*(field: PdfField): bool =
  field.impl.isReadOnly()

proc `readOnly=`*(field: PdfField, value: bool) =
  field.impl.setReadOnly(value)

proc isRequired*(field: PdfField): bool =
  field.impl.isRequired()

proc `required=`*(field: PdfField, value: bool) =
  field.impl.setRequired(value)

proc isNoExport*(field: PdfField): bool =
  field.impl.isNoExport()

proc `noExport=`*(field: PdfField, value: bool) =
  field.impl.setNoExport(value)

iterator fields*(form: PdfAcroForm): PdfField =
  for i in 0 ..< form.fieldCount:
    yield form.getFieldAt(i)

# PdfTextBox - Text input field

type PdfTextBox* = object
  impl: ptr PdfTextBoxObj
  doc: PdfDocument

proc createTextBox*(form: PdfAcroForm, name: string): PdfTextBox =
  ## Create a text input field
  PdfTextBox(
    impl:
      form.impl.createFieldTextBox(initStdStringView(name.cstring, name.len.csize_t)),
    doc: form.doc,
  )

proc text*(tb: PdfTextBox): string =
  let nullable = tb.impl.getText()
  if nullable.hasValue():
    result = $nullable.getStringOwned()
  else:
    result = ""

proc `text=`*(tb: PdfTextBox, text: string) =
  tb.impl.setText(initPdfString(initStdStringView(text.cstring, text.len.csize_t)))

proc maxLen*(tb: PdfTextBox): int =
  tb.impl.getMaxLen().int

proc `maxLen=`*(tb: PdfTextBox, len: int) =
  tb.impl.setMaxLen(len.int64)

proc isMultiLine*(tb: PdfTextBox): bool =
  tb.impl.isMultiLine()

proc `multiLine=`*(tb: PdfTextBox, value: bool) =
  tb.impl.setMultiLine(value)

proc isPasswordField*(tb: PdfTextBox): bool =
  tb.impl.isPasswordField()

proc `passwordField=`*(tb: PdfTextBox, value: bool) =
  tb.impl.setPasswordField(value)

proc isFileField*(tb: PdfTextBox): bool =
  tb.impl.isFileField()

proc `fileField=`*(tb: PdfTextBox, value: bool) =
  tb.impl.setFileField(value)

proc isSpellcheckingEnabled*(tb: PdfTextBox): bool =
  tb.impl.isSpellcheckingEnabled()

proc `spellchecking=`*(tb: PdfTextBox, value: bool) =
  tb.impl.setSpellcheckingEnabled(value)

proc isScrollBarsEnabled*(tb: PdfTextBox): bool =
  tb.impl.isScrollBarsEnabled()

proc `scrollBars=`*(tb: PdfTextBox, value: bool) =
  tb.impl.setScrollBarsEnabled(value)

proc isCombs*(tb: PdfTextBox): bool =
  tb.impl.isCombs()

proc `combs=`*(tb: PdfTextBox, value: bool) =
  tb.impl.setCombs(value)

proc isRichText*(tb: PdfTextBox): bool =
  tb.impl.isRichText()

proc `richText=`*(tb: PdfTextBox, value: bool) =
  tb.impl.setRichText(value)

# PdfCheckBox - Checkbox field

type PdfCheckBox* = object
  impl: ptr PdfCheckBoxObj
  doc: PdfDocument

proc createCheckBox*(form: PdfAcroForm, name: string): PdfCheckBox =
  ## Create a checkbox field
  PdfCheckBox(
    impl:
      form.impl.createFieldCheckBox(initStdStringView(name.cstring, name.len.csize_t)),
    doc: form.doc,
  )

proc isChecked*(cb: PdfCheckBox): bool =
  cb.impl.isChecked()

proc `checked=`*(cb: PdfCheckBox, value: bool) =
  cb.impl.setChecked(value)

# PdfPushButton - Push button field

type PdfPushButton* = object
  impl: ptr PdfPushButtonObj
  doc: PdfDocument

proc createPushButton*(form: PdfAcroForm, name: string): PdfPushButton =
  ## Create a push button field
  PdfPushButton(
    impl:
      form.impl.createFieldPushButton(initStdStringView(name.cstring, name.len.csize_t)),
    doc: form.doc,
  )

proc caption*(btn: PdfPushButton): string =
  let nullable = btn.impl.getCaption()
  if nullable.hasValue():
    result = $nullable.getStringOwned()
  else:
    result = ""

proc `caption=`*(btn: PdfPushButton, caption: string) =
  btn.impl.setCaption(initStdStringView(caption.cstring, caption.len.csize_t))

# PdfComboBox - Combo box field

type PdfComboBox* = object
  impl: ptr PdfComboBoxObj
  doc: PdfDocument

proc createComboBox*(form: PdfAcroForm, name: string): PdfComboBox =
  ## Create a combo box field
  PdfComboBox(
    impl:
      form.impl.createFieldComboBox(initStdStringView(name.cstring, name.len.csize_t)),
    doc: form.doc,
  )

proc selectedIndex*(cb: PdfComboBox): int =
  cb.impl.getSelectedIndex().int

proc `selectedIndex=`*(cb: PdfComboBox, index: int) =
  cb.impl.setSelectedIndex(index.cint)

proc isEditable*(cb: PdfComboBox): bool =
  cb.impl.isEditable()

proc `editable=`*(cb: PdfComboBox, value: bool) =
  cb.impl.setEditable(value)

# PdfListBox - List box field

type PdfListBox* = object
  impl: ptr PdfListBoxObj
  doc: PdfDocument

proc createListBox*(form: PdfAcroForm, name: string): PdfListBox =
  ## Create a list box field
  PdfListBox(
    impl:
      form.impl.createFieldListBox(initStdStringView(name.cstring, name.len.csize_t)),
    doc: form.doc,
  )

proc selectedIndex*(lb: PdfListBox): int =
  lb.impl.getSelectedIndexListBox().int

proc `selectedIndex=`*(lb: PdfListBox, index: int) =
  lb.impl.setSelectedIndexListBox(index.cint)

proc isMultiSelect*(lb: PdfListBox): bool =
  lb.impl.isMultiSelect()

proc `multiSelect=`*(lb: PdfListBox, value: bool) =
  lb.impl.setMultiSelect(value)

# PdfSignature - Digital signature field

type PdfSignature* = object
  impl: ptr PdfSignatureObj
  doc: PdfDocument

proc createSignature*(form: PdfAcroForm, name: string): PdfSignature =
  ## Create a digital signature field
  PdfSignature(
    impl:
      form.impl.createFieldSignature(initStdStringView(name.cstring, name.len.csize_t)),
    doc: form.doc,
  )

proc signerName*(sig: PdfSignature): string =
  let nullable = sig.impl.getSignerName()
  if nullable.hasValue():
    result = $nullable.getStringOwned()
  else:
    result = ""

proc `signerName=`*(sig: PdfSignature, name: string) =
  sig.impl.setSignerName(
    initPdfString(initStdStringView(name.cstring, name.len.csize_t))
  )

proc signatureReason*(sig: PdfSignature): string =
  let nullable = sig.impl.getSignatureReason()
  if nullable.hasValue():
    result = $nullable.getStringOwned()
  else:
    result = ""

proc `signatureReason=`*(sig: PdfSignature, reason: string) =
  sig.impl.setSignatureReason(
    initPdfString(initStdStringView(reason.cstring, reason.len.csize_t))
  )

proc signatureLocation*(sig: PdfSignature): string =
  let nullable = sig.impl.getSignatureLocation()
  if nullable.hasValue():
    result = $nullable.getStringOwned()
  else:
    result = ""

proc `signatureLocation=`*(sig: PdfSignature, location: string) =
  sig.impl.setSignatureLocation(
    initPdfString(initStdStringView(location.cstring, location.len.csize_t))
  )

proc `signatureCreator=`*(sig: PdfSignature, creator: string) =
  sig.impl.setSignatureCreator(
    initPdfString(initStdStringView(creator.cstring, creator.len.csize_t))
  )

proc setSignatureDateNow*(sig: PdfSignature) =
  sig.impl.setSignatureDate(initPdfDateNow())

proc addCertificationReference*(
    sig: PdfSignature, perm: PdfCertPermission = PdfCertPermission.NoPerms
) =
  sig.impl.addCertificationReference(perm)

proc ensureValueObject*(sig: PdfSignature) =
  sig.impl.ensureValueObject()

# PdfAction - Document actions (PoDoFo 1.0.x API)

type
  PdfURIActionInner = object
    impl: ptr PdfActionURIObj
    owned: bool

  PdfURIAction* = ref PdfURIActionInner

  PdfJavaScriptActionInner = object
    impl: ptr PdfActionJavaScriptObj
    owned: bool

  PdfJavaScriptAction* = ref PdfJavaScriptActionInner

proc `=destroy`(action: PdfURIActionInner) =
  if action.owned and action.impl != nil:
    deleteActionURI(action.impl)

proc `=destroy`(action: PdfJavaScriptActionInner) =
  if action.owned and action.impl != nil:
    deleteActionJavaScript(action.impl)

# Setters first (needed by constructors)
proc `uri=`*(action: PdfURIAction, uri: string) =
  let uriStr = initPdfString(initStdStringView(uri.cstring, uri.len.csize_t))
  action.impl.setURI(uriStr) # Pass PdfString directly - C++ handles implicit conversion

proc `script=`*(action: PdfJavaScriptAction, script: string) =
  let scriptStr = initPdfString(initStdStringView(script.cstring, script.len.csize_t))
  action.impl.setScript(scriptStr) # Pass PdfString directly

proc newURIAction*(doc: PdfDocument, uri: string): PdfURIAction =
  ## Create a URI action (link to a URL)
  result = PdfURIAction()
  var uniquePtr = createActionURI(doc.impl)
  result.impl = releaseActionURI(uniquePtr)
  result.owned = true
  result.uri = uri # Use setter to ensure proper string handling

proc newJavaScriptAction*(doc: PdfDocument, script: string): PdfJavaScriptAction =
  ## Create a JavaScript action
  result = PdfJavaScriptAction()
  var uniquePtr = createActionJavaScript(doc.impl)
  result.impl = releaseActionJavaScript(uniquePtr)
  result.owned = true
  result.script = script # Use setter to ensure proper string handling

proc uri*(action: PdfURIAction): string =
  let nullable = action.impl.getURINullable()
  if nullable.hasValue():
    result = $nullable.getStringOwned()
  else:
    result = ""

proc script*(action: PdfJavaScriptAction): string =
  let nullable = action.impl.getScriptNullable()
  if nullable.hasValue():
    result = $nullable.getStringOwned()
  else:
    result = ""

# PdfAnnotation - Annotations on pages

type PdfAnnotation* = object
  impl: ptr PdfAnnotationObj
  doc: PdfDocument

type PdfAnnotationLink* = object
  impl: ptr PdfAnnotationLinkObj
  doc: PdfDocument

type PdfAnnotationText* = object
  impl: ptr PdfAnnotationTextObj
  doc: PdfDocument

proc annotations*(page: PdfPage): ptr PdfAnnotationCollectionObj =
  page.impl.getAnnotations()

proc annotationCount*(page: PdfPage): int =
  page.impl.getAnnotations().getAnnotationCount().int

proc getAnnotationAt*(page: PdfPage, index: int): PdfAnnotation =
  ## Get an annotation by index (0-based)
  ## Raises PdfError if index is out of bounds
  if index < 0 or index >= page.annotationCount:
    raise newPdfError(
      PdfErrorCode.ValueOutOfRange,
      "Annotation index out of bounds: " & $index & " (page has " & $page.annotationCount &
        " annotations)",
    )
  PdfAnnotation(
    impl: page.impl.getAnnotations().getAnnotationAt(index.cuint), doc: page.doc
  )

proc removeAnnotationAt*(page: PdfPage, index: int) =
  ## Remove an annotation by index (0-based)
  ## Raises PdfError if index is out of bounds
  if index < 0 or index >= page.annotationCount:
    raise newPdfError(
      PdfErrorCode.ValueOutOfRange,
      "Annotation index out of bounds: " & $index & " (page has " & $page.annotationCount &
        " annotations)",
    )
  page.impl.getAnnotations().removeAnnotationAt(index.cuint)

proc createLinkAnnotation*(page: PdfPage, r: Rect): PdfAnnotationLink =
  ## Create a link annotation on a page
  PdfAnnotationLink(
    impl: page.impl.getAnnotations().createAnnotationLink(r.toPoDoFo()), doc: page.doc
  )

proc createTextAnnotation*(page: PdfPage, r: Rect): PdfAnnotationText =
  ## Create a text annotation (comment) on a page
  PdfAnnotationText(
    impl: page.impl.getAnnotations().createAnnotationText(r.toPoDoFo()), doc: page.doc
  )

# Base annotation properties (work on all annotation types)
proc annotationType*(annot: PdfAnnotation): PdfAnnotationType =
  annot.impl.getAnnotationType()

proc rect*(annot: PdfAnnotation): Rect =
  fromPoDoFo(annot.impl.getAnnotationRect())

proc `rect=`*(annot: PdfAnnotation, r: Rect) =
  annot.impl.setAnnotationRect(r.toPoDoFo())

proc flags*(annot: PdfAnnotation): PdfAnnotationFlags =
  annot.impl.getAnnotationFlags()

proc `flags=`*(annot: PdfAnnotation, f: PdfAnnotationFlags) =
  annot.impl.setAnnotationFlags(f)

proc title*(annot: PdfAnnotation): string =
  let nullable = annot.impl.getAnnotationTitle()
  if nullable.hasValue():
    result = $nullable.getStringOwned()
  else:
    result = ""

proc `title=`*(annot: PdfAnnotation, title: string) =
  annot.impl.setAnnotationTitle(
    initPdfString(initStdStringView(title.cstring, title.len.csize_t))
  )

proc contents*(annot: PdfAnnotation): string =
  let nullable = annot.impl.getAnnotationContents()
  if nullable.hasValue():
    result = $nullable.getStringOwned()
  else:
    result = ""

proc `contents=`*(annot: PdfAnnotation, contents: string) =
  annot.impl.setAnnotationContents(
    initPdfString(initStdStringView(contents.cstring, contents.len.csize_t))
  )

proc setBorderStyle*(annot: PdfAnnotation, hCorner, vCorner, width: float64) =
  annot.impl.setBorderStyle(hCorner, vCorner, width)

# Link annotation specific
proc setDestination*(link: PdfAnnotationLink, dest: PdfDestination) =
  ## Set the destination for a link annotation
  link.impl.setDestinationLink(initNullableDestinationRef(dest.impl))

iterator annotations*(page: PdfPage): PdfAnnotation =
  for i in 0 ..< page.annotationCount:
    yield page.getAnnotationAt(i)

# PdfXObjectForm - Reusable content (appearance streams)

type
  PdfXObjectFormInner = object
    impl: ptr PdfXObjectFormObj

  PdfXObjectForm* = ref PdfXObjectFormInner

proc `=destroy`(xobj: PdfXObjectFormInner) =
  if xobj.impl != nil:
    deletePdfXObjectForm(xobj.impl)

proc createXObjectForm*(doc: PdfDocument, r: Rect): PdfXObjectForm =
  ## Create a reusable XObject form (useful for appearance streams)
  result = PdfXObjectForm()
  var formPtr = doc.impl.createXObjectForm(r.toPoDoFo())
  result.impl = releaseXObjectForm(formPtr)

proc rect*(xobj: PdfXObjectForm): Rect =
  fromPoDoFo(xobj.impl.getXObjectFormRect())

proc `rect=`*(xobj: PdfXObjectForm, r: Rect) =
  xobj.impl.setXObjectFormRect(r.toPoDoFo())

proc setCanvas*(painter: PdfPainter, xobj: PdfXObjectForm) =
  ## Set an XObject form as the drawing canvas
  painter.impl.setCanvasXObject(xobj.impl)

# Low-level PDF Object Access

type
  PdfObjectList* = object
    impl: ptr PdfIndirectObjectListObj
    doc: PdfDocument

  PdfObject* = object
    impl*: ptr PdfObjectObj
    doc: PdfDocument

  PdfDictionary* = object
    impl*: ptr PdfDictionaryObj

  PdfReference* = object
    impl*: PdfReferenceObj

proc objects*(doc: PdfDocument): PdfObjectList =
  ## Get access to the internal vector of objects
  PdfObjectList(impl: doc.impl.getObjects(), doc: doc)

proc isNil*(obj: PdfObject): bool =
  ## Check if the PDF object is nil (has no underlying implementation)
  obj.impl == nil

proc createDictionaryObject*(objects: PdfObjectList): PdfObject =
  ## Create a new dictionary object in the document
  PdfObject(impl: objects.impl.createDictionaryObject(), doc: objects.doc)

proc createDictionaryObject*(objects: PdfObjectList, typeName: string): PdfObject =
  ## Create a new dictionary object with Type in the document
  PdfObject(
    impl: objects.impl.createDictionaryObjectWithType(
      initStdStringView(typeName.cstring, typeName.len.csize_t)
    ),
    doc: objects.doc,
  )

proc createDictionaryObject*(
    objects: PdfObjectList, typeName, subType: string
): PdfObject =
  ## Create a new dictionary object with Type and Subtype in the document
  PdfObject(
    impl: objects.impl.createDictionaryObjectWithTypeAndSubtype(
      initStdStringView(typeName.cstring, typeName.len.csize_t),
      initStdStringView(subType.cstring, subType.len.csize_t),
    ),
    doc: objects.doc,
  )

proc createArrayObject*(objects: PdfObjectList): PdfObject =
  ## Create a new array object in the document
  PdfObject(impl: objects.impl.createArrayObject(), doc: objects.doc)

proc objectCount*(objects: PdfObjectList): int =
  ## Get the number of objects in the document
  objects.impl.getObjectCount().int

proc getDictionary*(obj: PdfObject): PdfDictionary =
  ## Get the dictionary of a PDF object
  PdfDictionary(impl: obj.impl.getDictionary())

proc getReference*(obj: PdfObject): PdfReference =
  ## Get the reference of a PDF object
  PdfReference(impl: obj.impl.getReference())

proc objectNumber*(reference: PdfReference): int =
  ## Get the object number
  reference.impl.getObjectNumber().int

proc generationNumber*(reference: PdfReference): int =
  ## Get the generation number
  reference.impl.getGenerationNumber().int

proc hasStream*(obj: PdfObject): bool =
  ## Check if the object has a stream
  obj.impl.hasStream()

proc setStreamData*(obj: PdfObject, data: openArray[byte]) =
  ## Set the stream data of a PDF object
  if data.len > 0:
    let stream = obj.impl.getOrCreateStream()
    stream.setStreamData(cast[cstring](unsafeAddr data[0]), data.len.csize_t)

proc setStreamData*(obj: PdfObject, data: string) =
  ## Set the stream data of a PDF object from a string
  if data.len > 0:
    let stream = obj.impl.getOrCreateStream()
    stream.setStreamData(data.cstring, data.len.csize_t)

proc setStreamDataRaw*(obj: PdfObject, data: openArray[byte]) =
  ## Set the stream data without encoding
  if data.len > 0:
    let stream = obj.impl.getOrCreateStream()
    stream.setStreamDataRaw(cast[cstring](unsafeAddr data[0]), data.len.csize_t)

# Dictionary operations

proc setDictKey*(dict: PdfDictionary, key: string, value: PdfObject) =
  ## Set a key in the dictionary to reference an indirect object
  dict.impl.addKeyIndirect(
    initPdfName(initStdStringView(key.cstring, key.len.csize_t)), value.impl
  )

proc setDictKeyString*(dict: PdfDictionary, key: string, value: string) =
  ## Set a key in the dictionary to a string value
  let keyName = initPdfName(initStdStringView(key.cstring, key.len.csize_t))
  let strVal = initPdfString(initStdStringView(value.cstring, value.len.csize_t))
  dict.impl.addKeyString(keyName, strVal)

proc setDictKeyName*(dict: PdfDictionary, key: string, value: string) =
  ## Set a key in the dictionary to a name value
  let keyName = initPdfName(initStdStringView(key.cstring, key.len.csize_t))
  let nameVal = initPdfName(initStdStringView(value.cstring, value.len.csize_t))
  dict.impl.addKeyName(keyName, nameVal)

proc setDictKeyRef*(dict: PdfDictionary, key: string, reference: PdfReference) =
  ## Set a key in the dictionary to reference another object
  let keyName = initPdfName(initStdStringView(key.cstring, key.len.csize_t))
  dict.impl.addKeyRef(keyName, reference.impl)

proc hasKey*(dict: PdfDictionary, key: string): bool =
  ## Check if a key exists in the dictionary
  dict.impl.hasKey(initPdfName(initStdStringView(key.cstring, key.len.csize_t)))

proc removeKey*(dict: PdfDictionary, key: string) =
  ## Remove a key from the dictionary
  dict.impl.removeKey(initPdfName(initStdStringView(key.cstring, key.len.csize_t)))

# Catalog access

proc getCatalog*(doc: PdfDocument): PdfObject =
  ## Get the document catalog dictionary
  PdfObject(impl: doc.impl.getCatalog().getCatalogObject(), doc: doc)

proc getCatalogDict*(doc: PdfDocument): PdfDictionary =
  ## Get the document catalog as a dictionary
  PdfDictionary(impl: doc.impl.getCatalog().getCatalogDictionary())

# FileSpec extensions

proc getFileSpecObject*(fileSpec: PdfFileSpec): PdfObject =
  ## Get the underlying PdfObject of a FileSpec
  PdfObject(impl: fileSpec.impl.getFileSpecObject())

proc getFileSpecDict*(fileSpec: PdfFileSpec): PdfDictionary =
  ## Get the dictionary of a FileSpec
  PdfDictionary(impl: fileSpec.impl.getFileSpecDictionary())

proc getEmbeddedFileStream*(fileSpec: PdfFileSpec): PdfObject =
  ## Get the embedded file stream object from a FileSpec
  ## Note: This returns the EF/F entry if it exists
  let dict = fileSpec.impl.getFileSpecDictionary()
  let efKey = initPdfName(initStdStringView("EF", 2))
  if dict.hasKey(efKey):
    let efDict = dict.findKey(efKey)
    if efDict != nil:
      let fKey = initPdfName(initStdStringView("F", 1))
      let efDictPtr = efDict.getDictionary()
      if efDictPtr.hasKey(fKey):
        let streamObj = efDictPtr.findKey(fKey)
        if streamObj != nil:
          return PdfObject(impl: streamObj)
  PdfObject(impl: nil)

# XMP Metadata

proc syncXMPMetadata*(meta: PdfMetadata, reset: bool = false) =
  ## Synchronize XMP metadata with Info dictionary
  meta.impl.syncXMPMetadata(reset)

proc trySyncXMPMetadata*(meta: PdfMetadata) =
  ## Try to synchronize XMP metadata with Info dictionary (no exception on failure)
  meta.impl.trySyncXMPMetadata()

proc setXMP*(doc: PdfDocument, xmpData: string) =
  ## Set XMP metadata on the document
  ## This creates or replaces the XMP metadata stream in the catalog
  let catalog = doc.getCatalog()
  let catalogDict = catalog.getDictionary()

  # Create metadata object
  let metaObj = doc.objects().createDictionaryObject()
  let metaDict = metaObj.getDictionary()

  # Set Type and Subtype
  metaDict.setDictKeyName("Type", "Metadata")
  metaDict.setDictKeyName("Subtype", "XML")

  # Set the XMP data as stream
  metaObj.setStreamDataRaw(xmpData.toOpenArrayByte(0, xmpData.len - 1))

  # Add to catalog
  catalogDict.setDictKey("Metadata", metaObj)
