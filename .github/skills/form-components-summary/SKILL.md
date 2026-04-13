---
name: form-components-summary
description: give me a detailed summary about available form components from main module(s)?
argument-hint: '[optional: main module name]'
user-invocable: true
---

# Form Components Summary

Generate a concise, marketing-oriented summary of available form dialog and form components from main module(s) in an Axon Ivy project.

## Inputs
- Optional main module name.

## Procedure
1. Extract form component information from the main module(s) which is located by default in `src_hd`. Each component typically defined in its own directory with the structure:
 - XHTML file: reflect how ui looks like and what components are used in the form. Some logic could be implemented in UI's manage bean or additional javascript files, so it is important to also check these additional files for any features implemented in Java or scripting languages.
 - Process file: reflect the logic behind the form and any additional features implemented in Java or scripting languages. The name space of component is usually defined in the process file.
 - Data source definitions: reflect the data sources used in the form and their structure. This can provide insights into the data handling capabilities of the form components.
4. Check if there are any availbale form components that are reusable across different forms which is usually: 
  - located in `component` directory of `src_hd`.
  - defined as `IvyComponent` in the xhtml component type attribute.
  - could include parameters that can be configured when the component is used in a form.

## Output
- A markdown string that follows the Axon Ivy product UI form component schema with these top-level sections in order from [format reference](./references/output-format.md)
