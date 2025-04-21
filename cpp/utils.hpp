#ifndef UTILS_HPP
#define UTILS_HPP

#include <string>
#include <vector>
#include <regex>

std::vector<std::string> split(const std::string& str, const std::regex& delim) {
    std::vector<std::string> tokens;
    std::sregex_token_iterator it(str.begin(), str.end(), delim, -1);
    std::sregex_token_iterator end;
    while (it != end) {
        tokens.push_back(*it++);
    }
    return tokens;
}

std::vector<std::string> splitArgs(const std::string& args) {
    std::vector<std::string> result;
    std::string current;
    bool inQuotes = false;
    
    for (char c : args) {
        if (c == '"') {
            inQuotes = !inQuotes;
        } else if (c == ',' && !inQuotes) {
            if (!current.empty()) {
                result.push_back(current);
                current.clear();
            }
        } else {
            current += c;
        }
    }
    
    if (!current.empty()) {
        result.push_back(current);
    }
    
    return result;
}

std::vector<std::string> splitForLoop(const std::string& condition) {
    std::vector<std::string> parts;
    std::string current;
    int depth = 0;
    
    for (char c : condition) {
        if (c == '(') depth++;
        else if (c == ')') depth--;
        else if (c == ';' && depth == 0) {
            parts.push_back(current);
            current.clear();
            continue;
        }
        current += c;
    }
    
    if (!current.empty()) {
        parts.push_back(current);
    }
    
    return parts;
}

std::string findOperator(const std::string& str, const std::regex& ops) {
    std::smatch match;
    if (std::regex_search(str, match, ops)) {
        return match.str();
    }
    return "";
}

bool compareValues(const std::string& left, const std::string& right, const std::string& op) {
    if (op == "==") return left == right;
    if (op == "!=") return left != right;
    if (op == "<") return left < right;
    if (op == ">") return left > right;
    if (op == "<=") return left <= right;
    if (op == ">=") return left >= right;
    return false;
}

#endif