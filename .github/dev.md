# Chapter 1
The Syntax

## The syntax for AsciiScript needs to be memorable but declarative.

Hello, world example: <br>

```python
# AsciiScript Syntax Prototype 1
ascii(type=script) # the "ascii" type can be: script, document(<doc-type>), doc-type can be: book, article, letter

@script:                # scripting block
    .function main() {  # main function
        ascii.console(log => "Hello from AsciiScript!") # use ascii.console to "log" the value inside '"' to the console
        return self;    # return the function itself
    }

# use '@script' again if there's renderable code after the script 
```

A article example: <br>

```python
ascii(type=document(article)) # set the ascii.type to document.article

@style: {  # styling
    body, h1, p {
        text.align(center),
        font.family("Sans sarif", "Arial"),
        background(hex$ '#ffff'),
        font.size(x-large)
    }
}

# renderable content
@div.type=container "Document"
    # metadata
    @title: "AI on the go"
    @author: "Johnny M."

    # page content
    @content:
        # title
        @Heading(1): "The Rabbit R1"
        @paragraph:
            """
            The Rabbit R1 is an pocket AI companion made by Rabbit, it uses an modified Android version to run its interface, most called as 'RabbitOS'
            """
          &end(paragraph)
    @content&
```

## Additional Features

### Variables and Data Types
```python
ascii(type=script)

@script:
    .function example() {
        let number = 42              # Number type
        let text = "Hello"          # String type
        let flag = true            # Boolean type
        let list = [1, 2, 3]      # Array type
        let obj = {               # Object type
            name: "John",
            age: 30
        }
    }
```

### Control Flow
```python
ascii(type=script)

@script:
    .function controlFlow() {
        # If statements
        if (condition) {
            ascii.console(log => "True condition")
        } else {
            ascii.console(log => "False condition")
        }

        # Loops
        for (item in items) {
            ascii.console(log => item)
        }

        while (condition) {
            ascii.console(log => "Loop iteration")
        }
    }
```

### Document Styling
```python
ascii(type=document(article))

@style: {
    # Multiple selectors
    h1, h2, h3 {
        text.color(hex$ '#333333'),
        margin.top(2em)
    }

    # Class selectors
    .highlight {
        background(hex$ '#ffeb3b'),
        padding(1em)
    }

    # Nested elements
    article {
        max.width(800px),
        margin(auto),
        
        p {
            line.height(1.6),
            margin.bottom(1.5em)
        }
    }
}
```

### Advanced Content Features
```python
ascii(type=document(book))

@content:
    # Lists
    @list(type=ordered):
        @item: "First item"
        @item: "Second item"
        @item: "Third item"
    &end(list)

    # Tables
    @table:
        @header: ["Name", "Age", "City"]
        @row: ["John", "30", "New York"]
        @row: ["Alice", "25", "London"]
    &end(table)

    # Links and References
    @link(href="https://example.com"): "Visit Example"
    @image(src="path/to/image.jpg", alt="Description"): "Caption"

    # Code blocks with syntax highlighting
    @code(lang=python):
        """
        def hello():
            print("Hello, World!")
        """
    &end(code)
```

### Error Handling
```python
ascii(type=script)

@script:
    .function divideNumbers(a, b) {
        try {
            if (b == 0) {
                throw Error("Division by zero")
            }
            return a / b
        } catch (error) {
            ascii.console(log => error.message)
            return null
        }
    }
```

### Modules and Imports
```python
ascii(type=script)

# Import module
@import: "math.ascii"
@import: "utils/formatter.ascii" as fmt

@script:
    .function calculateArea() {
        let radius = 5
        let area = math.PI * math.pow(radius, 2)
        let formatted = fmt.round(area, 2)
        ascii.console(log => formatted)
    }
```

### Custom Components
```python
ascii(type=document(article))

# Define a reusable component
@component Card(title, content):
    @div.class="card":
        @h2: title
        @p: content
    &end(div)

@content:
    # Using the component
    @Card(
        title="Welcome",
        content="This is a reusable card component"
    )
    
    @Card(
        title="Features",
        content="Components can be nested and reused"
    )
```


