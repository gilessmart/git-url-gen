# Git URL Generator

Shell script that generates a GitHub URL for a file in a git repository. 

## Usage
```bash
git-url-gen.sh [-l line_number] [-b] <file_path>
```

### Options
- `-l line_number`: Specify a line number to include in the URL.
- `-b`: Use the current branch name instead of the commit hash in the URL.

### Examples
1. Generate the GitHub URL for a file:
   ```bash
   $ git-url-gen.sh test-files/example.txt
   https://github.com/gilessmart/git-url-gen/blob/e8f4df3/test-files/example.txt
   ```

2. Generate the GitHub URL for a file with a specific line number:
   ```bash
   $ git-url-gen.sh -l 42 test-files/example.txt
   https://github.com/gilessmart/git-url-gen/blob/e8f4df3/test-files/example.txt#L42
   ```

3. Generate the GitHub URL for a file using the current branch name instead of the current commit hash:
   ```bash
   $ git-url-gen.sh -b test-files/example.txt
   https://github.com/gilessmart/git-url-gen/blob/main/test-files/example.txt
   ```

## Requirements
- The script must be run inside a git repository.
- The file path must be committed to the repository.
- `jq` is required to properly URL-encode special characters.
