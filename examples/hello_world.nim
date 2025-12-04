# Example: Create a simple PDF document with text
#
# Compile with:
#   nim cpp examples/hello_world.nim

import pkg/podofo

proc main() =
  # Create a new document
  let doc = newPdfDocument()

  # Create an A4 page
  let page = doc.createPage(PdfPageSize.A4)

  # Get standard fonts
  let font = doc.helvetica()
  let fontBold = doc.helveticaBold()

  # Draw on the page
  page.draw:
    # Set title
    painter.setFont(fontBold, 24)
    painter.setFillColor(black())
    painter.drawText("Hello, World!", 50, 780)

    # Set body text
    painter.setFont(font, 12)
    painter.drawText("This PDF was created with nim-podofo.", 50, 750)
    painter.drawText(
      "nim-podofo provides Nim bindings for the PoDoFo library.", 50, 735
    )

    # Draw a line
    painter.setStrokeColor(rgbColor(0.0, 0.0, 0.8))
    painter.setLineWidth(2.0)
    painter.drawLine(50, 720, 545, 720)

    # Draw some shapes
    painter.setStrokeColor(red())
    painter.setFillColor(rgbColor(1.0, 0.9, 0.9))
    painter.drawRectangle(50, 600, 100, 80, PdfPathDrawMode.StrokeFill)

    painter.setStrokeColor(green())
    painter.setFillColor(rgbColor(0.9, 1.0, 0.9))
    painter.drawCircle(250, 640, 40, PdfPathDrawMode.StrokeFill)

    painter.setStrokeColor(blue())
    painter.setFillColor(rgbColor(0.9, 0.9, 1.0))
    painter.drawEllipse(350, 600, 120, 80, PdfPathDrawMode.StrokeFill)

    # Add more text
    painter.setFont(font, 10)
    painter.setFillColor(grayColor(0.3))
    painter.drawText("Rectangle", 70, 585)
    painter.drawText("Circle", 230, 585)
    painter.drawText("Ellipse", 390, 585)

  # Save the document
  doc.save("hello_world.pdf")
  echo "Created hello_world.pdf"

when isMainModule:
  main()
