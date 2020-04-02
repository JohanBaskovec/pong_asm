./build_tests.sh

if [ $? -eq 0 ]; then
    ./pong_tests
    echo "Exit with code" $?
    exit 0
else
    exit 1
fi

