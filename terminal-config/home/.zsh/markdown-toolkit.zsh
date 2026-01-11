#!/bin/zsh
# ============================================================================
# Markdown Toolkit - Convert, Print, Share Markdown Files
# ============================================================================
# 
# Viewing:
#   mdview file.md       - Pretty view in terminal (uses glow)
#   mdcat file.md        - View with images in terminal
#   mdpreview file.md    - Preview in browser (GitHub style)
#
# Converting:
#   mdpdf file.md        - Convert to PDF
#   mdhtml file.md       - Convert to HTML
#   mddocx file.md       - Convert to Word document
#   mdpptx file.md       - Convert to PowerPoint (for presentations)
#
# For Sharing:
#   mdplain file.md      - Strip to plain text (for basic chat)
#   mdslack file.md      - Format for Slack (copies to clipboard)
#   mdclip file.md       - Copy rendered content to clipboard
#
# Quick Print:
#   mdprint file.md      - Send to default printer
#
# ============================================================================

# ============================================================================
# VIEWING
# ============================================================================

# Pretty view in terminal
mdview() {
    if [[ -z "$1" ]]; then
        echo "Usage: mdview <file.md>"
        echo "View markdown beautifully in terminal"
        return 1
    fi
    
    if [[ ! -f "$1" ]]; then
        echo "❌ File not found: $1"
        return 1
    fi
    
    if command -v glow &> /dev/null; then
        glow -p "$1"
    elif command -v mdcat &> /dev/null; then
        mdcat "$1"
    else
        echo "❌ Install glow or mdcat: brew install glow"
        return 1
    fi
}

# View with images (mdcat supports images in some terminals)
mdimg() {
    if [[ -z "$1" ]]; then
        echo "Usage: mdimg <file.md>"
        return 1
    fi
    
    if command -v mdcat &> /dev/null; then
        mdcat "$1"
    else
        echo "❌ Install mdcat: brew install mdcat"
        return 1
    fi
}

# Preview in browser (GitHub-flavored)
mdpreview() {
    if [[ -z "$1" ]]; then
        echo "Usage: mdpreview <file.md>"
        echo "Opens GitHub-style preview in browser"
        return 1
    fi
    
    if command -v grip &> /dev/null; then
        echo "🌐 Opening preview in browser..."
        echo "   Press Ctrl+C to stop the server"
        grip "$1"
    else
        # Fallback: convert to HTML and open
        local tmpfile="/tmp/$(basename "$1" .md).html"
        mdhtml "$1" "$tmpfile"
        open "$tmpfile"
    fi
}

# ============================================================================
# CONVERTING TO PDF
# ============================================================================

mdpdf() {
    local input="$1"
    local output="${2:-${input%.md}.pdf}"
    
    if [[ -z "$input" ]]; then
        echo "Usage: mdpdf <input.md> [output.pdf]"
        echo ""
        echo "Converts markdown to PDF"
        echo "If output not specified, uses same name with .pdf extension"
        return 1
    fi
    
    if [[ ! -f "$input" ]]; then
        echo "❌ File not found: $input"
        return 1
    fi
    
    echo "📄 Converting to PDF..."
    echo "   Input:  $input"
    echo "   Output: $output"
    
    # Try different methods in order of preference
    if command -v md-to-pdf &> /dev/null; then
        # md-to-pdf is simple and works well
        md-to-pdf "$input" --output "$output"
    elif command -v pandoc &> /dev/null; then
        # Pandoc with different engines
        if command -v pdflatex &> /dev/null; then
            # Best quality with LaTeX
            pandoc "$input" -o "$output" \
                --pdf-engine=pdflatex \
                -V geometry:margin=1in \
                -V fontsize=11pt
        elif command -v wkhtmltopdf &> /dev/null; then
            # Alternative: HTML to PDF
            pandoc "$input" -o "$output" --pdf-engine=wkhtmltopdf
        else
            # Try pandoc's built-in (requires weasyprint or other)
            pandoc "$input" -o "$output" 2>/dev/null || {
                echo "❌ Need a PDF engine. Install one:"
                echo "   brew install --cask basictex   # Best quality"
                echo "   brew install wkhtmltopdf       # Alternative"
                echo "   npm install -g md-to-pdf       # Easiest"
                return 1
            }
        fi
    else
        echo "❌ Install pandoc or md-to-pdf:"
        echo "   brew install pandoc"
        echo "   npm install -g md-to-pdf"
        return 1
    fi
    
    if [[ -f "$output" ]]; then
        echo "✅ Created: $output"
        echo ""
        read -q "REPLY?Open PDF now? (y/n) "
        echo ""
        [[ "$REPLY" == "y" ]] && open "$output"
    else
        echo "❌ Failed to create PDF"
        return 1
    fi
}

