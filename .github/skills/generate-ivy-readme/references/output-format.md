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
Technical setup instructions derived from the main module's configuration definitions. This should include any mandatory configuration steps such as roles, databases, and rest clients that are required to get the product up and running.

{{variableSection}}

## Components

### Exposed CALLABLE_SUB processes

{{callableSubSection}}

### Form components

{{formComponentSection}}

### Open API resources

{{openApiSection}}

### Maven artifacts

{{mavenArtifactSection}}

```
