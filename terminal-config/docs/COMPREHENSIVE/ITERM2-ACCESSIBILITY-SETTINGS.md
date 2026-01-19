# iTerm2 Accessibility Settings

> **TL;DR:** iTerm2 has many hidden settings that make terminal work easier for people with low vision, hearing loss, or who just want clearer visual feedback. This guide shows how to configure them.

---

## Quick Reference

| Setting | Command | What It Does |
|---------|---------|--------------|
| Disable tab dimming | `defaults write com.googlecode.iterm2 DimInactiveSplitPanes -bool false` | Inactive tabs stay bright |
| Larger tab font | `defaults write com.googlecode.iterm2 CustomTabBarFontSize -int 15` | Bigger tab titles |
| Taller tab bar | `defaults write com.googlecode.iterm2 DefaultTabBarHeight -int 30` | More room for larger font |
| Disable animations | `defaults write com.googlecode.iterm2 DisableFullscreenTransparency -bool true` | Less motion |
| Boost cursor | `defaults write com.googlecode.iterm2 CursorBoost -float 0.5` | Easier to find cursor |
| No transparency | `defaults write com.googlecode.iterm2 DisableTransparencyForKeyWindow -bool true` | Solid backgrounds |

**After running these commands, restart iTerm2 to see changes.**

---

## The Problem

Default iTerm2 settings assume good vision:
- Inactive tabs fade to gray (hard to read)
- Tab fonts are small
- Animations can be distracting
- Finding your cursor can be difficult
- Low contrast between active/inactive elements

This guide fixes all of that.

---

## Tab Visibility Settings

### 1. Stop Inactive Tabs From Fading

By default, iTerm2 dims inactive tabs/panes. This makes them nearly invisible for people with low vision.

```bash
# Disable dimming of inactive split panes
defaults write com.googlecode.iterm2 DimInactiveSplitPanes -bool false

# Disable dimming of background windows
defaults write com.googlecode.iterm2 DimBackgroundWindows -bool false

# Don't dim just the text (dim nothing)
defaults write com.googlecode.iterm2 DimOnlyText -bool false

# Set inactive tab brightness to 100% (1 = full brightness)
defaults write com.googlecode.iterm2 DarkModeInactiveTabDarkness -float 1
defaults write com.googlecode.iterm2 LightModeInactiveTabDarkness -float 1
```

### 2. Increase Tab Font Size

Default tab font is 13pt - too small for many people.

```bash
# Increase tab font size (13 → 15 or higher)
defaults write com.googlecode.iterm2 CustomTabBarFontSize -int 15

# Increase tab bar height to fit larger font
defaults write com.googlecode.iterm2 DefaultTabBarHeight -int 30
```

**Font size options:**
- 13 = default (small)
- 15 = comfortable for most
- 17 = larger
- 19+ = very large (may need taller tab bar)

### 3. Tab Colors via Escape Codes

You can set tab colors programmatically. This is great for:
- Color-coding projects
- Visual status indicators
- Making tabs easier to identify

**Set tab color in your shell:**
```bash
# Bright green tab (high visibility)
printf "\033]6;1;bg;red;brightness;100\007"
printf "\033]6;1;bg;green;brightness;255\007"
printf "\033]6;1;bg;blue;brightness;100\007"

# Yellow tab
printf "\033]6;1;bg;red;brightness;255\007"
printf "\033]6;1;bg;green;brightness;255\007"
printf "\033]6;1;bg;blue;brightness;100\007"

# Red tab (warning/alert)
printf "\033]6;1;bg;red;brightness;255\007"
printf "\033]6;1;bg;green;brightness;100\007"
printf "\033]6;1;bg;blue;brightness;100\007"
```

**Auto-set tab color for all new terminals:**

Add this to your `~/.zshrc` or `~/.zshrc_local`:
```bash
# Set bright green tab color for all new iTerm2 tabs
if [[ "$TERM_PROGRAM" == "iTerm.app" ]] || [[ -n "$ITERM_SESSION_ID" ]]; then
    printf "\033]6;1;bg;red;brightness;100\007"
    printf "\033]6;1;bg;green;brightness;255\007"
    printf "\033]6;1;bg;blue;brightness;100\007"
fi
```

