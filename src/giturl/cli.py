import argparse
import os
import pathlib
import sys
from urllib.parse import quote

import giturl.git as git


def parse_args() -> tuple[str, int | None, bool | None]:
    parser = argparse.ArgumentParser(description="Generate a GitHub URL for a file or directory in a git repository.")
    parser.add_argument("-l", "--line", dest="line_number", type=int, help="Line number to include in the URL", metavar="line_number")
    parser.add_argument("-b", "--branch", dest="branch_mode", action="store_true", help="Use branch name instead of commit SHA in the URL")
    parser.add_argument("path", type=pathlib.Path, help="Path to a file or directory in the git repository")
    args = parser.parse_args()
    
    if not os.path.isfile(args.path) and not os.path.isdir(args.path):
        parser.error(f"'{args.path}' is not an existing file or directory")

    if args.line_number is not None and os.path.isdir(args.path):
        parser.error("line number is invalid when path is a directory")
    
    return args.path, args.line_number, args.branch_mode


def get_base_url(remote_url: str) -> str:
    if remote_url.startswith("git@github.com:"):
        remote_url = remote_url.replace("git@github.com:", "https://github.com/")
    if remote_url.endswith(".git"):
        remote_url = remote_url[: -len(".git")]
    return remote_url


def main():
    path_arg, line_number, branch_mode = parse_args()

    full_path = os.path.abspath(path_arg)

    repo_root = git.get_repo_root(full_path)
    if repo_root is None:
        print(f"Error: Path '{full_path}' is not part of a git repository.", file=sys.stderr)
        sys.exit(1)

    remotes = git.get_remotes(repo_root)
    if not remotes:
        print("Error: No git remotes found in this repository.", file=sys.stderr)
        sys.exit(1)

    if len(remotes) == 1:
        remote = remotes[0]
    else:
        upstream = git.get_upstream(repo_root)
        if not upstream:
            print("Error: Repository has multiple remotes, but no upstream to determine the correct one.", file=sys.stderr)
            sys.exit(1)
        remote = upstream.split("/")[0]

    remote_url = git.get_remote_url(repo_root, remote)
    repo_url = get_base_url(remote_url)

    if branch_mode:
        branch_name = git.get_current_branch_name(repo_root)
        if branch_name is None:
            print("Error: No branch is currently checked out.", file=sys.stderr)
            sys.exit(1)
        ref = quote(branch_name)
    else:
        short_hash = git.get_short_hash(repo_root)
        if short_hash is None:
            print("Error: Unable to fetch the latest commit hash. Does the repository have any commits?", file=sys.stderr)
            sys.exit(1)
        ref = short_hash

    if os.path.samefile(full_path, repo_root):
        relative_path = ""
    else:
        relative_path = "/" + quote(os.path.relpath(full_path, repo_root).replace(os.sep, "/"))

    file_url = f"{repo_url}/blob/{ref}{relative_path}"
    if line_number is not None:
        file_url = f"{file_url}#L{line_number}"

    print(file_url)
