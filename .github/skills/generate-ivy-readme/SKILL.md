---
name: generate-ivy-readme
description: Generate a product README for an Axon Ivy project.
---

Purpose
-------
Create a well-structured, detailed README for an Axon Ivy product that follows the standard schema with these top-level sections in order from [format reference](./references/output-format.md).
The README should be accessible to non-technical stakeholders while also providing technical details for developers.
The content should be derived from the main module and demo module(s) of the project, with a clear separation between product features and demo-only assets.

When to use
-----------
- Use in Axon Ivy repos that include a multi-module `pom.xml` at the repository root.
- Use when you want a consistent product README that is friendly for non-technical stakeholders and detailed enough for Axon Ivy developers.

Inputs
------
- `workspacePath` (optional): path to repository root. Default: current workspace.
- `pomPath` (optional): path to root `pom.xml` to scan and extract version for maven-artifact-listing.
- `module` (optional): explicit module name to treat as the main module.

Output
------
- A README markdown string that follows the Axon Ivy product README schema with these top-level sections in order from [format reference](./references/output-format.md)
- **If `README.md` already exists** in the product module: merge into it — read each section, compare its content against what this skill would generate, and append only the specific items that are absent. Never remove or rewrite existing text.
- **If `README.md` does not exist**: generate it in full and write it to the product module.

Restrictions
------------
- All of the result content from subskills (callable-sub-summary, form-components-summary, maven-artifact-listing) must be directly injected into the corresponding sections of the README without manual reformatting or summarization. This ensures traceability and correctness of the generated content.
- Image markdown snippets from `product-image-summary` must be used verbatim (do not alter the alt-text). **Rewrite the image path to be relative to the product module directory** (i.e. strip the leading `<product-module>/` prefix so the path starts with `images/`). Place them in the section indicated by the `Suggested readme placement` hint.

Behavior / Steps
----------------
1. Read the root `pom.xml`. If it declares `<modules>`, enumerate them.
2. Check for an existing `README.md` in the product module:
   - If it exists, read it and parse each top-level section (`## Demo`, `## Setup`, `## Components`, etc.) into a map of `section → current content`.
   - For each section, compare the current content against what this skill would generate for that section:
     - Identify **items present** in the generated output but **absent** from the existing section (e.g. a missing image, an undocumented callable sub, a missing maven artifact).
     - Append those missing items at the end of the existing section.
     - Keep all existing text exactly as-is — do not reword, reorder, or remove anything.
   - If a required section is entirely absent from the existing README, add it in full at the correct position.
   - Carry this merged map forward through all subsequent steps.
3. Classify each module by its artifactId or folder name suffix:
   - `-demo` → demo module(s) (its context only be used in Demo section)
   - `-test` → test modules (exclude from README)
   - `-product` → product module (target location for README / images)
   - others → candidate main module(s)
4. Pick the main module: prefer a module that is not `-demo`, `-test` or `-product`. If none found, the main module is the demo.
5. **PARALLEL PHASE — launch all of the following sub-tasks simultaneously and wait for all results before proceeding to step 6:**

   5a. **Inspect the main module** for Key features and configuration:
      - Public API, exported services, SPI implementations and notable classes in `src/`.
      - Derive the "Key features" list (3–8 concise bullets) only from this main module — do not include demo-only artifacts here.
      - Mandatory configuration definitions in `config/`:
          - Existing role from `roles.xml` (do not include default "Everyone" role) which could be mentioned in the component section of the README.
          - Extract `OpenAPI.SpecUrl` from `rest-clients.yaml`. If `SpecUrl` is Local-only values (e.g. `file:///...`), do not include in README. If it points to an external URL, include it in the `{{openApiSection}}` section with a note that it's an OpenAPI resource.

   5b. **CALL SUBAGENT: callable-sub-listing** — Pass the main module's process files (processes/*.p.json). **Directly inject the output of this subagent into the `## Components` section using a placeholder of `{{callableSubSection}}`. Do not reformat or summarize; use the subagent's output verbatim.**

   5c. **CALL SUBAGENT: form-components-listing** — Pass the main module path. **Directly inject the output of this subagent into the `## Components` section using a placeholder such as `{{formComponentSection}}`. Do not reformat or summarize; use the subagent's output verbatim.**

   5d. **Inspect demo module(s)** for user flows (step lists) and demo-only assets:
      - Find process definitions and any CMS or webContent pages used by the demo.
      - Translate sequence of demo processes into a step-by-step user workflow for the `## Demo` section.
      - Include sample docker setup or provided example deployments only in the `## Demo` section (do not list them as Key features).

   5e. **CALL SUBAGENT: maven-artifact-listing** — Pass the product module's `product.json` path and the root `pom.xml` path. The `maven-artifact-listing` subskill returns a list of artifacts with Maven dependency declarations. Insert the returned content verbatim at the `{{mavenArtifactSection}}` placeholder. Do not add additional formatting or change punctuation — inject the subskill output unchanged.

   5f. **CALL SUBAGENT: product-image-summary** — Pass the product module directory name (e.g. `open-weather-connector-product`). The subagent returns a catalog of images grouped by subdirectory with suggested alt-text and ready-to-copy markdown snippets.
      - If no `images/` directory exists in the product module, skip this sub-task silently.

