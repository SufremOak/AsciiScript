#!/usr/bin/env bash

# shellcheck disable=SC2034
# shellcheck disable=SC2154
# shellcheck disable=SC2086
# shellcheck disable=SC2016
# shellcheck disable=SC1091
# shellcheck disable=SC1090
# shellcheck disable=SC2154
# shellcheck disable=SC2120
# shellcheck disable=SC2128

set -euo pipefail
set -x
set -e

source "./lexer.sh"
source "./parser.sh"
source "./generator.sh"
source "./modules.sh"

lang() {
    local input=$1
    local tokens=()
    local current_block=""
    local in_script=false
    local in_style=false
    local in_content=false
    local variables=()
    local components=()
    local imported_modules=()

    # Handle imports
    if [[ $input =~ @import:[[:space:]]*\"(.*?)\"([[:space:]]*as[[:space:]]*([a-zA-Z_][a-zA-Z0-9_]*))? ]]; then
        local module_path="${BASH_REMATCH[1]}"
        local module_alias="${BASH_REMATCH[3]:-${module_path%.*}}"
        imported_modules+=("$module_path:$module_alias")
        echo "Imported module: $module_path as $module_alias"
    fi

    # Parse the header and document type
    if [[ $input =~ ascii\(type=([a-zA-Z]+)(\((.*?)\))?\) ]]; then
        local ascii_type="${BASH_REMATCH[1]}"
        local doc_type="${BASH_REMATCH[3]}"
        echo "Document Type: $ascii_type${doc_type:+ ($doc_type)}"
    fi

    # Parse blocks
    while IFS= read -r line; do
        # Handle component definitions
        if [[ $line =~ ^@component[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)\((.*?)\): ]]; then
            local comp_name="${BASH_REMATCH[1]}"
            local comp_params="${BASH_REMATCH[2]}"
            echo "Component defined: $comp_name with params: $comp_params"
            continue
        fi

        case "$current_block" in
            "script")
                # Variable declarations
                if [[ $line =~ let[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*=[[:space:]]*(.*) ]]; then
                    local var_name="${BASH_REMATCH[1]}"
                    local var_value="${BASH_REMATCH[2]}"
                    variables+=("$var_name")
                    echo "Variable declared: $var_name = $var_value"
                # Function declarations with improved parsing
                elif [[ $line =~ \.function[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)\((.*?)\)[[:space:]]*\{ ]]; then
                    echo "Function defined: ${BASH_REMATCH[1]} with params: ${BASH_REMATCH[2]}"
                # Control flow
                elif [[ $line =~ ^[[:space:]]*(if|while|for)[[:space:]]*\((.*?)\)[[:space:]]*\{ ]]; then
                    echo "Control structure: ${BASH_REMATCH[1]} with condition: ${BASH_REMATCH[2]}"
                # Error handling
                elif [[ $line =~ ^[[:space:]]*(try|catch)[[:space:]]*\{? ]]; then
                    echo "Error handling block: ${BASH_REMATCH[1]}"
                fi
                ;;
            "style")
                # Enhanced style parsing
                if [[ $line =~ ([a-zA-Z][a-zA-Z0-9]*|\.[-a-zA-Z0-9_]+)[[:space:]]*\{? ]]; then
                    echo "Style selector: ${BASH_REMATCH[1]}"
                elif [[ $line =~ ([a-zA-Z-]+)\((.*?)\) ]]; then
                    echo "Style property: ${BASH_REMATCH[1]} with value: ${BASH_REMATCH[2]}"
                fi
                ;;
            "content")
                # Enhanced content parsing
                if [[ $line =~ @([A-Z][a-zA-Z]*)\(([0-9])\):[[:space:]]*\"(.*)\" ]]; then
                    echo "${BASH_REMATCH[1]} level ${BASH_REMATCH[2]}: ${BASH_REMATCH[3]}"
                elif [[ $line =~ @(list|table|code)\(([^)]*)\): ]]; then
                    echo "Content block: ${BASH_REMATCH[1]} with options: ${BASH_REMATCH[2]}"
                elif [[ $line =~ @([a-zA-Z_][a-zA-Z0-9_]*)\((.*?)\):[[:space:]]*\"(.*)\" ]]; then
                    echo "Component usage: ${BASH_REMATCH[1]} with args: ${BASH_REMATCH[2]}"
                fi
                ;;
        esac

        # Block transitions
        if [[ $line =~ ^@(script|style|content): ]]; then
            current_block="${BASH_REMATCH[1]}"
            echo "Entering $current_block block"
        fi
    done <<< "$input"
}

process_file() {
    local input_file=$1
    local content=$(cat "$input_file")
    
    # Process imports first
    while IFS= read -r line; do
        if [[ $line =~ @import:[[:space:]]*\"([^\"]+)\"([[:space:]]*as[[:space:]]*([a-zA-Z_][a-zA-Z0-9_]*))? ]]; then
            local module_path="${BASH_REMATCH[1]}"
            local module_alias="${BASH_REMATCH[3]:-${module_path%.*}}"
            import_module "$module_path" "$module_alias"
        fi
    done <<< "$content"
    
    # Tokenize input
    local tokens=($(tokenize "$content"))
    
    # Parse and generate output
    local html_output=""
    local js_output=""
    local css_output=""
    
    while [ ${#tokens[@]} -gt 0 ]; do
        parse_block "${tokens[@]}"
        case "${ast_node[block_type]}" in
            "content")
                html_output+=$(generate_html "${ast_node[content]}")
                ;;
            "script")
                js_output+=$(generate_javascript "${ast_node[content]}")
                ;;
            "style")
                css_output+=$(generate_css "${ast_node[content]}")
                ;;
        esac
        # Remove processed tokens
        local block_size=$(echo "${ast_node[content]}" | wc -w)
        tokens=("${tokens[@]:$block_size}")
    done
    
    # Output generation
    local output_dir="${input_file%.*}"
    mkdir -p "$output_dir"
    
    if [ -n "$html_output" ]; then
        echo "$html_output" > "$output_dir/index.html"
    fi
    if [ -n "$js_output" ]; then
        echo "$js_output" > "$output_dir/script.js"
    fi
    if [ -n "$css_output" ]; then
        echo "$css_output" > "$output_dir/style.css"
    fi
}

# Main execution
if [ $# -eq 0 ]; then
    echo "Usage: $0 <input_file.ascii>"
    exit 1
fi

process_file "$1"