# Troubleshooting: Generate README Workflow

## Issue
The workflow failed with: `error: unknown option '--skill'` when trying to run:
```bash
copilot run --skill ".github/skills/generate-ivy-readme" --input '{"workspacePath":"."}'
```

## Root Cause
**The command syntax was incorrect.** According to the [GitHub Copilot CLI documentation on creating skills](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/create-skills):

1. **Skills are NOT directly executable** with `copilot run --skill` command
2. **Skills are auto-discovered** by Copilot based on the instructions in `SKILL.md`
3. **Skills are referenced in prompts** using forward slash notation: `/skillname`
4. **The skill is injected into the agent context** when relevant to the task

## How Copilot Skills Actually Work

When a skill exists in `.github/skills/generate-ivy-readme/SKILL.md`:
- Copilot automatically discovers it
- When you (or the workflow) mentions the skill in a prompt like "Use the /generate-ivy-readme skill to...", Copilot loads and follows those instructions
- The `SKILL.md` file provides detailed instructions for the agent to follow

## The Fix

The workflow was updated to:

1. **Use the Copilot agent interactively** in non-interactive mode (suitable for GitHub Actions)
2. **Pass a prompt that references the skill**: `Use the /generate-ivy-readme skill to generate a README`
3. **Let Copilot load and follow the skill's instructions** automatically
4. **Verify the output file** (`README.md`) was created

### Updated Command Structure

Instead of trying to "run" the skill directly:
```bash
# ❌ WRONG - This doesn't work
copilot run --skill ".github/skills/generate-ivy-readme"

# ✓ CORRECT - Reference skill in a prompt
echo "Use the /generate-ivy-readme skill to..." | copilot
```

## Key Learning from GitHub Docs

From [Creating agent skills documentation](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/create-skills#using-agent-skills):

> "To tell Copilot to use a specific skill, include the skill name in your prompt, preceded by a forward slash. For example, if you have a skill named "frontend-design" you could use a prompt such as: `Use the /frontend-design skill to create a responsive navigation bar in React.`"

This is exactly how the workflow now works - by sending a prompt that mentions the skill to the Copilot agent.

## Troubleshooting Next Steps

If the workflow still fails:

1. **Check copilot installation**:
   ```bash
   which copilot
   copilot --version
   ```

2. **Test the skill locally**:
   ```bash
   # Interactive mode
   copilot
   # Then type: Use the /generate-ivy-readme skill to generate README for this project
   ```

3. **Verify SKILL.md is valid**:
   - Located at: `.github/skills/generate-ivy-readme/SKILL.md`
   - Has proper YAML frontmatter with `name` and `description`
   - Contains clear instructions for the agent

4. **Check API token**:
   - Ensure `COPILOT_API_TOKEN` is set in GitHub repository secrets
   - Token must have necessary permissions

## References

- 📖 [GitHub Copilot CLI - Creating Skills](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/create-skills)
- 📖 [About Agent Skills](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills)
- 📖 [Skill Specification Format](../.github/skills/generate-ivy-readme/SKILL.md)
