#!/bin/bash
set -euo pipefail

PROJECT_NAME="${1:?Usage: catalog-images.sh <project-name> [output-file]}"
OUTPUT_FILE="${2:-}"

# Resolve images directory: {project-name}/images or {project-name} if no images subdir
resolve_images_dir() {
    local name="$1"
    if [[ -d "${name}/images" ]]; then
        echo "${name}/images"
    elif [[ -d "${name}" ]]; then
        echo "${name}"
    else
        return 1
    fi
}

get_alt_text() {
    local name="${1%.*}"   # strip extension
    echo "$name" | tr '-_' '  ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} {print}'
}

get_file_size() {
    local bytes
    bytes=$(wc -c < "$1")
    if (( bytes >= 1048576 )); then
        awk "BEGIN { printf \"%.1f MB\", $bytes/1048576 }"
    elif (( bytes >= 1024 )); then
        echo "$(( bytes / 1024 )) KB"
    else
        echo "${bytes} B"
    fi
}

get_section_title() {
    local reldir="$1"
    if [[ -z "$reldir" || "$reldir" == "." ]]; then
        echo "General"
        return
    fi
    # Title-case each path component, join with " / "
    local title=""
    while IFS= read -r part; do
        [[ -z "$part" ]] && continue
        word=$(echo "$part" | tr '-_' '  ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} {printf $0}')
        title+="${title:+ / }${word}"
    done < <(echo "$reldir" | tr '/' '\n')
    echo "$title"
}

get_readme_placement() {
    local section="${1,,}"
    if [[ "$section" =~ demo ]];              then echo "## Demo"
    elif [[ "$section" =~ setup|install ]];   then echo "## Setup"
    elif [[ "$section" =~ component|feature ]]; then echo "## Components"
    else echo "## Screenshots"
    fi
}

##############################################################################

IMAGES_DIR=$(resolve_images_dir "$PROJECT_NAME") || {
    echo "Error: Could not find directory for: $PROJECT_NAME" >&2
    echo "Tried: ${PROJECT_NAME}/images, ${PROJECT_NAME}/" >&2
    exit 1
}

echo "Scanning: $IMAGES_DIR" >&2

# Collect all images, sorted
mapfile -t IMAGE_FILES < <(
    find "$IMAGES_DIR" -type f \( \
        -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o \
        -iname "*.gif" -o -iname "*.svg" -o -iname "*.webp" -o \
        -iname "*.tiff" -o -iname "*.tif" -o -iname "*.bmp" -o \
        -iname "*.ico" -o -iname "*.mp4" \
    \) | sort
)

TOTAL=${#IMAGE_FILES[@]}
if [[ $TOTAL -eq 0 ]]; then
    echo "No images found in: $IMAGES_DIR" >&2
    exit 0
fi

# Unique sub-directories relative to IMAGES_DIR
mapfile -t SUBDIRS < <(
    for f in "${IMAGE_FILES[@]}"; do
        rel="${f#${IMAGES_DIR}/}"
        dir=$(dirname "$rel")
        [[ "$dir" == "." ]] && dir=""
        echo "$dir"
    done | sort -u
)

output="# Image Summary: ${PROJECT_NAME}\n\n"
output+="Source: \`${IMAGES_DIR}\`  \n"
output+="Total: ${TOTAL} image(s)\n\n"
output+="---\n\n"

for subdir in "${SUBDIRS[@]}"; do
    section=$(get_section_title "$subdir")
    placement=$(get_readme_placement "$section")
    count=0
    entries=""

    for f in "${IMAGE_FILES[@]}"; do
        rel="${f#${IMAGES_DIR}/}"
        dir=$(dirname "$rel")
        [[ "$dir" == "." ]] && dir=""
        if [[ "$dir" == "$subdir" ]]; then
            (( count++ ))
            filename=$(basename "$f")
            alt=$(get_alt_text "$filename")
            size=$(get_file_size "$f")
            relpath="${f#./}"
            entries+="### ${alt}\n"
            entries+="- **File:** \`${relpath}\`\n"
            entries+="- **Size:** ${size}\n\n"
            entries+="\`\`\`markdown\n"
            entries+="![${alt}](${relpath})\n"
            entries+="\`\`\`\n\n"
            entries+="---\n\n"
        fi
    done

    output+="## ${section} (${count})\n\n"
    output+="> Suggested readme placement: \`${placement}\`\n\n"
    output+="${entries}"
done

if [[ -z "$OUTPUT_FILE" ]]; then
    echo -e "$output"
else
    echo -e "$output" > "$OUTPUT_FILE"
    echo "[+] Saved to: $OUTPUT_FILE" >&2
fi
