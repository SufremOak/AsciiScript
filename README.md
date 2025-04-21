# AsciiScript

A modern, portable, and declarative scripting language designed for creating interactive documents and web content.

## Features

- **Declarative Syntax**: Clean and intuitive syntax for content creation
- **Component-Based**: Reusable components for efficient development
- **Style Integration**: Built-in styling system similar to CSS
- **Modular System**: Import and use modules to extend functionality
- **Error Handling**: Robust error handling with try-catch blocks
- **Cross-Platform**: C++ based interpreter for maximum portability

## Installation

### Prerequisites
- C++ compiler with C++17 support
- CMake 3.10 or higher

### Building from Source
```bash
git clone https://github.com/sufremoak/AsciiScript.git
cd AsciiScript/cpp
mkdir build && cd build
cmake ..
make
```

## Quick Start

### Hello World Example
```python
ascii(type=script)

@script:
    .function main() {
        ascii.console(log => "Hello from AsciiScript!")
        return self
    }
```

### Creating a Document
```python
ascii(type=document(article))

@style: {
    body {
        font.family("Arial"),
        margin(2em)
    }
}

@content:
    @Heading(1): "My First Document"
    @paragraph:
        """
        This is a simple AsciiScript document.
        """
    &end(paragraph)
```

## Language Features

### Variables and Data Types
- Numbers
- Strings
- Booleans
- Arrays
- Objects

### Control Flow
- If statements
- While loops
- For loops
- Try-catch blocks

### Functions
- Named functions
- Anonymous functions
- Arrow functions
- Function parameters

### Modules
- Import system
- Module aliases
- Built-in modules

### Components
- Custom components
- Component props
- Nested components

## Built-in Modules

- `dom`: DOM manipulation utilities
- `formatter`: String formatting tools
- `structures`: Data structure implementations
- `test`: Unit testing framework

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Credits

Created by Miguel Vicente (SufremOak)