#!/usr/bin/env python3
import sys, os, shutil
from xml.etree import ElementTree as ET

SETTINGS = {
    # Keep: public record Foo(...) {}
    "org.eclipse.jdt.core.formatter.keep_record_declaration_on_one_line": "one_line_if_empty",
    # ensure brace on same line
    "org.eclipse.jdt.core.formatter.brace_position_for_record_declaration": "end_of_line",
}

def ensure_setting(profile_elem, setting_id, value):
    for s in profile_elem.findall("./setting"):
        if s.get("id") == setting_id:
            s.set("value", value)
            return
    ET.SubElement(profile_elem, "setting", {"id": setting_id, "value": value})

def main():
    if len(sys.argv) != 2:
        print("Usage: python3 patch_record_one_line.py /path/to/eclipse-formatter.xml")
        sys.exit(1)
    path = os.path.abspath(sys.argv[1])
    if not os.path.isfile(path):
        print(f"File not found: {path}")
        sys.exit(1)

    backup = path + ".bak"
    shutil.copy2(path, backup)
    print(f"Backup created: {backup}")

    tree = ET.parse(path)
    root = tree.getroot()
    profiles = root.findall(".//profile")
    if not profiles:
        print("No <profile> elements found.")
        sys.exit(1)

    touched = 0
    for prof in profiles:
        if prof.get("kind") == "CodeFormatterProfile":
            for k, v in SETTINGS.items():
                ensure_setting(prof, k, v)
            touched += 1

    tree.write(path, encoding="utf-8", xml_declaration=True)
    print(f"Updated {touched} profile(s) in: {path}")

if __name__ == "__main__":
    main()
