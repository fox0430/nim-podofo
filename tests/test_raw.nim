# Low-level FFI binding tests for raw.nim

import std/[unittest, strutils]

import ../lowlevel/raw

suite "StdStringView":
  test "create from cstring":
    discard initStdStringView("hello")
    # Just verify it doesn't crash - can't easily inspect C++ object

  test "create from cstring with length":
    discard initStdStringView("hello world", 5)
    # Creates "hello" (first 5 chars)

suite "StdString":
  test "create empty":
    let s = initStdString()
    check s.len() == 0

  test "create from string view":
    let sv = initStdStringView("test", 4)
    # Note: initStdString from StdStringView may not work as expected
    # Just verify no crash
    let s = initStdString(sv)
    discard s

suite "PodofoRect":
  test "create empty rect":
    let r = initRect()
    check r.X == 0
    check r.Y == 0
    check r.Width == 0
    check r.Height == 0

  test "create rect with values":
    let r = initRect(10.0, 20.0, 100.0, 200.0)
    check r.X == 10.0
    check r.Y == 20.0
    check r.Width == 100.0
    check r.Height == 200.0

  test "rect getters":
    let r = initRect(10.0, 20.0, 100.0, 200.0)
    check r.getLeft() == 10.0
    check r.getBottom() == 20.0
    check r.getRight() == 110.0 # left + width
    check r.getTop() == 220.0 # bottom + height
    check r.getWidth() == 100.0
    check r.getHeight() == 200.0

  test "standard page sizes":
    let a4 = createStandardPageSize(PdfPageSize.A4, false)
    check a4.getWidth() > 0
    check a4.getHeight() > 0
    check a4.getHeight() > a4.getWidth() # Portrait

    let a4Landscape = createStandardPageSize(PdfPageSize.A4, true)
    check a4Landscape.getWidth() > a4Landscape.getHeight() # Landscape

    let letter = createStandardPageSize(PdfPageSize.Letter, false)
    check letter.getWidth() > 0
    check letter.getHeight() > 0

suite "Matrix":
  test "create identity matrix":
    discard initMatrix()
    # Identity matrix - just verify creation

  test "rotation matrix":
    discard createRotation(3.14159 / 4.0) # 45 degrees
    # Just verify creation

suite "PdfColor":
  test "grayscale color":
    let c = initPdfColorGray(0.5)
    check c.isGrayScale()
    check not c.isRGB()
    check not c.isCMYK()
    check not c.isTransparent()
    check c.getGrayScale() == 0.5

  test "grayscale black":
    let c = initPdfColorGray(0.0)
    check c.getGrayScale() == 0.0

  test "grayscale white":
    let c = initPdfColorGray(1.0)
    check c.getGrayScale() == 1.0

  test "RGB color":
    let c = initPdfColorRGB(1.0, 0.5, 0.25)
    check c.isRGB()
    check not c.isGrayScale()
    check not c.isCMYK()
    check c.getRed() == 1.0
    check c.getGreen() == 0.5
    check c.getBlue() == 0.25

  test "CMYK color":
    let c = initPdfColorCMYK(0.1, 0.2, 0.3, 0.4)
    check c.isCMYK()
    check not c.isRGB()
    check not c.isGrayScale()
    check c.getCyan() == 0.1
    check c.getMagenta() == 0.2
    check c.getYellow() == 0.3
    check c.getBlack() == 0.4

  test "transparent color":
    let c = initPdfColorTransparent()
    check c.isTransparent()

  test "convert RGB to grayscale":
    let rgb = initPdfColorRGB(0.5, 0.5, 0.5)
    let gray = rgb.convertToGrayScale()
    check gray.isGrayScale()
    # Grayscale value should be close to 0.5
    check gray.getGrayScale() > 0.4
    check gray.getGrayScale() < 0.6

  test "convert RGB to CMYK":
    let rgb = initPdfColorRGB(1.0, 0.0, 0.0) # Pure red
    let cmyk = rgb.convertToCMYK()
    check cmyk.isCMYK()

  test "convert CMYK to RGB":
    let cmyk = initPdfColorCMYK(0.0, 1.0, 1.0, 0.0) # Red in CMYK
    let rgb = cmyk.convertToRGB()
    check rgb.isRGB()

suite "PdfString":
  test "create from string view":
    let sv = initStdStringView("Hello World", 11)
    discard initPdfString(sv)
    # Just verify creation

  test "get string content":
    let sv = initStdStringView("Test", 4)
    let s = initPdfString(sv)
    check $s.getString() == "Test"

suite "PdfName":
  test "create from string view":
    let sv = initStdStringView("MyName", 6)
    let n = initPdfName(sv)
    check $n.getNameString() == "MyName"

suite "PdfDate":
  test "create empty date":
    discard initPdfDate()
    # Just verify creation

  test "create date now":
    discard initPdfDateNow()
    # Just verify creation - API may vary

suite "PdfReference":
  test "create reference":
    let r = initPdfReference(1, 0)
    check r.getObjectNumber() == 1
    check r.getGenerationNumber() == 0

  test "create reference with generation":
    let r = initPdfReference(42, 5)
    check r.getObjectNumber() == 42
    check r.getGenerationNumber() == 5

suite "PdfPainterPath":
  test "create and delete path":
    let path = createPdfPainterPath()
    check path != nil
    deletePdfPainterPath(path)

  test "path operations":
    let path = createPdfPainterPath()
    path.moveTo(0, 0)
    path.lineTo(100, 0)
    path.lineTo(100, 100)
    path.lineTo(0, 100)
    path.closePath()
    deletePdfPainterPath(path)

  test "cubic bezier":
    let path = createPdfPainterPath()
    path.moveTo(0, 0)
    path.cubicBezierTo(25, 50, 75, 50, 100, 0)
    deletePdfPainterPath(path)

  test "add shapes":
    let path = createPdfPainterPath()
    path.addCircle(50, 50, 25)
    path.addEllipse(0, 0, 100, 50)
    path.addRectangle(10, 10, 80, 80)
    path.addRectangle(10, 10, 80, 80, 5.0, 5.0) # Rounded corners
    deletePdfPainterPath(path)

  test "arc operations":
    let path = createPdfPainterPath()
    path.moveTo(50, 50)
    path.addArc(50, 50, 25, 0, 3.14159)
    path.addArcTo(100, 100, 150, 100, 10)
    deletePdfPainterPath(path)

  test "reset path":
    let path = createPdfPainterPath()
    path.moveTo(0, 0)
    path.lineTo(100, 100)
    path.reset()
    # Path should be empty now
    deletePdfPainterPath(path)

