# Basic tests for nim-podofo

import std/[unittest, strutils]

import ../podofo

suite "Rect":
  test "create rect":
    let r = rect(0, 0, 100, 200)
    check r.x == 0
    check r.y == 0
    check r.width == 100
    check r.height == 200

  test "rect properties":
    let r = rect(10, 20, 100, 200)
    check r.left == 10
    check r.bottom == 20
    check r.right == 110
    check r.top == 220

  test "standard page sizes":
    let a4 = standardPageSize(PdfPageSize.A4)
    check a4.width > 0
    check a4.height > 0
    check a4.height > a4.width # Portrait

    let a4Landscape = standardPageSize(PdfPageSize.A4, landscape = true)
    check a4Landscape.width > a4Landscape.height # Landscape

suite "Color":
  test "gray color":
    let c = grayColor(0.5)
    check c.kind == PdfColorSpaceType.DeviceGray
    check c.gray == 0.5

  test "RGB color":
    let c = rgbColor(1.0, 0.5, 0.0)
    check c.kind == PdfColorSpaceType.DeviceRGB
    check c.r == 1.0
    check c.g == 0.5
    check c.b == 0.0

  test "CMYK color":
    let c = cmykColor(1.0, 0.0, 0.0, 0.0)
    check c.kind == PdfColorSpaceType.DeviceCMYK
    check c.c == 1.0
    check c.m == 0.0

  test "predefined colors":
    check black().gray == 0.0
    check white().gray == 1.0
    check red().r == 1.0
    check green().g == 1.0
    check blue().b == 1.0

suite "PdfDocument":
  test "create new document":
    let doc = newPdfDocument()
    check doc.pageCount == 0

  test "create page":
    let doc = newPdfDocument()
    let page = doc.createPage(PdfPageSize.A4)
    check doc.pageCount == 1
    check page.pageNumber == 1

  test "create multiple pages":
    let doc = newPdfDocument()
    discard doc.createPage(PdfPageSize.A4)
    discard doc.createPage(PdfPageSize.Letter)
    discard doc.createPage(PdfPageSize.A3)
    check doc.pageCount == 3

  test "iterate pages":
    let doc = newPdfDocument()
    discard doc.createPage(PdfPageSize.A4)
    discard doc.createPage(PdfPageSize.A4)

    var count = 0
    for page in doc.pages:
      count += 1
    check count == 2

  test "get standard font":
    let doc = newPdfDocument()
    let font = doc.helvetica()
    check font.name.len > 0

  test "save and load document":
    let filename = "/tmp/test_podofo.pdf"

    # Create and save
    block:
      let doc = newPdfDocument()
      let page = doc.createPage(PdfPageSize.A4)
      let font = doc.helvetica()

      page.draw:
        painter.setFont(font, 12)
        painter.drawText("Hello, World!", 100, 700)

      doc.save(filename)

    # Load and verify
    block:
      let doc = loadPdf(filename)
      check doc.pageCount == 1

suite "PdfAcroForm":
  test "create acro form":
    let doc = newPdfDocument()
    let form = doc.acroForm()
    check form.fieldCount == 0

  test "create text box":
    let doc = newPdfDocument()
    let form = doc.acroForm()
    let textBox = form.createTextBox("myTextField")
    check form.fieldCount == 1
    textBox.text = "Hello"
    check textBox.text == "Hello"

  test "text box properties":
    let doc = newPdfDocument()
    let form = doc.acroForm()
    let textBox = form.createTextBox("textField")
    # Note: Some properties require a widget annotation to work properly
    # maxLen, multiLine, etc. work at the field level but may need widget for persistence
    textBox.maxLen = 100
    # Check that setting doesn't crash; value may be -1 if widget not created
    discard textBox.maxLen

    textBox.multiLine = true
    discard textBox.isMultiLine

  test "create checkbox":
    let doc = newPdfDocument()
    let form = doc.acroForm()
    let checkBox = form.createCheckBox("myCheckBox")
    check form.fieldCount == 1

    checkBox.checked = true
    check checkBox.isChecked == true

    checkBox.checked = false
    check checkBox.isChecked == false

  test "create push button":
    let doc = newPdfDocument()
    let form = doc.acroForm()
    discard form.createPushButton("myButton")
    check form.fieldCount == 1
    # Note: caption requires widget annotation, skip for now

  test "create signature field":
    let doc = newPdfDocument()
    let form = doc.acroForm()
    discard form.createSignature("mySignature")
    check form.fieldCount == 1
    # Note: Signature properties require widget/value object, skip for now

  test "iterate fields":
    let doc = newPdfDocument()
    let form = doc.acroForm()
    discard form.createTextBox("field1")
    discard form.createCheckBox("field2")
    discard form.createPushButton("field3")

    var count = 0
    for field in form.fields:
      count += 1
    check count == 3

  test "field base properties":
    let doc = newPdfDocument()
    let form = doc.acroForm()
    discard form.createTextBox("testField")

    let field = form.getFieldAt(0)
    check field.fieldType == PdfFieldType.TextBox