6. Assemble the README using all results collected from the parallel phase (step 5):
   - Place Key features, configuration, callable subs, and form components into their respective sections.
   - Each image entry from `product-image-summary` includes a `> Suggested readme placement` hint (e.g. `## Demo`, `## Setup`, `## Components`). Use this hint to decide which README section the image belongs in. **Before inserting, rewrite the image path to be relative to the product module directory**: strip the leading `<product-module>/` prefix so the final path starts with `images/` (e.g. `mattermost-connector-product/images/foo.png` → `images/foo.png`). Insert each image's markdown snippet (`![alt](images/...)`) directly into the matching README section. Place each image **immediately after the prose or step it illustrates** — for example, a screenshot of a setup step goes directly after that step's description, not at the end of the section. Only place an image at the end of a section if it applies to the section as a whole and cannot be associated with a specific step or paragraph.
7. The placeholder `{{variableSection}}` must be replaced with the exact fenced code block shown below (include the three backticks on their own lines). Ensure the code fence is preserved in the generated `README.md` output; emit the literal backtick characters and escape them if your templating engine would otherwise interpret or remove them.

```
@variables.yaml@
```

Implementation note: when your generator constructs the README string, it must include the three backtick characters as part of the output. If your templating or serialization step strips or normalizes markdown fences, output the backticks as literal characters (for example: output the string "```" directly) so the final README contains the fenced block exactly as shown above.
8. After `README.md` has been written or merged, **CALL SUBAGENT: translate-readme** to produce locale-specific translated files. Pass the following parameters:
   - `sourceFile`: the path to the `README.md` just written in the product module.
   - For each locale defined in the product module (detect by looking for existing `README_<LANG>.md` files; default to German / `README_DE.md` if none exist):
     - `targetLanguage`: the language matching the locale suffix (e.g. `DE` → `German`).
     - `outputFile`: the locale-specific file name (e.g. `README_DE.md`) in the same directory as `README.md`.
     - `sections`: `before:## Demo` — translate only the preamble and content that appears before the `## Demo` heading.
     - `tone`: `informal and friendly`.
   - The subagent follows the `translate-readme` skill rules: existing translated content is merged (never overwritten), only genuinely absent translated items are appended, and all Markdown structure, code fences, image paths, and technical tokens are preserved verbatim.

Quality criteria / Acceptance checks
----------------------------------
- README contains the headings in this order: product name, `### Key features`, `## Demo`, `## Setup`, `## Components`.
- Language: simple, non-technical summary first; technical details in Setup and Components sections.
- Key features: 3–8 concise bullet points derived from the main module only. The writing style should be accessible to non-technical stakeholders and marketing-oriented. It should avoid technical jargon and focus on the value proposition and capabilities of the product.
- Demo: one or more concrete user workflows (step lists) derived from demo processes.
- Before returning the final README, ensure that the outputs from the sibling skills - callable-sub-summary, form-components-summary, and maven-artifact-listing - are directly injected into the corresponding placeholders of the README without any manual reformatting or summarization. This is crucial for maintaining the accuracy and traceability of the generated content.
- Images discovered by `product-image-summary` must appear in the README in the section matching their placement hint. Each image must be placed immediately after the specific step or paragraph it illustrates; only place an image at the end of a section if it applies to the section as a whole and has no specific associated step.
- **Merge rule:** if a `README.md` already exists, the final output must contain all original text unchanged. Only genuinely absent items (images, artifacts, callable subs, setup steps, key features, etc.) may be appended inside the relevant section. A diff of the output vs. the original must show only additions, never deletions or modifications of existing lines.
- **Translation:** after `README.md` is finalised, a translated variant must exist for every locale detected in the product module (defaulting to `README_DE.md`). Each translated file must carry the `<!-- Translated from README.md | Language: … | Generated: … -->` comment header, must cover at minimum all content before `## Demo`, and must not have altered any code fences, image paths, or inline code spans.