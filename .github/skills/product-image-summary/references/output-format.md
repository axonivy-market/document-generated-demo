# Image Catalog Output Format Reference

The catalog script produces one entry per image. When placing images in the README, only the per-image entry structure matters — all header/summary/category wrapper sections are informational and produced by the script.

## Per-Image Entry Structure

```markdown
### [Image Description]

- **File:** `relative/path/to/image.png`
- **Suggested alt-text:** Descriptive text for accessibility

> Suggested readme placement: ## Demo — step 2

**Markdown snippet:**
![Descriptive text for accessibility](relative/path/to/image.png)
```

## Field Descriptions

| Field | Content |
|-------|---------|
| **File** | Relative path from project root |
| **Size** | Human-readable file size (KB, MB, etc.) |
| **Dimensions** | Image dimensions in pixels (width×height). Shows "unknown" if ImageMagick not available |
| **Suggested alt-text** | Auto-generated accessibility text based on filename and category |
| **Markdown snippet** | Ready-to-copy markdown image syntax for readme integration |

## Alt-Text Generation Rules

The skill generates alt-text following these rules:

1. **Extract filename** – Remove file extension
2. **Replace separators** – Convert hyphens and underscores to spaces
3. **Capitalize** – Title-case each word
4. **Add context** – For very short names, prepend category hint (e.g., "Screenshot: Login")

### Examples

| Filename | Category | Generated Alt-Text |
|----------|----------|-------------------|
| `feature-screenshot.png` | screenshots | Feature Screenshot |
| `system-architecture.svg` | diagrams | System Architecture |
| `demo-animation.gif` | animations | Demo Animation |
| `logo.svg` | icons | Logo |
| `unknown-file.png` | other | Unknown File |

## Example Full Output

```markdown
# Image Catalog for Documentation

Generated: 2026-04-24 10:30:15
Project: .
Filter: all

## Summary

- **Total images found:** 2
- **Screenshots:** 1
- **Diagrams:** 1
- **Animations:** 0
- **Icons:** 0
- **Other:** 0

---

## Screenshots (1)

### Login Feature Screenshot

- **File:** `docs/screenshots/login-feature-screenshot.png`
- **Size:** 87 KB | **Dimensions:** 1024×768px
- **Suggested alt-text:** Login Feature Screenshot

**Markdown snippet (ready to copy):**
\`\`\`markdown
![Login Feature Screenshot](docs/screenshots/login-feature-screenshot.png)
\`\`\`

---

## Diagrams (1)

### System Architecture

- **File:** `docs/diagrams/system-architecture.svg`
- **Size:** 145 KB | **Dimensions:** 1280×960px
- **Suggested alt-text:** System Architecture

**Markdown snippet (ready to copy):**
\`\`\`markdown
![System Architecture](docs/diagrams/system-architecture.svg)
\`\`\`

---
```

## Customization

To override auto-generated alt-text:

1. Run the skill to generate the catalog
2. Edit the markdown snippets directly
3. Paste the updated snippets into your readme
4. Follow WCAG 2.1 Level AA guidelines for alt-text (concise, descriptive, < 125 characters)

## Image Category Guidelines

**Screenshots**
- UI feature demonstrations
- User workflow captures
- Result/output displays
- Before/after comparisons

**Diagrams**
- Architecture diagrams
- Process flows
- Workflow diagrams
- System topology diagrams
- Entity relationship diagrams

**Animations**
- GIF demonstrations
- Screen recordings
- Feature walkthroughs
- Performance comparisons

**Icons**
- Badge/status indicators
- Logo files
- Navigation icons
- Symbol graphics

**Other**
- Images that don't fit categories above
- Review and manually categorize

