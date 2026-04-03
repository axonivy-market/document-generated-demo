---
name: generate-ivy-readme
description: Generate a product README for an Axon Ivy project.
---

Purpose
-------
Create a well-structured, detailed README for an Axon Ivy product that follows the Axon Ivy product README schema.

When to use
-----------
- Use in Axon Ivy repos that include a multi-module `pom.xml` at the repository root.
- Use when you want a consistent product README that is friendly for non-technical stakeholders and detailed enough for Axon Ivy developers.

Inputs
------
- `workspacePath` (optional): path to repository root. Default: current workspace.
- `pomPath` (optional): path to root `pom.xml` to scan.
- `module` (optional): explicit module name to treat as the main module.

Output
------
- A README markdown string that follows the Axon Ivy product README schema with these top-level sections in order:
  1. Title
  2. Description - no header required for this section:
     - Introduction and value proposition of the product in simple language for non-technical stakeholders.
     - Bullet list of key features in general which is extracted from the chosen main module (exclude demo/product artifacts)
     - Exposed callable subprocesses provided by the main module
  3. Demo (exact header: "## Demo")
  4. Setup (exact header: "## Setup")
  5. Optional: Screenshots / assets table (if images found in product module)

- The skill should write `README.md` to the repository root when executed in-place. If the runner only returns a markdown string, the caller should save it to `README.md`.

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
   - Callable subprocesses by calling this skill's sibling `callable-sub-summary` skill with the main module's process files as input.
   - Mandatory configuration definitions in `config/` (roles, variables, databases, rest clients) to be listed in Setup.
   - Derive the "Key features" list (3–8 concise bullets) only from this main module — do not include demo-only artifacts here.
5. Inspect demo module(s) for user flows (step lists) and demo-only assets:
   - Find process definitions and any CMS or webContent pages used by the demo.
   - Translate sequence of demo processes into a step-by-step user workflow for the `## Demo` section.
   - Include sample docker setup or provided example deployments only in the `## Demo` section (do not list them as Key features).
7. Render the final README. Ensure `## Demo` appears before `## Setup` and both are top-level headings exactly as written.

Quality criteria / Acceptance checks
----------------------------------
- README contains the headings in this order: product name  , `## Demo`, `## Setup`.
- Language: simple, non-technical summary first; technical details in Setup.
- Key features: 3–8 concise bullet points derived from the main module only. The writing style should be       accessible to non-technical stakeholders and marketing-oriented. It should avoid technical jargon and focus on the value proposition and capabilities of the product.
- Exposed callables: list with name, parameters and return type where available.
- Demo: one or more concrete user workflows (step lists) derived from demo processes.
- Setup: include mandatory set up (if needed) in roles, variables, databases from main module.

Implementation notes for the Copilot agent
----------------------------------------
- Use an XML parser to read `pom.xml` and extract `<modules>` and `<artifactId>`.
- Use heuristics to classify modules by suffix (`-demo`, `-test`, `-product`).
- When assembling the README, ensure "Key features" are sourced strictly from the chosen main module; demo-only artifacts (Docker Compose, sample data, demo scripts) belong only in the `## Demo` section.

Acceptance checklist for the skill author
---------------------------------------
- [ ] Detect modules from root `pom.xml`.
- [ ] Classify modules and select the main/demo/product modules.
- [ ] Extract callable subprocesses when available.
- [ ] Produce README with `## Demo` then `## Setup` headings.

End of skill.