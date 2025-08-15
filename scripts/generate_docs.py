import os
import re
from pathlib import Path

DOC_COMMENT = re.compile(r"(^--\s+)|(^---\s+)")
CLASS_ANNOTATION = re.compile(r"^---@class\s+(\w+)(.*)$")
METHOD_DEF = re.compile(r"^function\s+([\w_]+)[:.]([\w_]+)|([\w_]+)\s*=\s*function")
RETURN_ANNOTATION = re.compile(r"^---@return\s+(\w+)(.*)$")
IGNORE_TAG = "@ignore"
EXCLUSIONS = [
    "Accessor.lua",
    "Class.lua",
    "CommandExecutor.lua",
    "GUI.lua",
    "Logger.lua",
    "Time.lua",
    "ThreadManager.lua",
]


def format_annotation_block(annotations):
    summary = []
    params = []
    returns = []

    for line in annotations:
        line = line.lstrip("-").strip()
        if line.startswith("@param"):
            stripped = line.replace("@param ", "")
            params.append(stripped)
        elif line.startswith("@return"):
            m = RETURN_ANNOTATION.match("---" + line) 
            if m:
                returns.append((m.group(1), m.group(2).strip()))
        elif not line.startswith("---@") and not line.startswith("@") and not line.startswith("[["):
            summary.append(line)
    return summary, params, returns


def parse_lua_file(path):
    docs = []
    current_class = None
    class_desc = ""
    methods = []

    with open(path, "r", encoding="utf-8") as f:
        lines = f.readlines()

    annotations = []
    for _, line in enumerate(lines):
        class_match = CLASS_ANNOTATION.match(line)
        if class_match:
            if current_class:
                if methods:
                    docs.append((current_class, class_desc.strip(), methods))
                methods = []

            if any(IGNORE_TAG in ann for ann in annotations):
                current_class = None
                annotations = []
                continue

            current_class = class_match.group(1)

            desc_lines = []
            for ann in reversed(annotations):
                if DOC_COMMENT.match(ann):
                    text = ann.lstrip("-").strip()
                    if text:
                        desc_lines.insert(0, text)
                else:
                    break # outside annotation block??
            class_desc = "\n".join(desc_lines)
            annotations = []
            continue

        stripped = line.strip()
        if stripped.startswith("--"):
            annotations.append(line.rstrip())
            continue

        if current_class:
            m = METHOD_DEF.match(line.strip())
            if m:
                method_name = m.group(2) if m.group(1) and m.group(2) else m.group(3)
                doc_block = []
                for ann in reversed(annotations):
                    if ann.startswith("--") and not ann.startswith("---@field"):
                        doc_block.insert(0, ann)
                    else:
                        break
                if doc_block and not any(IGNORE_TAG in ann for ann in annotations):
                    methods.append((method_name, *format_annotation_block(doc_block)))

                annotations = []
                continue

    if current_class:
        docs.append((current_class, class_desc.strip(), methods))

    return docs


def generate_docs(docs, output_path):
    for class_name, class_desc, methods in docs:
        out_path = Path(output_path) / f"{class_name}.md"
        with open(out_path, "w", encoding="utf-8") as md:
            md.write(f"# {class_name}\n\n")
            if class_desc:
                md.write(f"**Description:**\n\n{class_desc}\n\n")
            if not methods:
                md.write("_No annotated methods found._\n")
                continue

            md.write("## Methods\n\n")

            for name, summary, params, returns in methods:
                md.write(f"### `{name}`\n\n")
                if summary:
                    md.write("\n".join(summary) + "\n\n")
                if params:
                    md.write("**Parameters:**\n")
                    for p in params:
                        param_name, param_desc = p.split(" ", 1)
                        md.write(f"- `{param_name}` {param_desc}\n")
                    md.write("\n\n")

                if returns:
                    md.write("**Returns:**\n")
                    for rtype, desc in returns:
                        md.write(f"- `{rtype}` {desc}\n")
                md.write("\n")


def scan_folder(folder):
    all_docs = []

    for root, _, files in os.walk(folder):
        for file in files:
            if file.endswith(".lua") and not file in EXCLUSIONS:
                parsed = parse_lua_file(Path(root) / file)
                all_docs.extend(parsed)
    return all_docs


def gen_docs_from_dir(dirname):
    src_dir = f"../SmallBase/includes/{dirname}"
    output_dir = f"../docs/{dirname}"
    os.makedirs(output_dir, exist_ok=True)

    docs = scan_folder(src_dir)
    generate_docs(docs, output_dir)
    print(f"Generated {len(docs)} class doc(s) from includes/{dirname} into docs/{dirname}")


if __name__ == "__main__":
    gen_docs_from_dir("modules")
    gen_docs_from_dir("services")
