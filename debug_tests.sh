./build_tests.sh


if [ $? -eq 0 ]; then
    gdb pong_tests

    echo "Exit with code" $?
fi
