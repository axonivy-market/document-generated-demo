---
name: translate-readme
description: Translate the product README (title, description, and ### Key features section) into German and write the result to README_DE.md in the product module.
argument-hint: '<product-module-name>'
user-invocable: true
---

# Translate README

Translate the opening section of a product `README.md` — from the title through to the end of the `### Key features` block — into German and write the result to `README_DE.md`.

## Purpose

Produce a German variant of the product introduction that reads naturally to native speakers while remaining accurate for a technical audience. Only the marketing-facing front matter is translated; all technical sections (`## Demo`, `## Setup`, `## Components`, etc.) are left out of the output.

## Input

- `productModule` (required): The product module folder name (e.g. `mattermost-connector-product`). The skill reads `README.md` from this folder and writes `README_DE.md` to the same folder.

## Script

Use the bundled helper to extract the translation scope before translating:

```bash
bash ./.github/skills/translate-readme/scripts/extract-translation-scope.sh <productModule>/README.md
```

The script prints all lines from the start of the file up to (but **not** including) the first `## ` heading, then exits. Feed its stdout directly as the text to translate.

## Output

- `README_DE.md` written to `<productModule>/README_DE.md`.
- Scope: **title + introductory description + `### Key features` block only** — everything from the first line of `README.md` up to and including the last bullet under `### Key features`. Nothing after that block appears in the output.
- Tone: **informal, friendly, and professional** — use `du`/`dein`, short sentences, and avoid jargon.
- Target language: **German**.

## Behavior / Steps

1. **Locate the source file**: `<productModule>/README.md`. Fail with a clear error if the file does not exist.

2. **Extract the translation scope** using the bundled script:

   ```bash
   bash ./.github/skills/translate-readme/scripts/extract-translation-scope.sh <productModule>/README.md
   ```

   - The script outputs every line from line 1 up to (but **not** including) the first `## ` heading (e.g. `## Demo`, `## Setup`, `## Components`).
   - This covers the product title, introductory description, and `### Key features` block regardless of whether those sections exist or are missing.
   - Everything from the first `## ` heading onward is out of scope and must not appear in the output.

3. **Translate the extracted content** into German, following these rules:

   **Preserve verbatim (do not translate or alter):**
   - Inline code spans: `` `like this` ``
   - Fenced code blocks and their entire content.
   - Image paths inside `![…](path)` — keep the path byte-for-byte identical.
   - Hyperlink URLs inside `[…](url)` — keep the URL unchanged.
   - Markdown structural markers: `#`, `##`, `###`, `**`, `_`, `|`, `---`.
   - HTML comments.

   **Translate:**
   - All prose and bullet point text.
   - Heading label text (e.g. `### Key features` → `### Wichtigste Funktionen`).
   - Image alt text (the `…` inside `![…]`).
   - Link display text (the `…` inside `[…](url)`).

4. **Apply tone**:
   - Use `du`/`dein` (informal second person) throughout.
   - Keep sentences short and direct.
   - Lead bullet points with a strong verb or benefit.
   - Avoid passive voice and overly technical jargon in prose.
   - Maintain a professional register — friendly but not casual.

5. **Assemble and write the output file**:

   - Follow immediately with the translated content (title, description, `### Key features`).
   - Nothing else — no `## Demo`, `## Setup`, or any other section.
   - Write to `<productModule>/README_DE.md`. If the file already exists, overwrite it.

## Quality criteria

- `README_DE.md` exists at the correct path.
- Content covers exactly: title + description + `### Key features` — nothing more, nothing less.
- No inline code span, image path, URL, or fenced code block was altered.
- The German text reads naturally with `du`/`dein` and short, benefit-led bullet points.
