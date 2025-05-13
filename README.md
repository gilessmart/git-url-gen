# Git URL Generator

This script generates a GitHub URL for a file in a git repository. 

## Usage
```bash
git-url.sh [-l line_number] <file_path>
```

### Examples
1. Generate a URL for a file:
   ```bash
   git-url.sh myfile.txt
   ```

2. Generate a URL for a file with a specific line number:
   ```bash
   git-url.sh -l 42 myfile.txt
   ```

## Requirements
- The script must be run inside a git repository.
- The file path must be committed to the repository.