# ============================================================================
# CONVERTING TO OTHER FORMATS
# ============================================================================

mdhtml() {
    local input="$1"
    local output="${2:-${input%.md}.html}"
    
    if [[ -z "$input" ]]; then
        echo "Usage: mdhtml <input.md> [output.html]"
        return 1
    fi
    
    if ! command -v pandoc &> /dev/null; then
        echo "❌ Install pandoc: brew install pandoc"
        return 1
    fi
    
    echo "🌐 Converting to HTML..."
    
    # Create standalone HTML with nice styling
    pandoc "$input" -o "$output" \
        --standalone \
        --metadata title="$(basename "$input" .md)" \
        --css="https://cdn.jsdelivr.net/npm/github-markdown-css/github-markdown.min.css" \
        2>/dev/null || pandoc "$input" -o "$output" --standalone
    
    if [[ -f "$output" ]]; then
        echo "✅ Created: $output"
    fi
}

mddocx() {
    local input="$1"
    local output="${2:-${input%.md}.docx}"
    
    if [[ -z "$input" ]]; then
        echo "Usage: mddocx <input.md> [output.docx]"
        return 1
    fi
    
    if ! command -v pandoc &> /dev/null; then
        echo "❌ Install pandoc: brew install pandoc"
        return 1
    fi
    
    echo "📝 Converting to Word document..."
    pandoc "$input" -o "$output"
    
    if [[ -f "$output" ]]; then
        echo "✅ Created: $output"
        read -q "REPLY?Open document now? (y/n) "
        echo ""
        [[ "$REPLY" == "y" ]] && open "$output"
    fi
}

# Markdown to PowerPoint (for presentations written in MD)
mdpptx() {
    local input="$1"
    local output="${2:-${input%.md}.pptx}"
    
    if [[ -z "$input" ]]; then
        echo "Usage: mdpptx <input.md> [output.pptx]"
        echo ""
        echo "Use --- to separate slides, # for titles"
        return 1
    fi
    
    if command -v marp &> /dev/null; then
        echo "🎯 Converting to PowerPoint with Marp..."
        marp "$input" -o "$output"
    elif command -v pandoc &> /dev/null; then
        echo "🎯 Converting to PowerPoint with Pandoc..."
        pandoc "$input" -o "$output"
    else
        echo "❌ Install marp or pandoc:"
        echo "   npm install -g @marp-team/marp-cli"
        echo "   brew install pandoc"
        return 1
    fi
    
    if [[ -f "$output" ]]; then
        echo "✅ Created: $output"
    fi
}

# ============================================================================
# FOR SHARING (Chat, Slack, iMessage, Email)
# ============================================================================

# Convert to plain text (for basic chats that don't support formatting)
mdplain() {
    local input="$1"
    
    if [[ -z "$input" ]]; then
        echo "Usage: mdplain <file.md>"
        echo "Converts to plain text and copies to clipboard"
        return 1
    fi
    
    if ! command -v pandoc &> /dev/null; then
        echo "❌ Install pandoc: brew install pandoc"
        return 1
    fi
    
    echo "📋 Converting to plain text..."
    
    local plain=$(pandoc "$input" -t plain --wrap=none)
    
    if command -v pbcopy &> /dev/null; then
        echo "$plain" | pbcopy
        echo "✅ Copied to clipboard!"
    else
        echo "$plain"
    fi
}

# Format for Slack
# Slack uses its own markdown-like format
mdslack() {
    local input="$1"
    
    if [[ -z "$input" ]]; then
        echo "Usage: mdslack <file.md>"
        echo "Converts markdown to Slack format and copies to clipboard"
        echo ""
        echo "Slack formatting:"
        echo "  *bold*  _italic_  ~strikethrough~  \`code\`"
        echo "  > quote"
        echo "  • bullet (use emoji)"
        return 1
    fi
    
    if [[ ! -f "$input" ]]; then
        echo "❌ File not found: $input"
        return 1
    fi
    
    echo "💬 Converting for Slack..."
    
    # Convert markdown to Slack format
    local content=$(cat "$input")
    
    # Transform markdown to Slack format:
    # **bold** → *bold*
    # _italic_ stays _italic_
    # ## Headers → *Header* (bold)
    # - bullets → • bullets
    # ```code``` → ```code```  (same)
    # [link](url) → <url|link>
    
    local slack_content=$(echo "$content" | \
        sed 's/\*\*\([^*]*\)\*\*/*\1*/g' | \
        sed 's/^## \(.*\)/*\1*/g' | \
        sed 's/^### \(.*\)/*\1*/g' | \
        sed 's/^# \(.*\)/*\1*/g' | \
        sed 's/^- /• /g' | \
        sed 's/^\* /• /g' | \
        sed 's/\[\([^]]*\)\](\([^)]*\))/<\2|\1>/g'
    )
    
    if command -v pbcopy &> /dev/null; then
        echo "$slack_content" | pbcopy
        echo "✅ Copied to clipboard (Slack format)!"
        echo ""
        echo "Preview:"
        echo "─────────────────────────────────"
        echo "$slack_content" | head -20
        [[ $(echo "$slack_content" | wc -l) -gt 20 ]] && echo "... (truncated)"
    else
        echo "$slack_content"
    fi
}

