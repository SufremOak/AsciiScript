#ifndef ASCIICPP_HPP
#define ASCIICPP_HPP

#include <iostream>
#include <string>
#include <vector>
#include <map>
#include <regex>
#include <functional>

using namespace std;

// Class to handle ASCII conversion

class script {
    private:
        std::map<std::string, std::function<void(const std::string&)>> macroHandlers;
        std::map<std::string, std::string> variables;
        std::vector<std::string> tokenStack;

        void registerDefaultMacros() {
            macroHandlers["@script"] = [this](const std::string& content) {
                parseScriptBlock(content);
            };
            macroHandlers["@style"] = [this](const std::string& content) {
                parseStyleBlock(content);
            };
            macroHandlers["@content"] = [this](const std::string& content) {
                parseContentBlock(content);
            };
        }

        void parseScriptBlock(const std::string& content);
        void parseStyleBlock(const std::string& content);
        void parseContentBlock(const std::string& content);
        
    public:
        // Constructor
        script() {
            registerDefaultMacros();
        }

        // Destructor
        ~script();
        
        void runScript(const std::string& scriptPath);
        void runScript(const std::string& scriptPath, const std::string& args);
        void runScript(const std::string& scriptPath, const std::string& args, const std::string& env);
        void runScript(const std::string& scriptPath, const std::string& args, const std::string& env, const std::string& input);
        void runScript(const std::string& scriptPath, const std::string& args, const std::string& env, const std::string& input, const std::string& output);
        void runScript(const std::string& scriptPath, const std::string& args, const std::string& env, const std::string& input, const std::string& output, const std::string& error);
        void runScript(const std::string& scriptPath, const std::string& args, const std::string& env, const std::string& input, const std::string& output, const std::string& error, const std::string& workingDir);
        void runScript(const std::string& scriptPath, const std::string& args, const std::string& env, const std::string& input, const std::string& output, const std::string& error, const std::string& workingDir, const std::string& interpreter);

        void parseScript(const std::string& script) {
            std::regex macroPattern("@([a-zA-Z]+):\\s*\\{([^}]+)\\}");
            std::smatch matches;
            std::string::const_iterator searchStart(script.cbegin());
            
            while (std::regex_search(searchStart, script.cend(), matches, macroPattern)) {
                std::string macroName = "@" + matches[1].str();
                std::string content = matches[2].str();
                
                if (macroHandlers.find(macroName) != macroHandlers.end()) {
                    macroHandlers[macroName](content);
                }
                
                searchStart = matches.suffix().first;
            }
        }

        void macroInterpret(const std::string& macro) {
            std::regex tokenPattern("([a-zA-Z_][a-zA-Z0-9_]*|[(){}\\[\\].,;\"']|\\s+)");
            std::sregex_iterator it(macro.begin(), macro.end(), tokenPattern);
            std::sregex_iterator end;

            while (it != end) {
                std::string token = it->str();
                if (!std::regex_match(token, std::regex("\\s+"))) {
                    tokenStack.push_back(token);
                }
                ++it;
            }

            interpretTokens();
        }

        void interpretTokens() {
            while (!tokenStack.empty()) {
                std::string token = tokenStack.back();
                tokenStack.pop_back();

                if (token == ".function") {
                    parseFunctionDefinition();
                } else if (token == "let") {
                    parseVariableDeclaration();
                } else if (token == "if" || token == "while" || token == "for") {
                    parseControlFlow(token);
                }
            }
        }

        void parseFunctionDefinition();
        void parseVariableDeclaration();
        void parseControlFlow(const std::string& type);
};

class AsciiCPP {
    public:
        // Constructor
        AsciiCPP();

        // Destructor
        ~AsciiCPP();

        // Function to convert a string to ASCII values
        std::vector<int> stringToAscii(const std::string& str);

        // Function to convert ASCII values back to a string
        std::string asciiToString(const std::vector<int>& asciiValues);
};

#endif