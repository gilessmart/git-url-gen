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

setup_test_repo ssh-main git@github.com:gilessmart/giturl.git main $clear_repos
setup_test_repo ssh-slash-branch git@github.com:gilessmart/giturl.git 'test-branches/abc' $clear_repos
setup_test_repo ssh-special-chars-branch git@github.com:gilessmart/giturl.git 'test-branches/_=+,.@¬£' $clear_repos
setup_test_repo https-main https://github.com/gilessmart/giturl.git main $clear_repos
printf '\n'

failed_tests=0

ssh_main_hash=$(cd "$TEST_REPOS_DIR/ssh-main" && git rev-parse --short HEAD)
https_main_hash=$(cd "$TEST_REPOS_DIR/https-main" && git rev-parse --short HEAD)

description="With root level folder path"
command="python -m giturl '$TEST_REPOS_DIR/ssh-main'"
expected="https://github.com/gilessmart/giturl/blob/$ssh_main_hash"
test "$description" "$command" "$expected" || ((++failed_tests))

description="With root level file path"
command="python -m giturl '$TEST_REPOS_DIR/ssh-main/README.md'"
expected="https://github.com/gilessmart/giturl/blob/$ssh_main_hash/README.md"
test "$description" "$command" "$expected" || ((++failed_tests))

description="With nested folder path"
command="python -m giturl '$TEST_REPOS_DIR/ssh-main/tests/test-files'"
expected="https://github.com/gilessmart/giturl/blob/$ssh_main_hash/tests/test-files"
test "$description" "$command" "$expected" || ((++failed_tests))

description="With nested file path"
command="python -m giturl '$TEST_REPOS_DIR/ssh-main/tests/test-files/example.txt'"
expected="https://github.com/gilessmart/giturl/blob/$ssh_main_hash/tests/test-files/example.txt"
test "$description" "$command" "$expected" || ((++failed_tests))

description="With line number option"
command="python -m giturl -l 5 '$TEST_REPOS_DIR/ssh-main/tests/test-files/example.txt'"
expected="https://github.com/gilessmart/giturl/blob/$ssh_main_hash/tests/test-files/example.txt#L5"
test "$description" "$command" "$expected" || ((++failed_tests))

description="With branch option"
command="python -m giturl -b '$TEST_REPOS_DIR/ssh-main/tests/test-files/example.txt'"
expected="https://github.com/gilessmart/giturl/blob/main/tests/test-files/example.txt"
test "$description" "$command" "$expected" || ((++failed_tests))

description="With branch and line number options"
command="python -m giturl -b -l 5 '$TEST_REPOS_DIR/ssh-main/tests/test-files/example.txt'"
expected="https://github.com/gilessmart/giturl/blob/main/tests/test-files/example.txt#L5"
test "$description" "$command" "$expected" || ((++failed_tests))

description="With a file name with special characters"
command="python -m giturl '$TEST_REPOS_DIR/ssh-main/tests/test-files/example-_=+,.@¬£.txt'"
expected="https://github.com/gilessmart/giturl/blob/$ssh_main_hash/tests/test-files/example-_%3D%2B%2C.%40%C2%AC%C2%A3.txt"
test "$description" "$command" "$expected" || ((++failed_tests))

description="With branch with a slash in its name"
command="python -m giturl -b '$TEST_REPOS_DIR/ssh-slash-branch/tests/test-files/example.txt'"
expected="https://github.com/gilessmart/giturl/blob/test-branches/abc/tests/test-files/example.txt"
test "$description" "$command" "$expected" || ((++failed_tests))

description="With branch with special characters in its name"
command="python -m giturl -b '$TEST_REPOS_DIR/ssh-special-chars-branch/tests/test-files/example.txt'"
expected="https://github.com/gilessmart/giturl/blob/test-branches/_%3D%2B%2C.%40%C2%AC%C2%A3/tests/test-files/example.txt"
test "$description" "$command" "$expected" || ((++failed_tests))

description="With https remote URL"
command="python -m giturl '$TEST_REPOS_DIR/https-main/tests/test-files/example.txt'"
expected="https://github.com/gilessmart/giturl/blob/$https_main_hash/tests/test-files/example.txt"
test "$description" "$command" "$expected" || ((++failed_tests))

# check the results return 200 with:
# curl -o /dev/null -w "%{response_code}\n" -s <URL>

if [[ $failed_tests -eq 0 ]]; then
    echo "All tests passed"
else
    echo "$failed_tests test(s) failed"
    exit 1
fi
