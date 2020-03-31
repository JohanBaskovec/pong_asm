./build.sh


if [ $? -eq 0 ]; then
    gdb pong

    echo "Exit with code" $?
fi
