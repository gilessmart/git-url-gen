#!/bin/sh

# Generates a GitHub URL for a file in a git repository at a specific commit or branch.
# Usage: giturl [-l line_number] [-b] <file_path>
# Example: giturl -l 42 -b myfile.txt

print_usage_and_exit() {
    reason=$1
    echo "$reason" >&2
    echo "Usage: giturl [-l line_number] [-b] <file_path>" >&2
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

# Ensure at least one argument (file path) is provided
if [ $# -lt 1 ]; then
    print_usage_and_exit "Error: Missing required argument (file_path)."
fi

# Get the repository's remote URL and convert it to an HTTPS GitHub URL
repo_url=$(git config remote.origin.url | sed 's,git@github.com:,https://github.com/,' | sed 's,\.git,,')

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

# Get the file path relative to the repository root
# -z is used becuase ls-files may otherwise add quotes
# tr is used to remove the null character added by -z
file_path=$(git ls-files -z --full-name "$1" 2> /dev/null | tr -d '\0')
if [ -z "$file_path" ]; then
    echo "Error: File not found in the repository." >&2
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
    file_path=$(echo -n "$file_path" | jq -R -s -r @uri)
    # Decode characters that GitHub doesn't encode back to what they were 
    file_path=$(echo "$file_path" \
        | sed "s/%2F/\//g" \
        | sed "s/%28/(/g" \
        | sed "s/%29/)/g" \
        | sed "s/%21/!/g" \
        | sed "s/%27/'/g" \
        | sed "s/%2A/*/g")
fi

# Construct the GitHub URL for the file at the specific ref
file_url=$repo_url/blob/$ref/$file_path

# Append the line number fragment to the URL if provided
if [ -n "$line_number" ]; then
    fragment=#L$line_number
    file_url=$file_url$fragment
fi

# Output the constructed URL
echo $file_url