# Format for iMessage/texting (simple, clean)
mdtext() {
    local input="$1"
    
    if [[ -z "$input" ]]; then
        echo "Usage: mdtext <file.md>"
        echo "Converts to clean text for iMessage/SMS"
        return 1
    fi
    
    echo "📱 Converting for text messages..."
    
    # Very simple: just clean up markdown syntax
    local content=$(cat "$input" | \
        sed 's/^#* //g' | \
        sed 's/\*\*\([^*]*\)\*\*/\1/g' | \
        sed 's/\*\([^*]*\)\*/\1/g' | \
        sed 's/_\([^_]*\)_/\1/g' | \
        sed 's/`\([^`]*\)`/\1/g' | \
        sed 's/^- /• /g' | \
        sed 's/\[\([^]]*\)\](\([^)]*\))/\1: \2/g'
    )
    
    if command -v pbcopy &> /dev/null; then
        echo "$content" | pbcopy
        echo "✅ Copied to clipboard!"
    else
        echo "$content"
    fi
}

# Copy with formatting (for apps that support rich text paste)
mdclip() {
    local input="$1"
    
    if [[ -z "$input" ]]; then
        echo "Usage: mdclip <file.md>"
        echo "Copies as rich text (works in some apps)"
        return 1
    fi
    
    # Convert to HTML, then copy as rich text
    local html=$(pandoc "$input" -t html 2>/dev/null || cat "$input")
    
    # On macOS, we can copy HTML as rich text
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "$html" | textutil -stdin -format html -convert rtf -stdout | pbcopy
        echo "✅ Copied as rich text!"
        echo "💡 Paste into Mail, Notes, Pages, etc."
    else
        echo "$html" | xclip -selection clipboard -t text/html 2>/dev/null || {
            echo "$html"
        }
    fi
}

# ============================================================================
# PRINTING
# ============================================================================

mdprint() {
    local input="$1"
    
    if [[ -z "$input" ]]; then
        echo "Usage: mdprint <file.md>"
        echo "Converts to PDF and sends to default printer"
        return 1
    fi
    
    local tmpfile="/tmp/$(basename "$input" .md)-print.pdf"
    
    echo "🖨️  Preparing to print..."
    
    # Convert to PDF first
    mdpdf "$input" "$tmpfile"
    
    if [[ -f "$tmpfile" ]]; then
        echo "📤 Sending to printer..."
        
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS - open print dialog
            open -a Preview "$tmpfile"
            echo "💡 Press Cmd+P to print from Preview"
            # Or direct print: lpr "$tmpfile"
        else
            # Linux
            lpr "$tmpfile" 2>/dev/null || xdg-open "$tmpfile"
        fi
    fi
}

# ============================================================================
# HELP
# ============================================================================

mdhelp() {
    echo ""
    echo "📄 Markdown Toolkit"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "VIEWING:"
    echo "  mdview file.md      Pretty view in terminal"
    echo "  mdpreview file.md   Preview in browser (GitHub style)"
    echo ""
    echo "CONVERTING:"
    echo "  mdpdf file.md       → PDF"
    echo "  mdhtml file.md      → HTML"
    echo "  mddocx file.md      → Word document"
    echo "  mdpptx file.md      → PowerPoint"
    echo ""
    echo "FOR SHARING:"
    echo "  mdslack file.md     Format for Slack (→ clipboard)"
    echo "  mdtext file.md      Clean text for iMessage"
    echo "  mdplain file.md     Plain text (→ clipboard)"
    echo "  mdclip file.md      Rich text (→ clipboard)"
    echo ""
    echo "PRINTING:"
    echo "  mdprint file.md     Convert to PDF and print"
    echo ""
    echo "💡 Most commands copy to clipboard automatically"
    echo ""
}

# Aliases
alias md='mdview'
alias mdp='mdpdf'
alias mdh='mdhtml'
