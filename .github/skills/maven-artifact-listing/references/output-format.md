# Output Format Reference

The maven artifact listing generates a sequential numbered list with artifact details and Maven dependency declarations.

## Format Structure

- Sequential numbering: `N.installer-type:`
- For each artifact:
  - Sequential header with installer type (maven-dependency, maven-import, or maven-dropins)
  - Raw XML `<dependency>` declaration:
    - `<groupId>` – Maven group ID
    - `<artifactId>` – Maven artifact ID
    - `<type>` – Artifact format (e.g., iar, jar)

## Example Output

```
1.maven-dependency:
<dependency>
  <groupId>com.axonivy.connector.docuware</groupId>
  <artifactId>docuware-connector</artifactId>
  <type>iar</type>
</dependency>

2.maven-import:
<dependency>
  <groupId>com.axonivy.connector.docuware</groupId>
  <artifactId>docuware-connector-demo</artifactId>
  <type>iar</type>
</dependency>
```

## Edge Cases

- If no artifacts are found, output is empty