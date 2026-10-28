#!/usr/bin/env python3
"""Deterministic Doxygen stub generator/updater for C/C++, backed by libclang.

Reads source text on stdin, writes updated source text on stdout.
No text/AI inference is involved: comment bodies are always blank stubs.

Behavior:
  - Function/method has no immediately-preceding doc comment -> insert a full
    stub block (@brief / @tparam / @param / @return, all blank).
  - Function/method already has a doc comment -> only ever append missing
    @tparam / @param / @return lines just before the closing '*/'. Existing
    lines (even ones documenting a since-removed parameter) are never
    touched, reworded, or deleted.

Scope: free functions, class methods, constructors, destructors. Classes
themselves are not documented.
"""
import os
import re
import shlex
import sys

import clang.cindex

FUNC_KINDS = {
    clang.cindex.CursorKind.FUNCTION_DECL,
    clang.cindex.CursorKind.CXX_METHOD,
    clang.cindex.CursorKind.CONSTRUCTOR,
    clang.cindex.CursorKind.DESTRUCTOR,
    clang.cindex.CursorKind.FUNCTION_TEMPLATE,
}
TPARAM_KINDS = {
    clang.cindex.CursorKind.TEMPLATE_TYPE_PARAMETER,
    clang.cindex.CursorKind.TEMPLATE_NON_TYPE_PARAMETER,
    clang.cindex.CursorKind.TEMPLATE_TEMPLATE_PARAMETER,
}

PARAM_RE = re.compile(r'^\s*\*?\s*[@\\]param\b(?:\[[^\]]*\])?\s+(\w+)')
TPARAM_RE = re.compile(r'^\s*\*?\s*[@\\]tparam\b\s+(\w+)')
RETURN_RE = re.compile(r'^\s*\*?\s*[@\\]return\b')


def find_up(start_dir, filename):
    d = os.path.abspath(start_dir)
    while True:
        candidate = os.path.join(d, filename)
        if os.path.exists(candidate):
            return candidate
        parent = os.path.dirname(d)
        if parent == d:
            return None
        d = parent


def clang_args(filepath):
    directory = os.path.dirname(os.path.abspath(filepath))
    ext = os.path.splitext(filepath)[1].lower()

    cc_json = find_up(directory, "compile_commands.json")
    if cc_json:
        try:
            db = clang.cindex.CompilationDatabase.fromDirectory(os.path.dirname(cc_json))
            cmds = db.getCompileCommands(filepath)
            if cmds:
                args = list(cmds[0].arguments)[1:]
                return [a for a in args if a != filepath]
        except clang.cindex.CompilationDatabaseError:
            pass

    flags_file = find_up(directory, "compile_flags.txt")
    if flags_file:
        with open(flags_file) as f:
            return shlex.split(f.read())

    if ext == ".c":
        return ["-std=c11", "-x", "c"]
    return ["-std=c++17", "-x", "c++"]


def indent_of(line):
    return line[: len(line) - len(line.lstrip())]


def find_comment_block(lines, decl_idx):
    """Look for a /** ... */ block immediately above lines[decl_idx]
    (blank lines in between are skipped). Returns (start_idx, end_idx)
    0-indexed inclusive, or None."""
    i = decl_idx - 1
    while i >= 0 and lines[i].strip() == "":
        i -= 1
    if i < 0 or "*/" not in lines[i]:
        return None
    end_idx = i
    while i >= 0 and "/**" not in lines[i]:
        i -= 1
    if i < 0:
        return None
    return i, end_idx


def process(text, filepath, target_line=None):
    """target_line: 1-indexed cursor line. If given, only the enclosing
    function/method (innermost by extent) is processed; otherwise every
    function/method in the file is."""
    lines = text.split("\n")
    index = clang.cindex.Index.create()
    tu = index.parse(filepath, args=clang_args(filepath), unsaved_files=[(filepath, text)])

    main_file = os.path.abspath(filepath)
    edits = []  # (insert_before_0idx, [new_lines]); applied bottom-up

    def in_main_file(cursor):
        f = cursor.location.file
        return f is not None and os.path.abspath(str(f)) == main_file

    def handle(c):
        decl_idx = c.extent.start.line - 1
        if decl_idx < 0 or decl_idx >= len(lines):
            return

        params = [p.spelling for p in c.get_arguments() if p.spelling]
        tparams = [t.spelling for t in c.get_children() if t.kind in TPARAM_KINDS and t.spelling]
        is_ctor_dtor = c.kind in (clang.cindex.CursorKind.CONSTRUCTOR, clang.cindex.CursorKind.DESTRUCTOR)
        has_return = not is_ctor_dtor and c.result_type.spelling != "void"

        indent = indent_of(lines[decl_idx])
        block = find_comment_block(lines, decl_idx)

        if block is None:
            new_block = [f"{indent}/**", f"{indent} * @brief", f"{indent} *"]
            for t in tparams:
                new_block.append(f"{indent} * @tparam {t}")
            for p in params:
                new_block.append(f"{indent} * @param {p}")
            if has_return:
                new_block.append(f"{indent} * @return")
            new_block.append(f"{indent} */")
            edits.append((decl_idx, new_block))
            return

        start_idx, end_idx = block
        block_lines = lines[start_idx : end_idx + 1]
        documented_params = set()
        documented_tparams = set()
        has_doc_return = False
        for l in block_lines:
            m = PARAM_RE.match(l)
            if m:
                documented_params.add(m.group(1))
            m = TPARAM_RE.match(l)
            if m:
                documented_tparams.add(m.group(1))
            if RETURN_RE.match(l):
                has_doc_return = True

        new_lines = []
        for t in tparams:
            if t not in documented_tparams:
                new_lines.append(f"{indent} * @tparam {t}")
        for p in params:
            if p not in documented_params:
                new_lines.append(f"{indent} * @param {p}")
        if has_return and not has_doc_return:
            new_lines.append(f"{indent} * @return")

        if new_lines:
            edits.append((end_idx, new_lines))

    candidates = []

    def walk(cursor):
        for c in cursor.get_children():
            if in_main_file(c) and c.kind in FUNC_KINDS:
                candidates.append(c)
            walk(c)

    walk(tu.cursor)

    if target_line is not None:
        enclosing = [
            c for c in candidates if c.extent.start.line <= target_line <= c.extent.end.line
        ]
        if not enclosing:
            return text
        target = min(enclosing, key=lambda c: c.extent.end.line - c.extent.start.line)
        candidates = [target]

    for c in candidates:
        handle(c)

    for insert_idx, block in sorted(edits, key=lambda e: e[0], reverse=True):
        lines[insert_idx:insert_idx] = block

    return "\n".join(lines)


def main():
    if len(sys.argv) < 2:
        print("usage: doxydoc.py <filepath> [cursor_line]", file=sys.stderr)
        sys.exit(1)

    filepath = sys.argv[1]
    target_line = int(sys.argv[2]) if len(sys.argv) > 2 else None
    text = sys.stdin.read()
    out = process(text, filepath, target_line)
    sys.stdout.write(out)


if __name__ == "__main__":
    main()
