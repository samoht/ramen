import sys
import re

def find_tailwind_classes_in_files(files):
    tailwind_pattern = re.compile(r"""
        string_attr
        \s+
        "class"
        .*?
        "
        ([^"]*?
        (bg-|text-|p[xy]*-|m[xy]*-|flex|grid|border|rounded|shadow|hover:|focus:|w-|h-|gap-|space-|opacity-)
        [^" ]*?)
        "
    """, re.MULTILINE | re.DOTALL | re.VERBOSE)

    for file_path in files:
        try:
            with open(file_path, 'r') as f:
                content = f.read()
                for match in tailwind_pattern.finditer(content):
                    line_number = content.count('\n', 0, match.start()) + 1
                    print(f"{file_path}:{line_number}:{match.group(1)}")
        except FileNotFoundError:
            print(f"Error: File not found {file_path}", file=sys.stderr)
        except Exception as e:
            print(f"Error processing file {file_path}: {e}", file=sys.stderr)

if __name__ == "__main__":
    if len(sys.argv) > 1:
        find_tailwind_classes_in_files(sys.argv[1:])
