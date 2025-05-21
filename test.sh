#!/bin/sh

# Tests the behavior of the git-url.sh script

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
        echo "git-url.sh failed to execute command - $command - $result"
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
command="./git-url.sh README.md"
expected="https://github.com/gilessmart/git-url-gen/blob/$commit_hash/README.md"
test "$description" "$command" "$expected" || failed_tests=$(($failed_tests + 1))

description="With line number option"
command="./git-url.sh -l 42 README.md"
expected="https://github.com/gilessmart/git-url-gen/blob/$commit_hash/README.md#L42"
test "$description" "$command" "$expected" || failed_tests=$(($failed_tests + 1))

branch_name=$(git rev-parse --abbrev-ref HEAD)

description="With branch option"
command="./git-url.sh -b README.md"
expected="https://github.com/gilessmart/git-url-gen/blob/$branch_name/README.md"
test "$description" "$command" "$expected" || failed_tests=$(($failed_tests + 1))

description="With branch and line number options"
command="./git-url.sh -b -l 42 README.md"
expected="https://github.com/gilessmart/git-url-gen/blob/$branch_name/README.md#L42"
test "$description" "$command" "$expected" || failed_tests=$(($failed_tests + 1))

description="With a file name with various special characters"
command="./git-url.sh 'test-files/¬£%^&()_+-=[]{};:@#~<>,.?|'"
expected="https://github.com/gilessmart/git-url-gen/blob/$commit_hash/test-files/%C2%AC%C2%A3%25%5E%26()_%2B-%3D%5B%5D%7B%7D%3B%3A%40%23~%3C%3E%2C.%3F%7C"
test "$description" "$command" "$expected" || failed_tests=$(($failed_tests + 1))

description="With a file name with spaces"
command="./git-url.sh 'test-files/file with spaces'"
expected="https://github.com/gilessmart/git-url-gen/blob/$commit_hash/test-files/file%20with%20spaces"
test "$description" "$command" "$expected" || failed_tests=$(($failed_tests + 1))

description="With a file name with extra-special characters"
command="./git-url.sh 'test-files/\`!\"'\''\$*\'"
expected="https://github.com/gilessmart/git-url-gen/blob/$commit_hash/test-files/%60!%22'%24*%5C"
test "$description" "$command" "$expected" || failed_tests=$(($failed_tests + 1))

if [ $failed_tests -eq 0 ]; then
    echo "All tests passed"
else
    echo "$failed_tests test(s) failed"
    exit 1
fi
