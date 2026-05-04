---
name: generate-ivy-readme
description: Generate a product README for an Axon Ivy project.
---

Purpose
-------
Create a well-structured README for an Axon Ivy product following the schema in [format reference](./references/output-format.md).
Content is derived from the main module and demo module(s), with a clear separation between product features and demo-only assets.

When to use
-----------
- Use in Axon Ivy repos that include a multi-module `pom.xml` at the repository root.
- Use when you want a consistent product README that is friendly for non-technical stakeholders and detailed enough for Axon Ivy developers.

Inputs
------
- `workspacePath` (optional): path to repository root. Default: current workspace.
- `pomPath` (optional): path to root `pom.xml` for version extraction. Default: `pom.xml` in workspace root.
- `module` (optional): explicit module name to treat as the main module.

Configuration defaults
----------------------
- `defaultLocale`: `DE` (used when no `README_<LANG>.md` exists in the product module)
- `keyFeatureRange`: 3–8 bullets
- `excludeSuffixes`: `-test`

Sub-skill protocol
------------------
For every **APPLY SKILL: `<name>`** instruction in the steps below:
1. `read_file` the skill at `.github/skills/<name>/SKILL.md`.
2. Execute it with the listed inputs.
3. Inject the stdout output **verbatim** at the named `{{placeholder}}` — do not reformat, summarize, or paraphrase.

Output
------
- **If `README.md` does not exist** in the product module: generate it in full and write it there.
- **If `README.md` already exists**: append-only merge — parse each `## ` section into a map, identify items absent from the existing content, and append only those. Never remove or rewrite existing lines.

Behavior / Steps
----------------
1. Read the root `pom.xml`. If it declares `<modules>`, enumerate them.

2. Classify each module by its artifactId or folder name suffix:
   - `-demo` → demo module(s) — context used in `## Demo` only
   - `-test` → exclude from README
   - `-product` → product module (target location for `README.md` and images)
   - others → candidate main module(s)

3. Pick the main module: prefer a module that is not `-demo`, `-test`, or `-product`. If the only non-test module is a `-demo` module, treat it as the main module (note in the README that callable subs and form components may carry a demo context).

4. Check for an existing `README.md` in the product module. If it exists, read it and parse each top-level `## ` heading into a map of `section → current content`. Carry this map forward; every later write appends to the relevant bucket, never replaces.

5. **DISCOVERY PHASE** — run sub-tasks 5a–5f and collect all outputs before assembling.

   | Step | Input source | Action | Placeholder |
   |------|-------------|--------|-------------|
   | 5a | Main module `src/`, `config/roles.xml`, `config/rest-clients.yaml` | Inspect (details below) | Key features, `{{openApiSection}}` |
   | 5b | Main module `processes/*.p.json` | APPLY SKILL: `callable-sub-listing` | `{{callableSubSection}}` |
   | 5c | Main module `<main-module>/src_hd` | APPLY SKILL: `form-components-listing` | `{{formComponentSection}}` |
   | 5d | Demo module(s) processes | Inspect (details below) | `## Demo` content |
   | 5e | Product module `product.json` + root `pom.xml` | APPLY SKILL: `maven-artifact-listing` | `{{mavenArtifactSection}}` |
   | 5f | Product module directory name | APPLY SKILL: `product-image-summary` | Image catalog (used in step 6) |

   **5a — Key features & configuration:**
   - Derive 3–8 concise, marketing-oriented Key features bullets from public API, services, and exported classes in `src/`. Main module only — no demo-only artifacts.
   - From `config/roles.xml`: note any roles other than "Everyone" for the `## Setup` section.
   - From `config/rest-clients.yaml`: if `OpenAPI.SpecUrl` is an external URL (`http://` or `https://`), include it in `{{openApiSection}}`; skip `file:///` values.

   **5d — Demo workflows:**
   - Translate demo process sequences into step-by-step user workflows for `## Demo`.
   - Docker/example deployments go in `## Demo` only — not in Key features.

   **5f — Image catalog:**
   - Skip silently if no `images/` directory exists in the product module.
   - Image paths from the catalog use the form `<product-module>/images/…`. Strip the leading `<product-module>/` prefix so all paths start with `images/` before using them.

6. Assemble the README from all collected outputs. For each image from `product-image-summary`: use its `> Suggested readme placement` hint to place it in the correct section, then insert its markdown snippet (`![alt](images/…)`) immediately after the step/ paragraph/ content it illustrates. Do not create a isolated image section.

7. Replace `{{variableSection}}` with this exact fenced block (preserve the backticks literally in the output file):

```
@variables.yaml@
```

8. Write or merge `README.md` to the product module, then **APPLY SKILL: `translate-readme`** — pass `productModule` set to the product module folder name. This produces `README_DE.md` covering the title, description, and `### Key features` block in German.

Invariants
----------
- Heading order: product name → `### Key features` → `## Demo` → `## Setup` → `## Components`.
- Sub-skill output injected verbatim — never reformatted (see Sub-skill protocol).
- Image paths normalized to `images/…` (relative to product module) before insertion.
- Merge is additions-only: a diff of output vs. original must show only added lines, no deletions or modifications.
- A translated file (`README_DE.md` by default) must exist after the skill completes.
- Key features: 3–8 bullets, marketing language, main module only — no technical jargon.
