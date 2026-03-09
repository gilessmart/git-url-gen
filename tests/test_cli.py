import os
import subprocess
import sys


def repo_create(repo_dir, remotes, branch="main"):
    subprocess.check_call(["git", "init", "-b", branch], cwd=repo_dir)
    
    subprocess.check_call(["git", "config", "user.name", "Test User"], cwd=repo_dir)
    subprocess.check_call(["git", "config", "user.email", "test@example.com"], cwd=repo_dir)

    for name, url in remotes.items():
        subprocess.check_call(["git", "remote", "add", name, url], cwd=repo_dir)


def repo_get_current_hash(repo_dir):
    return subprocess.check_output(["git", "rev-parse", "--short", "HEAD"], cwd=repo_dir, text=True).strip()


def repo_commit_file(repo_dir, file_path):
    dir = repo_dir / os.path.dirname(file_path)
    os.makedirs(dir, exist_ok=True)

    with open(repo_dir / file_path, "w") as file:
        file.write("hello\n")

    subprocess.check_call(["git", "add", file_path], cwd=repo_dir)
    subprocess.check_call(["git", "commit", "-m", f"Add {file_path}"], cwd=repo_dir)


def run_giturl(path, args=None):
    cmd = [sys.executable, "-m", "giturl"]
    if args:
        cmd.extend(args)
    cmd.append(str(path))
    return subprocess.run(cmd, capture_output=True, text=True)


def test_no_git_repo(tmp_path):
    proc = run_giturl(tmp_path)
    assert proc.returncode == 1
    assert "not part of a git repository" in proc.stderr


def test_multiple_remotes_no_tracking(tmp_path):
    remotes = {
        "origin": "git@github.com:gilessmart/giturl.git",
        "other": "git@github.com:user/other.git"
    }
    repo_create(tmp_path, remotes)
    repo_commit_file(tmp_path, "README.md")
    proc = run_giturl(tmp_path)
    assert proc.returncode == 1
    assert "multiple remotes" in proc.stderr


def test_root_level_folder(tmp_path):
    repo_create(tmp_path, {"origin": "git@github.com:gilessmart/giturl.git"})
    repo_commit_file(tmp_path, "README.md")
    hash = repo_get_current_hash(tmp_path)
    proc = run_giturl(tmp_path)
    assert proc.returncode == 0
    assert proc.stdout.strip() == f"https://github.com/gilessmart/giturl/blob/{hash}"


def test_root_level_file(tmp_path):
    repo_create(tmp_path, {"origin": "git@github.com:gilessmart/giturl.git"})
    repo_commit_file(tmp_path, "README.md")
    hash = repo_get_current_hash(tmp_path)
    proc = run_giturl(tmp_path / "README.md")
    assert proc.returncode == 0
    assert proc.stdout.strip() == f"https://github.com/gilessmart/giturl/blob/{hash}/README.md"


def test_nested_file(tmp_path):
    repo_create(tmp_path, {"origin": "git@github.com:gilessmart/giturl.git"})
    repo_commit_file(tmp_path, "a/b/foo.txt")
    hash = repo_get_current_hash(tmp_path)
    proc = run_giturl(tmp_path /"a/b/foo.txt")
    assert proc.returncode == 0
    assert proc.stdout.strip() == f"https://github.com/gilessmart/giturl/blob/{hash}/a/b/foo.txt"


def test_line_num_option(tmp_path):
    repo_create(tmp_path, {"origin": "git@github.com:gilessmart/giturl.git"})
    repo_commit_file(tmp_path, "README.md")
    hash = repo_get_current_hash(tmp_path)
    proc = run_giturl(tmp_path / "README.md", args=["-l", "7"])
    assert proc.returncode == 0
    assert proc.stdout.strip() == f"https://github.com/gilessmart/giturl/blob/{hash}/README.md#L7"


def test_branch_option(tmp_path):
    repo_create(tmp_path, {"origin": "git@github.com:gilessmart/giturl.git"}, branch="feature/x")
    repo_commit_file(tmp_path, "README.md")
    proc = run_giturl(tmp_path / "README.md", args=["-b"])
    assert proc.returncode == 0
    assert proc.stdout.strip() == f"https://github.com/gilessmart/giturl/blob/feature/x/README.md"


def test_path_with_special_chars(tmp_path):
    repo_create(tmp_path, {"origin": "git@github.com:gilessmart/giturl.git"})
    repo_commit_file(tmp_path, "weird -=+.txt")
    hash = repo_get_current_hash(tmp_path)
    proc = run_giturl(tmp_path / "weird -=+.txt")
    assert proc.returncode == 0
    assert proc.stdout.strip() == f"https://github.com/gilessmart/giturl/blob/{hash}/weird%20-%3D%2B.txt"


def test_branch_with_slash(tmp_path):
    repo_create(tmp_path, {"origin": "git@github.com:gilessmart/giturl.git"}, branch="test-branches/abc")
    repo_commit_file(tmp_path, "README.md")
    proc = run_giturl(tmp_path / "README.md", args=["-b"])
    assert proc.returncode == 0
    assert proc.stdout.strip() == f"https://github.com/gilessmart/giturl/blob/test-branches/abc/README.md"


def test_branch_with_special_chars(tmp_path):
    repo_create(tmp_path, {"origin": "git@github.com:gilessmart/giturl.git"}, branch="test-branches/_=+,.@¬£")
    repo_commit_file(tmp_path, "README.md")
    proc = run_giturl(tmp_path / "README.md", args=["-b"])
    assert proc.returncode == 0
    assert proc.stdout.strip() == f"https://github.com/gilessmart/giturl/blob/test-branches/_%3D%2B%2C.%40%C2%AC%C2%A3/README.md"
