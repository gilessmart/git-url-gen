# Git URL Generator

This script generates a GitHub URL for a file in a git repository. 

## Usage
```bash
git-url.sh [-l line_number] [-b] <file_path>
```

### Options
- `-l line_number`: Specify a line number to include in the URL.
- `-b`: Use the current branch name instead of the commit hash in the URL.

### Examples
1. Generate the GitHub URL for a file:
   ```bash
   git-url.sh myfile.txt
   ```

2. Generate the GitHub URL for a file with a specific line number:
   ```bash
   git-url.sh -l 42 myfile.txt
   ```

3. Generate the GitHub URL for a file using the current branch name instead of the current commit hash:
   ```bash
   git-url.sh -b myfile.txt
   ```

## Requirements
- The script must be run inside a git repository.
- The file path must be committed to the repository.
