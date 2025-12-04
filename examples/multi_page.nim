# Example: Create a multi-page PDF document
#
# Compile with:
#   nim cpp examples/multi_page.nim

import std/strformat

import pkg/podofo

proc main() =
  let doc = newPdfDocument()
  let font = doc.timesRoman()
  let fontBold = doc.timesBold()

  # Create 5 pages
  for i in 1 .. 5:
    let page = doc.createPage(PdfPageSize.A4)

    page.draw:
      # Header
      painter.setFont(fontBold, 18)
      painter.setFillColor(black())
      painter.drawText(fmt"Page {i} of 5", 50, 780)

      # Content
      painter.setFont(font, 12)
      painter.drawText(fmt"This is page number {i}.", 50, 740)

      # Page border
      painter.setStrokeColor(grayColor(0.7))
      painter.setLineWidth(0.5)
      let r = page.rect
      painter.drawRectangle(20, 20, r.width - 40, r.height - 40)

      # Page number at bottom
      painter.setFont(font, 10)
      painter.setFillColor(grayColor(0.5))
      painter.drawTextAligned(
        fmt"- {i} -", 0, 30, r.width, PdfHorizontalAlignment.Center
      )

  doc.save("multi_page.pdf")
  echo "Created multi_page.pdf with ", doc.pageCount, " pages"

when isMainModule:
  main()
