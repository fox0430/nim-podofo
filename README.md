# nim-podofo

Nim bindings for [PoDoFo](https://podofo.github.io/podofo/documentation/) library.

## Requirements

- [Nim](https://nim-lang.org) >= 2.0.6
- [PoDoFo](https://podofo.github.io/podofo/documentation/) >= 1.0.0

## Usage

```nim
import pkg/podofo

# Create a new document
let doc = newPdfDocument()

# Create an A4 page
let page = doc.createPage(PdfPageSize.A4)

# Get a standard font
let font = doc.helvetica()

# Draw on the page
page.draw:
  painter.setFont(font, 12)
  painter.setFillColor(black())
  painter.drawText("Hello, World!", 100, 700)

# Save the document
doc.save("output.pdf")
```

## Build

podofo requires C++ compilation. Use `nim cpp`.

```bash
nim cpp yourfile.nim
```

> [!NOTE]
> Add the following lines to your .nimble
```
backend = "cpp"
```

## License

MIT
