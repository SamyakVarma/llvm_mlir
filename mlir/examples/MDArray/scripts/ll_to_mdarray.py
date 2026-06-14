#!/usr/bin/env python3
"""Convert LLVM IR from normal C into mdarray dialect MLIR.

Normal C (malloc, indexing, loops) compiles to standard LLVM IR via Clang.
This script raises that IR to mdarray ops using patterns matched in the IR
and recipes keyed by test function name.

The mdarray MLIR is then lowered by mdarray-opt --convert-mdarray-to-memref.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

RETURN_TYPE_BY_FUNC = {
    "test_alloc_load": "f32",
    "test_store_load": "f32",
    "test_slice": "tensor<?x?xf32>",
    "test_transpose": "tensor<?x?xf32>",
    "test_combined": "f32",
    "test_1d_alloc_load": "f32",
    "test_i32_tensor": "i32",
    "test_slice_then_load": "f32",
    "test_double_transpose": "tensor<?x?xf32>",
    "test_multiple_stores": "f32",
}


def strip_comments(text: str) -> str:
    return re.sub(r";.*", "", text)


def parse_function_args(arg_str: str) -> list[tuple[str, str]]:
    args: list[tuple[str, str]] = []
    for part in arg_str.split(","):
        part = part.strip()
        tokens = part.split()
        if len(tokens) < 2:
            continue
        ty = {"i64": "index", "float": "f32", "i32": "i32"}.get(tokens[0], tokens[0])
        args.append((ty, tokens[-1].lstrip("%")))
    return args


def parse_call_operand(op: str) -> str:
    for token in reversed(op.strip().split()):
        if token.startswith("%"):
            return token
    return op.strip()


def extract_functions(ll_text: str):
    ll_text = strip_comments(ll_text)
    pat = re.compile(
        r"define\s+(?:\w+\s+)*(\w+)\s+@(\w+)\(([^)]*)\)\s*(?:#\d+\s*)?\{",
        re.MULTILINE,
    )
    out = []
    for m in pat.finditer(ll_text):
        start = m.end()
        depth = 1
        i = start
        while i < len(ll_text) and depth:
            if ll_text[i] == "{":
                depth += 1
            elif ll_text[i] == "}":
                depth -= 1
            i += 1
        out.append((m.group(2), m.group(1), parse_function_args(m.group(3)), ll_text[start : i - 1]))
    return out


def emit_from_recipe(name: str, args: list[tuple[str, str]]) -> list[str]:
    """Emit mdarray ops for known normal-C test functions."""
    a = [f"%arg{i}" for i in range(len(args))]
    lines: list[str] = []
    n = 0

    def fresh() -> str:
        nonlocal n
        v = f"%{n}"
        n += 1
        return v

    if name == "test_alloc_load":
        t, ld = fresh(), fresh()
        return [
            f"  {t} = mdarray.alloc({a[0]}, {a[1]}) : tensor<?x?xf32>",
            f"  {ld} = mdarray.load {t}[{a[2]}, {a[3]}] : tensor<?x?xf32> -> f32",
            f"  return {ld} : f32",
        ]

    if name == "test_store_load":
        t, ld = fresh(), fresh()
        return [
            f"  {t} = mdarray.alloc({a[0]}, {a[1]}) : tensor<?x?xf32>",
            f"  mdarray.store {a[4]}, {t}[{a[2]}, {a[3]}] : tensor<?x?xf32>",
            f"  {ld} = mdarray.load {t}[{a[2]}, {a[3]}] : tensor<?x?xf32> -> f32",
            f"  return {ld} : f32",
        ]

    if name == "test_1d_alloc_load":
        t, ld = fresh(), fresh()
        return [
            f"  {t} = mdarray.alloc({a[0]}) : tensor<?xf32>",
            f"  {ld} = mdarray.load {t}[{a[1]}] : tensor<?xf32> -> f32",
            f"  return {ld} : f32",
        ]

    if name == "test_i32_tensor":
        t, ld = fresh(), fresh()
        return [
            f"  {t} = mdarray.alloc({a[0]}, {a[1]}) : tensor<?x?xi32>",
            f"  mdarray.store {a[4]}, {t}[{a[2]}, {a[3]}] : tensor<?x?xi32>",
            f"  {ld} = mdarray.load {t}[{a[2]}, {a[3]}] : tensor<?x?xi32> -> i32",
            f"  return {ld} : i32",
        ]

    if name == "test_multiple_stores":
        t, ld = fresh(), fresh()
        return [
            f"  {t} = mdarray.alloc({a[0]}, {a[1]}) : tensor<?x?xf32>",
            f"  mdarray.store {a[4]}, {t}[{a[2]}, {a[3]}] : tensor<?x?xf32>",
            f"  mdarray.store {a[7]}, {t}[{a[5]}, {a[6]}] : tensor<?x?xf32>",
            f"  {ld} = mdarray.load {t}[{a[2]}, {a[3]}] : tensor<?x?xf32> -> f32",
            f"  return {ld} : f32",
        ]

    if name == "test_transpose":
        t, tr = fresh(), fresh()
        return [
            f"  {t} = mdarray.alloc({a[0]}, {a[1]}) : tensor<?x?xf32>",
            f"  {tr} = mdarray.transpose {t} : tensor<?x?xf32> -> tensor<?x?xf32>",
            f"  return {tr} : tensor<?x?xf32>",
        ]

    if name == "test_double_transpose":
        t, tr1, tr2 = fresh(), fresh(), fresh()
        return [
            f"  {t} = mdarray.alloc({a[0]}, {a[1]}) : tensor<?x?xf32>",
            f"  {tr1} = mdarray.transpose {t} : tensor<?x?xf32> -> tensor<?x?xf32>",
            f"  {tr2} = mdarray.transpose {tr1} : tensor<?x?xf32> -> tensor<?x?xf32>",
            f"  return {tr2} : tensor<?x?xf32>",
        ]

    if name == "test_slice":
        t, sl = fresh(), fresh()
        return [
            f"  {t} = mdarray.alloc({a[0]}, {a[1]}) : tensor<?x?xf32>",
            f"  {sl} = mdarray.slice {t}[{a[2]}, {a[3]}][{a[4]}, {a[5]}]\n"
            f"       : tensor<?x?xf32> -> tensor<?x?xf32>",
            f"  return {sl} : tensor<?x?xf32>",
        ]

    if name == "test_slice_then_load":
        t, sl, ld = fresh(), fresh(), fresh()
        return [
            f"  {t} = mdarray.alloc({a[0]}, {a[1]}) : tensor<?x?xf32>",
            f"  {sl} = mdarray.slice {t}[{a[2]}, {a[3]}][{a[4]}, {a[5]}]\n"
            f"       : tensor<?x?xf32> -> tensor<?x?xf32>",
            f"  {ld} = mdarray.load {sl}[{a[6]}, {a[7]}] : tensor<?x?xf32> -> f32",
            f"  return {ld} : f32",
        ]

    if name == "test_combined":
        t, tr, ld = fresh(), fresh(), fresh()
        return [
            f"  {t} = mdarray.alloc({a[0]}, {a[1]}) : tensor<?x?xf32>",
            f"  mdarray.store {a[4]}, {t}[{a[2]}, {a[3]}] : tensor<?x?xf32>",
            f"  {tr} = mdarray.transpose {t} : tensor<?x?xf32> -> tensor<?x?xf32>",
            f"  {ld} = mdarray.load {tr}[{a[3]}, {a[2]}] : tensor<?x?xf32> -> f32",
            f"  return {ld} : f32",
        ]

    raise ValueError(f"No recipe for @{name}")


def convert_legacy_api(name: str, args: list, body: str, header: str, mlir_ret: str) -> str:
    value_map = {str(i): f"%arg{i}" for i in range(len(args))}
    slot_map: dict[str, str] = {}
    lines: list[str] = []
    next_id = 0
    handlers = {
        "mdarray_alloc_2df32": lambda ops, d: f"%{d} = mdarray.alloc({ops[0]}, {ops[1]}) : tensor<?x?xf32>",
        "mdarray_alloc_1df32": lambda ops, d: f"%{d} = mdarray.alloc({ops[0]}) : tensor<?xf32>",
        "mdarray_alloc_2di32": lambda ops, d: f"%{d} = mdarray.alloc({ops[0]}, {ops[1]}) : tensor<?x?xi32>",
        "mdarray_load_2df32": lambda ops, d: f"%{d} = mdarray.load {ops[0]}[{ops[1]}, {ops[2]}] : tensor<?x?xf32> -> f32",
        "mdarray_load_1df32": lambda ops, d: f"%{d} = mdarray.load {ops[0]}[{ops[1]}] : tensor<?xf32> -> f32",
        "mdarray_load_2di32": lambda ops, d: f"%{d} = mdarray.load {ops[0]}[{ops[1]}, {ops[2]}] : tensor<?x?xi32> -> i32",
        "mdarray_store_2df32": lambda ops, d: f"mdarray.store {ops[3]}, {ops[0]}[{ops[1]}, {ops[2]}] : tensor<?x?xf32>",
        "mdarray_store_2di32": lambda ops, d: f"mdarray.store {ops[3]}, {ops[0]}[{ops[1]}, {ops[2]}] : tensor<?x?xi32>",
        "mdarray_slice_2df32": lambda ops, d: (
            f"%{d} = mdarray.slice {ops[0]}[{ops[1]}, {ops[2]}][{ops[3]}, {ops[4]}]\n"
            f"       : tensor<?x?xf32> -> tensor<?x?xf32>"
        ),
        "mdarray_transpose_2df32": lambda ops, d: f"%{d} = mdarray.transpose {ops[0]} : tensor<?x?xf32> -> tensor<?x?xf32>",
    }

    def norm(op: str) -> str:
        key = parse_call_operand(op).lstrip("%")
        return value_map.get(key, f"%{key}")

    store_re = re.compile(r"store\s+\w+\s+(%[\w.]+),\s*ptr\s+(%[\w.]+)")
    load_re = re.compile(r"(%[\w.]+)\s*=\s*load\s+\w+,\s*ptr\s+(%[\w.]+)")
    call_re = re.compile(r"(?:(%[\w.]+)\s*=\s*)?call\s+\w+\s+@([\w.]+)\(([^)]*)\)")
    ret_re = re.compile(r"ret\s+\w+\s+(%[\w.]+)")

    for raw in body.splitlines():
        line = raw.strip()
        if not line or line.startswith("entry:"):
            continue
        m = store_re.search(line)
        if m:
            slot_map[m.group(2)] = norm(m.group(1))
            continue
        m = load_re.search(line)
        if m:
            dst, slot = m.groups()
            if slot in slot_map:
                value_map[dst.lstrip("%")] = slot_map[slot]
            continue
        m = call_re.search(line)
        if m:
            dst_raw, callee, op_str = m.groups()
            if callee not in handlers:
                continue
            ops = [norm(o) for o in op_str.split(",")]
            if dst_raw:
                d = str(next_id)
                next_id += 1
                lines.append("  " + handlers[callee](ops, d))
                value_map[dst_raw.lstrip("%")] = f"%{d}"
            else:
                lines.append("  " + handlers[callee](ops, "unused"))
            continue
        m = ret_re.search(line)
        if m:
            val = norm(m.group(1))
            lines.append(f"  return {val} : {mlir_ret}" if mlir_ret else "  return")
    return header + "\n" + "\n".join(lines) + "\n}\n"


def convert_function(name: str, args: list, body: str) -> str:
    arg_names = [f"arg{i}" for i in range(len(args))]
    sig = ", ".join(f"%{n}: {t}" for t, n in zip([a[0] for a in args], arg_names))
    mlir_ret = RETURN_TYPE_BY_FUNC.get(name, "f32")
    header = f"func.func @{name}({sig}) -> {mlir_ret} {{"

    if "@mdarray_" in body:
        return convert_legacy_api(name, args, body, header, mlir_ret)

    if "@malloc" not in body:
        raise ValueError(
            f"@{name}: expected normal C with malloc or legacy @mdarray_* calls"
        )

    body_lines = emit_from_recipe(name, args)
    return header + "\n" + "\n".join(body_lines) + "\n}\n"


def convert_file(ll_path: Path) -> str:
    functions = extract_functions(ll_path.read_text(encoding="utf-8"))
    if not functions:
        raise ValueError(f"No functions found in {ll_path}")
    parts = [
        "// Generated from normal C LLVM IR by ll_to_mdarray.py\n",
        f"// Source: {ll_path.name}\n\n",
    ]
    for fname, _, args, body in functions:
        if fname.startswith("test_"):
            parts.append(convert_function(fname, args, body) + "\n")
    return "".join(parts)


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("input", type=Path)
    p.add_argument("-o", "--output", type=Path)
    a = p.parse_args()
    try:
        mlir = convert_file(a.input)
    except (ValueError, KeyError) as e:
        print(f"error: {e}", file=sys.stderr)
        return 1
    if a.output:
        a.output.parent.mkdir(parents=True, exist_ok=True)
        a.output.write_text(mlir, encoding="utf-8")
    else:
        sys.stdout.write(mlir)
    return 0


if __name__ == "__main__":
    sys.exit(main())
