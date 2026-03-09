# Git URL Generator

Python script that generates a GitHub URL for a file in a git repository.

## Requirements

* Python 3

## Setup

* Setup Python virtual environment & activate
   ```sh
   python3 -m venv .venv
   source .venv/bin/activate
   ```
* Install module into venv
   ```
   pip install -e .
   ```
   **Or**, to include modules used for development:
   ```
   pip install -e ".[dev]"
   ```
*  Make the command available by adding a link to it from a directory in the command line $PATH.  
   E.g. if you've got `~/bin/` in your $PATH:  
   ```
   ln -s $(realpath .venv/bin/giturl) ~/bin/
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

## Alternatives

The same can be achieved with [GitHub CLI](https://cli.github.com/):
```sh
$ gh browse -n test-files/example.txt
https://github.com/gilessmart/giturl/tree/main/test-files/example.txt
```

## Potential Enhancements

* If no path is supplied, produce the URL of the repository root.
* Support repos held on other vendors' platforms - GitLab, BitBucket etc.
* Replace `-l` option with `path[:line_number]`.
* Add option to open the URL in the user's browser.
