# Output Format Reference

The maven artifact listing generates a sequential numbered list with artifact details and Maven dependency declarations.

## Ordering rules

1. `maven-dependency` installer artifacts — always listed first (required).
2. `maven-import` artifacts where `importInWorkspace` is omitted or `true` — required imports, listed second.
3. `maven-import` artifacts where `importInWorkspace` is `false` — optional, listed last and marked *(optional)*.

The installer type (`maven-dependency` / `maven-import`) is **not** exposed in the output.

## Format Structure

- Sequential numbering: `N. artifactId` (with ` *(optional)*` suffix for optional artifacts)
- For each artifact, a fenced XML `<dependency>` block:
  - `<groupId>` – Maven group ID
  - `<artifactId>` – Maven artifact ID
  - `<type>` – Artifact format (e.g., `iar`, `jar`)

## Example Output

Given a `product.json` with a `maven-dependency` for `persistence-utils` and `maven-import` projects `persistence-utils-demo`, `persistence-utils-demo-tool`, and `persistence-utils-demo-test` (excluded — ends with `test`):

1. persistence-utils
```xml
<dependency>
  <groupId>com.axonivy.utils.persistence</groupId>
  <artifactId>persistence-utils</artifactId>
  <type>jar</type>
</dependency>
```

2. persistence-utils-demo
```xml
<dependency>
  <groupId>com.axonivy.utils.persistence</groupId>
  <artifactId>persistence-utils-demo</artifactId>
  <type>iar</type>
</dependency>
```

3. persistence-utils-demo-tool
```xml
<dependency>
  <groupId>com.axonivy.utils.persistence</groupId>
  <artifactId>persistence-utils-demo-tool</artifactId>
  <type>iar</type>
</dependency>
```

## Edge Cases

- If no artifacts are found, output is empty
- Artifacts whose `artifactId` ends with `test` are silently excluded from the output
- `maven-dropins` artifacts are listed after optional imports, also without exposing the installer type