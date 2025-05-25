#!/bin/sh

# Tests the behavior of the git-url-gen.sh script

# Usage: ./test.sh

test() {
    description=$1
    command=$2
    expected=$3
    
    echo "Test:     $description"
    echo "Expected: $expected"

    result=$(eval $command 2>&1)
    if [ $? -ne 0 ]; then
        echo "Result:   Fail"
        echo "git-url-gen.sh failed to execute command - $command - $result"
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

failed_tests=0

commit_hash=$(git rev-parse --short HEAD)

description="With no options"
command="./git-url-gen.sh test-files/example.txt"
expected="https://github.com/gilessmart/git-url-gen/blob/$commit_hash/test-files/example.txt"
test "$description" "$command" "$expected" || failed_tests=$(($failed_tests + 1))

description="With line number option"
command="./git-url-gen.sh -l 5 test-files/example.txt"
expected="https://github.com/gilessmart/git-url-gen/blob/$commit_hash/test-files/example.txt#L5"
test "$description" "$command" "$expected" || failed_tests=$(($failed_tests + 1))

branch_name=$(git rev-parse --abbrev-ref HEAD)

description="With branch option"
command="./git-url-gen.sh -b test-files/example.txt"
expected="https://github.com/gilessmart/git-url-gen/blob/$branch_name/test-files/example.txt"
test "$description" "$command" "$expected" || failed_tests=$(($failed_tests + 1))

description="With branch and line number options"
command="./git-url-gen.sh -b -l 5 test-files/example.txt"
expected="https://github.com/gilessmart/git-url-gen/blob/$branch_name/test-files/example.txt#L5"
test "$description" "$command" "$expected" || failed_tests=$(($failed_tests + 1))

description="With a file name with special characters"
command="./git-url-gen.sh 'test-files/¬\`!£$%^&()-_=+[]{};'\''@#~, .txt'"
expected="https://github.com/gilessmart/git-url-gen/blob/$commit_hash/test-files/%C2%AC%60!%C2%A3%24%25%5E%26()-_%3D%2B%5B%5D%7B%7D%3B'%40%23~%2C%20.txt"
test "$description" "$command" "$expected" || failed_tests=$(($failed_tests + 1))

description="With a file name with 'extra-special' characters"
command="./git-url-gen.sh 'test-files/<>:\"\\|?*.txt'"
expected="https://github.com/gilessmart/git-url-gen/blob/$commit_hash/test-files/%3C%3E%3A%22%5C%7C%3F*.txt"
test "$description" "$command" "$expected" || failed_tests=$(($failed_tests + 1))

description="With a folder as the path"
command="./git-url-gen.sh test-files/"
expected="https://github.com/gilessmart/git-url-gen/blob/$commit_hash/test-files"
test "$description" "$command" "$expected" || failed_tests=$(($failed_tests + 1))

description="With the current folder (.) as the path"
command="./git-url-gen.sh ."
expected="https://github.com/gilessmart/git-url-gen/blob/$commit_hash"
test "$description" "$command" "$expected" || failed_tests=$(($failed_tests + 1))

if [ $failed_tests -eq 0 ]; then
    echo "All tests passed"
else
    echo "$failed_tests test(s) failed"
    exit 1
fi
