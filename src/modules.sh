#!/usr/bin/env bash

declare -A module_cache
declare -A module_exports

import_module() {
    local module_path=$1
    local module_alias=$2

    if [[ -n "${module_cache[$module_path]}" ]]; then
        return
    fi

    if [[ ! -f $module_path ]]; then
        parse_error "Module not found: $module_path" 0 0
    fi

    local module_content=$(cat "$module_path")
    module_cache[$module_path]=$module_content

    local tokens=($(tokenize "$module_content"))
    parse_block "${tokens[@]}"
    
    if [[ ${ast_node["block_type"]} == "script" ]]; then
        module_exports[$module_alias]=${ast_node["content"]}
    fi
}

get_export() {
    local module_alias=$1
    local export_name=$2
    
    if [[ -n "${module_exports[$module_alias]}" ]]; then
        local exports="${module_exports[$module_alias]}"
        local function_pattern="function[[:space:]]+$export_name"
        if [[ $exports =~ $function_pattern ]]; then
            echo "${BASH_REMATCH[0]}"
        fi
    fi
}