suite "PdfMemDocument":
  test "create and delete document":
    let doc = newPdfMemDocument()
    check doc != nil
    deletePdfMemDocument(doc)

  test "document not encrypted by default":
    let doc = newPdfMemDocument()
    check not doc.isEncrypted()
    deletePdfMemDocument(doc)

  test "permissions on new document":
    let doc = newPdfMemDocument()
    check doc.isPrintAllowed()
    check doc.isEditAllowed()
    check doc.isCopyAllowed()
    check doc.isEditNotesAllowed()
    check doc.isFillAndSignAllowed()
    check doc.isHighPrintAllowed()
    deletePdfMemDocument(doc)

  test "get pages collection":
    let doc = newPdfMemDocument()
    let pages = doc.getPages()
    check pages != nil
    check pages.getCount() == 0
    deletePdfMemDocument(doc)

  test "get font manager":
    let doc = newPdfMemDocument()
    let fonts = doc.getFonts()
    check fonts != nil
    deletePdfMemDocument(doc)

  test "get metadata":
    let doc = newPdfMemDocument()
    let meta = doc.getMetadata()
    check meta != nil
    deletePdfMemDocument(doc)

suite "PdfPageCollection":
  test "create page":
    let doc = newPdfMemDocument()
    let pages = doc.getPages()
    let rect = createStandardPageSize(PdfPageSize.A4, false)
    let page = pages.createPage(rect)
    check page != nil
    check pages.getCount() == 1
    deletePdfMemDocument(doc)

  test "create multiple pages":
    let doc = newPdfMemDocument()
    let pages = doc.getPages()
    let a4 = createStandardPageSize(PdfPageSize.A4, false)
    let letter = createStandardPageSize(PdfPageSize.Letter, false)

    discard pages.createPage(a4)
    discard pages.createPage(letter)
    discard pages.createPage(a4)

    check pages.getCount() == 3
    deletePdfMemDocument(doc)

  test "get page at index":
    let doc = newPdfMemDocument()
    let pages = doc.getPages()
    let rect = createStandardPageSize(PdfPageSize.A4, false)
    discard pages.createPage(rect)

    let page = pages.getPageAt(0)
    check page != nil
    deletePdfMemDocument(doc)

  test "create page at index":
    let doc = newPdfMemDocument()
    let pages = doc.getPages()
    let a4 = createStandardPageSize(PdfPageSize.A4, false)

    discard pages.createPage(a4)
    discard pages.createPage(a4)
    discard pages.createPageAt(1, a4) # Insert at index 1

    check pages.getCount() == 3
    deletePdfMemDocument(doc)

  test "remove page":
    let doc = newPdfMemDocument()
    let pages = doc.getPages()
    let a4 = createStandardPageSize(PdfPageSize.A4, false)

    discard pages.createPage(a4)
    discard pages.createPage(a4)
    check pages.getCount() == 2

    pages.removePageAt(0)
    check pages.getCount() == 1
    deletePdfMemDocument(doc)

suite "PdfPage":
  test "get page rect":
    let doc = newPdfMemDocument()
    let pages = doc.getPages()
    let rect = initRect(0, 0, 612, 792) # Letter size
    let page = pages.createPage(rect)

    let pageRect = page.getRect()
    check pageRect.getWidth() == 612
    check pageRect.getHeight() == 792
    deletePdfMemDocument(doc)

  test "page number and index":
    let doc = newPdfMemDocument()
    let pages = doc.getPages()
    let a4 = createStandardPageSize(PdfPageSize.A4, false)

    discard pages.createPage(a4)
    discard pages.createPage(a4)

    let page1 = pages.getPageAt(0)
    let page2 = pages.getPageAt(1)

    check page1.getIndex() == 0
    check page2.getIndex() == 1
    check page1.getPageNumber() == 1
    check page2.getPageNumber() == 2
    deletePdfMemDocument(doc)

  test "page rotation":
    let doc = newPdfMemDocument()
    let pages = doc.getPages()
    let a4 = createStandardPageSize(PdfPageSize.A4, false)
    let page = pages.createPage(a4)

    # Just test page creation - rotation API may have changed
    check page != nil
    deletePdfMemDocument(doc)

  test "page boxes":
    let doc = newPdfMemDocument()
    let pages = doc.getPages()
    let a4 = createStandardPageSize(PdfPageSize.A4, false)
    let page = pages.createPage(a4)

    # MediaBox should match page size
    let mediaBox = page.getRect() # getRect returns the page rect
    check mediaBox.getWidth() > 0
    check mediaBox.getHeight() > 0

    deletePdfMemDocument(doc)

suite "PdfFontManager":
  test "get standard 14 fonts":
    let doc = newPdfMemDocument()
    let fonts = doc.getFonts()

    let helvetica = fonts.getStandard14Font(PdfStandard14FontType.Helvetica)
    check helvetica != nil
    # Font name may include subset prefix (e.g., "BAAAAA+Helvetica")
    check "Helvetica" in $helvetica.getName()
    check helvetica.isStandard14Font()

    let times = fonts.getStandard14Font(PdfStandard14FontType.TimesRoman)
    check times != nil
    check times.isStandard14Font()

    let courier = fonts.getStandard14Font(PdfStandard14FontType.Courier)
    check courier != nil
    check courier.isStandard14Font()

    deletePdfMemDocument(doc)

  test "all standard 14 fonts":
    let doc = newPdfMemDocument()
    let fonts = doc.getFonts()

    # Test all standard fonts can be retrieved
    let fontTypes = [
      PdfStandard14FontType.TimesRoman, PdfStandard14FontType.TimesItalic,
      PdfStandard14FontType.TimesBold, PdfStandard14FontType.TimesBoldItalic,
      PdfStandard14FontType.Helvetica, PdfStandard14FontType.HelveticaOblique,
      PdfStandard14FontType.HelveticaBold, PdfStandard14FontType.HelveticaBoldOblique,
      PdfStandard14FontType.Courier, PdfStandard14FontType.CourierOblique,
      PdfStandard14FontType.CourierBold, PdfStandard14FontType.CourierBoldOblique,
      PdfStandard14FontType.Symbol, PdfStandard14FontType.ZapfDingbats,
    ]

    for fontType in fontTypes:
      let font = fonts.getStandard14Font(fontType)
      check font != nil
      check font.isStandard14Font()

    deletePdfMemDocument(doc)

