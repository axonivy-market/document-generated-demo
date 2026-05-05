---
name: callable-sub-listing
description: 'Generate docs listings for Axon Ivy CALLABLE_SUB process files and connector-tagged CallSubStart entries, including signature, parameter, and result details. Use when process JSON changes and docs need refresh.'
argument-hint: '[optional: path-glob for process files]'
user-invocable: true
---

# Callable Sub Listing

Generate a repeatable documentation listing from process files where:
- process kind is CALLABLE_SUB
- start element type is CallSubStart
- tags contains connector

## Inputs
- Optional file glob argument. Default: `./**/*.p.json`
- Optional output file path. If omitted, print to stdout

## Procedure
1. Ensure `jq` is available.
2. Run the listing script:
   - `bash ./.github/skills/callable-sub-listing/scripts/list-callable-sub-starts.sh`
3. For docs output, write to a file:
   - `bash ./.github/skills/callable-sub-listing/scripts/list-callable-sub-starts.sh './**/*.p.json' docs/callable-sub-starts.md`
4. Copy the generated Markdown section into product docs as needed.

## Output Shape
The script outputs Markdown grouped by process file and includes:
- signature
- input (params)
- result (params)

See details in [format reference](./references/output-format.md).
