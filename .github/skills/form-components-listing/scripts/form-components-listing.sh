#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 <directory> [--md]

Scan an Axon Ivy UI folder tree and list nested UI dialogs and UI components.

By default prints readable text. Use `--md` (or `md`) as second argument to
emit Markdown output.

Requires: jq
EOF
}

if [[ ${1:-} == "" ]]; then
  usage
  exit 1
fi

ARG=$1

# Determine module and src_hd root.
# If user passed a module name (e.g. process-analyser) or module path, prefer module/src_hd.
if [[ -d "$ARG/src_hd" ]]; then
  MODULE_DIR=$(realpath -m "$ARG")
  ROOT=$(realpath -m "$ARG/src_hd")
elif [[ -d "$ARG" && $(basename "$ARG") == "src_hd" ]]; then
  ROOT=$(realpath -m "$ARG")
  MODULE_DIR=$(realpath -m "$(dirname "$ARG")")
elif [[ -d "$ARG" ]]; then
  # if arg is a full path to module directory which already contains files but no src_hd
  if [[ -d "$ARG/src_hd" ]]; then
    MODULE_DIR=$(realpath -m "$ARG")
    ROOT=$(realpath -m "$ARG/src_hd")
  else
    echo "Error: module '$ARG' does not contain src_hd directory" >&2
    exit 2
  fi
else
  echo "Error: module or path '$ARG' not found" >&2
  exit 2
fi

# module name for relative paths
MODULE_NAME=$(basename "$MODULE_DIR")

# Ensure ROOT exists
if [[ ! -d "$ROOT" ]]; then
  echo "Error: src_hd directory '$ROOT' not found" >&2
  exit 2
fi

to_module_path() {
  # convert an absolute path to module-relative path starting with module name
  local p=$1
  # make absolute
  if command -v realpath >/dev/null 2>&1; then
    p=$(realpath -m "$p")
  fi
  local rel=${p#"$MODULE_DIR"/}
  # if path equals module dir, rel will be p without prefix
  if [[ "$rel" == "$p" ]]; then
    # not under module dir, fallback to basename
    echo "$p"
  else
    echo "$MODULE_NAME/$rel"
  fi
}

FORMAT="text"
if [[ ${2:-} == "--md" || ${2:-} == "md" || ${2:-} == "-m" ]]; then
  FORMAT="md"
fi

# summary-only flag: when set, the script will also emit a concise marketing-style
# summary file and (if requested) print only that summary to stdout.
SUMMARY_ONLY=false
for a in "${@:2}"; do
  case "$a" in
    --summary|-s) SUMMARY_ONLY=true ;;
  esac
done

command -v jq >/dev/null 2>&1 || { echo "Error: 'jq' is required." >&2; exit 3; }

if [[ "$SUMMARY_ONLY" == false ]]; then
  echo "Scanning: $ROOT"
fi

# temporary buffers
dlg_tmp=$(mktemp)
comp_tmp=$(mktemp)
summary_tmp=$(mktemp)