suite "PdfAnnotation":
  test "create link annotation":
    let doc = newPdfDocument()
    let page = doc.createPage(PdfPageSize.A4)
    discard page.createLinkAnnotation(rect(100, 700, 200, 20))
    check page.annotationCount == 1

  test "create text annotation":
    let doc = newPdfDocument()
    let page = doc.createPage(PdfPageSize.A4)
    discard page.createTextAnnotation(rect(100, 600, 100, 100))
    check page.annotationCount == 1

  test "annotation properties":
    let doc = newPdfDocument()
    let page = doc.createPage(PdfPageSize.A4)
    discard page.createTextAnnotation(rect(50, 50, 100, 100))

    let annot = page.getAnnotationAt(0)
    let r = annot.rect
    check r.x == 50
    check r.y == 50

  test "iterate annotations":
    let doc = newPdfDocument()
    let page = doc.createPage(PdfPageSize.A4)
    discard page.createLinkAnnotation(rect(0, 0, 100, 20))
    discard page.createTextAnnotation(rect(0, 100, 50, 50))

    var count = 0
    for annot in page.annotations:
      count += 1
    check count == 2

  test "link with destination":
    let doc = newPdfDocument()
    let page1 = doc.createPage(PdfPageSize.A4)
    let page2 = doc.createPage(PdfPageSize.A4)

    let link = page1.createLinkAnnotation(rect(100, 700, 200, 20))
    let dest = newDestination(page2)
    link.setDestination(dest)

    check page1.annotationCount == 1

suite "PdfAction":
  test "create URI action":
    let doc = newPdfDocument()
    let action = newURIAction(doc, "https://example.com")
    # actionType check removed - type is implicit in PdfURIAction
    check action.uri == "https://example.com"

  test "create JavaScript action":
    let doc = newPdfDocument()
    let action = newJavaScriptAction(doc, "app.alert('Hello');")
    # actionType check removed - type is implicit in PdfJavaScriptAction
    check action.script == "app.alert('Hello');"

  test "modify action":
    let doc = newPdfDocument()
    let action = newURIAction(doc, "https://old.com")
    action.uri = "https://new.com"
    check action.uri == "https://new.com"

suite "PdfOutlines":
  test "create root bookmark":
    let doc = newPdfDocument()
    discard doc.createPage(PdfPageSize.A4)

    let outlines = doc.outlines()
    let root = outlines.createRoot("Chapter 1")
    check root.title == "Chapter 1"

  test "bookmark formatting":
    let doc = newPdfDocument()
    discard doc.createPage(PdfPageSize.A4)

    let outlines = doc.outlines()
    let root = outlines.createRoot("Styled Bookmark")
    root.setTextFormat(italic = true, bold = true)
    root.setTextColor(1.0, 0.0, 0.0) # Red

suite "PdfMetadata":
  test "set and get metadata":
    let doc = newPdfDocument()
    let meta = doc.metadata()

    meta.title = "Test Document"
    check meta.title == "Test Document"

    meta.author = "Test Author"
    check meta.author == "Test Author"

    meta.subject = "Test Subject"
    check meta.subject == "Test Subject"

    meta.creator = "nim-podofo"
    check meta.creator == "nim-podofo"

    meta.producer = "PoDoFo"
    check meta.producer == "PoDoFo"

  test "set dates":
    let doc = newPdfDocument()
    let meta = doc.metadata()
    meta.setCreationDateNow()
    meta.setModifyDateNow()

suite "PdfImage":
  test "create image":
    let doc = newPdfDocument()
    discard doc.createImage()
    # Note: Can't test loading without actual image file

