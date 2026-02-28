#!/usr/bin/env bash

# Usage: run-tests.sh [-c]
#   -c = clear (and recreate) test repos

set -E # ERR traps are inherited into command subs, subshells etc.
set -e # exit script if a command fails
set -u # error on unset variables
set -o pipefail # pipelines return last non-zero value, or 0

trap 'echo "ERROR: line $LINENO: exit code $?" >&2' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. $SCRIPT_DIR/helpers.sh

getopts ":c" opt || true
clear_repos=false
[[ $opt = c ]] && clear_repos=true

setup_test_repo main-branch git@github.com:gilessmart/git-url-gen.git main $clear_repos
setup_test_repo slash-branch git@github.com:gilessmart/git-url-gen.git 'test-branches/abc' $clear_repos
setup_test_repo special-chars-branch git@github.com:gilessmart/git-url-gen.git 'test-branches/_=+,.@¬£' $clear_repos
printf '\n'

failed_tests=0

commit_hash=$(cd "$TEST_REPOS_DIR/main-branch" && git rev-parse --short HEAD)

description="With root level folder path"
command="'$GITURL_PATH' '$TEST_REPOS_DIR/main-branch'"
expected="https://github.com/gilessmart/git-url-gen/blob/$commit_hash"
test "$description" "$command" "$expected" || ((++failed_tests))

description="With root level file path"
command="'$GITURL_PATH' '$TEST_REPOS_DIR/main-branch/README.md'"
expected="https://github.com/gilessmart/git-url-gen/blob/$commit_hash/README.md"
test "$description" "$command" "$expected" || ((++failed_tests))

description="With nested folder path"
command="'$GITURL_PATH' '$TEST_REPOS_DIR/main-branch/tests/test-files'"
expected="https://github.com/gilessmart/git-url-gen/blob/$commit_hash/tests/test-files"
test "$description" "$command" "$expected" || ((++failed_tests))

description="With nested file path"
command="'$GITURL_PATH' '$TEST_REPOS_DIR/main-branch/tests/test-files/example.txt'"
expected="https://github.com/gilessmart/git-url-gen/blob/$commit_hash/tests/test-files/example.txt"
test "$description" "$command" "$expected" || ((++failed_tests))

description="With line number option"
command="'$GITURL_PATH' -l 5 '$TEST_REPOS_DIR/main-branch/tests/test-files/example.txt'"
expected="https://github.com/gilessmart/git-url-gen/blob/$commit_hash/tests/test-files/example.txt#L5"
test "$description" "$command" "$expected" || ((++failed_tests))

description="With branch option"
command="'$GITURL_PATH' -b '$TEST_REPOS_DIR/main-branch/tests/test-files/example.txt'"
expected="https://github.com/gilessmart/git-url-gen/blob/main/tests/test-files/example.txt"
test "$description" "$command" "$expected" || ((++failed_tests))

description="With branch and line number options"
command="'$GITURL_PATH' -b -l 5 '$TEST_REPOS_DIR/main-branch/tests/test-files/example.txt'"
expected="https://github.com/gilessmart/git-url-gen/blob/main/tests/test-files/example.txt#L5"
test "$description" "$command" "$expected" || ((++failed_tests))

description="With a file name with special characters"
command="'$GITURL_PATH' '$TEST_REPOS_DIR/main-branch/tests/test-files/¬\`!£$%^&()-_=+[]{};'\''@#~, .txt'"
expected="https://github.com/gilessmart/git-url-gen/blob/$commit_hash/tests/test-files/%C2%AC%60!%C2%A3%24%25%5E%26()-_%3D%2B%5B%5D%7B%7D%3B'%40%23~%2C%20.txt"
test "$description" "$command" "$expected" || ((++failed_tests))

description="With branch with a slash in its name"
command="'$GITURL_PATH' -b '$TEST_REPOS_DIR/slash-branch/tests/test-files/example.txt'"
expected="https://github.com/gilessmart/git-url-gen/blob/test-branches/abc/tests/test-files/example.txt"
test "$description" "$command" "$expected" || ((++failed_tests))

description="With branch with special characters in its name"
command="'$GITURL_PATH' -b '$TEST_REPOS_DIR/special-chars-branch/tests/test-files/example.txt'"
expected="https://github.com/gilessmart/git-url-gen/blob/test-branches/_%3D%2B%2C.%40%C2%AC%C2%A3/tests/test-files/example.txt"
test "$description" "$command" "$expected" || ((++failed_tests))

if [[ $failed_tests -eq 0 ]]; then
    echo "All tests passed"
else
    echo "$failed_tests test(s) failed"
    exit 1
fi