# Collect xhtml files, splitting dialogs vs component dialogs; exclude webContent
while IFS= read -r -d '' xhtml; do
  # skip webContent paths (case-insensitive)
  case "$xhtml" in
    *[/]webContent/*|*[/]webcontent/*)
      continue
      ;;
  esac

  dir=$(dirname "$xhtml")
  # Detect Ivy composite component by checking cc:interface componentType="IvyComponent"
  is_component=false
  if grep -qiE 'componentType\s*=\s*"IvyComponent"' "$xhtml" 2>/dev/null; then
    is_component=true
  else
    # fallback: check data-class files in the same dir for a namespace containing ".component."
    for df in "$dir"/*.d.json; do
      [[ -f $df ]] || continue
      ns=$(jq -r '.namespace // empty' "$df" 2>/dev/null || true)
      if [[ -n $ns ]] && echo "$ns" | grep -q '\.component\.'; then
        is_component=true
        break
      fi
    done
    # fallback: check process p.json config.data or namespace for ".component."
    if [[ $is_component == false ]]; then
      while IFS= read -r -d '' pf; do
        pns=$(jq -r '.config.data // .namespace // empty' "$pf" 2>/dev/null || true)
        if [[ -n $pns ]] && echo "$pns" | grep -q '\.component\.'; then
          is_component=true
          break
        fi
      done < <(find "$dir" -maxdepth 1 -type f -name '*.p.json' -print0)
    fi
  fi
  if [[ $is_component == true ]]; then
    echo "$dir|$xhtml" >> "$comp_tmp"
  else
    echo "$dir|$xhtml" >> "$dlg_tmp"
  fi
done < <(find "$ROOT" -type f -name '*.xhtml' -print0)

if [[ $FORMAT == "md" && "$SUMMARY_ONLY" == false ]]; then
  echo "# Axon Ivy UI Scan"
  echo
  echo "Scanned path: $ROOT"
  echo
  echo "#### dialogs"
elif [[ "$SUMMARY_ONLY" == false ]]; then
  printf "\n--- Dialogs (detected by .xhtml files) ---\n"
fi

# Print normal dialogs (unique dirs)
sort -u "$dlg_tmp" | while IFS='|' read -r dir xhtml; do
  # derive a friendly name from data-class simpleName or directory basename
  name="$(basename "$dir")"
  datafile=$(ls -1 "$dir"/*.d.json 2>/dev/null | head -n1 || true)
  namespace=""
  params=""
  if [[ -n $datafile ]]; then
    ns=$(jq -r '.namespace // empty' "$datafile" 2>/dev/null || true)
    [[ -n $ns ]] && namespace=$ns
    simple=$(jq -r '.simpleName // empty' "$datafile" 2>/dev/null || true)
    [[ -n $simple ]] && name=$simple
    # list fields
    params=$(jq -r '.fields[]? | "- " + .name + " (" + .type + ")"' "$datafile" 2>/dev/null || true)
  fi
  # process info
  pf=$(find "$dir" -maxdepth 1 -type f -name '*.p.json' | head -n1 || true)
  kind=""
  if [[ -n $pf ]]; then
    kind=$(jq -r '.kind // empty' "$pf" 2>/dev/null || true)
    [[ -z $namespace ]] && ns2=$(jq -r '.config.data // .namespace // empty' "$pf" 2>/dev/null || true) && [[ -n $ns2 ]] && namespace=$ns2
  fi
  # compute a best-effort start signature for summary use
  sig=""
  if [[ -n $pf ]]; then
    sig=$(jq -r '.elements[]? | select(.type=="HtmlDialogStart") | .name // empty' "$pf" 2>/dev/null | head -n1 || true)
  fi

  if [[ $FORMAT == "md" && "$SUMMARY_ONLY" == false ]]; then
    echo
    echo "#### $name"
    echo
    echo "- **Name Space**: ${namespace:-(unknown)}"
    # paths (module-relative)
    echo "- **Paths**:"
    echo "  - xhtml: $(to_module_path "$xhtml")"
    echo "- **Component type**: ${kind:-HTML_DIALOG}"
    if [[ -n $params ]]; then
      echo "- **Parameter**:"
      echo "$params" | sed 's/^/  /'
    else
      echo "- **Parameter**: (none declared)"
    fi
    # main logic: best-effort from process elements or filename hints
    if [[ -n $pf ]]; then
      if [[ -n $sig ]]; then
        echo "- **Main logic/feature included in that UI**: Dialog with start method '${sig}'"
      else
        echo "- **Main logic/feature included in that UI**: UI dialog (behavior defined in process)"
      fi
      echo "  - process: $(to_module_path "$pf")"
    else
      echo "- **Main logic/feature included in that UI**: UI view (no process file found)"
    fi
  elif [[ "$SUMMARY_ONLY" == false ]]; then
    echo "\nDialog: $dir"
    echo "  xhtml: $xhtml"
  fi
  # always append a concise summary entry for skill consumption
  {
    echo "#### $name"
    echo "- **Name Space**: ${namespace:-(unknown)}"
    echo "- **Component type**: ${kind:-HTML_DIALOG}"
    if [[ -n $params ]]; then
      echo "- **Parameter**:"
      echo "$params" | sed 's/^/  /'
    else
      echo "- **Parameter**: (none declared)"
    fi
    if [[ -n $pf ]]; then
      if [[ -n $sig ]]; then
        echo "- **Main logic/feature included in that UI**: Dialog with start method '${sig}'"
      else
        echo "- **Main logic/feature included in that UI**: UI dialog (behavior defined in process)"
      fi
    else
      echo "- **Main logic/feature included in that UI**: UI view (no process file found)"
    fi
    echo
  } >> "$summary_tmp"
done

# Components section: include component dialogs collected and p.json component files
if [[ $FORMAT == "md" && "$SUMMARY_ONLY" == false ]]; then
  echo
  echo "#### components"
elif [[ "$SUMMARY_ONLY" == false ]]; then
  printf "\n--- Components (detected under component dirs or p.json type) ---\n"
fi

# Print component dialogs
sort -u "$comp_tmp" | while IFS='|' read -r dir xhtml; do
  name="$(basename "$dir")"
  datafile=$(ls -1 "$dir"/*.d.json 2>/dev/null | head -n1 || true)
  namespace=""
  params=""
  if [[ -n $datafile ]]; then
    ns=$(jq -r '.namespace // empty' "$datafile" 2>/dev/null || true)
    [[ -n $ns ]] && namespace=$ns
    simple=$(jq -r '.simpleName // empty' "$datafile" 2>/dev/null || true)
    [[ -n $simple ]] && name=$simple
    params=$(jq -r '.fields[]? | "- " + .name + " (" + .type + ")"' "$datafile" 2>/dev/null || true)
  fi
  pf=$(find "$dir" -maxdepth 1 -type f -name '*.p.json' | head -n1 || true)
  kind=""
  if [[ -n $pf ]]; then
    kind=$(jq -r '.kind // empty' "$pf" 2>/dev/null || true)
    [[ -z $namespace ]] && ns2=$(jq -r '.config.data // .namespace // empty' "$pf" 2>/dev/null || true) && [[ -n $ns2 ]] && namespace=$ns2
  fi
  if [[ $FORMAT == "md" && "$SUMMARY_ONLY" == false ]]; then
    echo
    echo "#### $name"
    echo
    echo "- **Name Space**: ${namespace:-(unknown)}"
    echo "- **Paths**:"
    echo "  - xhtml: $(to_module_path "$xhtml")"
    echo "- **Component type**: ${kind:-HTML_DIALOG}"
    if [[ -n $params ]]; then
      echo "- **Parameter**:"
      echo "$params" | sed 's/^/  /'
    else
      echo "- **Parameter**: (none declared)"
    fi
    if [[ -n $pf ]]; then
      sig=$(jq -r '.elements[]? | select(.type=="HtmlDialogStart") | .name // empty' "$pf" 2>/dev/null | head -n1 || true)
      if [[ -n $sig ]]; then
        echo "- **Main logic/feature included in that UI**: Component dialog with start method '${sig}'"
      else
        echo "- **Main logic/feature included in that UI**: Reusable Ivy component (behavior in managed bean)"
      fi
      echo "  - process: $(to_module_path "$pf")"
    else
      echo "- **Main logic/feature included in that UI**: Reusable UI component (no process file found)"
    fi
    # also append a concise summary entry for skill consumption
    {
      echo "#### $name"
      echo "- **Name Space**: ${namespace:-(unknown)}"
      echo "- **Component type**: ${kind:-HTML_DIALOG}"
      if [[ -n $params ]]; then
        echo "- **Parameter**:"
        echo "$params" | sed 's/^/  /'
      else
        echo "- **Parameter**: (none declared)"
      fi
      if [[ -n $pf ]]; then
        if [[ -n $sig ]]; then
          echo "- **Main logic/feature included in that UI**: Component dialog with start method '${sig}'"
        else
          echo "- **Main logic/feature included in that UI**: Reusable Ivy component (behavior in managed bean)"
        fi
      else
        echo "- **Main logic/feature included in that UI**: Reusable UI component (no process file found)"
      fi
      echo
    } >> "$summary_tmp"
  elif [[ "$SUMMARY_ONLY" == false ]]; then
    echo "\nComponent Dialog: $dir"
    echo "  xhtml: $xhtml"
  fi
done

# Print p.json component files anywhere (exclude webContent)
while IFS= read -r -d '' pf; do
  case "$pf" in
    *[/]webContent/*|*[/]webcontent/*)
      continue
      ;;
  esac
  type_field=$(jq -r '.type // empty' "$pf" 2>/dev/null || true)
  in_component_dir=false
  case "$pf" in
    */component/*|*/components/*) in_component_dir=true ;;
  esac

  if [[ $in_component_dir == true ]] || echo "$type_field" | grep -qi component; then
    if [[ $FORMAT == "md" && "$SUMMARY_ONLY" == false ]]; then
      echo "\n- Component file: $(to_module_path "$pf")"
      [[ -n $type_field ]] && echo "  - type: $type_field"
      name=$(jq -r '.name // .id // empty' "$pf" 2>/dev/null || true)
      [[ -n $name ]] && echo "  - name: $name"
      if jq -e '.description' "$pf" >/dev/null 2>&1; then
        desc=$(jq -r '.description' "$pf")
        echo "  - description: $desc"
      fi
    elif [[ "$SUMMARY_ONLY" == false ]]; then
      echo "\nComponent file: $(to_module_path "$pf")"
      [[ -n $type_field ]] && echo "  type: $type_field"
      name=$(jq -r '.name // .id // empty' "$pf" 2>/dev/null || true)
      [[ -n $name ]] && echo "  name: $name"
      if jq -e '.description' "$pf" >/dev/null 2>&1; then
        desc=$(jq -r '.description' "$pf")
        echo "  description: $desc"
      fi
    fi
  fi
done < <(find "$ROOT" -type f -name '*.p.json' -print0)

rm -f "$dlg_tmp" "$comp_tmp"

if [[ $FORMAT == "md" && "$SUMMARY_ONLY" == false ]]; then
  echo
  echo "---"
  echo "Scan complete."
elif [[ "$SUMMARY_ONLY" == false ]]; then
  echo "\nScan complete."
fi

# write summary file and optionally print only the summary
OUTDIR=.github/skills/form-components-listing/output
mkdir -p "$OUTDIR"
summary_file="$OUTDIR/ivy-summary.md"
if [[ -s "$summary_tmp" ]]; then
  printf "# Form Components Summary\n\n" > "$summary_file"
  cat "$summary_tmp" >> "$summary_file"
  if [[ "$SUMMARY_ONLY" == true ]]; then
    cat "$summary_file"
  fi
fi
rm -f "$summary_tmp"
