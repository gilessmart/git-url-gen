#!/bin/sh

# Tests the behavior of the giturl.sh script

cwd=$(dirname "$0")
cd "$cwd"

. ./helpers.sh

setup_remote github "git@github.com:gilessmart/git-url-gen.git" main

failed_tests=0

commit_hash=$(git rev-parse --short HEAD)

description="With no options"
command="../giturl.sh test-files/example.txt"
expected="https://github.com/gilessmart/git-url-gen/blob/$commit_hash/tests/test-files/example.txt"
test "$description" "$command" "$expected" || failed_tests=$(($failed_tests + 1))

description="With line number option"
command="../giturl.sh -l 5 test-files/example.txt"
expected="https://github.com/gilessmart/git-url-gen/blob/$commit_hash/tests/test-files/example.txt#L5"
test "$description" "$command" "$expected" || failed_tests=$(($failed_tests + 1))

branch_name=$(git rev-parse --abbrev-ref HEAD)

description="With branch option"
command="../giturl.sh -b test-files/example.txt"
expected="https://github.com/gilessmart/git-url-gen/blob/$branch_name/tests/test-files/example.txt"
test "$description" "$command" "$expected" || failed_tests=$(($failed_tests + 1))

description="With branch and line number options"
command="../giturl.sh -b -l 5 test-files/example.txt"
expected="https://github.com/gilessmart/git-url-gen/blob/$branch_name/tests/test-files/example.txt#L5"
test "$description" "$command" "$expected" || failed_tests=$(($failed_tests + 1))

description="With a file name with special characters"
command="../giturl.sh 'test-files/¬\`!£$%^&()-_=+[]{};'\''@#~, .txt'"
expected="https://github.com/gilessmart/git-url-gen/blob/$commit_hash/tests/test-files/%C2%AC%60!%C2%A3%24%25%5E%26()-_%3D%2B%5B%5D%7B%7D%3B'%40%23~%2C%20.txt"
test "$description" "$command" "$expected" || failed_tests=$(($failed_tests + 1))

description="With a folder as the path"
command="../giturl.sh test-files/"
expected="https://github.com/gilessmart/git-url-gen/blob/$commit_hash/tests/test-files"
test "$description" "$command" "$expected" || failed_tests=$(($failed_tests + 1))

description="With the current folder (.) as the path"
command="../giturl.sh ."
expected="https://github.com/gilessmart/git-url-gen/blob/$commit_hash/tests"
test "$description" "$command" "$expected" || failed_tests=$(($failed_tests + 1))

if [ $failed_tests -eq 0 ]; then
    echo "All tests passed"
else
    echo "$failed_tests test(s) failed"
    exit 1
fi
