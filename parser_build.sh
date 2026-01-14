# Clone required parser.
# Python available at https://github.com/tree-sitter/tree-sitter-python.git
gcc -o parser.so -shared src/parser.c src/scanner.c -Os -I./src

# Parser shared library files (.so) files go in folder .local/share/nvim/site/parser/
