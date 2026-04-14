# Document Generated Demo

A demonstration repository showcasing **GitHub Copilot skills** for automated documentation generation in Axon Ivy projects. This repository contains reusable skills that generate and maintain consistent, high-quality documentation for Axon Ivy marketplace products.

## 📚 Available Skills

### 1. **generate-ivy-readme**
Generates comprehensive, well-structured README files for Axon Ivy products following a standardized schema.

**Features:**
- Non-technical summaries for stakeholders
- Key features extraction from main modules
- Demo workflows from demo modules
- Technical setup instructions
- Components documentation
- Maven artifact listings

**Use case:** Automated README generation for Axon Ivy marketplace products

---

### 2. **callable-sub-listing**
Extracts and documents CALLABLE_SUB process definitions and connector-tagged entries from Axon Ivy projects.

**Features:**
- Process signature extraction
- Parameter documentation
- Result type documentation
- Connector tag identification
- Sequential numbering and detailed listings

**Use case:** Generate reference documentation for callable sub-processes

---

### 3. **callable-sub-summary**
Provides marketing-oriented summaries of available callable sub-processes and their capabilities.

**Features:**
- Feature-focused descriptions
- Non-technical language suitable for stakeholders
- Capability highlights
- Integration guidance

**Use case:** Product overview generation

---

### 4. **form-components-listing**
Documents available form components from main Axon Ivy modules.

**Features:**
- DataClass form field extraction
- UI component discovery
- Component property documentation
- Usage examples

**Use case:** Generate form component reference docs

---

### 5. **maven-artifact-listing**
Extracts Maven dependencies and generates dependency documentation for Axon Ivy products.

**Features:**
- Direct dependency extraction
- Maven XML snippet generation
- Sequential artifact numbering
- Artifact metadata documentation

**Use case:** Generate dependency reference for developers

---

## 🚀 Quick Start

### Using a Skill via GitHub Copilot

Run a skill using the Copilot CLI:

```bash
copilot -p "Use the /generate-ivy-readme skill to create a README for my Axon Ivy project"
```

Or invoke a specific skill with parameters:

```bash
copilot -p "Please use /callable-sub-listing to generate documentation for processes/*.p.json"
```

### Skill Location

Each skill is located in `.github/skills/<skill-name>/`:

```
.github/skills/
├── callable-sub-listing/
├── callable-sub-summary/
├── form-components-listing/
├── generate-ivy-readme/
└── maven-artifact-listing/
```

---

## 📖 How Skills Work

Each skill directory contains:

- **SKILL.md** - Skill definition with purpose, inputs, outputs, and behavior
- **scripts/** - Implementation scripts (JavaScript or shell)
- **references/** - Format references and templates

### Example Skill Structure

```
generate-ivy-readme/
├── SKILL.md                          # Skill documentation
├── references/
│   └── output-format.md             # README format reference
└── scripts/
    └── generate-readme.js           # Implementation
```

---

## 🔧 Integration

These skills are designed for use with:

- **GitHub Copilot Chat** - Interactive documentation generation
- **GitHub Actions** - Automated documentation workflows
- **VS Code** - Local development with Copilot assistance

### Example GitHub Action Workflow

```yaml
name: Auto-Generate Documentation

on:
  pull_request:
    paths:
      - 'processes/**'
      - 'src/**'

jobs:
  generate-docs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Generate README
        run: |
          copilot -p "Use /generate-ivy-readme to update the README"
```

---

## 📝 Best Practices

1. **Keep modules organized**: Separate main (`pdf-box/`), demo (`pdf-box-demo/`), test, and product modules
2. **Update documentation regularly**: Re-run skills when code changes
3. **Review generated content**: Validate and adjust as needed for your use case
4. **Maintain consistency**: Use the same skills across related projects
5. **Version skills**: Tag skill versions for reproducible documentation

---

## 📋 Supported Project Types

- **Axon Ivy Processes** (`.p.json` files)
- **Axon Ivy DataClasses** (`.d.json` files)
- **Axon Ivy HTML Dialogs** (`.xhtml` files)
- **Axon Ivy Configuration** (`roles.xml`, `rest-clients.yaml`, `variables.yaml`)
- **Java Services** (SPI implementations, exported classes)
- **Maven Projects** (`pom.xml` files)

---

## 🛠️ Development

### Adding a New Skill

1. Create a directory in `.github/skills/<skill-name>/`
2. Add `SKILL.md` with skill definition:
   - Purpose
   - When to use
   - Inputs/Outputs
   - Behavior/Steps
   - Quality criteria
3. Create implementation in `scripts/`
4. Add format references if needed in `references/`

### Running Locally

Skills can be tested locally using the Copilot CLI:

```bash
copilot -p "Run the /my-skill skill with input: <input>"
```

---

## 📦 Requirements

- **GitHub Copilot** access
- **Node.js 18+** (for JavaScript scripts)
- **Bash 4+** (for shell scripts)
- Axon Ivy project structure (for generate-ivy-readme target)

---

## 🔗 Related Resources

- [Axon Ivy Market](https://market.axonivy.com/)
- [Axon Ivy Documentation](https://docs.axonivy.com/)
- [GitHub Copilot Skills](https://github.com/features/copilot)

---

## 📄 License

This repository is part of the Axon Ivy market ecosystem. See LICENSE for details.

---

## 🤝 Contributing

To improve these skills:

1. Test changes locally with Copilot CLI
2. Update SKILL.md with any behavioral changes
3. Ensure outputs follow the defined format references
4. Validate with sample Axon Ivy projects

---

**Created:** April 2026  
**Purpose:** Demonstration of GitHub Copilot skills for automated Axon Ivy documentation
