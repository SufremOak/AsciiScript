#!/usr/bin/env bash

source "./parser.sh"

declare -A style_map
declare -A component_registry

generate_html() {
    local ast=$1
    local output=""
    
    if [[ ${ast_node["type"]} == "block" ]]; then
        case ${ast_node["block_type"]} in
            "content")
                while IFS= read -r token; do
                    IFS='|' read -r type value _ _ <<< "$token"
                    case "$value" in
                        "@Heading")
                            local level="${tokens[1]}"
                            local text="${tokens[2]}"
                            output+="<h$level>$text</h$level>"
                            ;;
                        "@paragraph")
                            local text=""
                            while [[ $next_token != "&end(paragraph)" ]]; do
                                text+="$next_token "
                            done
                            output+="<p>$text</p>"
                            ;;
                        "@list")
                            local list_type="${tokens[1]}"
                            output+="<${list_type}>"
                            while [[ $next_token != "&end(list)" ]]; do
                                if [[ $next_token == "@item" ]]; then
                                    output+="<li>${tokens[1]}</li>"
                                fi
                            done
                            output+="</${list_type}>"
                            ;;
                    esac
                done <<< "${ast_node["content"]}"
                ;;
        esac
    fi
    echo "$output"
}

generate_javascript() {
    local ast=$1
    local output=""
    
    if [[ ${ast_node["type"]} == "block" ]]; then
        case ${ast_node["block_type"]} in
            "script")
                while IFS= read -r token; do
                    IFS='|' read -r type value _ _ <<< "$token"
                    case "$type" in
                        "KEYWORD")
                            case "$value" in
                                "function")
                                    output+="function ${tokens[1]} "
                                    ;;
                                "let")
                                    output+="let ${tokens[1]} = ${tokens[3]};"
                                    ;;
                                "if"|"while"|"for")
                                    output+="$value (${tokens[2]}) "
                                    ;;
                            esac
                            ;;
                        "SYMBOL")
                            output+="$value"
                            ;;
                    esac
                done <<< "${ast_node["content"]}"
                ;;
        esac
    fi
    echo "$output"
}

generate_css() {
    local ast=$1
    local output=""
    
    if [[ ${ast_node["type"]} == "block" && ${ast_node["block_type"]} == "style" ]]; then
        while IFS= read -r token; do
            IFS='|' read -r type value _ _ <<< "$token"
            if [[ $type == "IDENTIFIER" ]]; then
                output+="$value {"
            elif [[ $type == "SYMBOL" && $value == "." ]]; then
                output+="."
            elif [[ $value =~ ^[{}]$ ]]; then
                output+="$value"
            else
                output+="$value;"
            fi
        done <<< "${ast_node["content"]}"
    fi
    echo "$output"
}