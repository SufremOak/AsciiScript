#!/usr/bin/env bash

source "./lexer.sh"

declare -A ast_node

parse_error() {
    local message=$1
    local line=$2
    local column=$3
    echo "Error at line $line, column $column: $message" >&2
    exit 1
}

parse_block() {
    local tokens=("$@")
    local block_type=""
    local block_content=()
    
    for token in "${tokens[@]}"; do
        IFS='|' read -r type value line column <<< "$token"
        
        case "$type" in
            "SYMBOL")
                if [[ $value == "@" ]]; then
                    local next_token="${tokens[1]}"
                    IFS='|' read -r next_type next_value _ _ <<< "$next_token"
                    if [[ $next_type == "IDENTIFIER" ]]; then
                        block_type=$next_value
                    fi
                elif [[ $value == "{" ]]; then
                    local depth=1
                    while [[ $depth -gt 0 && ${#tokens[@]} -gt 0 ]]; do
                        local current="${tokens[0]}"
                        IFS='|' read -r curr_type curr_value _ _ <<< "$current"
                        if [[ $curr_value == "{" ]]; then
                            ((depth++))
                        elif [[ $curr_value == "}" ]]; then
                            ((depth--))
                        fi
                        block_content+=("$current")
                        tokens=("${tokens[@]:1}")
                    done
                fi
                ;;
            *)
                block_content+=("$token")
                ;;
        esac
    done
    
    ast_node["type"]="block"
    ast_node["block_type"]=$block_type
    ast_node["content"]="${block_content[*]}"
}

parse_expression() {
    local tokens=("$@")
    local expr_tokens=()
    
    while [[ ${#tokens[@]} -gt 0 ]]; do
        local token="${tokens[0]}"
        IFS='|' read -r type value line column <<< "$token"
        
        case "$type" in
            "NUMBER"|"STRING"|"IDENTIFIER")
                expr_tokens+=("$token")
                ;;
            "SYMBOL")
                if [[ $value =~ ^[\+\-\*\/\(\)]$ ]]; then
                    expr_tokens+=("$token")
                else
                    break
                fi
                ;;
            *)
                break
                ;;
        esac
        tokens=("${tokens[@]:1}")
    done
    
    echo "${expr_tokens[*]}"
}

parse_statement() {
    local tokens=("$@")
    local stmt_type=""
    local stmt_content=()
    
    local first_token="${tokens[0]}"
    IFS='|' read -r type value line column <<< "$first_token"
    
    case "$value" in
        "let")
            stmt_type="variable_declaration"
            local var_name="${tokens[1]}"
            local var_value=$(parse_expression "${tokens[@]:3}")
            stmt_content=("$var_name" "$var_value")
            ;;
        "if"|"while"|"for")
            stmt_type="control_flow"
            local condition=$(parse_expression "${tokens[@]:2}")
            stmt_content=("$value" "$condition")
            ;;
        "function")
            stmt_type="function_declaration"
            local func_name="${tokens[1]}"
            stmt_content=("$func_name")
            ;;
        *)
            if [[ $type == "IDENTIFIER" ]]; then
                stmt_type="expression"
                stmt_content=($(parse_expression "${tokens[@]}"))
            fi
            ;;
    esac
    
    ast_node["type"]="statement"
    ast_node["statement_type"]=$stmt_type
    ast_node["content"]="${stmt_content[*]}"
}