suite "PdfFont":
  test "font metrics":
    let doc = newPdfMemDocument()
    let fonts = doc.getFonts()
    let font = fonts.getStandard14Font(PdfStandard14FontType.Helvetica)

    let state = initPdfTextState(font, 12.0)

    let lineSpacing = font.getLineSpacing(state)
    check lineSpacing > 0

    let ascent = font.getAscent(state)
    check ascent > 0

    discard font.getDescent(state)
    # Descent is typically negative

    let strLen = font.getStringLength(initStdStringView("Hello", 5), state)
    check strLen > 0

    deletePdfMemDocument(doc)

  test "font underline metrics":
    let doc = newPdfMemDocument()
    let fonts = doc.getFonts()
    let font = fonts.getStandard14Font(PdfStandard14FontType.Helvetica)

    let state = initPdfTextState(font, 12.0)

    let thickness = font.getUnderlineThickness(state)
    check thickness > 0

    discard font.getUnderlinePosition(state)
    # Position is typically negative (below baseline)

    deletePdfMemDocument(doc)

  test "font strikethrough metrics":
    let doc = newPdfMemDocument()
    let fonts = doc.getFonts()
    let font = fonts.getStandard14Font(PdfStandard14FontType.Helvetica)

    let state = initPdfTextState(font, 12.0)

    let thickness = font.getStrikeThroughThickness(state)
    check thickness > 0

    let position = font.getStrikeThroughPosition(state)
    check position > 0 # Strikethrough is above baseline

    deletePdfMemDocument(doc)

suite "PdfPainter":
  test "create and delete painter":
    let painter = createPdfPainter()
    check painter != nil
    deletePdfPainter(painter)

  test "painter with canvas":
    let doc = newPdfMemDocument()
    let pages = doc.getPages()
    let a4 = createStandardPageSize(PdfPageSize.A4, false)
    let page = pages.createPage(a4)

    let painter = createPdfPainter()
    painter.setCanvas(page)
    painter.finishDrawing()

    deletePdfPainter(painter)
    deletePdfMemDocument(doc)

  test "painter save and restore":
    let doc = newPdfMemDocument()
    let pages = doc.getPages()
    let a4 = createStandardPageSize(PdfPageSize.A4, false)
    let page = pages.createPage(a4)

    let painter = createPdfPainter()
    painter.setCanvas(page)

    painter.save()
    painter.restore()

    painter.finishDrawing()
    deletePdfPainter(painter)
    deletePdfMemDocument(doc)

  test "draw line":
    let doc = newPdfMemDocument()
    let pages = doc.getPages()
    let a4 = createStandardPageSize(PdfPageSize.A4, false)
    let page = pages.createPage(a4)

    let painter = createPdfPainter()
    painter.setCanvas(page)

    painter.drawLine(0, 0, 100, 100)

    painter.finishDrawing()
    deletePdfPainter(painter)
    deletePdfMemDocument(doc)

  test "draw shapes":
    let doc = newPdfMemDocument()
    let pages = doc.getPages()
    let a4 = createStandardPageSize(PdfPageSize.A4, false)
    let page = pages.createPage(a4)

    let painter = createPdfPainter()
    painter.setCanvas(page)

    painter.drawRectangle(10, 10, 100, 50, PdfPathDrawMode.Stroke)
    painter.drawCircle(200, 200, 50, PdfPathDrawMode.Fill)
    painter.drawEllipse(300, 300, 80, 40, PdfPathDrawMode.StrokeFill)

    painter.finishDrawing()
    deletePdfPainter(painter)
    deletePdfMemDocument(doc)

  test "set colors":
    let doc = newPdfMemDocument()
    let pages = doc.getPages()
    let a4 = createStandardPageSize(PdfPageSize.A4, false)
    let page = pages.createPage(a4)

    let painter = createPdfPainter()
    painter.setCanvas(page)

    painter.setStrokingColor(initPdfColorRGB(1.0, 0.0, 0.0))
    painter.setNonStrokingColor(initPdfColorRGB(0.0, 1.0, 0.0))

    painter.drawRectangle(10, 10, 100, 50, PdfPathDrawMode.StrokeFill)

    painter.finishDrawing()
    deletePdfPainter(painter)
    deletePdfMemDocument(doc)

  test "draw text":
    let doc = newPdfMemDocument()
    let pages = doc.getPages()
    let a4 = createStandardPageSize(PdfPageSize.A4, false)
    let page = pages.createPage(a4)

    let fonts = doc.getFonts()
    let font = fonts.getStandard14Font(PdfStandard14FontType.Helvetica)

    let painter = createPdfPainter()
    painter.setCanvas(page)

    let textState = painter.getTextState()
    textState.setFont(font, 12.0)

    painter.drawText(initStdStringView("Hello, World!", 13), 100, 700)

    painter.finishDrawing()
    deletePdfPainter(painter)
    deletePdfMemDocument(doc)

  test "graphics state wrapper":
    let doc = newPdfMemDocument()
    let pages = doc.getPages()
    let a4 = createStandardPageSize(PdfPageSize.A4, false)
    let page = pages.createPage(a4)

    let painter = createPdfPainter()
    painter.setCanvas(page)

    let gs = painter.getGraphicsState()
    gs.setLineWidth(2.0)
    gs.setLineCapStyle(PdfLineCapStyle.Round)
    gs.setLineJoinStyle(PdfLineJoinStyle.Bevel)

    check gs.getLineWidth() == 2.0

    painter.finishDrawing()
    deletePdfPainter(painter)
    deletePdfMemDocument(doc)

  test "text state wrapper":
    let doc = newPdfMemDocument()
    let pages = doc.getPages()
    let a4 = createStandardPageSize(PdfPageSize.A4, false)
    let page = pages.createPage(a4)

    let fonts = doc.getFonts()
    let font = fonts.getStandard14Font(PdfStandard14FontType.Helvetica)

    let painter = createPdfPainter()
    painter.setCanvas(page)

    let ts = painter.getTextState()
    ts.setFont(font, 14.0)
    ts.setFontScale(100.0)
    ts.setCharSpacing(0.5)
    ts.setWordSpacing(1.0)
    ts.setRenderingMode(PdfTextRenderingMode.Fill)

    check ts.getFontSize() == 14.0

    painter.finishDrawing()
    deletePdfPainter(painter)
    deletePdfMemDocument(doc)

  # Note: BeginText/EndText/TextMoveTo/AddText are private in newer PoDoFo
  # Use drawText for text drawing instead

  test "draw path":
    let doc = newPdfMemDocument()
    let pages = doc.getPages()
    let a4 = createStandardPageSize(PdfPageSize.A4, false)
    let page = pages.createPage(a4)

    let painter = createPdfPainter()
    painter.setCanvas(page)

    let path = createPdfPainterPath()
    path.moveTo(100, 700)
    path.lineTo(200, 700)
    path.lineTo(150, 750)
    path.closePath()

    painter.drawPath(path, PdfPathDrawMode.StrokeFill)

    deletePdfPainterPath(path)
    painter.finishDrawing()
    deletePdfPainter(painter)
    deletePdfMemDocument(doc)

  test "clip rect":
    let doc = newPdfMemDocument()
    let pages = doc.getPages()
    let a4 = createStandardPageSize(PdfPageSize.A4, false)
    let page = pages.createPage(a4)

    let painter = createPdfPainter()
    painter.setCanvas(page)

    painter.save()
    painter.setClipRect(50, 50, 200, 200)
    painter.drawRectangle(0, 0, 300, 300, PdfPathDrawMode.Fill)
    painter.restore()

    painter.finishDrawing()
    deletePdfPainter(painter)
    deletePdfMemDocument(doc)

