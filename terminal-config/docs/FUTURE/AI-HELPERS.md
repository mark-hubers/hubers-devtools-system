# AI Helper Aliases (Future Feature)

**Status:** Notes for later implementation
**Date:** 2026-01-21

## Concept

Quick CLI aliases using `claude -p` for one-off AI help without starting a full session.

## Proposed Aliases

```bash
# General
alias aiq='claude -p'                                    # Quick question
alias aihelp='claude -p'                                 # Same as aiq

# Writing/Grammar
alias aiwrite='claude -p "fix spelling and grammar:"'    # Fix text
alias aiclear='claude -p "rewrite more clearly:"'        # Clarify
alias aipro='claude -p "rewrite professionally:"'        # Professional tone

# Git
alias aicommit='claude -p "improve this commit message:"'
alias aigit='claude -p "help with this git problem:"'

# Code
alias aiexplain='claude -p "explain what this does:"'
alias aicode='claude -p "write code for:"'
```

## Usage Examples

```bash
# Fix spelling (pipe text)
echo "this is a test to and help me workd this better" | aiwrite

# Quick question
aiq "how do I undo my last git commit?"

# Professional rewrite
echo "hey can u fix the bug its broke" | aipro

# Explain a file
cat script.sh | aiexplain

# Git help in any repo
cd /some/messy/repo
aigit "run git status and help me understand this mess"
```

## Notes

- `claude -p` answers and exits (no interactive session)
- Still uses API/subscription
- Good for quick help without "polluting" project sessions
- Global CLAUDE.md still loads (good - has preferences)
- Project CLAUDE.md only loads if in that project

## Local LLM Alternative (Ollama)

For offline/free option:
```bash
brew install ollama
ollama serve &
ollama pull llama3.2:3b

alias localai='ollama run llama3.2:3b'
```

But: Local LLMs can't run commands, only give text advice.

---

*Add to devtools when ready*
