---
name: generate-ivy-readme
description: Generate a product README for an Axon Ivy project. Use when asked to create, generate, or update a README.md or README_DE.md for an Axon Ivy product module.
---

Purpose
-------
Create a well-structured README for an Axon Ivy product following the schema in [format reference](./references/output-format.md).
Content is derived from the main module(s) and demo module(s). The tone is friendly and professional, suitable for both technical and non-technical stakeholders.

Inputs
------
- `workspacePath` (optional): path to repository root. Default: current workspace.
- `module` (optional): explicit module name to treat as the main module.

Configuration defaults
----------------------
- `keyFeatureRange`: 3–8 bullets
- `excludeSuffixes`: `test` or `webtest`

Sub-skill protocol
------------------
For every **APPLY SKILL: `<name>`** instruction in the steps below:
1. Call the specified skill with the given arguments.
2. Inject the stdout output **verbatim** at the named `{{placeholder}}` — do not reformat, summarize, or paraphrase.

Output
------
- **If `README.md` does not exist** in the product module: generate a full README and write it there.
- **If `README.md` already exists**: replace all of section content if its outdated, but preserve the original wording as much as possible.

Behavior / Steps
----------------
1. Read the root `pom.xml`. If it declares `<modules>`, enumerate them.

2. Classify each module by its artifactId or folder name suffix:
   - `-demo` → demo module(s) — context used in `## Demo` only
   - `test` → exclude from README
   - `-product` → product module (target location for `README.md` and images)
   - others → candidate main module(s)

3. Pick the main module: prefer a module that is not `-demo`, `-test`, or `-product`. If the only non-test module is a `-demo` module, treat it as the main module (note in the README that callable subs and form components may carry a demo context).

4. **DISCOVERY PHASE** — run sub-tasks 4a–4f and collect all outputs before assembling.
   - **Script-backed** (4b, 4c, 4e, 4f): invoke via `APPLY SKILL`, inject stdout verbatim into the named placeholder (see Sub-skill protocol above).
   - **AI-inspection** (4a, 4d): read source files directly and write content — no script, no verbatim injection.

   | Step | Input source | Action | Placeholder |
   |------|-------------|--------|-------------|
   | 4a | Main module `src/`, `config/roles.xml`, `config/rest-clients.yaml` | Inspect (details below) | Key features, `{{openApiSection}}` |
   | 4b | Main module `processes/*.p.json` | APPLY SKILL: `callable-sub-listing` | `{{callableSubSection}}` |
   | 4c | Main module `<main-module>/src_hd` | APPLY SKILL: `form-components-listing` | `{{formComponentSection}}` |
   | 4d | Demo module(s) processes | Inspect (details below) | `## Demo` content |
   | 4e | Product module `product.json` | APPLY SKILL: `maven-artifact-listing` | `{{mavenArtifactSection}}` |
   | 4f | Product module directory name | APPLY SKILL: `product-image-summary` | Image catalog (used in step 6) |

   **4a — Key features & configuration:**
   - Derive 3–8 concise, marketing-oriented Key features bullets from public API, services, and exported classes in `src/`. Main module only — no demo-only artifacts.
   - From `config/roles.xml`: note any roles other than "Everybody" for the `## Setup` section. If "Everybody" is the only role, omit the roles section entirely.
   - From `config/rest-clients.yaml`: if `OpenAPI.SpecUrl` is an public URL (`http://` or `https://`), insert its markdown snippet (`![Rest Client Name](URL)`) (e.g. `![Petstore](https://petstore.swagger.io/v2/swagger.json)`) in `{{openApiSection}}`. If no public OpenAPI specs are found, mention that there are no public specs available.

   **4d — Demo workflows:**
      **Tone:** Friendly and professional; write for non-technical stakeholders. Avoid jargon — focus on value, use cases, and how to reproduce the demo.

      **Writing each workflow:**
      Translate each demo process into separated step-by-step guideline. Adapt the number of steps freely to fit the actual workflow. Each step must focus on the user action or observable outcome — not internal technical details. Cover:
      - How to launch the process (use the friendly name from the `RequestStart` element, not the internal file name).
      - What the user sees at each stage (general view of dialogs, forms, displayed information).
      - What the user can do at each stage (fill in fields, trigger actions, view results).
      
      If a Docker image or example deployment is available, mention it in the last step.
      > Docker/example deployments belong in `## Demo` only — never in Key features.

      **Merging with an existing `## Demo` section:**
      When a `## Demo` section already exists, compare it against the freshly analyzed demo processes and apply:
      - **Add** a new workflow for any `RequestStart` process present in the demo module but not yet documented.
      - **Remove** any workflow for a process no longer found in the demo module (deleted or renamed).
      - **Update** any workflow whose description no longer matches the current process flow; preserve accurate wording and rewrite only what has changed.

   **4f — Image catalog:**
   - Skip silently if no `images/` directory exists in the product module.
   - Image paths from the catalog use the form `<product-module>/images/…`. Strip the leading `<product-module>/` prefix so all paths start with `images/` before using them.

5. Assemble the README following the schema in `output-format.md`:
   -  For each image from `product-image-summary`: use its `> Suggested readme placement` hint to place it in the correct section, then insert its markdown snippet (`![alt](images/…)`) immediately after the step/paragraph/content it illustrates.
   -  Do not create an isolated image section.
   - The schema of readme should strictly follow the order and structure defined in `output-format.md`. Do not rearrange sections or headings.
   - If there no relevant content for a section (for example, no OpenAPI specs or no roles), do not omit the section entirely. 
   Instead, include the section heading and a single bullet noting the absence of that content (for example, "This product does not require any special roles" or "No public OpenAPI specs are available for this product").
   - All of the extracted content from Apply skill in step 4 must be injected verbatim without reformatting or summarization. Do not rewrite or paraphrase the output from the sub-skills; simply place it in the correct section as-is.
   - Replace `{{variableSection}}` with this exact fenced block (preserve the backticks literally in the output file):

```
@variables.yaml@
```

7. **APPLY SKILL: `translate-readme`** — pass `productModule` set to the product module folder name.

Invariants
----------
- Section and heading order must follow `output-format.md` exactly.
- Image paths normalized to `images/…` (relative to product module) before insertion.
- A translated file (`README_DE.md` by default) must exist after the skill completes.
- Key features: 3–8 bullets, marketing language, main module only — no technical jargon.