---

## Cursor and Focus Settings

### Make Cursor Easier to Find

```bash
# Boost cursor visibility (0.0 to 1.0, higher = more visible)
defaults write com.googlecode.iterm2 CursorBoost -float 0.5
```

### Cursor Style Options

In iTerm2 Preferences → Profiles → Text:
- **Block cursor** - Most visible
- **Underline** - Less obtrusive
- **Vertical bar** - Standard but can be hard to see

Recommendation: Use block cursor with a bright color.

---

## Reduce Visual Noise

### Disable Animations

```bash
# Disable fullscreen transition animations
defaults write com.googlecode.iterm2 DisableFullscreenTransparency -bool true
```

### Disable Transparency

Transparent backgrounds look cool but reduce readability.

```bash
# Solid background for active window
defaults write com.googlecode.iterm2 DisableTransparencyForKeyWindow -bool true
```

### Hide Tab Close Buttons

Less visual clutter - use ⌘W to close tabs instead.

```bash
# In iTerm2 Preferences → Appearance → Tabs
# Uncheck "Show tab close buttons"
```

---

## Audio/Visual Alerts

### Replace Audio Bell with Visual Flash

For hearing loss or noisy environments:

```bash
# Flash the tab bar on bell
defaults write com.googlecode.iterm2 FlashTabBarInFullscreen -bool true
```

In iTerm2 Preferences → Profiles → Terminal:
- Check "Flash visual bell"
- Uncheck "Audible bell" (optional)

---

## Tab Title Configuration

### Set Tab Title Programmatically

```bash
# Set tab title
printf "\033]0;My Project Name\007"
```

### Dynamic Tab Titles

Add to your prompt or scripts:
```bash
# Show current directory in tab title
precmd() {
    printf "\033]0;%s\007" "${PWD##*/}"
}
```

### Badge (Corner Overlay)

Small text overlay in corner of terminal - useful for status info:

```bash
# Set badge text
printf "\033]1337;SetBadgeFormat=%s\007" "$(echo -n "Status: OK" | base64)"
```

---

## Complete Accessibility Setup Script

Run all recommended settings at once:

```bash
#!/bin/bash
# iTerm2 Accessibility Setup
# Run this script, then restart iTerm2

echo "Configuring iTerm2 accessibility settings..."

# Tab visibility
defaults write com.googlecode.iterm2 DimInactiveSplitPanes -bool false
defaults write com.googlecode.iterm2 DimBackgroundWindows -bool false
defaults write com.googlecode.iterm2 DimOnlyText -bool false
defaults write com.googlecode.iterm2 DarkModeInactiveTabDarkness -float 1
defaults write com.googlecode.iterm2 LightModeInactiveTabDarkness -float 1

# Tab font and size
defaults write com.googlecode.iterm2 CustomTabBarFontSize -int 15
defaults write com.googlecode.iterm2 DefaultTabBarHeight -int 30

# Cursor and focus
defaults write com.googlecode.iterm2 CursorBoost -float 0.5

# Reduce visual noise
defaults write com.googlecode.iterm2 DisableFullscreenTransparency -bool true
defaults write com.googlecode.iterm2 DisableTransparencyForKeyWindow -bool true

# Visual bell
defaults write com.googlecode.iterm2 FlashTabBarInFullscreen -bool true

echo "Done! Restart iTerm2 to apply changes."
```

Save as `iterm2-accessibility-setup.sh` and run with `bash iterm2-accessibility-setup.sh`.

---

## Claude Code Statusline Integration

If you use Claude Code CLI, you can configure the statusline to set tab colors based on context usage:

| Context % | Tab Color | Meaning |
|-----------|-----------|---------|
| 0-49% | Green | Plenty of context left |
| 50-69% | Yellow | Getting full, /compact soon |
| 70-84% | Orange | Running low, /compact now |
| 85%+ | Red | Critical, start fresh |

