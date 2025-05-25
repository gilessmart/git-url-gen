#!/bin/sh

# Generates a GitHub URL for a file in a git repository at a specific commit or branch.
# Usage: giturl [-l line_number] [-b] <path>
# Example: giturl -l 42 -b myfile.txt

print_usage_and_exit() {
    reason=$1
    echo "$reason" >&2
    echo "Usage: giturl [-l line_number] [-b] <path>" >&2
    exit 1
}

# Parse command-line options
while getopts ":l:b" opt; do
    case $opt in
        l)
            # Capture the line number argument

            # Ensure the line number is numeric
            if ! echo "$OPTARG" | grep -qE '^[0-9]+$'; then
                print_usage_and_exit "Line number must be a numeric value."
            fi
            line_number="$OPTARG"
            ;;
        b)
            ref_type="branch"
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

# Ensure exactly one path argument is provided
if [ $# != 1 ]; then
    print_usage_and_exit "Error: Exactly one path is required."
fi

# Check the path exists
if ! [ -e "$1" ]; then
    echo "Error: File or folder '$1' does not exist." >&2
    exit 1
fi

# Change to the directory of the supplied path (so git commands are running from there) 
# and get a full path from the one supplied
if [ -d "$1" ]; then
    if [ -n "$line_number" ]; then
        echo "Error: Line number is invalid when path is a directory" >&2
        exit 1
    fi
    cd "$1"
    full_path=$(pwd)
elif [ -f "$1" ]; then
    cd $(dirname "$1")
    full_path=$(pwd)/$(basename "$1")
else
    echo "Error: '$1' is not a file or a directory." >&2
    exit 1
fi

# Get the root path of the git repository
repo_root_path=$(git rev-parse --show-toplevel 2> /dev/null)
if [ $? -ne 0 ]; then
    echo "Error: Path is not part of a git repository." >&2
    exit 1
fi

# Get the path relative to the repository root
relative_path_start=$((${#repo_root_path} + 1))
relative_path=$(echo "$full_path" | cut -c ${relative_path_start}-)

# Try to get the remote the current branch is tracking
remote=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null | cut -d'/' -f1)
# Failing that, use "origin" if it exists
if [ -z "$remote" ] && git remote | grep -q '^origin$'; then
    remote="origin"
fi
# If that fails too, bail out
if [ -z "$remote" ]; then
    echo "Error: Current branch has no tracking remote, and no 'origin' remote." >&2
    exit 1
fi

# Construct the GitHub website URL from the remote URL
repo_url=$(git remote get-url "$remote" | sed 's,git@github.com:,https://github.com/,' | sed 's,\.git,,')

# Get the current commit hash or branch name
if [ "$ref_type" = "branch" ]; then
    ref=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
else
    ref=$(git rev-parse --short HEAD 2> /dev/null)
fi
if [ -z "$ref" ]; then
    echo "Error: Unable to find a git revision. Ensure the repository has at least one commit." >&2
    exit 1
fi

# If we've got jq, use it for URL encoding
if [ $(which jq 2> /dev/null) ]; then
    # If the ref is a branch..
    if [ "$ref_type" = "branch" ]; then
        # Encode using jq
        ref=$(echo -n "$ref" | jq -R -s -r @uri)
        # Decode characters that GitHub doesn't encode back to what they were 
        ref=$(echo "$ref" \
            | sed "s/%2F/\//g" \
            | sed "s/%28/(/g" \
            | sed "s/%29/)/g" \
            | sed "s/%21/!/g" \
            | sed "s/%27/'/g" \
            | sed "s/%2A/*/g")
    fi

    # Encode file path using jq
    relative_path=$(echo -n "$relative_path" | jq -R -s -r @uri)
    # Decode characters that GitHub doesn't encode back to what they were 
    relative_path=$(echo "$relative_path" \
        | sed "s/%2F/\//g" \
        | sed "s/%28/(/g" \
        | sed "s/%29/)/g" \
        | sed "s/%21/!/g" \
        | sed "s/%27/'/g" \
        | sed "s/%2A/*/g")
fi

# Construct the GitHub URL for the file at the specific ref
file_url=$repo_url/blob/$ref$relative_path

# Append the line number fragment to the URL if provided
if [ -n "$line_number" ]; then
    fragment=#L$line_number
    file_url=$file_url$fragment
fi

# Output the constructed URL
echo $file_url