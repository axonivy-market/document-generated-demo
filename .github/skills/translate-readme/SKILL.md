---
name: translate-readme
description: Use when asked to translate a README to German, create README_DE.md, or produce a German version of product documentation.
argument-hint: '<product-module-name>'
user-invocable: true
---

# Translate README

Translate the `README.md` into German and write the result to `README_DE.md`.

## Purpose

Produce a German variant of the product introduction that reads naturally to native speakers while remaining accurate for a technical audience.

## Input

- `productModule` (required): The product module folder name (e.g. `mattermost-connector-product`). The skill reads `README.md` from this folder and writes `README_DE.md` to the same folder.

## Output

- `README_DE.md` written to `<productModule>/README_DE.md`.
- Tone: **natural, friendly, and professional** — use `du`/`dein`, and avoid jargon.
- Target language: **German**.

## Behavior / Steps

1. **Locate the source file**: `<productModule>/README.md`. Fail with a clear error if the file does not exist.

2. **Translate the extracted content** into German, following these rules:

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

3. **Apply tone**:
   - Use `du`/`dein` (informal second person) throughout.
   - Keep sentences short and direct.
   - Lead bullet points with a strong verb or benefit.
   - Avoid passive voice and overly technical jargon in prose.
   - Maintain a professional register — friendly but not casual.

4. **Assemble and write the output file**:

   - Keep the heading structure.
   - Write to `<productModule>/README_DE.md`. If the file already exists, overwrite it.

## Quality criteria

- `README_DE.md` exists at the correct path.
- No inline code span, image path, URL, or fenced code block was altered.
- The German text reads naturally with `du`/`dein` and short, benefit-led bullet points.