See the Claude Code statusline configuration in `~/.claude/statusline-detailed.sh` for implementation details.

---

## Triggers (Auto-Highlight Errors)

Triggers automatically highlight text matching patterns. Great for spotting errors without scanning.

### Pre-configured Triggers

These triggers highlight important keywords so you don't have to scan for them:

| Pattern | Color | Matches |
|---------|-------|---------|
| `(?i)\berror\b` | Red | "error", "Error", "ERROR" |
| `(?i)\bwarn(ing)?\b` | Yellow | "warn", "warning", "WARNING" |
| `(?i)\bfail(ed\|ure)?\b` | Red | "fail", "failed", "failure" |

### Adding Triggers via GUI

1. iTerm2 → Settings → Profiles → Advanced → Triggers → Edit
2. Click + to add new trigger
3. Set:
   - **Regex:** `(?i)\berror\b`
   - **Action:** Highlight Text
   - **Color:** Red

### Adding Triggers via Command Line

```bash
PLIST=~/Library/Preferences/com.googlecode.iterm2.plist

# Create triggers array
/usr/libexec/PlistBuddy -c "Add 'New Bookmarks':0:Triggers array" "$PLIST"

# Add ERROR trigger (red highlight)
/usr/libexec/PlistBuddy -c "Add 'New Bookmarks':0:Triggers:0 dict" "$PLIST"
/usr/libexec/PlistBuddy -c "Add 'New Bookmarks':0:Triggers:0:action integer 1" "$PLIST"
/usr/libexec/PlistBuddy -c "Set 'New Bookmarks':0:Triggers:0:regex '(?i)\\\\berror\\\\b'" "$PLIST"
/usr/libexec/PlistBuddy -c "Add 'New Bookmarks':0:Triggers:0:partial bool false" "$PLIST"
/usr/libexec/PlistBuddy -c "Add 'New Bookmarks':0:Triggers:0:parameter dict" "$PLIST"
/usr/libexec/PlistBuddy -c "Add 'New Bookmarks':0:Triggers:0:parameter:Red\ Component real 1" "$PLIST"
/usr/libexec/PlistBuddy -c "Add 'New Bookmarks':0:Triggers:0:parameter:Green\ Component real 0.2" "$PLIST"
/usr/libexec/PlistBuddy -c "Add 'New Bookmarks':0:Triggers:0:parameter:Blue\ Component real 0.2" "$PLIST"
```

**Note:** Restart iTerm2 after adding triggers via command line.

### Other Useful Trigger Patterns

| Pattern | Use For |
|---------|---------|
| `(?i)success` | Highlight successful operations (green) |
| `(?i)permission denied` | Access issues (red) |
| `(?i)not found` | Missing files/commands (yellow) |
| `(?i)deprecated` | Old code warnings (yellow) |

---

## Troubleshooting

### Settings Not Taking Effect

1. Restart iTerm2 completely (⌘Q, then reopen)
2. Check if settings were written: `defaults read com.googlecode.iterm2 | grep -i dim`
3. Some settings require creating a new tab/window

### Tab Colors Not Showing

- Make sure you're in iTerm2 (not Terminal.app or VS Code terminal)
- Check that escape codes are being printed (not suppressed by shell config)
- Try a fresh tab

### Want to Reset Everything

```bash
# Reset all iTerm2 settings to defaults (careful - loses ALL customizations)
defaults delete com.googlecode.iterm2
```

---

## Related Documentation

- [iTerm2 Documentation](https://iterm2.com/documentation.html)
- [iTerm2 Escape Codes](https://iterm2.com/documentation-escape-codes.html)
- Shell Integration: `terminal-config/docs/COMPREHENSIVE/ITERM2-SSH-GUIDE.md`

---

## Credits

Developed with assistance from Claude Code to address USH2 (Usher Syndrome Type 2) accessibility needs - limited visual field and hearing loss. These settings help anyone who needs clearer visual feedback from their terminal.
