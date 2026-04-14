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
- The skill should write `README.md` to the product module when executed in-place. If the runner only returns a markdown string, the caller should save it to `README.md`.

Restrictions
------------
- All of the result content from subskills (callable-sub-summary, form-components-summary, maven-artifact-listing) must be directly injected into the corresponding sections of the README without manual reformatting or summarization. This ensures traceability and correctness of the generated content.

Behavior / Steps
----------------
1. Read the root `pom.xml`. If it declares `<modules>`, enumerate them.
2. Classify each module by its artifactId or folder name suffix:
   - `-demo` → demo module(s) (its context only be used in Demo section)
   - `-test` → test modules (exclude from README)
   - `-product` → product module (target location for README / images)
   - others → candidate main module(s)
3. Pick the main module: prefer a module that is not `-demo`, `-test` or `-product`. If none found, the main module is the demo.
4. Inspect the main module, looking for (these are the authoritative sources for the README's "Key features"):
   - Public API, exported services, SPI implementations and notable classes in `src/`.
   - Derive the "Key features" list (3–8 concise bullets) only from this main module — do not include demo-only artifacts here.
   - **CALL SUBAGENT: callable-sub-listing** — Pass the main module's process files (processes/*.p.json). **Directly inject the output of this subagent into the `## Components` section using a placeholder of `{{callableSubSection}}`. Do not reformat or summarize; use the subagent's output verbatim.**
   - **CALL SUBAGENT: form-components-summary** — Pass the main module path. **Directly inject the output of this subagent into the `## Components` section using a placeholder such as `{{formComponentSection}}`. Do not reformat or summarize; use the subagent's output verbatim.**
   - Mandatory configuration definitions in `config/`:
       - Existing role from `roles.xml` (do not include default "Everyone" role) which could be mentioned in the component section of the README.
       - Rest client name and existing open api spec section from `rest-clients.yaml` which will be used for `{{openApiSection}}` in the Components section.
5. Inspect demo module(s) for user flows (step lists) and demo-only assets:
   - Find process definitions and any CMS or webContent pages used by the demo.
   - Translate sequence of demo processes into a step-by-step user workflow for the `## Demo` section.
   - Include sample docker setup or provided example deployments only in the `## Demo` section (do not list them as Key features).
6. Inspect product module for Maven artifacts:
   - **CALL SUBAGENT: maven-artifact-listing** — Pass the product module's `product.json` path and the root `pom.xml` path. The `maven-artifact-listing` subskill returns a sequentially numbered list of artifacts with Maven dependency declarations (groupId, artifactId, version extracted from pom.xml with snapshot versions converted to release versions, and type). Insert the returned content verbatim at the `{{mavenArtifactSection}}` placeholder. Do not add additional formatting or change punctuation — inject the subskill output unchanged.
7. The placeholder `{{variableSection}}` must be replaced with the exact fenced code block shown below (include the three backticks on their own lines). Ensure the code fence is preserved in the generated `README.md` output; emit the literal backtick characters and escape them if your templating engine would otherwise interpret or remove them.

```
@variables.yaml@
```

Implementation note: when your generator constructs the README string, it must include the three backtick characters as part of the output. If your templating or serialization step strips or normalizes markdown fences, output the backticks as literal characters (for example: output the string "```" directly) so the final README contains the fenced block exactly as shown above.

Quality criteria / Acceptance checks
----------------------------------
- README contains the headings in this order: product name, `### Key features`, `## Demo`, `## Setup`, `## Components`.
- Language: simple, non-technical summary first; technical details in Setup and Components sections.
- Key features: 3–8 concise bullet points derived from the main module only. The writing style should be accessible to non-technical stakeholders and marketing-oriented. It should avoid technical jargon and focus on the value proposition and capabilities of the product.
- Demo: one or more concrete user workflows (step lists) derived from demo processes.
- Before returning the final README, ensure that the outputs from the sibling skills - callable-sub-summary, form-components-summary, and maven-artifact-listing - are directly injected into the corresponding placeholders of the README without any manual reformatting or summarization. This is crucial for maintaining the accuracy and traceability of the generated content.