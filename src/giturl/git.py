import os
import subprocess


def get_repo_root(path: str) -> str | None:
    dir_path = path if os.path.isdir(path) else os.path.dirname(path)
    result = subprocess.run(["git", "rev-parse", "--show-toplevel"], text=True, capture_output=True, cwd=dir_path)
    return result.stdout.strip() if result.returncode == 0 else None


def get_remotes(repo_root: str) -> list[str]:
    remotes = subprocess.check_output(["git", "remote"], text=True, cwd=repo_root).splitlines()
    return [r.strip() for r in remotes if r]


def get_upstream(repo_root: str) -> str | None:
    result = subprocess.run(
        ["git", "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{u}"],
        text=True,
        capture_output=True,
        cwd=repo_root
    )
    return result.stdout.strip() if result.returncode == 0 else None


def get_remote_url(repo_root: str, remote: str) -> str:
    return subprocess.check_output(["git", "remote", "get-url", remote], text=True, cwd=repo_root).strip()


def get_current_branch_name(repo_root: str) -> str | None:
    branch = subprocess.check_output(["git", "branch", "--show-current"], text=True, cwd=repo_root).strip()
    return branch if branch else None # If the branch name is empty, return None to indicate we're in a detached HEAD state


def get_short_hash(repo_root: str) -> str | None:
    result = subprocess.run(["git", "rev-parse", "--short", "HEAD"], text=True, capture_output=True, cwd=repo_root)
    return result.stdout.strip() if result.returncode == 0 else None # Return None if the command fails, e.g. if there are no commits in the repository
