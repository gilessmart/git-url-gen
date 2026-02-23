setup_remote() {
    remote=$1
    url=$2
    branch=$3

    # Ensure remote exists with correct URL
    current_url=$(git remote get-url "$remote" 2>/dev/null)

    if [ -z "$current_url" ]; then
        printf 'Adding remote %s -> %s\n' "$remote" "$url"
        git remote add "$remote" "$url"
    elif [ "$current_url" != "$url" ]; then
        printf 'Updating remote %s URL -> %s\n' "$remote" "$url"
        git remote set-url "$remote" "$url"
    fi

    # Determine current branch (fails cleanly in detached HEAD)
    current_branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null)
    if [ -z "$current_branch" ]; then
        printf 'Error: repo is in detached HEAD state\n'
        exit 1
    fi

    # Check if correct upstream already set
    current_upstream=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null)

    if [ "$current_upstream" != "$remote/$branch" ]; then
        # Fetch only if remote-tracking branch missing
        if ! git show-ref --verify --quiet "refs/remotes/$remote/$branch"; then
            printf 'Fetching %s\n' "$remote"
            git fetch "$remote"
        fi

        printf 'Setting upstream to %s/%s\n' "$remote" "$branch"
        git branch --set-upstream-to="$remote/$branch"
    fi
}

test() {
    description=$1
    command=$2
    expected=$3
    
    echo "Test:     $description"
    echo "Expected: $expected"

    result=$(eval $command 2>&1)
    if [ $? -ne 0 ]; then
        echo "Result:   Fail"
        echo "giturl.sh failed to execute command - $command - $result"
        echo
        return 1
    fi

    echo "Actual:   $result"

    if [ "$expected" = "$result" ]; then
        echo "Result:   Pass"
        echo
    else
        echo "Result:   Fail"
        echo
        return 1
    fi
}