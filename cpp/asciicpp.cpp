#include "asciicpp.hpp"

void script::parseFunctionDefinition() {
    std::string funcName;
    std::vector<std::string> params;
    std::string body;
    
    // Get function name
    if (!tokenStack.empty()) {
        funcName = tokenStack.back();
        tokenStack.pop_back();
    }
    
    // Parse parameters
    if (!tokenStack.empty() && tokenStack.back() == "(") {
        tokenStack.pop_back(); // Remove "("
        while (!tokenStack.empty() && tokenStack.back() != ")") {
            params.push_back(tokenStack.back());
            tokenStack.pop_back();
            if (!tokenStack.empty() && tokenStack.back() == ",") {
                tokenStack.pop_back();
            }
        }
        if (!tokenStack.empty()) tokenStack.pop_back(); // Remove ")"
    }
    
    // Parse body
    if (!tokenStack.empty() && tokenStack.back() == "{") {
        tokenStack.pop_back(); // Remove "{"
        int braceCount = 1;
        while (!tokenStack.empty() && braceCount > 0) {
            std::string token = tokenStack.back();
            tokenStack.pop_back();
            if (token == "{") braceCount++;
            if (token == "}") braceCount--;
            if (braceCount > 0) body += token + " ";
        }
    }
    
    // Register function in the interpreter
    macroHandlers[funcName] = [this, params, body](const std::string& args) {
        // Create new scope for variables
        std::map<std::string, std::string> localVars;
        
        // Parse arguments and bind to parameters
        std::vector<std::string> argList = splitArgs(args);
        for (size_t i = 0; i < params.size() && i < argList.size(); ++i) {
            localVars[params[i]] = argList[i];
        }
        
        // Execute function body with local scope
        executeWithScope(body, localVars);
    };
}

void script::parseVariableDeclaration() {
    if (tokenStack.size() < 4) return; // Need at least: name = value
    
    std::string varName = tokenStack.back();
    tokenStack.pop_back();
    
    if (tokenStack.back() != "=") return;
    tokenStack.pop_back();
    
    std::string value = evaluateExpression();
    variables[varName] = value;
}

void script::parseControlFlow(const std::string& type) {
    std::string condition;
    std::string body;
    
    // Parse condition
    if (!tokenStack.empty() && tokenStack.back() == "(") {
        tokenStack.pop_back(); // Remove "("
        int parenCount = 1;
        while (!tokenStack.empty() && parenCount > 0) {
            std::string token = tokenStack.back();
            tokenStack.pop_back();
            if (token == "(") parenCount++;
            if (token == ")") parenCount--;
            if (parenCount > 0) condition += token + " ";
        }
    }
    
    // Parse body
    if (!tokenStack.empty() && tokenStack.back() == "{") {
        tokenStack.pop_back(); // Remove "{"
        int braceCount = 1;
        while (!tokenStack.empty() && braceCount > 0) {
            std::string token = tokenStack.back();
            tokenStack.pop_back();
            if (token == "{") braceCount++;
            if (token == "}") braceCount--;
            if (braceCount > 0) body += token + " ";
        }
    }
    
    // Execute control flow
    if (type == "if") {
        if (evaluateCondition(condition)) {
            macroInterpret(body);
        }
    } else if (type == "while") {
        while (evaluateCondition(condition)) {
            macroInterpret(body);
        }
    } else if (type == "for") {
        // Parse for loop components: for (init; condition; increment)
        std::vector<std::string> forParts = splitForLoop(condition);
        if (forParts.size() == 3) {
            macroInterpret(forParts[0]); // initialization
            while (evaluateCondition(forParts[1])) {
                macroInterpret(body);
                macroInterpret(forParts[2]); // increment
            }
        }
    }
}

std::string script::evaluateExpression() {
    // Simple expression evaluator
    if (tokenStack.empty()) return "";
    
    std::string result = tokenStack.back();
    tokenStack.pop_back();
    
    // Handle variable references
    if (variables.find(result) != variables.end()) {
        result = variables[result];
    }
    
    return result;
}

bool script::evaluateCondition(const std::string& condition) {
    // Simple condition evaluator
    std::regex compareOps("==|!=|<|>|<=|>=");
    std::vector<std::string> parts = split(condition, compareOps);
    
    if (parts.size() == 2) {
        std::string left = evaluateExpression(parts[0]);
        std::string right = evaluateExpression(parts[1]);
        std::string op = findOperator(condition, compareOps);
        
        return compareValues(left, right, op);
    }
    
    return !condition.empty() && condition != "0" && condition != "false";
}