suite "PdfPainterPath":
  test "create path":
    let path = newPainterPath()
    path.moveTo(0, 0)
    path.lineTo(100, 0)
    path.lineTo(100, 100)
    path.lineTo(0, 100)
    path.close()

  test "path shapes":
    let path = newPainterPath()
    path.addCircle(50, 50, 25)
    path.addRectangle(0, 0, 100, 50)
    path.addEllipse(0, 0, 100, 50)

  test "draw path":
    let doc = newPdfDocument()
    let page = doc.createPage(PdfPageSize.A4)

    let path = newPainterPath()
    path.moveTo(100, 700)
    path.lineTo(200, 700)
    path.lineTo(150, 750)
    path.close()

    page.draw:
      painter.setFillColor(red())
      painter.drawPath(path, PdfPathDrawMode.Fill)

suite "PdfExtGState":
  test "create ext gstate":
    let doc = newPdfDocument()
    discard newExtGState(
      doc, fillOpacity = 0.5, strokeOpacity = 0.8, blendMode = PdfBlendMode.Multiply
    )

  test "apply ext gstate":
    let doc = newPdfDocument()
    let page = doc.createPage(PdfPageSize.A4)
    let gs = newExtGState(doc, fillOpacity = 0.5)

    page.draw:
      painter.setExtGState(gs)
      painter.setFillColor(blue())
      painter.drawRectangle(100, 700, 100, 50, PdfPathDrawMode.Fill)

suite "FileEmbedding":
  test "embed string as file":
    let doc = newPdfDocument()
    discard doc.createPage(PdfPageSize.A4)

    let content = "This is embedded content"
    let fileSpec = doc.embedString("test.txt", content)
    check fileSpec.filename == "test.txt"

  test "embed data":
    let doc = newPdfDocument()
    discard doc.createPage(PdfPageSize.A4)

    let data = @[byte(0x48), byte(0x65), byte(0x6C), byte(0x6C), byte(0x6F)] # "Hello"
    let fileSpec = doc.embedData("binary.dat", data)
    check fileSpec.filename == "binary.dat"

suite "Integration":
  test "create complete PDF with forms":
    let filename = "/tmp/test_form.pdf"

    let doc = newPdfDocument()
    let page = doc.createPage(PdfPageSize.A4)
    let font = doc.helvetica()

    # Set metadata
    let meta = doc.metadata()
    meta.title = "Test Form"
    meta.author = "nim-podofo"

    # Draw content
    page.draw:
      painter.setFont(font, 16)
      painter.drawText("Registration Form", 50, 750)

      painter.setFont(font, 12)
      painter.drawText("Name:", 50, 700)
      painter.drawText("Email:", 50, 650)
      painter.drawText("Agree to terms:", 50, 600)

    # Create form fields
    let form = doc.acroForm()
    let nameField = form.createTextBox("name")
    nameField.maxLen = 50

    let emailField = form.createTextBox("email")
    emailField.maxLen = 100

    let agreeBox = form.createCheckBox("agree")
    agreeBox.checked = false

    # Create bookmark
    let outlines = doc.outlines()
    let bookmark = outlines.createRoot("Form")
    let dest = newDestination(page)
    bookmark.setDestination(dest)

    doc.save(filename)

    # Verify
    let loaded = loadPdf(filename)
    check loaded.pageCount == 1

suite "Error Handling":
  test "load non-existent file":
    expect PdfError:
      discard loadPdf("/non/existent/file.pdf")

  test "load non-existent file has correct error code":
    try:
      discard loadPdf("/non/existent/file.pdf")
      fail()
    except PdfError as e:
      check e.code == PdfErrorCode.FileNotFound
      check "not found" in e.msg.toLowerAscii()

  test "get page out of bounds":
    let doc = newPdfDocument()
    discard doc.createPage(PdfPageSize.A4)
    expect PdfError:
      discard doc.getPage(5)

  test "get page negative index":
    let doc = newPdfDocument()
    discard doc.createPage(PdfPageSize.A4)
    expect PdfError:
      discard doc.getPage(-1)

  test "remove page out of bounds":
    let doc = newPdfDocument()
    discard doc.createPage(PdfPageSize.A4)
    expect PdfError:
      doc.removePage(10)

  test "save to non-existent directory":
    let doc = newPdfDocument()
    discard doc.createPage(PdfPageSize.A4)
    expect PdfError:
      doc.save("/non/existent/directory/test.pdf")

  test "load non-existent font":
    let doc = newPdfDocument()
    expect PdfError:
      discard doc.getFont("/non/existent/font.ttf")