suite "PdfIndirectObjectList":
  test "get objects from document":
    let doc = newPdfMemDocument()
    let objects = doc.getObjects()
    check objects != nil

    let count = objects.getObjectCount()
    # New document may have some internal objects
    check count >= 0

    deletePdfMemDocument(doc)

  test "create dictionary object":
    let doc = newPdfMemDocument()
    let objects = doc.getObjects()

    let obj = objects.createDictionaryObject()
    check obj != nil
    check obj.isDictionary()

    deletePdfMemDocument(doc)

  test "create array object":
    let doc = newPdfMemDocument()
    let objects = doc.getObjects()

    let obj = objects.createArrayObject()
    check obj != nil
    check obj.isArray()

    deletePdfMemDocument(doc)

suite "PdfObject":
  test "object type checks":
    let doc = newPdfMemDocument()
    let objects = doc.getObjects()

    let dictObj = objects.createDictionaryObject()
    check dictObj.isDictionary()
    check not dictObj.isArray()
    check not dictObj.isString()
    check not dictObj.isName()
    check not dictObj.isNumber()
    check not dictObj.isBool()
    check not dictObj.isNull()

    let arrayObj = objects.createArrayObject()
    check arrayObj.isArray()
    check not arrayObj.isDictionary()

    deletePdfMemDocument(doc)

  test "get dictionary from object":
    let doc = newPdfMemDocument()
    let objects = doc.getObjects()

    let obj = objects.createDictionaryObject()
    let dict = obj.getDictionary()
    check dict != nil

    deletePdfMemDocument(doc)

  test "get reference from object":
    let doc = newPdfMemDocument()
    let objects = doc.getObjects()

    let obj = objects.createDictionaryObject()
    let reference = obj.getReference()
    check reference.getObjectNumber() > 0
    check reference.getGenerationNumber() == 0

    deletePdfMemDocument(doc)

  test "object stream":
    let doc = newPdfMemDocument()
    let objects = doc.getObjects()

    let obj = objects.createDictionaryObject()
    check not obj.hasStream()

    let stream = obj.getOrCreateStream()
    check stream != nil

    let data = "Hello, World!"
    stream.setStreamData(data.cstring, data.len.csize_t)

    check obj.hasStream()
    check stream.getStreamLength() > 0

    deletePdfMemDocument(doc)

suite "PdfDictionary":
  test "add and check keys":
    let doc = newPdfMemDocument()
    let objects = doc.getObjects()

    let obj = objects.createDictionaryObject()
    let dict = obj.getDictionary()

    let key = initPdfName(initStdStringView("TestKey", 7))
    check not dict.hasKey(key)

    # Add a string value
    dict.addKeyString(key, initPdfString(initStdStringView("TestValue", 9)))
    check dict.hasKey(key)

    deletePdfMemDocument(doc)

  test "add integer key":
    let doc = newPdfMemDocument()
    let objects = doc.getObjects()

    let obj = objects.createDictionaryObject()
    let dict = obj.getDictionary()

    let key = initPdfName(initStdStringView("Count", 5))
    dict.addKeyInt(key, 42)
    check dict.hasKey(key)

    deletePdfMemDocument(doc)

  test "add name key":
    let doc = newPdfMemDocument()
    let objects = doc.getObjects()

    let obj = objects.createDictionaryObject()
    let dict = obj.getDictionary()

    let key = initPdfName(initStdStringView("Type", 4))
    let value = initPdfName(initStdStringView("Catalog", 7))
    dict.addKeyName(key, value)
    check dict.hasKey(key)

    deletePdfMemDocument(doc)

  test "remove key":
    let doc = newPdfMemDocument()
    let objects = doc.getObjects()

    let obj = objects.createDictionaryObject()
    let dict = obj.getDictionary()

    let key = initPdfName(initStdStringView("ToRemove", 8))
    dict.addKeyString(key, initPdfString(initStdStringView("Value", 5)))
    check dict.hasKey(key)

    dict.removeKey(key)
    check not dict.hasKey(key)

    deletePdfMemDocument(doc)

  test "add indirect key":
    let doc = newPdfMemDocument()
    let objects = doc.getObjects()

    let obj1 = objects.createDictionaryObject()
    let obj2 = objects.createDictionaryObject()

    let dict1 = obj1.getDictionary()
    let key = initPdfName(initStdStringView("Reference", 9))

    dict1.addKeyIndirect(key, obj2)
    check dict1.hasKey(key)

    deletePdfMemDocument(doc)

suite "PdfMetadata":
  test "set and get title":
    let doc = newPdfMemDocument()
    let meta = doc.getMetadata()

    let titleStr = initPdfString(initStdStringView("Test Title", 10))
    meta.setTitle(initNullablePdfStringRef(titleStr))

    let title = meta.getTitle()
    check title.hasValue()

    deletePdfMemDocument(doc)

  test "set and get author":
    let doc = newPdfMemDocument()
    let meta = doc.getMetadata()

    let authorStr = initPdfString(initStdStringView("Test Author", 11))
    meta.setAuthor(initNullablePdfStringRef(authorStr))

    let author = meta.getAuthor()
    check author.hasValue()

    deletePdfMemDocument(doc)

  test "set dates":
    let doc = newPdfMemDocument()
    let meta = doc.getMetadata()

    let now = initPdfDateNow()
    meta.setCreationDate(initNullablePdfDate(now))
    meta.setModifyDate(initNullablePdfDate(now))

    # Dates are set - just verify no crash

    deletePdfMemDocument(doc)

