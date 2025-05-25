# Git URL Generator

Shell script that generates a GitHub URL for a file in a git repository.

## Usage

```
git-url-gen.sh [-l line_number] [-b] <path>
```

### Options

- `-l line_number`: Specify a line number to include in the URL.
- `-b`: Use the current branch name instead of the commit hash in the URL.

### Examples

1. Generate the GitHub URL for a file:
   ```
   $ git-url-gen.sh test-files/example.txt
   https://github.com/gilessmart/git-url-gen/blob/e8f4df3/test-files/example.txt
   ```

2. Generate the GitHub URL for a file with a specific line number:
   ```
   $ git-url-gen.sh -l 42 test-files/example.txt
   https://github.com/gilessmart/git-url-gen/blob/e8f4df3/test-files/example.txt#L42
   ```

3. Generate the GitHub URL for a file using the current branch name instead of the current commit hash:
   ```
   $ git-url-gen.sh -b test-files/example.txt
   https://github.com/gilessmart/git-url-gen/blob/main/test-files/example.txt
   ```

4. Generate the GitHub URL for a folder:
   ```
   $ git-url-gen.sh test-files/
   https://github.com/gilessmart/git-url-gen/blob/e8f4df3/test-files
   ```

## Requirements

- `jq` is required to properly URL-encode special characters.
- The current branch must track a remote, or an `origin` remote must exist.

## Alternatives

The same can be achieved with [GitHub CLI](https://cli.github.com/):
```
$ gh browse -n test-files/example.txt
https://github.com/gilessmart/git-url-gen/tree/main/test-files/example.txt
```

## Potential Enhancements

* If no path is supplied, produce the URL of the repository root.
* Use sub-repos (or maybe containers) for testing, so it's possible to test branch name URL encoding.
* Support repos held on other vendors' platforms - GitLab, BitBucket etc.
* Replace `-l` option with `path[:line_number]`.

