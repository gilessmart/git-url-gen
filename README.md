# Git URL Generator

Python script that generates a GitHub URL for a file in a git repository.

## Requirements

* Python 3

## Installation

```
pip install --user .
```

The directory where `pip` installs modules may need to be added to your PATH environment variable.

**Upgrade**

```
pip install --user --upgrade .
```

**Reinstall**

```
pip install --user --force-reinstall .
```

## Usage

```
giturl [-l line_number] [-b] <path>
```

### Options

- `-l line_number`: Specify a line number to include in the URL.
- `-b`: Use the current branch name instead of the commit hash in the URL.

### Examples

1. Generate the GitHub URL for a file:
   ```sh
   $ giturl tests/test-files/example.txt
   https://github.com/gilessmart/giturl/blob/e8f4df3/test-files/example.txt
   ```

2. Generate the GitHub URL for a file with a specific line number:
   ```sh
   $ giturl -l 5 tests/test-files/example.txt
   https://github.com/gilessmart/giturl/blob/e8f4df3/test-files/example.txt#L42
   ```

3. Generate the GitHub URL for a file using the current branch name instead of the current commit hash:
   ```sh
   $ giturl -b tests/test-files/example.txt
   https://github.com/gilessmart/giturl/blob/main/test-files/example.txt
   ```

4. Generate the GitHub URL for a folder:
   ```sh
   $ giturl tests/test-files/
   https://github.com/gilessmart/giturl/blob/e8f4df3/test-files
   ```

## Development Setup

* Setup Python virtual environment:
  ```sh
  python -m venv .venv
  ```
* Activate virtual environment:
  ```
  source .venv/bin/activate
  ```
  Or on Windows:  
  * Git Bash: `source .venv/Scripts/activate`  
  * Command Prompt: `.venv\Scripts\activate.bat`  
  * Powershell: `.\.venv\Scripts\Activate.ps1`
* Install module into venv:
  ```
  pip install -e ".[dev]"
  ```

## Alternatives

The same can be achieved with [GitHub CLI](https://cli.github.com/):
```sh
$ gh browse -n test-files/example.txt
https://github.com/gilessmart/giturl/tree/main/test-files/example.txt
```

But hopefully this can be enhanced in future to work with GitLab, BitBucket etc.

## Potential Enhancements

* If no path is supplied, produce the URL of the repository root.
* Support repos held on other vendors' platforms - GitLab, BitBucket etc.
* Replace `-l` option with `path[:line_number]`.
* Add option to open the URL in the user's browser.