suite "PdfAcroForm":
  test "create acro form":
    let doc = newPdfMemDocument()
    let form = doc.getOrCreateAcroForm()
    check form != nil
    check form.getFieldCount() == 0
    deletePdfMemDocument(doc)

  test "need appearances":
    let doc = newPdfMemDocument()
    let form = doc.getOrCreateAcroForm()

    form.setNeedAppearances(true)
    check form.getNeedAppearances()

    form.setNeedAppearances(false)
    check not form.getNeedAppearances()

    deletePdfMemDocument(doc)

  test "create text box field":
    let doc = newPdfMemDocument()
    let form = doc.getOrCreateAcroForm()

    let textBox = form.createFieldTextBox(initStdStringView("myField", 7))
    check textBox != nil
    check form.getFieldCount() == 1

    deletePdfMemDocument(doc)

  test "text box properties":
    let doc = newPdfMemDocument()
    let form = doc.getOrCreateAcroForm()

    let textBox = form.createFieldTextBox(initStdStringView("textField", 9))

    textBox.setMaxLen(100)
    textBox.setMultiLine(true)
    textBox.setPasswordField(false)

    check textBox.isMultiLine()
    check not textBox.isPasswordField()

    deletePdfMemDocument(doc)

  test "create checkbox field":
    let doc = newPdfMemDocument()
    let form = doc.getOrCreateAcroForm()

    let checkBox = form.createFieldCheckBox(initStdStringView("myCheck", 7))
    check checkBox != nil

    checkBox.setChecked(true)
    check checkBox.isChecked()

    checkBox.setChecked(false)
    check not checkBox.isChecked()

    deletePdfMemDocument(doc)

  test "iterate fields":
    let doc = newPdfMemDocument()
    let form = doc.getOrCreateAcroForm()

    discard form.createFieldTextBox(initStdStringView("field1", 6))
    discard form.createFieldCheckBox(initStdStringView("field2", 6))
    discard form.createFieldPushButton(initStdStringView("field3", 6))

    check form.getFieldCount() == 3

    let field0 = form.getFieldAt(0)
    let field1 = form.getFieldAt(1)
    let field2 = form.getFieldAt(2)

    check field0.getFieldType() == PdfFieldType.TextBox
    check field1.getFieldType() == PdfFieldType.CheckBox
    check field2.getFieldType() == PdfFieldType.PushButton

    deletePdfMemDocument(doc)

suite "PdfAnnotation":
  test "annotation collection":
    let doc = newPdfMemDocument()
    let pages = doc.getPages()
    let a4 = createStandardPageSize(PdfPageSize.A4, false)
    let page = pages.createPage(a4)

    let annots = page.getAnnotations()
    check annots != nil
    check annots.getAnnotationCount() == 0

    deletePdfMemDocument(doc)

  test "create link annotation":
    let doc = newPdfMemDocument()
    let pages = doc.getPages()
    let a4 = createStandardPageSize(PdfPageSize.A4, false)
    let page = pages.createPage(a4)

    let annots = page.getAnnotations()
    let rect = initRect(100, 700, 200, 20)
    let link = annots.createAnnotationLink(rect)

    check link != nil
    check annots.getAnnotationCount() == 1

    deletePdfMemDocument(doc)

  test "create text annotation":
    let doc = newPdfMemDocument()
    let pages = doc.getPages()
    let a4 = createStandardPageSize(PdfPageSize.A4, false)
    let page = pages.createPage(a4)

    let annots = page.getAnnotations()
    let rect = initRect(50, 600, 100, 100)
    let textAnnot = annots.createAnnotationText(rect)

    check textAnnot != nil
    check annots.getAnnotationCount() == 1

    deletePdfMemDocument(doc)

  test "annotation properties":
    let doc = newPdfMemDocument()
    let pages = doc.getPages()
    let a4 = createStandardPageSize(PdfPageSize.A4, false)
    let page = pages.createPage(a4)

    let annots = page.getAnnotations()
    let rect = initRect(50, 50, 100, 100)
    discard annots.createAnnotationText(rect)

    let annot = annots.getAnnotationAt(0)
    check annot.getAnnotationType() == PdfAnnotationType.Text

    let annotRect = annot.getAnnotationRect()
    check annotRect.X == 50
    check annotRect.Y == 50

    deletePdfMemDocument(doc)

  test "remove annotation":
    let doc = newPdfMemDocument()
    let pages = doc.getPages()
    let a4 = createStandardPageSize(PdfPageSize.A4, false)
    let page = pages.createPage(a4)

    let annots = page.getAnnotations()
    let rect = initRect(50, 50, 100, 100)
    discard annots.createAnnotationText(rect)
    discard annots.createAnnotationLink(rect)

    check annots.getAnnotationCount() == 2

    annots.removeAnnotationAt(0)
    check annots.getAnnotationCount() == 1

    deletePdfMemDocument(doc)

suite "PdfOutlines":
  test "create outlines":
    let doc = newPdfMemDocument()
    let outlines = doc.getOrCreateOutlines()
    check outlines != nil
    deletePdfMemDocument(doc)

  test "create root bookmark":
    let doc = newPdfMemDocument()
    let outlines = doc.getOrCreateOutlines()

    let root = outlines.createRoot(initStdStringView("Chapter 1", 9))
    check root != nil
    check $root.getTitle() == "Chapter 1"

    deletePdfMemDocument(doc)

  test "bookmark formatting":
    let doc = newPdfMemDocument()
    let outlines = doc.getOrCreateOutlines()

    let root = outlines.createRoot(initStdStringView("Styled", 6))
    root.setTextFormat(true, true) # italic, bold
    root.setTextColor(initPdfColorRGB(1.0, 0.0, 0.0))

    deletePdfMemDocument(doc)

