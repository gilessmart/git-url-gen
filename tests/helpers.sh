SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export TEST_REPOS_DIR="$SCRIPT_DIR/test-repos"
export GITURL_PATH="$(realpath $SCRIPT_DIR/../giturl.sh)"

setup_test_repo() {
    local dir_path=$1
    local remote_url=$2
    local branch=$3
    local clear_repos=$4

    if $clear_repos; then
        printf 'Removing test repo: %s...\n' "$dir_path"
        rm -rf "$TEST_REPOS_DIR/$dir_path"
    fi

    if [[ ! -d $TEST_REPOS_DIR/$dir_path ]]; then
        printf 'Cloning test repo: %s...\n' "$dir_path"
        git clone -q -b "$branch" "$remote_url" "$TEST_REPOS_DIR/$dir_path"
        printf '\n'
    fi
}

test() {
    local description=$1
    local command=$2
    local expected=$3

    printf 'Test:     %s\n' "$description"

    local result=$(eval $command 2>&1)
    if [[ $? -ne 0 ]]; then
        printf 'Failed to execute command\nCommand: %s\nResult: %s\n\n' "$command" "$result"
        return 1
    fi

    printf 'Expected: %s\n' "$expected"
    printf 'Actual:   %s\n' "$result"

    if [ "$expected" = "$result" ]; then
        printf 'Result:   Pass\n\n'
    else
        printf 'Result:   Fail\n\n'
        return 1
    fi
}
