#!/usr/bin/env python3
"""
This script finds all header files in the project and prints their paths.
It uses the compile_commands.json file to find the include paths.
Header paths are printed relative to their include paths.

Author:  Maddison Hellstrom
License: MIT
"""
import json
import os
import sys
import glob
import getopt

ROOT_PATTERNS = ['.git', '.svn', '.hg', '.cvs', 'compile_commands.json']
CANDIDATE_DIRS = ('', 'build', 'out', 'builds', 'builds/Debug',
                  'builds/Release')


def find_project_root(root_patterns):
    current_dir = os.path.abspath(os.getcwd())
    while True:
        for pattern in root_patterns:
            if glob.glob(os.path.join(current_dir, pattern)):
                return current_dir
        parent_dir = os.path.dirname(current_dir)
        if parent_dir == current_dir:
            raise FileNotFoundError(
                f"None of the root patterns {root_patterns} were found in any parent directory."
            )
        current_dir = parent_dir


def find_compile_commands(project_root, candidate_dirs):
    for candidate_dir in candidate_dirs:
        compile_commands_path = os.path.join(project_root, candidate_dir,
                                             'compile_commands.json')
        if os.path.exists(compile_commands_path):
            return compile_commands_path
    raise FileNotFoundError(
        f"compile_commands.json not found in any of the candidate directories: {candidate_dirs}"
    )


def find_header_files(include_paths):
    header_files = set()
    for include_path in include_paths:
        for ext in ('*.h', '*.hpp', '*.hxx', '*.hh'):
            for path in glob.glob(os.path.join(include_path, '**', ext),
                                  recursive=True):
                header_files.add(
                    (include_path, os.path.relpath(path, include_path)))

    return header_files


def extract_include_paths(compile_commands):
    include_paths = set()
    for command in compile_commands:
        cmd = command['command']
        for part in cmd.split():
            if part.startswith("-I"):
                include_path = part[2:]
                include_paths.add(os.path.abspath(include_path))
    return include_paths


def main():
    usage = f"""
Usage: findheaders.py [options] [directory]

{__doc__}

Options:
    -h, --help  Show this message and exit.

    -c, --compile-commands  Path to compile_commands.json. If not specified,
                the script will try to find the file by searching for
                patterns in the parent directories.

    -r, --root  Root directory of the project. If not specified, the script
                will try to find the root directory by searching for
                patterns in the parent directories.

    -R, --root-patterns  Glob-style patterns to search for the project root,
                separated by commas.
                Default: {ROOT_PATTERNS}

    -C, --candidate-dirs  Directories to search for compile_commands.json.
                Default: {CANDIDATE_DIRS}

    -f --fmt    Output format. Can be either 'json' or 'list'.
                Default: list

Arguments:
    directory  Starting directory. If not specified, the current working
               directory will be used.
    """

    try:
        opts, args = getopt.getopt(sys.argv[1:], "hc:r:R:C:f:", [
            "help", "compile-commands=", "root=", "root-patterns=",
            "candidate-dirs=", "fmt="
        ])
    except getopt.GetoptError:
        print(usage)
        sys.exit(2)

    compile_commands = None
    project_root = None
    root_patterns = ROOT_PATTERNS
    candidate_dirs = CANDIDATE_DIRS
    output_fmt = 'list'

    for opt, arg in opts:
        if opt in ("-h", "--help"):
            print(usage)
            sys.exit()
        elif opt in ("-c", "--compile-commands"):
            compile_commands = arg
        elif opt in ("-r", "--root"):
            project_root = arg
        elif opt in ("-R", "--root-patterns"):
            root_patterns = arg.split(',')
        elif opt in ("-C", "--candidate-dirs"):
            candidate_dirs = arg.split(',')
        elif opt in ("-f", "--fmt"):
            if arg not in ('json', 'list'):
                print(usage)
                sys.exit(2)
            output_fmt = arg

    if len(args) > 1:
        print(usage)
        sys.exit(2)
    elif len(args) == 1:
        os.chdir(args[0])

    if compile_commands is None:
        if project_root is None:
            project_root = find_project_root(root_patterns)
        compile_commands = find_compile_commands(project_root, candidate_dirs)

    with open(compile_commands, 'r', encoding='utf-8') as file:
        compile_commands = json.load(file)
    include_paths = extract_include_paths(compile_commands)
    header_files = find_header_files(include_paths)
    for include_dir, header_file in sorted(header_files):
        if output_fmt == 'json':
            print(
                json.dumps({
                    'include_dir': include_dir,
                    'header_file': header_file
                }))
        else:
            print(header_file)


if __name__ == "__main__":
    main()