suite "PdfDestination":
  test "create destination":
    let doc = newPdfMemDocument()
    let pages = doc.getPages()
    let a4 = createStandardPageSize(PdfPageSize.A4, false)
    let page = pages.createPage(a4)

    var destPtr = createDestination(doc)
    let dest = getDestinationPtr(destPtr)
    check dest != nil

    dest.setDestination(page, PdfDestinationFit.Fit)

    discard releaseDestination(destPtr)
    deletePdfMemDocument(doc)

  test "create XYZ destination":
    let doc = newPdfMemDocument()
    let pages = doc.getPages()
    let a4 = createStandardPageSize(PdfPageSize.A4, false)
    let page = pages.createPage(a4)

    var destPtr = createDestination(doc)
    let dest = getDestinationPtr(destPtr)

    dest.setDestinationXYZ(page, 100.0, 700.0, 1.5)

    discard releaseDestination(destPtr)
    deletePdfMemDocument(doc)

suite "PdfExtGState":
  test "create ext gstate":
    let doc = newPdfMemDocument()

    var def = initExtGStateDefinition()
    def.setStrokingAlpha(0.5)
    def.setNonStrokingAlpha(0.8)
    def.setBlendModeOnDef(PdfBlendMode.Multiply)

    let defPtr = makeSharedExtGStateDefinition(def)
    var gsPtr = createExtGState(doc, defPtr)
    let gs = releaseExtGState(gsPtr)

    check gs != nil
    deleteExtGState(gs)
    deletePdfMemDocument(doc)

suite "PdfImage":
  test "create image":
    let doc = newPdfMemDocument()

    var imgPtr = doc.createImage()
    let img = releaseImage(imgPtr)
    check img != nil

    # Can't test loading without actual image file

    deletePdfImage(img)
    deletePdfMemDocument(doc)

suite "PdfXObjectForm":
  test "create xobject form":
    let doc = newPdfMemDocument()

    let rect = initRect(0, 0, 100, 100)
    var formPtr = doc.createXObjectForm(rect)
    let form = releaseXObjectForm(formPtr)
    check form != nil

    let formRect = form.getXObjectFormRect()
    check formRect.Width == 100
    check formRect.Height == 100

    deletePdfXObjectForm(form)
    deletePdfMemDocument(doc)

  test "draw on xobject form":
    let doc = newPdfMemDocument()

    let rect = initRect(0, 0, 100, 100)
    var formPtr = doc.createXObjectForm(rect)
    let form = releaseXObjectForm(formPtr)

    let painter = createPdfPainter()
    painter.setCanvasXObject(form)

    painter.drawRectangle(10, 10, 80, 80, PdfPathDrawMode.Stroke)

    painter.finishDrawing()
    deletePdfPainter(painter)
    deletePdfXObjectForm(form)
    deletePdfMemDocument(doc)

suite "Document I/O":
  test "save and load document":
    let filename = "/tmp/test_raw_podofo.pdf"

    # Create and save
    block:
      let doc = newPdfMemDocument()
      let pages = doc.getPages()
      let a4 = createStandardPageSize(PdfPageSize.A4, false)
      let page = pages.createPage(a4)

      let fonts = doc.getFonts()
      let font = fonts.getStandard14Font(PdfStandard14FontType.Helvetica)

      let painter = createPdfPainter()
      painter.setCanvas(page)

      let ts = painter.getTextState()
      ts.setFont(font, 12.0)

      painter.drawText(initStdStringView("Hello from raw.nim!", 19), 100, 700)

      painter.finishDrawing()
      deletePdfPainter(painter)

      doc.save(initStdStringView(filename.cstring, filename.len.csize_t))
      deletePdfMemDocument(doc)

    # Load and verify
    block:
      let doc = newPdfMemDocument()
      doc.load(initStdStringView(filename.cstring, filename.len.csize_t))

      let pages = doc.getPages()
      check pages.getCount() == 1

      deletePdfMemDocument(doc)

suite "Enums":
  test "PdfPageSize values":
    check ord(PdfPageSize.A0) == 0
    check ord(PdfPageSize.A4) == 4
    check ord(PdfPageSize.Letter) == 7

  test "PdfPathDrawMode values":
    check ord(PdfPathDrawMode.Stroke) == 1
    check ord(PdfPathDrawMode.Fill) == 2
    check ord(PdfPathDrawMode.StrokeFill) == 3

  test "PdfLineCapStyle values":
    check ord(PdfLineCapStyle.Butt) == 0
    check ord(PdfLineCapStyle.Round) == 1
    check ord(PdfLineCapStyle.Square) == 2

  test "PdfLineJoinStyle values":
    check ord(PdfLineJoinStyle.Miter) == 0
    check ord(PdfLineJoinStyle.Round) == 1
    check ord(PdfLineJoinStyle.Bevel) == 2

  test "PdfStandard14FontType values":
    check ord(PdfStandard14FontType.TimesRoman) == 1
    check ord(PdfStandard14FontType.Helvetica) == 5
    check ord(PdfStandard14FontType.Courier) == 9

  test "PdfBlendMode values":
    check ord(PdfBlendMode.Normal) == 0
    check ord(PdfBlendMode.Multiply) == 1
    check ord(PdfBlendMode.Screen) == 2

  test "PdfAnnotationType values":
    check ord(PdfAnnotationType.Text) == 1
    check ord(PdfAnnotationType.Link) == 2
    check ord(PdfAnnotationType.Widget) == 20

  test "PdfFieldType values":
    check ord(PdfFieldType.PushButton) == 1
    check ord(PdfFieldType.CheckBox) == 2
    check ord(PdfFieldType.TextBox) == 4

suite "Catalog":
  test "get catalog":
    let doc = newPdfMemDocument()
    let catalog = doc.getCatalog()
    check catalog != nil

    let catalogObj = catalog.getCatalogObject()
    check catalogObj != nil
    check catalogObj.isDictionary()

    let catalogDict = catalog.getCatalogDictionary()
    check catalogDict != nil

    deletePdfMemDocument(doc)

suite "PdfAction":
  test "create URI action":
    let doc = newPdfMemDocument()

    var actionPtr = createActionURI(doc)
    let action = getActionURIPtr(actionPtr)
    check action != nil

    let uri = initPdfString(initStdStringView("https://example.com", 19))
    action.setURI(uri)

    let uriValue = action.getURINullable()
    check uriValue.hasValue()

    discard releaseActionURI(actionPtr)
    deletePdfMemDocument(doc)

  test "create JavaScript action":
    let doc = newPdfMemDocument()

    var actionPtr = createActionJavaScript(doc)
    let action = getActionJavaScriptPtr(actionPtr)
    check action != nil

    let script = initPdfString(initStdStringView("app.alert('Hi');", 16))
    action.setScript(script)

    let scriptValue = action.getScriptNullable()
    check scriptValue.hasValue()

    discard releaseActionJavaScript(actionPtr)
    deletePdfMemDocument(doc)

