# AI-Powered Terminal Notes System - Project Specification

**Created:** December 17, 2025  
**Status:** Design Phase  
**Priority:** HIGH - This is an amazing idea!

---

## 🎯 Vision

A terminal-based notes system that uses AI to:
- Automatically organize and categorize notes
- Find notes using natural language queries
- Fix typos and improve wording (unless it's code)
- Group related notes intelligently
- Never make you fight with formatting or search

**The Goal:** Make note-taking so easy you actually do it, and finding notes so smart you always find what you need.

---

## 💡 User Stories

### Adding Notes:
```bash
❯ mynotes add "prod server foo went down, rebooted at 3pm, back up"
✨ Note saved!
💡 AI suggests: Group with "server-incidents" (3 related notes)
   Want to add tags? (Y/n): 
```

### Finding Notes:
```bash
❯ mynotes find "something a few weeks ago about road"
🔍 Found 3 notes:

1. [2 weeks ago] "foo gone down the road"
2. [3 weeks ago] "deployment roadmap discussion"
3. [1 month ago] "roadblock with AWS migration"

Select note to view (1-3):
```

### Smart Features:
```bash
❯ mynotes add "teh serveer is dowm"
🤔 Did you mean: "the server is down"? (Y/n): y
✨ Fixed and saved!
💡 This looks like a server incident. Add to "incidents" category? (Y/n):
```

---

## 🏗️ System Architecture

### Components:

1. **CLI Interface** (`mynotes` command)
   - Add, find, edit, delete, list, export
   - Interactive prompts with fzf
   - Syntax highlighting for viewing notes

2. **Storage Backend**
   - SQLite database (local, fast, no server needed)
   - Schema: notes, tags, categories, embeddings
   - Full-text search index

3. **AI Integration** (Choose one):
   - **Option A:** Claude API (accurate, requires API key)
   - **Option B:** Ollama local (private, requires local install)
   - **Option C:** OpenAI API (fast, requires API key)

4. **Embedding System**
   - Generate embeddings for semantic search
   - Store embeddings in SQLite
   - Use cosine similarity for finding related notes

5. **Smart Features**
   - Typo correction (using AI)
   - Auto-categorization (using embeddings)
   - Related notes suggestions
   - Code detection (don't fix code formatting)

---

## 📊 Database Schema

```sql
-- Notes table
CREATE TABLE notes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    category TEXT,
    embedding BLOB  -- Store as binary
);

-- Tags table (many-to-many)
CREATE TABLE tags (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL
);

CREATE TABLE note_tags (
    note_id INTEGER,
    tag_id INTEGER,
    FOREIGN KEY (note_id) REFERENCES notes(id),
    FOREIGN KEY (tag_id) REFERENCES tags(id)
);

-- Categories table
CREATE TABLE categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    description TEXT
);

-- Full-text search
CREATE VIRTUAL TABLE notes_fts USING fts5(content, category);
```

---

## 🎨 Command Interface

### Core Commands:

```bash
# Adding notes
mynotes add "note content"                    # Quick add
mynotes add                                   # Opens editor (EDITOR or vim)
mynotes add -c incidents "server down"        # Add with category
mynotes add -t server,prod "note"             # Add with tags

# Finding notes
mynotes find "natural language query"         # Semantic search
mynotes search "exact text"                   # Full-text search
mynotes list                                  # Recent notes (last 20)
mynotes list --all                            # All notes
mynotes list -c incidents                     # Filter by category
mynotes list -t server                        # Filter by tag

# Viewing notes
mynotes show 123                              # Show note by ID
mynotes view 123                              # Same as show

# Editing
mynotes edit 123                              # Edit note in EDITOR
mynotes retag 123                             # Re-tag note
mynotes categorize 123                        # Re-categorize note

# Organization
mynotes categories                            # List all categories
mynotes tags                                  # List all tags
mynotes related 123                           # Show related notes

# Maintenance
mynotes export notes.json                     # Export all notes
mynotes import notes.json                     # Import notes
mynotes backup ~/backups/                     # Backup database
mynotes stats                                 # Show statistics

# AI Features
mynotes fix 123                               # Fix typos in note
mynotes suggest 123                           # Get category suggestions
mynotes similar "some text"                   # Find similar notes
```

---

## 🤖 AI Features in Detail

### 1. Typo Correction
```python
When user adds note with typos:
1. Detect if content looks like code (has syntax like {}, [], etc.)
2. If not code, send to AI: "Fix typos and improve clarity: {text}"
3. Show diff to user
4. Ask for confirmation
5. Save corrected version
```

### 2. Auto-Categorization
```python
When user adds note:
1. Generate embedding of note content
2. Compare with existing category embeddings
3. Find top 3 similar categories
4. Suggest: "This looks like: [category]. Confirm? (Y/n)"
5. User can accept, reject, or create new category
```

### 3. Semantic Search
```python
When user searches with natural language:
1. Generate embedding of search query
2. Compare with all note embeddings (cosine similarity)
3. Rank by similarity score
4. Also run full-text search
5. Merge and deduplicate results
6. Show top 10 results with scores
```

### 4. Related Notes
```python
When viewing a note:
1. Use note's embedding
2. Find 5 most similar notes
3. Show at bottom: "Related notes: ..."
4. Allow quick navigation
```

---

## 🔧 Technical Implementation

### Language Choice:
**Python** (best for AI/ML work)
- Rich ecosystem (sqlite3, numpy, requests)
- Easy AI integration
- Good CLI libraries (click, rich)
- Fast enough for local use

### Dependencies:
```bash
# Core
pip install click          # CLI framework
pip install rich           # Beautiful terminal output
pip install sqlite3        # Database (built-in)

# AI (choose one)
pip install anthropic      # For Claude API
pip install openai         # For OpenAI API
# OR: Install Ollama locally

# Embeddings
pip install sentence-transformers  # For local embeddings
# OR: Use API embeddings

# Utils
pip install fuzzywuzzy     # Fuzzy string matching
pip install python-dateutil # Date parsing
```

### File Structure:
```
~/.mynotes/
├── notes.db              # SQLite database
├── config.json           # Configuration (API keys, model choice)
└── backups/              # Auto-backups

/usr/local/bin/
└── mynotes               # Executable script
```

---

## 🎨 User Experience Design

### Adding a Note (Full Flow):
```bash
❯ mynotes add "server crashed need to check logs"

✨ Analyzing note...

🤔 Typo check: Looks good!
   (or: "Did you mean 'server crashed, need to check logs'?")

💡 Smart suggestions:
   • Category: "incidents" (90% confident)
   • Tags: server, urgent, logs
   • Related notes: 3 found

📝 Accept? (Y/n/edit): y

✅ Note #42 saved!
   Category: incidents
   Tags: server, urgent, logs
   
💡 Tip: View it with 'mynotes show 42'
```

### Finding Notes (Full Flow):
```bash
❯ mynotes find "that thing a few weeks ago about the road"

🔍 Semantic Search Results (3 found):

1. [Score: 0.92] 2 weeks ago | incidents
   "foo gone down the road after deployment"
   Tags: server, deployment
   
2. [Score: 0.78] 3 weeks ago | planning
   "roadmap for Q1 discussed with team"
   Tags: planning, meeting
   
3. [Score: 0.65] 1 month ago | incidents  
   "roadblock with AWS migration certificate issue"
   Tags: aws, certificates

Select note (1-3, or 'q' to quit): 1

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Note #127 | 2 weeks ago | incidents
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

foo gone down the road after deployment

Tags: server, deployment
Related notes: #45, #89, #103

(e)dit | (d)elete | (r)elated | (b)ack | (q)uit: 
```

---

## 🚀 MVP (Minimum Viable Product)

Start with core features:

### Phase 1 (Week 1):
- [x] Basic CLI structure
- [x] SQLite database setup
- [x] Add notes (simple text)
- [x] List recent notes
- [x] Search notes (full-text only)
- [x] View note by ID

### Phase 2 (Week 2):
- [x] AI typo correction
- [x] Basic categorization (manual)
- [x] Tags system
- [x] Edit notes

### Phase 3 (Week 3):
- [x] Embeddings generation
- [x] Semantic search
- [x] Auto-categorization suggestions
- [x] Related notes feature

### Phase 4 (Week 4):
- [x] Export/import
- [x] Backup system
- [x] Stats and analytics
- [x] Polish UI with colors and formatting

---

## 🎯 Success Criteria

You'll know it's working when:
1. ✅ You actually use it daily
2. ✅ Finding notes takes <5 seconds
3. ✅ Adding notes takes <10 seconds
4. ✅ You never lose a note
5. ✅ Search finds what you need 90%+ of the time
6. ✅ Zero formatting frustration

---

## 💰 Cost Considerations

### Option A: Claude API
- ~$0.003 per note (categorization + correction)
- ~$0.001 per search
- Budget: ~$10/month for heavy use

### Option B: Ollama Local
- Free after install (~4GB disk space)
- Slower but private
- Runs on your machine

### Option C: OpenAI API
- Similar to Claude pricing
- Embeddings: $0.0001 per note
- Very cheap for this use case

**Recommendation:** Start with Ollama (free, private), add API option later.

---

## 🔒 Privacy & Security

- **Local-first:** All notes stored locally in SQLite
- **No cloud sync:** (unless you want it)
- **Encryption:** Optional database encryption
- **API keys:** Stored securely in config
- **Backups:** Local only, you control them

---

## 🎨 Future Enhancements

Ideas for later versions:

1. **Voice input:** Record notes via voice, transcribe with Whisper
2. **Image attachments:** OCR text from screenshots
3. **Code highlighting:** Better code snippet handling
4. **Daily digest:** "Here's what you noted today"
5. **Reminders:** "Follow up on this note in 3 days"
6. **Sync:** Optional cloud sync with encryption
7. **Web interface:** View notes in browser
8. **Mobile app:** iOS/Android companion
9. **Collaboration:** Share notes with team
10. **Integrations:** Slack, email, GitHub issues

---

## 📚 Similar Tools (For Inspiration)

- **nb** (https://github.com/xwmx/nb) - CLI notes
- **jrnl** (https://jrnl.sh/) - Terminal journaling
- **Obsidian** - Note linking and organization
- **Notion** - All-in-one workspace
- **mem.ai** - AI-powered notes

**Our advantage:** Semantic search + auto-categorization + terminal-native!

---

## 🛠️ Next Steps

When we start the AI notes project session:

1. **Choose AI backend** (Claude API vs Ollama)
2. **Set up Python environment**
3. **Create database schema**
4. **Build core CLI** (add, list, search)
5. **Integrate AI features** (typo fix, categorization)
6. **Add embeddings** (semantic search)
7. **Polish UX** (colors, prompts, fzf integration)
8. **Test with real notes**
9. **Package for easy install**
10. **Add to your terminal setup!**

---

## 💬 Questions to Answer in Next Session

1. Which AI backend do you prefer?
   - Claude API (accurate, costs ~$10/month)
   - Ollama local (free, private, slower)
   - OpenAI API (fast, costs ~$5/month)

2. Storage preference?
   - SQLite local only (recommended)
   - Add optional cloud sync?

3. Note format?
   - Plain text (recommended)
   - Support markdown?
   - Support code blocks?

4. Privacy level?
   - Send to AI for processing?
   - Process locally only?
   - Make it configurable?

---

## 🎉 Why This Will Be Amazing

1. **You'll actually use it** - No friction, no apps, just terminal
2. **Finding is effortless** - Natural language search works
3. **It gets smarter** - Learns from your notes
4. **No lock-in** - It's just SQLite + text
5. **Fast as hell** - Local database, instant results
6. **You own it** - Your notes, your machine, your control

---

**This is going to be incredible! Let's build it!** 🚀

---

## 📝 Notes for Next Session

When you're ready to start:
1. Show me this document
2. Tell me which AI backend you prefer
3. We'll build the MVP in ~4 hours
4. You'll have a working notes system by end of session

**Can't wait to build this with you!** 🎊
