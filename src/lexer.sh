#!/usr/bin/env bash

KEYWORDS=("ascii" "type" "script" "style" "content" "let" "function" "return" "if" "else" "while" "for" "try" "catch" "throw" "import" "as" "component")

tokenize() {
    local input=$1
    local tokens=()
    local position=0
    local line=1
    local column=1

    while [ $position -lt ${#input} ]; do
        local char="${input:$position:1}"
        
        case "$char" in
            [[:space:]])
                if [[ $char == $'\n' ]]; then
                    ((line++))
                    column=1
                else
                    ((column++))
                fi
                ((position++))
                ;;
            [a-zA-Z_])
                local identifier=""
                local start_col=$column
                while [[ $position -lt ${#input} && "${input:$position:1}" =~ [a-zA-Z0-9_] ]]; do
                    identifier+="${input:$position:1}"
                    ((position++))
                    ((column++))
                done
                if [[ " ${KEYWORDS[*]} " =~ " ${identifier} " ]]; then
                    echo "KEYWORD|$identifier|$line|$start_col"
                else
                    echo "IDENTIFIER|$identifier|$line|$start_col"
                fi
                ;;
            [0-9])
                local number=""
                local start_col=$column
                while [[ $position -lt ${#input} && "${input:$position:1}" =~ [0-9.] ]]; do
                    number+="${input:$position:1}"
                    ((position++))
                    ((column++))
                done
                echo "NUMBER|$number|$line|$start_col"
                ;;
            \"|\')
                local string=""
                local quote=$char
                local start_col=$column
                ((position++))
                ((column++))
                while [[ $position -lt ${#input} && "${input:$position:1}" != "$quote" ]]; do
                    string+="${input:$position:1}"
                    ((position++))
                    ((column++))
                done
                ((position++))
                ((column++))
                echo "STRING|$string|$line|$start_col"
                ;;
            [@&.(){}\[\],:]*)
                echo "SYMBOL|$char|$line|$column"
                ((position++))
                ((column++))
                ;;
        esac
    done
}