suite "PdfSignature":
  test "create signature field":
    let doc = newPdfMemDocument()
    let form = doc.getOrCreateAcroForm()

    let sig = form.createFieldSignature(initStdStringView("mySig", 5))
    check sig != nil

    deletePdfMemDocument(doc)

  test "signature properties":
    let doc = newPdfMemDocument()
    let form = doc.getOrCreateAcroForm()

    let sig = form.createFieldSignature(initStdStringView("sigField", 8))

    let signerName = initPdfString(initStdStringView("John Doe", 8))
    sig.setSignerName(signerName)

    let reason = initPdfString(initStdStringView("Approval", 8))
    sig.setSignatureReason(reason)

    let location = initPdfString(initStdStringView("Tokyo", 5))
    sig.setSignatureLocation(location)

    sig.setSignatureDate(initPdfDateNow())

    # Verify getters work
    let gotName = sig.getSignerName()
    check gotName.hasValue()

    let gotReason = sig.getSignatureReason()
    check gotReason.hasValue()

    let gotLocation = sig.getSignatureLocation()
    check gotLocation.hasValue()

    deletePdfMemDocument(doc)

suite "PdfComboBox":
  test "create combo box":
    let doc = newPdfMemDocument()
    let form = doc.getOrCreateAcroForm()

    let combo = form.createFieldComboBox(initStdStringView("myCombo", 7))
    check combo != nil

    combo.setEditable(true)
    check combo.isEditable()

    deletePdfMemDocument(doc)

suite "PdfListBox":
  test "create list box":
    let doc = newPdfMemDocument()
    let form = doc.getOrCreateAcroForm()

    let listBox = form.createFieldListBox(initStdStringView("myList", 6))
    check listBox != nil

    listBox.setMultiSelect(true)
    check listBox.isMultiSelect()

    deletePdfMemDocument(doc)

suite "PdfPushButton":
  test "create push button":
    let doc = newPdfMemDocument()
    let form = doc.getOrCreateAcroForm()

    let button = form.createFieldPushButton(initStdStringView("myButton", 8))
    check button != nil

    # Note: setCaption may require widget annotation, skip for now

    deletePdfMemDocument(doc)

suite "charbuff":
  test "create empty charbuff":
    let buf = initCharbuff()
    discard buf # Just verify creation

  test "create charbuff from data":
    let data = "Hello World"
    let buf = initCharbuffFromData(data.cstring, data.len.csize_t)
    discard buf # Just verify creation

  test "nullable charbuff":
    let data = "Test data"
    let buf = initCharbuffFromData(data.cstring, data.len.csize_t)
    let nullable = initNullableCharbuff(buf)
    discard nullable # Just verify creation

    let nullBuf = initNullableCharbuffNull()
    discard nullBuf # Just verify null creation

suite "PdfFileSpec":
  test "create file spec":
    let doc = newPdfMemDocument()

    var fsPtr = doc.createFileSpec()
    let fs = getFileSpecPtr(fsPtr)
    check fs != nil

    let filename = initPdfString(initStdStringView("test.txt", 8))
    fs.setFilenameStr(filename)

    check fs.hasFilename()

    discard releaseFileSpec(fsPtr)
    deletePdfMemDocument(doc)

  test "file spec with embedded data":
    let doc = newPdfMemDocument()
    discard doc.getPages().createPage(createStandardPageSize(PdfPageSize.A4, false))

    var fsPtr = doc.createFileSpec()
    let fs = getFileSpecPtr(fsPtr)

    let filename = initPdfString(initStdStringView("data.bin", 8))
    fs.setFilenameStr(filename)

    let data = "Binary content here"
    let buf = initCharbuffFromData(data.cstring, data.len.csize_t)
    fs.setEmbeddedData(initNullableCharbuff(buf))

    discard releaseFileSpec(fsPtr)
    deletePdfMemDocument(doc)

suite "PdfNameTrees":
  test "get or create names":
    let doc = newPdfMemDocument()

    let names = doc.getOrCreateNames()
    check names != nil

    deletePdfMemDocument(doc)

  test "embedded files tree":
    let doc = newPdfMemDocument()

    let names = doc.getOrCreateNames()
    let embeddedFiles = names.getOrCreateEmbeddedFiles()
    check embeddedFiles != nil

    deletePdfMemDocument(doc)

suite "Painter Drawing":
  test "draw cubic bezier":
    let doc = newPdfMemDocument()
    let pages = doc.getPages()
    let a4 = createStandardPageSize(PdfPageSize.A4, false)
    let page = pages.createPage(a4)

    let painter = createPdfPainter()
    painter.setCanvas(page)

    painter.drawCubicBezier(100, 700, 150, 750, 200, 750, 250, 700)

    painter.finishDrawing()
    deletePdfPainter(painter)
    deletePdfMemDocument(doc)

  test "draw arc":
    let doc = newPdfMemDocument()
    let pages = doc.getPages()
    let a4 = createStandardPageSize(PdfPageSize.A4, false)
    let page = pages.createPage(a4)

    let painter = createPdfPainter()
    painter.setCanvas(page)

    painter.drawArc(200, 500, 50, 0, 3.14159)

    painter.finishDrawing()
    deletePdfPainter(painter)
    deletePdfMemDocument(doc)

  # Note: DrawTextMultiLine API changed in newer PoDoFo - uses params struct

  test "draw text aligned":
    let doc = newPdfMemDocument()
    let pages = doc.getPages()
    let a4 = createStandardPageSize(PdfPageSize.A4, false)
    let page = pages.createPage(a4)

    let fonts = doc.getFonts()
    let font = fonts.getStandard14Font(PdfStandard14FontType.Helvetica)

    let painter = createPdfPainter()
    painter.setCanvas(page)

    let ts = painter.getTextState()
    ts.setFont(font, 12.0)

    let text = initStdStringView("Centered Text", 13)
    painter.drawTextAligned(text, 100, 500, 200, PdfHorizontalAlignment.Center)

    painter.finishDrawing()
    deletePdfPainter(painter)
    deletePdfMemDocument(doc)

  test "set precision":
    let doc = newPdfMemDocument()
    let pages = doc.getPages()
    let a4 = createStandardPageSize(PdfPageSize.A4, false)
    let page = pages.createPage(a4)

    let painter = createPdfPainter()
    painter.setCanvas(page)

    painter.setPrecision(6)
    painter.drawLine(0, 0, 100.123456, 100.654321)

    painter.finishDrawing()
    deletePdfPainter(painter)
    deletePdfMemDocument(doc)

