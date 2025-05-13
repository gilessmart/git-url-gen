#!/bin/sh

# Generates a GitHub URL for a file in a git repository at a specific commit.
# Usage: giturl [-l line_number] <file_path>
# Example: giturl -l 42 myfile.txt

print_usage_and_exit() {
    reason=$1
    echo "$reason" >&2
    echo "Usage: giturl [-l line_number] <file_path>" >&2
    exit 1
}

# Parse command-line options
while getopts ":l:" opt; do
    case $opt in
        l)
            # Capture the line number argument

            # Ensure the line number is numeric
            if ! echo "$OPTARG" | grep -qE '^[0-9]+$'; then
                print_usage_and_exit "Line number must be a numeric value."
            fi
            line_number="$OPTARG"
            ;;
        \?)
            # Handle invalid options
            print_usage_and_exit "Invalid option: -$OPTARG"
            ;;
        :)
            # Handle missing argument for an option
            print_usage_and_exit "Option -$OPTARG requires an argument."
            ;;
    esac
done

# Shift positional arguments to remove processed options
shift $((OPTIND - 1))

# Ensure at least one argument (file path) is provided
if [ $# -lt 1 ]; then
    print_usage_and_exit "Error: Missing required argument (file_path)."
fi

# Get the repository's remote URL and convert it to an HTTPS GitHub URL
repo_url=$(git config remote.origin.url | sed 's,git@github.com:,https://github.com/,' | sed 's,\.git,,')

# Get the current commit hash
ref=$(git rev-parse --short HEAD 2>/dev/null)
if [ -z "$ref" ]; then
    echo "Error: Unable to find a git revision. Ensure the repository has at least one commit." >&2
    exit 1
fi

# Get the file path relative to the repository root
file_path=$(git ls-files --full-name "$1" 2>/dev/null)
if [ -z "$file_path" ]; then
    echo "Error: File not found in the repository." >&2
    exit 1
fi

# Construct the GitHub URL for the file at the specific commit
file_url=$repo_url/blob/$ref/$file_path

# Append the line number fragment to the URL if provided
if [ -n "$line_number" ]; then
    fragment=#L$line_number
    file_url=$file_url$fragment
fi

# Output the constructed URL
echo $file_url