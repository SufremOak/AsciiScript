require('dotenv').config();
const readline = require('readline');
const axios = require('axios');
const fs = require('fs');
const path = require('path');

// File: /home/miguel/Desktop/AsciiScript/ai-transpile.js

const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
const GEMINI_API_URL = 'https://gemini.googleapis.com/v1/transpile';

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
});

async function transpileCode(language, sourceCode) {
    try {
        const response = await axios.post(
            GEMINI_API_URL,
            {
                targetLanguage: language,
                sourceCode: sourceCode,
            },
            {
                headers: {
                    'Authorization': `Bearer ${GEMINI_API_KEY}`,
                    'Content-Type': 'application/json',
                },
            }
        );

        return response.data.transpiledCode;
    } catch (error) {
        console.error('Error transpiling code:', error.response?.data || error.message);
        return null;
    }
}

function readFiles(filePaths) {
    try {
        return filePaths.map((filePath) => {
            const absolutePath = path.resolve(filePath);
            return fs.readFileSync(absolutePath, 'utf-8');
        }).join('\n');
    } catch (error) {
        console.error('Error reading files:', error.message);
        return null;
    }
}

function promptUser() {
    rl.question('Enter the target language: ', (language) => {
        rl.question('Enter file paths (comma-separated) or type "manual" for manual input:\n', (input) => {
            if (input.toLowerCase() === 'manual') {
                rl.question('Enter the source code (end with a blank line):\n', function getSourceCode(input, sourceCode = '') {
                    if (input.trim() === '') {
                        transpileCode(language, sourceCode).then((transpiledCode) => {
                            if (transpiledCode) {
                                console.log('\nTranspiled Code:\n');
                                console.log(transpiledCode);
                            }
                            rl.close();
                        });
                    } else {
                        rl.question('', (nextInput) => getSourceCode(nextInput, sourceCode + input + '\n'));
                    }
                });
            } else {
                const filePaths = input.split(',').map((filePath) => filePath.trim());
                const sourceCode = readFiles(filePaths);
                if (sourceCode) {
                    transpileCode(language, sourceCode).then((transpiledCode) => {
                        if (transpiledCode) {
                            console.log('\nTranspiled Code:\n');
                            console.log(transpiledCode);
                        }
                        rl.close();
                    });
                } else {
                    rl.close();
                }
            }
        });
    });
}

promptUser();