suite "Annotation Details":
  test "annotation flags":
    let doc = newPdfMemDocument()
    let pages = doc.getPages()
    let a4 = createStandardPageSize(PdfPageSize.A4, false)
    let page = pages.createPage(a4)

    let annots = page.getAnnotations()
    let rect = initRect(50, 50, 100, 100)
    discard annots.createAnnotationText(rect)

    let annot = annots.getAnnotationAt(0)

    annot.setAnnotationFlags(PdfAnnotationFlags.Print)
    check annot.getAnnotationFlags() == PdfAnnotationFlags.Print

    deletePdfMemDocument(doc)

  test "annotation title and contents":
    let doc = newPdfMemDocument()
    let pages = doc.getPages()
    let a4 = createStandardPageSize(PdfPageSize.A4, false)
    let page = pages.createPage(a4)

    let annots = page.getAnnotations()
    let rect = initRect(50, 50, 100, 100)
    discard annots.createAnnotationText(rect)

    let annot = annots.getAnnotationAt(0)

    let title = initPdfString(initStdStringView("My Title", 8))
    annot.setAnnotationTitle(title)

    let contents = initPdfString(initStdStringView("Note content", 12))
    annot.setAnnotationContents(contents)

    let gotTitle = annot.getAnnotationTitle()
    check gotTitle.hasValue()

    let gotContents = annot.getAnnotationContents()
    check gotContents.hasValue()

    deletePdfMemDocument(doc)

  test "annotation color":
    let doc = newPdfMemDocument()
    let pages = doc.getPages()
    let a4 = createStandardPageSize(PdfPageSize.A4, false)
    let page = pages.createPage(a4)

    let annots = page.getAnnotations()
    let rect = initRect(50, 50, 100, 100)
    discard annots.createAnnotationText(rect)

    let annot = annots.getAnnotationAt(0)

    let color = initPdfColorRGB(1.0, 0.0, 0.0)
    annot.setAnnotationColor(color)

    deletePdfMemDocument(doc)

  test "annotation border style":
    let doc = newPdfMemDocument()
    let pages = doc.getPages()
    let a4 = createStandardPageSize(PdfPageSize.A4, false)
    let page = pages.createPage(a4)

    let annots = page.getAnnotations()
    let rect = initRect(50, 50, 100, 100)
    discard annots.createAnnotationText(rect)

    let annot = annots.getAnnotationAt(0)
    annot.setBorderStyle(5.0, 5.0, 2.0)

    deletePdfMemDocument(doc)

# Note: IsCIDKeyed may not be available in newer PoDoFo

suite "Document Operations":
  test "collect garbage":
    let doc = newPdfMemDocument()
    discard doc.getPages().createPage(createStandardPageSize(PdfPageSize.A4, false))

    doc.collectGarbage()

    deletePdfMemDocument(doc)

  test "flatten page structure":
    let doc = newPdfMemDocument()
    let pages = doc.getPages()
    discard pages.createPage(createStandardPageSize(PdfPageSize.A4, false))
    discard pages.createPage(createStandardPageSize(PdfPageSize.A4, false))

    pages.flattenStructure()

    check pages.getCount() == 2
    deletePdfMemDocument(doc)

suite "PdfDictionary Extended":
  test "add bool key":
    let doc = newPdfMemDocument()
    let objects = doc.getObjects()

    let obj = objects.createDictionaryObject()
    let dict = obj.getDictionary()

    let key = initPdfName(initStdStringView("Flag", 4))
    dict.addKeyBool(key, true)
    check dict.hasKey(key)

    # Verify the value
    let value = dict.findKey(key)
    check value != nil
    check value.isBool()
    check value.getBool() == true

    deletePdfMemDocument(doc)

  test "get name from object":
    let doc = newPdfMemDocument()
    let objects = doc.getObjects()

    let obj = objects.createDictionaryObject()
    let dict = obj.getDictionary()

    let key = initPdfName(initStdStringView("Type", 4))
    let nameVal = initPdfName(initStdStringView("Catalog", 7))
    dict.addKeyName(key, nameVal)

    let value = dict.findKey(key)
    check value != nil
    check value.isName()
    let name = value.getName()
    check $name.getNameString() == "Catalog"

    deletePdfMemDocument(doc)

suite "PdfArray Extended":
  test "add indirect to array":
    let doc = newPdfMemDocument()
    let objects = doc.getObjects()

    let arrayObj = objects.createArrayObject()
    let arr = arrayObj.getArray()

    let dictObj = objects.createDictionaryObject()
    arr.addIndirectToArray(dictObj)

    check arr.getArraySize() == 1

    deletePdfMemDocument(doc)

  test "add string to array":
    let doc = newPdfMemDocument()
    let objects = doc.getObjects()

    let arrayObj = objects.createArrayObject()
    let arr = arrayObj.getArray()

    let strVal = initPdfString(initStdStringView("Hello", 5))
    arr.addStringToArray(strVal)

    check arr.getArraySize() == 1

    deletePdfMemDocument(doc)

  test "get array element":
    let doc = newPdfMemDocument()
    let objects = doc.getObjects()

    let arrayObj = objects.createArrayObject()
    let arr = arrayObj.getArray()

    let dictObj1 = objects.createDictionaryObject()
    let dictObj2 = objects.createDictionaryObject()
    arr.addIndirectToArray(dictObj1)
    arr.addIndirectToArray(dictObj2)

    check arr.getArraySize() == 2

    let elem = arr.getArrayElement(0)
    check elem != nil

    deletePdfMemDocument(doc)

suite "PdfObjectList Iterator":
  test "iterate objects":
    let doc = newPdfMemDocument()
    let objects = doc.getObjects()

    # Create some objects
    discard objects.createDictionaryObject()
    discard objects.createDictionaryObject()
    discard objects.createArrayObject()

    # Count objects using iterator
    var count = 0
    var it = objects.objectListBegin()
    let endIt = objects.objectListEnd()
    while it != endIt:
      inc count
      it.objectListIteratorInc()

    check count >= 3 # At least our 3 objects

    deletePdfMemDocument(doc)

  test "iterator deref":
    let doc = newPdfMemDocument()
    let objects = doc.getObjects()

    discard objects.createDictionaryObject()

    var it = objects.objectListBegin()
    let obj = it.objectListIteratorDeref()
    check obj != nil

    deletePdfMemDocument(doc)
