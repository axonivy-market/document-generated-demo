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
  - `all` — translate the entire file.
  - Default (when omitted): **preamble-only scope** — see the [Scope rule](#scope-rule) below.
- `tone` (optional): Writing style guidance, e.g. `informal and friendly`, `formal`, `marketing`. Default: `professional`.

## Scope rule

This is the single canonical definition of translation scope. All Behavior steps and Acceptance checks defer to it.

- **Default (sections omitted) — preamble-only**: The output contains **only** the preamble — the title, introductory description, and `### Key features` block (everything before the first `## ` heading). No `## ` section from the source appears in the output.
- **`before:<heading>`**: The output contains the preamble plus every `## ` section that appears before `<heading>`. The boundary heading itself and everything after it must be absent.
- **Comma-separated heading list**: The output contains exactly the listed sections, in source order. Sections not listed are absent.
- **`all`**: The output contains every section from the source.

In every case the output contains **only** in-scope content. Out-of-scope sections are never copied verbatim and never appended.

## Output

- A Markdown file at `outputFile` containing:
  - The translated section(s) with all Markdown formatting preserved.
  - Any sections that were **not** selected for translation copied verbatim from the source.
  - A comment header at the top of the file indicating the source file, target language, and the date of generation.

## Behavior / Steps

1. **Read the source file** from `sourceFile`. Parse it into top-level sections by splitting on level-2 headings (`## `). The content before the first `## ` heading (title, description, key features) is treated as the "preamble" section.

2. **Determine the translation scope** using the `sections` parameter as defined in the [Scope rule](#scope-rule).

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
   - Include only in-scope content per the [Scope rule](#scope-rule). Out-of-scope sections must not appear.
   - Write the result to `outputFile` in the same directory as `sourceFile`.

6. **Validate** before writing:
   - Confirm that no fenced code block content was altered.
   - Confirm that no image paths were changed.
   - Confirm the output matches the [Scope rule](#scope-rule) for the selected `sections` value.
   - Recommended: run `scripts/verify-translation.sh <sourceFile> <outputFile> [--before "## Heading"]` to assert byte-for-byte equality of fenced code blocks, image URLs, hyperlink URLs, and inline code spans within the in-scope range.

## Quality criteria / Acceptance checks

- The output file exists at the expected path.
- The output content matches the [Scope rule](#scope-rule) for the selected `sections` value.
- Code fences and their content are byte-for-byte identical to the source.
- Image `src` paths are unchanged; alt text is translated where applicable.
- The translation reads naturally in the target language with the requested tone — avoid literal word-for-word translations that sound unnatural.
- No section is accidentally duplicated or omitted from the intended scope.
- The comment header is present at the top of the output file.
- `scripts/verify-translation.sh` exits with status 0 (use `--before "## Heading"` for `before:<heading>` scope, or omit the flag for `all`).

## Example invocation

Translate everything before `## Demo` into German with an informal tone and write to `README_DE.md`:

```
sections: before:## Demo
targetLanguage: German
tone: informal and friendly
sourceFile: open-weather-connector-product/README.md
outputFile: README_DE.md
```
