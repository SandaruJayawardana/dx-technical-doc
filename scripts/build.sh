#!/usr/bin/env bash

set -euo pipefail

CONFIG_FILE="documents.yaml"
COMMON_METADATA="templates/metadata.yaml"

if ! command -v yq >/dev/null 2>&1; then
    echo "Error: yq is required."
    echo "macOS: brew install yq"
    exit 1
fi

if ! command -v pandoc >/dev/null 2>&1; then
    echo "Error: pandoc is required."
    exit 1
fi

build_document() {
    local product="$1"
    local document_type="$2"

    local base_path=".products.\"${product}\".documents.\"${document_type}\""

    local source
    local title
    local version
    local status
    local effective_date
    local owner
    local output_name

    source=$(yq -r "${base_path}.source" "$CONFIG_FILE")
    title=$(yq -r "${base_path}.title" "$CONFIG_FILE")
    version=$(yq -r "${base_path}.version" "$CONFIG_FILE")
    status=$(yq -r "${base_path}.status" "$CONFIG_FILE")
    effective_date=$(yq -r "${base_path}.effective_date" "$CONFIG_FILE")
    owner=$(yq -r "${base_path}.owner" "$CONFIG_FILE")
    output_name=$(yq -r "${base_path}.output_name" "$CONFIG_FILE")

    if [[ ! -f "$source" ]]; then
        echo "Error: source file not found: $source"
        return 1
    fi

    local version_dir="dist/${product}/v${version}"
    local versioned_output="${version_dir}/${output_name}-v${version}.pdf"
    local latest_output="dist/${product}/${output_name}-latest.pdf"

    mkdir -p "$version_dir"

    echo "Building ${product}/${document_type} version ${version}..."

    pandoc "$source" \
        --metadata-file="$COMMON_METADATA" \
        --metadata="title:${title}" \
        --metadata="subtitle:Version ${version} — ${status}" \
        --metadata="version:${version}" \
        --metadata="status:${status}" \
        --metadata="effective-date:${effective_date}" \
        --metadata="author:${owner}" \
        --pdf-engine=xelatex \
        --output="$versioned_output"

    cp "$versioned_output" "$latest_output"

    echo "Created:"
    echo "  $versioned_output"
    echo "  $latest_output"
}

build_all() {
    while IFS= read -r product; do
        while IFS= read -r document_type; do
            build_document "$product" "$document_type"
        done < <(
            yq -r ".products.\"${product}\".documents | keys | .[]" \
                "$CONFIG_FILE"
        )
    done < <(
        yq -r '.products | keys | .[]' "$CONFIG_FILE"
    )
}

case "${1:-all}" in
    all)
        build_all
        ;;
    document)
        if [[ $# -ne 3 ]]; then
            echo "Usage: $0 document <product> <document-type>"
            exit 1
        fi

        build_document "$2" "$3"
        ;;
    *)
        echo "Usage:"
        echo "  $0 all"
        echo "  $0 document dx-crm api"
        echo "  $0 document dx-travelz usermanual"
        exit 1
        ;;
esac