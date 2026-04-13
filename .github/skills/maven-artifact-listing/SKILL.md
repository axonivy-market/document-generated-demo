---
name: maven-artifact-listing
description: provide a list of maven artifacts that current Axon Ivy project could produce via product.json in product module.
---

Purpose
-------
Provide a list of Maven artifacts that the current Axon Ivy project could produce via `product.json` in the product module.

Inputs
------
- `version` (optional): version string to include in the README. Default: "1.0.0".
- `module` (optional): explicit module name to treat as the product module.

Output
------
- A README markdown string that follows the Axon Ivy Maven artifact README schema with these top-level sections in order from [format reference](./references/output-format.md)

Behavior / Steps
----------------
1. Read the `pom.xml` to identify the build version. If a `version` input is provided as snapshot, use its official release version instead (for example, "1.0.0-SNAPSHOT" should be treated as "1.0.0"). If no version can be determined, use the default "1.0.0".
2. Check the `product.json` file in the product module for the list of artifacts that the project produces. If no `product.json` is found, return an empty artifact list.


## Output
- A markdown string that follows the Axon Ivy Maven artifact README schema with these top-level sections in order from [format reference](./references/output-format.md)
