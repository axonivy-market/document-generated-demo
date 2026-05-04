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
- **If `README.md` already exists**: parse each top-level `## ` heading into a map of `section → current content`. Compare generated content to the existing README and compute two change sets:

   - **Additions:** items present in the generated output but absent from the existing README. These additions will be appended automatically to the relevant sections.
   - **Proposed removals:** items present in the existing README but not found in the generated content. Proposed removals are NOT applied automatically. The skill will present a summary of proposed removals and ask the user to confirm each deletion before applying it.

If the skill is run non-interactively (no confirmation channel), it will not perform deletions. Instead it will write a `README.PROPOSED.md` containing the merged README with suggested removals commented, and a `README.changes.json` summarizing additions and proposed removals for manual review. The skill never silently deletes content.

Behavior / Steps
----------------
1. Read the root `pom.xml`. If it declares `<modules>`, enumerate them.

2. Classify each module by its artifactId or folder name suffix:
   - `-demo` → demo module(s) — context used in `## Demo` only
   - `-test` → exclude from README
   - `-product` → product module (target location for `README.md` and images)
   - others → candidate main module(s)

3. Pick the main module: prefer a module that is not `-demo`, `-test`, or `-product`. If the only non-test module is a `-demo` module,
treat it as the main module (note in the README that callable subs and form components may carry a demo context).

4. Check for an existing `README.md` in the product module. If it exists, read it and parse each top-level `## ` heading into a map of `section → current content`. Apply the merge behavior defined in the **Output** section above.

5. **DISCOVERY PHASE** — run sub-tasks 5a–5f and collect all outputs before assembling.
   - **Script-backed** (5b, 5c, 5e, 5f): invoke via `APPLY SKILL`, inject stdout verbatim into the named placeholder (see Sub-skill protocol above).
   - **AI-inspection** (5a, 5d): read source files directly and write content — no script, no verbatim injection.

   | Step | Input source | Action | Placeholder |
   |------|-------------|--------|-------------|
   | 5a | Main module `src/`, `config/roles.xml`, `config/rest-clients.yaml` | Inspect (details below) | Key features, `{{openApiSection}}` |
   | 5b | Main module `processes/*.p.json` | APPLY SKILL: `callable-sub-listing` | `{{callableSubSection}}` |
   | 5c | Main module `<main-module>/src_hd` | APPLY SKILL: `form-components-listing` | `{{formComponentSection}}` |
   | 5d | Demo module(s) processes | Inspect (details below) | `## Demo` content |
   | 5e | Product module `product.json` | APPLY SKILL: `maven-artifact-listing` | `{{mavenArtifactSection}}` |
   | 5f | Product module directory name | APPLY SKILL: `product-image-summary` | Image catalog (used in step 6) |

   **5a — Key features & configuration:**
   - Derive 3–8 concise, marketing-oriented Key features bullets from public API, services, and exported classes in `src/`. Main module only — no demo-only artifacts.
   - From `config/roles.xml`: note any roles other than "Everyone" for the `## Setup` section. If "Everyone" is the only role, omit the roles section entirely.
   - From `config/rest-clients.yaml`: if `OpenAPI.SpecUrl` is an public URL (`http://` or `https://`), insert its markdown snippet (`![Rest Client Name](URL)`) in `{{openApiSection}}`.
   If there are no public URLs, omit the OpenAPI section entirely.

   **5c — Form components:**
   - If there is no Form component, omit the section entirely.

   **5d — Demo workflows:**
   - Tone: friendly and professional, and simple enough for non-technical stakeholders to understand the value, use cases, and how to reproduce the demo.
   Avoid excessive technical jargon in the demo descriptions.
   - Translate demo process sequences into step-by-step user workflows for `## Demo`.
   - Each workflow must explain step by step and follow this structure:
     1. **Start**: Name the process to launch, using the friendly name from the `RequestStart` element (not the internal process file name).
     2. **What happens**: Describe what the user will see or experience — which dialog or form opens, what information is displayed.
     3. **Interact**: Describe which features the user can interact with (e.g., fill in fields, trigger actions, see results).
   - If a Docker image or example deployment is provided for demo purposes, mention it in the last sentence of the workflow description.
   - Each step should be concise and focused on the user action or observable outcome, rather than internal technical details.
   - Docker/example deployments go in `## Demo` only — not in Key features.

   **5f — Image catalog:**
   - Skip silently if no `images/` directory exists in the product module.
   - Image paths from the catalog use the form `<product-module>/images/…`. Strip the leading `<product-module>/` prefix so all paths start with `images/` before using them.

6. Assemble the README from all collected outputs. For each image from `product-image-summary`: use its `> Suggested readme placement` hint to place it in the correct section,
then insert its markdown snippet (`![alt](images/…)`) immediately after the step/ paragraph/ content it illustrates. Do not create a isolated image section.

7. Replace `{{variableSection}}` with this exact fenced block (preserve the backticks literally in the output file):

```
@variables.yaml@
```

8. Write or merge `README.md` to the product module, then **APPLY SKILL: `translate-readme`** — pass `productModule` set to the product module folder name. This produces `README_DE.md` covering the title, description, and `### Key features` block in German.

Invariants
----------
- Heading order should follow the schema from `output-format.md`. If a section has no content, it is omitted entirely (e.g., if there are no form components, the `### Form components` section is not included at all; if `{{callableSubSection}}` is empty, the `### Exposed CALLABLE_SUB processes` heading is also omitted).
- Sub-skill output injected verbatim — never reformatted (see Sub-skill protocol).
- Image paths normalized to `images/…` (relative to product module) before insertion.
- Merge behavior: additions are applied automatically; deletions require explicit user confirmation. When no confirmation is available, no deletions are performed and proposed-change files (`README.PROPOSED.md` and `README.changes.json`) are produced for review.
- A translated file (`README_DE.md` by default) must exist after the skill completes.
- Key features: 3–8 bullets, marketing language, main module only — no technical jargon.
- If any section has no content (e.g., no form components, no roles, no OpenAPI URLs), that section is omitted entirely from the README.
