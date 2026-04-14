# Output Format Reference

The generated README should follow this format:

```markdown
# Product Name
Product description: a simple, non-technical summary of the product's value proposition and capabilities. This should be accessible to non-technical stakeholders and marketing-oriented, avoiding technical jargon.
### Key features
- Concise bullet point describing a key feature of the product.

## Demo
Step-by-step user workflow derived from the demo module(s). This should describe how a user would interact with the product in a real-world scenario, based on the processes and assets found in the demo module(s).

## Setup
Technical setup instructions derived from the main module's configuration definitions. This should include any mandatory configuration steps such as roles, variables, databases, and rest clients that are required to get the product up and running.
If the main module requires variables, the README should include a code snippet with the content of `@variables.yaml@` as placeholders for required values which will be replaced while the module is being packaged as below:

```
@variables.yaml@
```

## Components
List of notable components exposed by the main module, categorized by type (e.g. CALLABLE_SUB processes, form components, PI process extensions, Open API resources, Maven artifacts). Each item should include relevant details such as parameters, return types, and usage notes. If no components of a given type are exposed, that category should be omitted from the README.
### Exposed CALLABLE_SUB processes
- List of callable sub processes exposed in main module. Each item should include the process name, parameters and return type where available.
### Form components
- List of form components exposed in main module. Each item should include the component name, available parameters and its types.
### PI process extensions
- List of process extensions (e.g. process start, process end, activity entry/exit) exposed in main module. Each item should include the extension type, the target process and any relevant parameters.
### Open API resources
- List of Open API resources exposed in main module or from open API specifications. Each item should include the resource name, available endpoints, and any relevant parameters.
### Maven artifacts
- List of notable Maven artifacts (groupId:artifactId:version) exposed from product module that we can use/ import or download from a registry.
```
