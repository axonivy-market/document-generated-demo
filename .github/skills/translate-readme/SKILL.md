---
name: translate-readme
description: Translate selected sections of a product README into a target language and write the result to a locale-specific output file (e.g. README_DE.md). Preserves all Markdown formatting, code fences, image links, and variable placeholders unchanged.
argument-hint: '[source README path] [target language] [output file name]'
user-invocable: true
---

# Translate README

Translate specified sections of a product README into a target language while keeping all Markdown structure, code fences, image references, and technical tokens exactly as they are.

## Purpose

Produce a locale-specific copy of a README that reads naturally to native speakers while remaining fully accurate for the technical audience. The translation must not alter any Markdown syntax, code blocks, image paths, or special placeholders such as `@variables.yaml@`.

## When to use

- When a product module has a complete `README.md` and a translated variant (e.g. `README_DE.md`) is needed.
- When only a subset of sections must be translated (e.g. introductory and feature content, excluding demo walkthroughs and technical API reference sections).
- When the target audience for the translated file is a mix of business stakeholders and developers who prefer to read in their native language.

## Inputs

- `sourceFile` (required): Path to the source `README.md` to translate. Default: `README.md` in the product module.
- `targetLanguage` (required): The language to translate into (e.g. `German`, `French`, `Spanish`).
- `outputFile` (required): File name for the translated output (e.g. `README_DE.md`). Written to the same directory as the source file.
- `sections` (optional): Which top-level sections to translate. Accepts:
  - `before:<heading>` — translate everything up to (but not including) the named heading.
  - A comma-separated list of heading names to translate (e.g. `Key features,Setup`).
  - `all` — translate the entire file (default when omitted).
- `tone` (optional): Writing style guidance, e.g. `informal and friendly`, `formal`, `marketing`. Default: `professional`.

## Output

- A Markdown file at `outputFile` containing:
  - The translated section(s) with all Markdown formatting preserved.
  - Any sections that were **not** selected for translation copied verbatim from the source.
  - A comment header at the top of the file indicating the source file, target language, and the date of generation.

## Behavior / Steps

1. **Read the source file** from `sourceFile`. Parse it into top-level sections by splitting on level-2 headings (`## `). The content before the first `## ` heading (title, description, key features) is treated as the "preamble" section.

2. **Determine the translation scope** using the `sections` parameter:
   - If `before:<heading>` is specified, collect the preamble and all sections that appear before `<heading>`. The `<heading>` section and everything after it are out of scope.
   - If a heading list is given, only those named sections (and the preamble if `preamble` is listed) are in scope.
   - If `sections` is omitted or set to `all`, the entire file is in scope.

3. **Translate each in-scope section** according to the following rules:
   - Use the `targetLanguage` and `tone` to guide the translation.
   - **Preserve verbatim** (do not translate or alter):
     - Fenced code blocks (``` ``` ` ... ` ``` ```) and their content, including `@variables.yaml@` and any XML/YAML snippets.
     - Inline code spans (`` `like this` ``).
     - Image markdown: `![alt text](path)` — keep path unchanged; the alt text **may** be translated.
     - URLs and hyperlink targets `[text](url)` — translate the link text, keep the URL.
     - Markdown heading markers (`#`, `##`, `###`), bold/italic markers (`**`, `_`), table delimiters (`|`, `---`).
     - HTML comments.
   - **Translate**:
     - All prose, bullet point text, table cell content (excluding code), and heading label text.
     - Alt text of images (the part inside `![…]`).
     - Link display text (the part inside `[…]` before the URL).

4. **Apply tone guidance**:
   - `informal and friendly`: use `du`/`dein` (German), `tu`/`ton` (French), or the equivalent second-person informal form. Prefer short sentences. Avoid overly technical jargon in prose sections.
   - `formal`: use the polite form (`Sie`/`Ihr` in German). Keep a neutral, documentation-style register.
   - `marketing`: use upbeat, benefit-oriented language. Lead with value propositions. Avoid passive voice.
   - `professional` (default): balanced register — clear, accurate, and approachable.

5. **Assemble the output file**:
   - Add a comment header at the very top:
     ```html
     <!-- Translated from README.md | Language: <targetLanguage> | Generated: <date> -->
     ```
   - Write translated sections in their original order.
   - Copy any out-of-scope sections verbatim, in their original position.
   - Write the result to `outputFile` in the same directory as `sourceFile`.

6. **Validate** before writing:
   - Confirm that no fenced code block content was altered.
   - Confirm that no image paths were changed.
   - Confirm that the number of top-level sections in the output matches the source.

## Quality criteria / Acceptance checks

- The output file exists at the expected path.
- All Markdown headings are present in the same order as the source.
- Code fences and their content are byte-for-byte identical to the source.
- Image `src` paths are unchanged; alt text is translated where applicable.
- The translation reads naturally in the target language with the requested tone — avoid literal word-for-word translations that sound unnatural.
- No section is accidentally duplicated or omitted.
- The comment header is present at the top of the output file.

## Example invocation

Translate everything before `## Demo` into German with an informal tone and write to `README_DE.md`:

```
sections: before:## Demo
targetLanguage: German
tone: informal and friendly
sourceFile: open-weather-connector-product/README.md
outputFile: README_DE.md
```
