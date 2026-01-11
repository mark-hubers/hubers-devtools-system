# 📄 Markdown Toolkit

Convert, view, print, and share markdown files easily.

## Quick Reference

| Command | Description |
|---------|-------------|
| `mdview file.md` | Pretty view in terminal |
| `mdpdf file.md` | Convert to PDF |
| `mdhtml file.md` | Convert to HTML |
| `mddocx file.md` | Convert to Word |
| `mdslack file.md` | Format for Slack → clipboard |
| `mdtext file.md` | Clean text for iMessage |
| `mdprint file.md` | Print markdown |
| `mdhelp` | Show all commands |

## Installing Required Tools

```bash
# Essential (via devsetup)
devsetup add pandoc    # Universal converter
devsetup add glow      # Terminal viewer

# For PDF conversion (pick one)
devsetup add basictex     # Best quality PDFs
# OR
devsetup add wkhtmltopdf  # Alternative PDF engine
# OR
npm install -g md-to-pdf  # Easiest option

# Optional extras
devsetup add grip      # GitHub-style preview in browser
devsetup add mdcat     # Terminal viewer with images
npm install -g @marp-team/marp-cli  # MD to PowerPoint
```

## Common Workflows

### View Markdown in Terminal

```bash
# Pretty view with glow
mdview README.md

# Or just use glow directly
glow README.md
```

### Convert to PDF

```bash
# Simple conversion
mdpdf document.md

# Specify output name
mdpdf document.md output.pdf
```

### Share in Slack

```bash
# Converts and copies to clipboard
mdslack notes.md

# Then just paste in Slack!
```

Slack formatting:
- `**bold**` → `*bold*`
- `- bullets` → `• bullets`
- `[link](url)` → `<url|link>`

### Share in iMessage/Text

```bash
# Strips formatting for plain text
mdtext notes.md

# Copies to clipboard, ready to paste
```

### Convert to Word Document

```bash
mddocx report.md

# Opens in Word/Pages automatically
```

### Print Markdown

```bash
mdprint document.md

# Converts to PDF and opens print dialog
```

### Preview in Browser (GitHub style)

```bash
mdpreview README.md

# Opens browser with GitHub-flavored rendering
# Press Ctrl+C to stop the server
```

## Copy as Rich Text

For apps that support rich text paste (Mail, Notes, Pages):

```bash
mdclip document.md

# Paste with Cmd+V - formatting preserved!
```

## Convert to Presentation

Write your slides in markdown:

```markdown
# Slide 1 Title

Content for slide 1

---

# Slide 2 Title

- Bullet point
- Another point
```

Then convert:

```bash
# To PowerPoint
mdpptx presentation.md

# To HTML slides
marp presentation.md -o slides.html
```

## PDF Quality Tips

For best PDF quality, install BasicTeX:

```bash
devsetup add basictex

# Then use pandoc with LaTeX
mdpdf document.md
```

For quick/simple PDFs, use md-to-pdf:

```bash
npm install -g md-to-pdf
mdpdf document.md
```

## Troubleshooting

### "No PDF engine found"

Install one of these:
```bash
devsetup add basictex      # Best quality
devsetup add wkhtmltopdf   # Alternative
npm install -g md-to-pdf   # Easiest
```

### PDF looks wrong

Try a different engine:
```bash
# With wkhtmltopdf
pandoc doc.md -o doc.pdf --pdf-engine=wkhtmltopdf

# With LaTeX (best)
pandoc doc.md -o doc.pdf --pdf-engine=pdflatex
```

### Slack formatting not perfect

Slack has its own markdown variant. The `mdslack` command handles the most common conversions, but complex formatting may need manual adjustment.

## All Commands

```
VIEWING:
  mdview file.md      - Pretty view in terminal (glow)
  mdpreview file.md   - GitHub-style preview in browser
  mdimg file.md       - View with images (mdcat)

CONVERTING:
  mdpdf file.md       - Convert to PDF
  mdhtml file.md      - Convert to HTML
  mddocx file.md      - Convert to Word document
  mdpptx file.md      - Convert to PowerPoint

FOR SHARING:
  mdslack file.md     - Format for Slack (→ clipboard)
  mdtext file.md      - Clean text for iMessage (→ clipboard)
  mdplain file.md     - Plain text (→ clipboard)
  mdclip file.md      - Rich text paste (→ clipboard)

PRINTING:
  mdprint file.md     - Convert and print

HELP:
  mdhelp              - Show all commands
```
